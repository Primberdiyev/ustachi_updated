"""
Chat va bildirishnoma API'lari — MIJOZ va USTA uchun bir xil.

Ikkala ilova ham shu view'larni o'z prefiksida (client/master) ishlatadi;
ruxsat qatnashchilik bo'yicha tekshiriladi (rol bo'yicha emas), chunki bitta
odam ham mijoz, ham usta bo'lishi mumkin.
"""

from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models.device import app_filter
from apps.orders import services
from apps.orders.api.v1.serializers import (
    DEFAULT_CHAT_PAGE,
    ChatHistoryQuerySerializer,
    ChatMessageSerializer,
    ChatThreadSerializer,
    NotificationSerializer,
)
from apps.orders.models import ChatThread, Notification


# ───────────────────────── Bildirishnomalar ─────────────────────────


class _AppScopedMixin:
    app = ""

    def _mine(self, request):
        return Notification.objects.filter(app_filter(self.app), user=request.user)


class NotificationListView(_AppScopedMixin, APIView):
    """Bildirishnomalar ro'yxati + o'qilmaganlar soni (qo'ng'iroqcha uchun)."""

    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer

    def get(self, request):
        items = self._mine(request)
        if request.query_params.get("unread") == "true":
            items = items.filter(is_read=False)
        limit = int(request.query_params.get("limit", 50))
        return Response(
            {
                "unread_count": self._mine(request).filter(is_read=False).count(),
                "results": NotificationSerializer(items[:limit], many=True).data,
            }
        )


class NotificationReadView(APIView):
    """Bittasini o'qilgan deb belgilash."""

    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer

    def post(self, request, pk):
        item = get_object_or_404(Notification, pk=pk, user=request.user)
        item.is_read = True
        item.save(update_fields=["is_read"])
        return Response(NotificationSerializer(item).data)


class NotificationReadAllView(_AppScopedMixin, APIView):
    """Hammasini o'qilgan deb belgilash."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        updated = self._mine(request).filter(is_read=False).update(is_read=True)
        return Response({"updated": updated})


# ───────────────────────── Chat ─────────────────────────


def _visible_threads(user):
    """Foydalanuvchi qatnashadigan suhbatlar (mijoz yoki usta sifatida)."""
    return (
        ChatThread.objects.filter(Q(order__client=user) | Q(master=user))
        .select_related("order", "order__client", "master")
        .distinct()
    )


class ChatThreadListView(APIView):
    """Suhbatlar ro'yxati (Chat tab). `?order=<id>` bilan filtrlanadi."""

    permission_classes = [IsAuthenticated]
    serializer_class = ChatThreadSerializer

    def get(self, request):
        threads = _visible_threads(request.user)
        order_id = request.query_params.get("order")
        if order_id:
            threads = threads.filter(order_id=order_id)
        return Response(
            ChatThreadSerializer(
                threads, many=True, context={"request": request}
            ).data
        )


class ChatMessageListView(APIView):
    """
    GET  — suhbat tarixi (va qarshi tomon xabarlari o'qilgan deb belgilanadi).
    POST — xabar yuborish.

    SAHIFALASH (foydalanuvchi talabi 2026-09-05). Ilgari HAR SO'ROVDA butun
    tarix qaytarilardi — chat ochilganda ham, har yangi xabar signalida ham,
    soket o'lik bo'lsa har 5 soniyada ham. 500 xabarli suhbatda bu ~100 KB
    va server har safar hamma qatorni seriyalardi.

    Javob SHAKLI o'zgarmadi — baribir oddiy massiv, VAQT BO'YICHA o'sish
    tartibida. Do'kondagi eski ilovalar sahifalashni bilmaydi va parametrsiz
    so'rov ularga avvalgidek BUTUN tarixni beradi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = ChatMessageSerializer

    def _thread(self, request, pk):
        thread = get_object_or_404(ChatThread.objects.select_related("order"), pk=pk)
        if request.user.pk not in thread.participant_ids():
            raise PermissionDenied("Bu suhbat sizga tegishli emas.")
        return thread

    def get(self, request, pk):
        thread = self._thread(request, pk)
        thread.messages.filter(is_read=False).exclude(sender=request.user).update(
            is_read=True
        )

        query = ChatHistoryQuerySerializer(data=request.query_params)
        query.is_valid(raise_exception=True)
        messages = self._page(thread, query.validated_data)

        return Response(
            ChatMessageSerializer(
                messages, many=True, context={"request": request}
            ).data
        )

    @staticmethod
    def _page(thread, params: dict) -> list:
        """
        So'ralgan bo'lakni qaytaradi — DOIM vaqt bo'yicha o'sish tartibida.

        Kursor `id` bo'yicha: `created_at` teng bo'lib qolishi mumkin
        (bir soniyada ikki xabar), `id` esa hech qachon takrorlanmaydi.
        """
        base = thread.messages.select_related("sender")
        after, before = params.get("after"), params.get("before")
        limit = params.get("limit")

        # JONLI YANGILANISH — faqat yangilari. Ilova butun ro'yxatni
        # qayta yuklamaydi, borini saqlab ustiga qo'shadi.
        if after is not None:
            return list(base.filter(id__gt=after).order_by("id")[: limit or DEFAULT_CHAT_PAGE])

        # TEPAGA SURILDI — shu xabardan oldingi sahifa. Teskari o'qib,
        # qaytarishdan oldin to'g'rilaymiz.
        if before is not None:
            page = base.filter(id__lt=before).order_by("-id")[: limit or DEFAULT_CHAT_PAGE]
            return list(reversed(page))

        # CHAT OCHILDI — eng so'nggi sahifa.
        if limit is not None:
            return list(reversed(base.order_by("-id")[:limit]))

        # Parametrsiz — ESKI ilovalar uchun butun tarix.
        return list(base.order_by("id"))

    def post(self, request, pk):
        thread = self._thread(request, pk)
        message = services.send_message(
            thread, request.user, request.data.get("text", "")
        )
        return Response(
            ChatMessageSerializer(message, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )
