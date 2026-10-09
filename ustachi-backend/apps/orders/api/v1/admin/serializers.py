"""Admin panel — buyurtma, javob, baho va chat serializerlari.

Mijoz/usta serializerlaridan farqi: admin HAMMA tomonni ko'radi
(mijoz + usta, hisob, bekor qilish sababi) va hech qanday
ko'rinish filtri (`visibility.py`) qo'llanmaydi.
"""

from rest_framework import serializers

from apps.orders.models import (
    ChatMessage,
    ChatThread,
    Order,
    OrderResponse,
    OrderStageEvent,
    Review,
)


class AdminUserBriefSerializer(serializers.Serializer):
    """Jadvalda odamni ko'rsatish uchun minimal blok."""

    id = serializers.IntegerField(read_only=True)
    full_name = serializers.CharField(read_only=True)
    phone_number = serializers.CharField(read_only=True)


class AdminOrderListSerializer(serializers.ModelSerializer):
    client = AdminUserBriefSerializer(read_only=True)
    assigned_master = AdminUserBriefSerializer(read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    stage_display = serializers.CharField(source="get_stage_display", read_only=True, default=None)
    specialty_name = serializers.CharField(source="specialty.name", read_only=True, default=None)
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)
    district_name = serializers.CharField(source="district.name", read_only=True, default=None)
    responses_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = Order
        fields = [
            "id",
            "title",
            "client",
            "assigned_master",
            "status",
            "status_display",
            "stage",
            "stage_display",
            "specialty",
            "specialty_name",
            "region",
            "region_name",
            "district",
            "district_name",
            "calculated_price",
            "is_public",
            "responses_count",
            "created_at",
            "expires_at",
            "completed_at",
        ]


class AdminOrderStageEventSerializer(serializers.ModelSerializer):
    stage_display = serializers.CharField(source="get_stage_display", read_only=True)
    actor = AdminUserBriefSerializer(read_only=True)

    class Meta:
        model = OrderStageEvent
        fields = ["id", "stage", "stage_display", "note", "actor", "created_at"]


class AdminOrderResponseSerializer(serializers.ModelSerializer):
    master = AdminUserBriefSerializer(read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = OrderResponse
        fields = [
            "id",
            "order",
            "master",
            "status",
            "status_display",
            "message",
            "created_at",
        ]


class AdminOrderDetailSerializer(AdminOrderListSerializer):
    """Kartochka — taklif surati, bosqich tarixi va javoblar bilan."""

    responses = AdminOrderResponseSerializer(many=True, read_only=True)
    stage_events = AdminOrderStageEventSerializer(many=True, read_only=True)
    cost_base = serializers.IntegerField(read_only=True)

    class Meta(AdminOrderListSerializer.Meta):
        fields = AdminOrderListSerializer.Meta.fields + [
            "description",
            "address",
            "proposal",
            "cost_base",
            "cancelled_reason",
            "responses",
            "stage_events",
            "modified_at",
        ]


class AdminOrderCancelSerializer(serializers.Serializer):
    """Adminning majburiy bekor qilishi — sabab SHART (audit uchun)."""

    reason = serializers.CharField(max_length=255, allow_blank=False)


class AdminReviewSerializer(serializers.ModelSerializer):
    client = AdminUserBriefSerializer(read_only=True)
    master = AdminUserBriefSerializer(read_only=True)
    order_title = serializers.CharField(source="order.title", read_only=True)

    class Meta:
        model = Review
        fields = [
            "id",
            "order",
            "order_title",
            "client",
            "master",
            "rating",
            "comment",
            "created_at",
        ]


class AdminChatMessageSerializer(serializers.ModelSerializer):
    sender = AdminUserBriefSerializer(read_only=True)

    class Meta:
        model = ChatMessage
        fields = ["id", "thread", "sender", "text", "is_read", "created_at"]


class AdminChatThreadSerializer(serializers.ModelSerializer):
    master = AdminUserBriefSerializer(read_only=True)
    order_title = serializers.CharField(source="order.title", read_only=True)
    client = AdminUserBriefSerializer(source="order.client", read_only=True)
    messages_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = ChatThread
        fields = [
            "id",
            "order",
            "order_title",
            "client",
            "master",
            "messages_count",
            "created_at",
            "last_message_at",
        ]
