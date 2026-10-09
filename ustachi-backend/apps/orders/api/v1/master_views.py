"""
USTA buyurtma API'si — `ustachi_usta` ilovasi uchun.

Oqim: hududdagi e'lonlar feed'i → "Qabul qilaman" → chatda kelishuv →
mijoz tanlasa ish boshlanadi → 5 bosqichni surish → yakunlash.
"""

from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import BasePermission, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.orders import services, visibility
from apps.orders.api.v1.serializers import (
    OrderFeedSerializer,
    OrderResponseSerializer,
    OrderSerializer,
)
from apps.orders.models import Order, OrderStatus, ResponseStatus


class IsMaster(BasePermission):
    """Faqat usta roli bor foydalanuvchi (mijozligi saqlanadi)."""

    message = "Bu bo'lim faqat ustalar uchun."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_master)


class MasterOrderFeedView(APIView):
    """
    Ochiq e'lonlar — ustaning HUDUDIDA. O'z buyurtmalari ko'rinmaydi.
    Javob berilganlari ham ro'yxatda qoladi (`my_response_status` bilan).

    IKKI XIL e'lon keladi:
      * ochiq e'lon (`is_public`) — hududdagi hamma ko'radi;
      * SHAXSIY taklif (`is_invited`) — mijoz aynan shu ustani tanlagan.
        Bunda hudud filtri QO'LLANMAYDI: mijoz ustani ataylab tanlagan bo'lsa,
        u boshqa viloyatda bo'lsa ham taklif unga yetib borishi kerak.
    """

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderFeedSerializer

    def get(self, request):
        services.expire_stale_orders()
        orders = (
            Order.objects.filter(status=OrderStatus.PUBLISHED)
            .exclude(client=request.user)
            .select_related("client", "region", "district", "specialty")
            .prefetch_related("responses", "invites")
        )

        # Hudud + YO'NALISH qoidasi `visibility.py` da — bildirishnoma
        # bilan AYNI manba (ajralib ketmasin, 2026-08-08 xatosi).
        # Taklif qilingan e'lon ikkala filtrdan ham xoli.
        invited = Q(invites__master=request.user)
        orders = orders.filter(
            visibility.public_orders_q(request.user) | invited
        ).distinct()

        return Response(
            OrderFeedSerializer(
                orders,
                many=True,
                context={"request": request, "audience": "master"},
            ).data
        )


class MasterOrderDeclineView(APIView):
    """
    Shaxsiy taklifni RAD ETISH — "bu ishni ololmayman".

    Buyurtma yopilmaydi: mijozga darhol xabar ketadi va u boshqa ustani
    tanlashi yoki e'lonni hammaga ochishi mumkin. Faqat TAKLIF QILINGAN usta
    chaqira oladi (ochiq e'londa rad etish tushunchasi yo'q — javob bermaslik
    kifoya).
    """

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderFeedSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk)
        services.decline_invite(order, request.user, request.data.get("reason", ""))
        order.refresh_from_db()
        return Response(
            OrderFeedSerializer(
                order, context={"request": request, "audience": "master"}
            ).data
        )


class MasterOrderRespondView(APIView):
    """"Qabul qilaman" — narx TAKLIF QILINMAYDI, kelishuv chatda."""

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderResponseSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk)
        response = services.respond_to_order(
            order, request.user, request.data.get("message", "")
        )
        return Response(OrderResponseSerializer(response).data)


class MasterOrderWithdrawView(APIView):
    """Javobdan voz kechish (tanlangunga qadar)."""

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderResponseSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk)
        response = services.withdraw_response(order, request.user)
        return Response(OrderResponseSerializer(response).data)


class MasterOrderListView(APIView):
    """
    Ustaning buyurtmalari: tanlangan (ishdagi/yakunlangan) + javob berganlari.
    `?scope=assigned|responded` bilan filtrlanadi.
    """

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderSerializer

    def get(self, request):
        scope = request.query_params.get("scope", "assigned")
        base = Order.objects.select_related(
            "client", "assigned_master", "region", "district"
        ).prefetch_related("stage_events", "review", "responses")

        if scope == "responded":
            orders = base.filter(
                responses__master=request.user,
                responses__status=ResponseStatus.INTERESTED,
            ).distinct()
        else:
            orders = base.filter(assigned_master=request.user)

        status_filter = request.query_params.get("status")
        if status_filter:
            orders = orders.filter(status=status_filter)
        return Response(
            OrderSerializer(
                orders, many=True, context={"audience": "master"}
            ).data
        )


class MasterOrderDetailView(APIView):
    """Ommaviy buyurtmalarni barcha ustalar ko'radi, amallar esa cheklangan."""

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderSerializer

    def get(self, request, pk):
        order = get_object_or_404(
            Order.objects.select_related(
                "client", "assigned_master", "region", "district"
            ).prefetch_related("stage_events", "review"),
            pk=pk,
        )

        # Historical notification recipients must still be able to read the
        # order after it closes. Current feed visibility is intentionally not
        # used here: assignment/cancellation changes that visibility.
        from apps.orders.models import Notification
        from apps.orders.models.notification import NotificationType

        is_assigned = order.assigned_master_id == request.user.pk

        has_response = order.responses.filter(master=request.user).exists()

        has_invite = order.invites.filter(master=request.user).exists()
        has_notification = Notification.objects.filter(
            user=request.user,
            order=order,
            type__in=[
                NotificationType.ORDER_PUBLISHED,
                NotificationType.ORDER_INVITE,
                NotificationType.ORDER_NOT_CHOSEN,
                NotificationType.ORDER_CANCELLED,
            ],
        ).exists()

        # Telegram'dagi public e'lon havolasini boshqa hudud/soha ustalari ham
        # ochib ko'ra olishi kerak. Javob berish huquqi alohida ravishda
        # `respond_to_order` ichida hudud/soha qoidalari bilan tekshiriladi.
        # Shaxsiy (private) buyurtmalar esa faqat ishtirokchilar uchun qoladi.
        # Biriktirilgan hudud e'loni (8-qoida) boshqa ustaga havola bilan ham
        # ochilmaydi — faqat u bilan haqiqatan bog'langan bo'lsa (taklif,
        # javob, tayinlov yoki avval kelgan xabar).
        open_to_all = order.is_public and not visibility.territory_closed_to(
            order, request.user
        )
        involved = (
            open_to_all
            or is_assigned
            or has_response
            or has_invite
            or has_notification
        )

        if not involved:
            raise PermissionDenied("Bu buyurtma sizga tegishli emas.")

        data = OrderSerializer(
            order, context={"audience": "master", "request": request}
        ).data
        data["viewer_is_assigned"] = is_assigned
        # A historic notification recipient can see the order and its assigned
        # master, but does not need other masters' private invite records.
        if not is_assigned and not has_response and not has_invite:
            data["invites"] = []
        return Response(data)


class MasterOrderAdvanceView(APIView):
    """
    Keyingi bosqichga o'tkazish. Oxirgi bosqich (`handover`) dan keyin
    buyurtma yakunlanadi va mijozdan baho so'raladi.
    """

    permission_classes = [IsAuthenticated, IsMaster]
    serializer_class = OrderSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk)
        order = services.advance_stage(
            order, request.user, request.data.get("note", "")
        )
        return Response(
            OrderSerializer(order, context={"audience": "master"}).data
        )
