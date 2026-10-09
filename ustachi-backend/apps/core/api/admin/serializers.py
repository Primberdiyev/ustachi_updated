"""Admin panel — dashboard va ilova versiyasi serializerlari."""

from rest_framework import serializers

from apps.core.models.app_release import AppRelease


class AdminAppReleaseSerializer(serializers.ModelSerializer):
    app_display = serializers.CharField(source="get_app_display", read_only=True)
    platform_display = serializers.CharField(source="get_platform_display", read_only=True)

    class Meta:
        model = AppRelease
        fields = [
            "id",
            "app",
            "app_display",
            "platform",
            "platform_display",
            "latest_version",
            "min_version",
            "store_url",
            "notes",
            "is_active",
            "updated_at",
        ]


# ── Dashboard ──────────────────────────────────────────────────────────
# Bu serializerlar YOZUVGA emas, faqat OpenAPI shakli uchun: frontend
# `/dashboard/summary/` javobiga tipli client generatsiya qiladi.


class DashboardCountsSerializer(serializers.Serializer):
    total = serializers.IntegerField()
    today = serializers.IntegerField()
    week = serializers.IntegerField()
    month = serializers.IntegerField()


class DashboardOrderStatusSerializer(serializers.Serializer):
    status = serializers.CharField()
    label = serializers.CharField()
    count = serializers.IntegerField()


class DashboardSummarySerializer(serializers.Serializer):
    users = DashboardCountsSerializer()
    masters = DashboardCountsSerializer()
    orders = DashboardCountsSerializer()
    orders_by_status = DashboardOrderStatusSerializer(many=True)
    pending_verification = serializers.IntegerField()
    active_orders = serializers.IntegerField()
    completed_revenue = serializers.IntegerField()
    average_rating = serializers.FloatField(allow_null=True)


class DashboardTimeseriesPointSerializer(serializers.Serializer):
    date = serializers.DateField()
    orders = serializers.IntegerField()
    users = serializers.IntegerField()
