"""
MIJOZ buyurtma API'si — `ustachgi_mijoz` ilovasi uchun.

Oqim: taklifni tanlash → e'lon → javob bergan ustalar → chat (savdolashuv) →
bittasini tanlash → bosqichlarni kuzatish → baho.
"""

from django.db.models import Prefetch
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import MasterSpecialty
from apps.accounts.models.master import ROM_SPECIALTY_CODE
from apps.common import telegram
from apps.orders import services
from apps.orders.api.v1.serializers import (
    OrderCreateSerializer,
    OrderInviteCreateSerializer,
    OrderResponseSerializer,
    OrderSerializer,
    ReviewSerializer,
)
from apps.orders.models import Order, OrderResponse, OrderStatus, ResponseStatus


class ClientOrderListCreateView(APIView):
    """
    GET  — mening buyurtmalarim (yangi birinchi).
    POST — yangi buyurtma E'LON qilish; hududdagi ustalarga xabar ketadi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def get(self, request):
        services.expire_stale_orders()
        orders = (
            Order.objects.filter(client=request.user)
            .select_related("client", "assigned_master", "region", "district")
            .prefetch_related(
                "responses",
                "stage_events",
                "review",
                "invites__master__master_profile",
            )
        )
        status_filter = request.query_params.get("status")
        if status_filter:
            orders = orders.filter(status=status_filter)
        return Response(OrderSerializer(orders, many=True).data)

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # `master_ids` — mijoz ustalar ro'yxatidan O'ZI tanlagan ustalar.
        # Model maydoni emas, shuning uchun saqlashdan OLDIN olinadi.
        masters = serializer.validated_data.pop("master_ids", [])

        # Manzil berilmagan bo'lsa foydalanuvchi profilidan olinadi.
        defaults = {}
        if not serializer.validated_data.get("region"):
            defaults["region"] = request.user.region
        if not serializer.validated_data.get("district"):
            defaults["district"] = request.user.district

        # YO'NALISH berilmagan bo'lsa — ROM (foydalanuvchi talabi 2026-08-13).
        # 2026-08-13 gacha platformada faqat rom bor edi va CHIQIB BO'LGAN
        # mijoz ilovalari bu maydonni bilmaydi: ularning e'loni sohasiz
        # kelib, har soha ustasiga ko'rinib ketardi.
        if not serializer.validated_data.get("specialty"):
            defaults["specialty"] = MasterSpecialty.objects.filter(
                code=ROM_SPECIALTY_CODE
            ).first()

        # Usta tanlangan bo'lsa e'lon YOPIQ tug'iladi: uni boshqa ustalar
        # ko'rmaydi. Bu birgina tranzaksiyada bo'lishi shart — aks holda
        # taklif yozilmay qolsa e'lon "hammaga ochiq" bo'lib qolardi.
        order = serializer.save(
            client=request.user, is_public=not masters, **defaults
        )

        if masters:
            services.invite_masters(order, masters)
        else:
            services.notify_masters_of_new_order(order)
        telegram.notify_new_order(order)
        return Response(
            OrderSerializer(order).data, status=status.HTTP_201_CREATED
        )


class ClientOrderDetailView(APIView):
    """Bitta buyurtma (faqat egasiga)."""

    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def get_object(self, request, pk):
        return get_object_or_404(
            Order.objects.select_related(
                "client", "assigned_master", "region", "district"
            ).prefetch_related(
                "stage_events", "review", "invites__master__master_profile"
            ),
            pk=pk,
            client=request.user,
        )

    def get(self, request, pk):
        return Response(OrderSerializer(self.get_object(request, pk)).data)


class ClientOrderInviteView(APIView):
    """
    Buyurtmani TANLANGAN ustaga (yoki bir nechtasiga) yuborish.

    Ikki holatda ishlatiladi: e'lon berilgandan keyin "yana usta taklif
    qilish", va yopiq e'londa birinchi usta rad etgach boshqasini tanlash.
    Ochiq e'longa ham taklif yuborish mumkin — bu unga shaxsan turtki bo'ladi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = OrderInviteCreateSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, client=request.user)
        if order.status != OrderStatus.PUBLISHED:
            return Response(
                {"detail": "Bu buyurtma bo'yicha usta allaqachon tanlangan."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        serializer = OrderInviteCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.invite_masters(order, serializer.validated_data["master_ids"])

        order.refresh_from_db()
        return Response(OrderSerializer(order).data)


class ClientOrderPublishView(APIView):
    """
    Yopiq e'lonni HAMMAGA ochish — "kutib o'tirmayman, hamma ko'rsin".

    Bir tomonlama amal (orqaga qaytarilmaydi), shuning uchun ilovada
    tasdiqlash so'raladi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, client=request.user)
        order = services.open_order_to_everyone(order)
        return Response(OrderSerializer(order).data)


class ClientOrderCancelView(APIView):
    """Buyurtmani bekor qilish."""

    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, client=request.user)
        order = services.cancel_order(
            order, request.user, request.data.get("reason", "")
        )
        return Response(OrderSerializer(order).data)


class ClientOrderResponseListView(APIView):
    """Buyurtmaga javob bergan ustalar (mijoz shulardan tanlaydi)."""

    permission_classes = [IsAuthenticated]
    serializer_class = OrderResponseSerializer

    def get(self, request, pk):
        from django.db.models import Avg, Count, Prefetch

        order = get_object_or_404(Order, pk=pk, client=request.user)

        responses = (
            order.responses.exclude(status=ResponseStatus.WITHDRAWN)
            .select_related("master", "master__master_profile", "master__master_profile__specialty")
            .prefetch_related("order__threads", "master__received_reviews")
        )

        # N+1 FIX (2026-08-18): Prefetch reviews with aggregation
        # to avoid per-master queries in MasterBriefSerializer
        from apps.orders.models import Review

        master_ids = [resp.master_id for resp in responses]
        reviews_qs = (
            Review.objects.filter(master_id__in=master_ids)
            .values("master_id")
            .annotate(
                rating=Avg("rating"),
                count=Count("id"),
            )
        )

        reviews_by_master = {
            r["master_id"]: {
                "rating": round(r["rating"], 1) if r["rating"] is not None else None,
                "count": r["count"],
            }
            for r in reviews_qs
        }

        # Cache ratings in context to avoid N+1 in serializer
        context = {
            "request": request,
            "_cached_ratings": reviews_by_master,
        }

        return Response(
            OrderResponseSerializer(responses, many=True, context=context).data
        )


class ClientChooseMasterView(APIView):
    """Ustani tanlash — buyurtma `assigned` bo'ladi va ish boshlanadi."""

    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def post(self, request, pk, response_id):
        order = get_object_or_404(Order, pk=pk, client=request.user)
        response = get_object_or_404(OrderResponse, pk=response_id, order=order)
        order = services.choose_master(order, response)
        return Response(OrderSerializer(order).data)


class ClientReviewView(APIView):
    """Yakunlangan buyurtmaga baho (bir marta)."""

    permission_classes = [IsAuthenticated]
    serializer_class = ReviewSerializer

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, client=request.user)
        serializer = ReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = services.leave_review(
            order,
            request.user,
            serializer.validated_data["rating"],
            serializer.validated_data.get("comment", ""),
        )
        return Response(
            ReviewSerializer(review).data, status=status.HTTP_201_CREATED
        )
