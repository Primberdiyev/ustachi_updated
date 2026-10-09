"""
Ustaning O'Z buyurtmalari uchun serializerlar.

Marketplace serializerlaridan (`serializers.py`) ATAYLAB ajratilgan: bu yerda
mijoz FK yo'q va statuslar boshqa.
"""

from rest_framework import serializers

from apps.orders.models import MasterOrder, MasterOrderItem, MasterOrderStatus


class MasterOrderItemSerializer(serializers.ModelSerializer):
    """Bitta rom — o'lcham va chizma."""

    class Meta:
        model = MasterOrderItem
        fields = [
            "id",
            "position",
            "title",
            "material_label",
            "width_mm",
            "height_mm",
            "qty",
            "drawing",
        ]
        read_only_fields = ["id"]

    def validate_qty(self, value):
        if value < 1:
            raise serializers.ValidationError("Sanoq kamida 1 bo'lishi kerak.")
        return value


class MasterOrderSerializer(serializers.ModelSerializer):
    """
    To'liq buyurtma. `items` bilan BIRGA yaratiladi/yangilanadi —
    buyurtma mahsulotsiz ma'noga ega emas.
    """

    items = MasterOrderItemSerializer(many=True)
    product_count = serializers.IntegerField(read_only=True)
    status_label = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = MasterOrder
        fields = [
            "id",
            "sync_client_id",
            "customer_name",
            "customer_phone",
            "customer_address",
            "deadline",
            "note",
            "product_count",
            "status",
            "status_label",
            "completed_at",
            "items",
            "created_at",
        ]
        read_only_fields = ["id", "product_count", "completed_at", "created_at"]

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError("Kamida bitta mahsulot kerak.")
        return value

    def validate_customer_name(self, value):
        name = (value or "").strip()
        if not name:
            raise serializers.ValidationError("Buyurtmachi ismi majburiy.")
        return name

    def _write_items(self, order, items_data):
        order.items.all().delete()
        MasterOrderItem.objects.bulk_create(
            [
                MasterOrderItem(
                    order=order,
                    **{**data, "position": data.get("position", index)},
                )
                for index, data in enumerate(items_data)
            ]
        )

    def create(self, validated_data):
        items_data = validated_data.pop("items")
        master = validated_data.pop("master")
        sync_id = (validated_data.get("sync_client_id") or "").strip()

        # Idempotentlik: tarmoq uzilib qayta yuborilsa dublikat YARATILMAYDI —
        # o'sha buyurtma YANGILANADI.
        order = None
        if sync_id:
            order = MasterOrder.objects.filter(
                master=master, sync_client_id=sync_id
            ).first()

        if order is None:
            order = MasterOrder.objects.create(master=master, **validated_data)
        else:
            for field, value in validated_data.items():
                setattr(order, field, value)
            order.save()

        self._write_items(order, items_data)
        return order

    def update(self, instance, validated_data):
        items_data = validated_data.pop("items", None)
        for field, value in validated_data.items():
            setattr(instance, field, value)
        instance.save()
        if items_data is not None:
            self._write_items(instance, items_data)
        return instance


class MasterOrderStatusSerializer(serializers.Serializer):
    """Holatni o'zgartirish — faqat ruxsat etilgan qiymatlar."""

    status = serializers.ChoiceField(choices=MasterOrderStatus.choices)
