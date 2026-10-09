"""Admin panel — buyurtmalar, baholar va chat monitoringi."""

from django.db.models import Count
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.common.pagination import AdminPagination
from apps.common.viewsets import AdminModelViewSet, AdminReadOnlyViewSet
from apps.orders import services
from apps.orders.api.v1.admin.filters import AdminOrderFilter, AdminReviewFilter
from apps.orders.api.v1.admin.serializers import (
    AdminChatMessageSerializer,
    AdminChatThreadSerializer,
    AdminOrderCancelSerializer,
    AdminOrderDetailSerializer,
    AdminOrderListSerializer,
    AdminReviewSerializer,
)
from apps.orders.models import ChatMessage, ChatThread, Order, Review


@extend_schema_view(
    list=extend_schema(summary="Buyurtmalar ro'yxati", tags=["admin:orders"]),
    retrieve=extend_schema(summary="Buyurtma kartochkasi", tags=["admin:orders"]),
)
class AdminOrderViewSet(AdminReadOnlyViewSet):
    """
    Buyurtmalar — faqat o'qish + majburiy bekor qilish.

    Tahrirlash ATAYLAB yo'q: buyurtma holati/bosqichi hodisa tarixi
    (`OrderStageEvent`), bildirishnoma va WebSocket bilan bog'liq —
    maydonni jadvaldan qo'lda o'zgartirish ularni buzadi.
    """

    filterset_class = AdminOrderFilter
    search_fields = ["title", "description", "client__phone_number", "client__full_name"]
    ordering_fields = ["created_at", "calculated_price", "expires_at", "id"]
    ordering = ["-created_at"]

    def get_queryset(self):
        qs = Order.objects.select_related(
            "client", "assigned_master", "specialty", "region", "district"
        ).annotate(responses_count=Count("responses", distinct=True))
        if self.action == "retrieve":
            qs = qs.prefetch_related(
                "responses__master", "stage_events__actor"
            )
        return qs

    def get_serializer_class(self):
        if self.action == "retrieve":
            return AdminOrderDetailSerializer
        if self.action == "cancel":
            return AdminOrderCancelSerializer
        return AdminOrderListSerializer

    @extend_schema(
        summary="Majburiy bekor qilish",
        tags=["admin:orders"],
        request=AdminOrderCancelSerializer,
        responses=AdminOrderDetailSerializer,
    )
    @action(detail=True, methods=["post"])
    def cancel(self, request, pk=None):
        """Sabab SHART — u mijozga bildirishnoma matni bo'lib boradi."""
        order = self.get_object()
        serializer = AdminOrderCancelSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        services.cancel_order(
            order,
            request.user,
            reason=serializer.validated_data["reason"],
            force=True,
        )
        order.refresh_from_db()
        return Response(
            AdminOrderDetailSerializer(order, context=self.get_serializer_context()).data
        )

    @extend_schema(
        summary="Buyurtma chati",
        tags=["admin:orders"],
        responses=AdminChatMessageSerializer(many=True),
    )
    @action(detail=True, methods=["get"], url_path="messages")
    def messages(self, request, pk=None):
        """Nizo ko'rilganda yozishmani o'qish. Admin chatga YOZA olmaydi."""
        order = self.get_object()
        qs = (
            ChatMessage.objects.filter(thread__order=order)
            .select_related("sender", "thread")
            .order_by("created_at")
        )
        paginator = AdminPagination()
        page = paginator.paginate_queryset(qs, request, view=self)
        serializer = AdminChatMessageSerializer(
            page, many=True, context=self.get_serializer_context()
        )
        return paginator.get_paginated_response(serializer.data)


@extend_schema_view(
    list=extend_schema(summary="Baholar ro'yxati", tags=["admin:reviews"]),
    retrieve=extend_schema(summary="Baho", tags=["admin:reviews"]),
    destroy=extend_schema(summary="Bahoni o'chirish", tags=["admin:reviews"]),
)
class AdminReviewViewSet(AdminModelViewSet):
    """
    Baholar — o'qish va moderatsiya uchun O'CHIRISH.

    Bahoni tahrirlash yo'q: matnni admin o'zgartirsa u mijozning bahosi
    bo'lmay qoladi. Haqoratli izoh butunlay o'chiriladi — usta reytingi
    shunda qayta hisoblanadi.
    """

    http_method_names = ["get", "delete", "head", "options"]
    serializer_class = AdminReviewSerializer
    filterset_class = AdminReviewFilter
    search_fields = ["comment", "master__full_name", "client__full_name"]
    ordering_fields = ["created_at", "rating"]
    ordering = ["-created_at"]

    def get_queryset(self):
        return Review.objects.select_related("client", "master", "order")


@extend_schema_view(
    list=extend_schema(summary="Suhbatlar", tags=["admin:chats"]),
    retrieve=extend_schema(summary="Suhbat", tags=["admin:chats"]),
)
class AdminChatThreadViewSet(AdminReadOnlyViewSet):
    """Chat monitoringi — nizolarni ko'rish uchun, faqat o'qish."""

    serializer_class = AdminChatThreadSerializer
    filterset_fields = ["order", "master"]
    search_fields = ["order__title", "master__full_name", "master__phone_number"]
    ordering_fields = ["last_message_at", "created_at"]
    ordering = ["-last_message_at"]

    def get_queryset(self):
        return (
            ChatThread.objects.select_related("order", "order__client", "master")
            .annotate(messages_count=Count("messages", distinct=True))
        )

    @extend_schema(
        summary="Suhbat xabarlari",
        tags=["admin:chats"],
        responses=AdminChatMessageSerializer(many=True),
    )
    @action(detail=True, methods=["get"], url_path="messages")
    def messages(self, request, pk=None):
        thread = self.get_object()
        qs = thread.messages.select_related("sender").order_by("created_at")
        paginator = AdminPagination()
        page = paginator.paginate_queryset(qs, request, view=self)
        serializer = AdminChatMessageSerializer(
            page, many=True, context=self.get_serializer_context()
        )
        return paginator.get_paginated_response(serializer.data)
