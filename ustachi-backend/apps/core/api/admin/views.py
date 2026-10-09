"""Admin panel — bosh sahifa statistikasi va ilova versiyalari."""

from datetime import timedelta

from django.db.models import Avg, Count, Sum
from django.db.models.functions import TruncDate
from django.utils import timezone
from drf_spectacular.utils import OpenApiParameter, extend_schema, extend_schema_view
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import MasterProfile, User
from apps.common.permissions import IsAdmin
from apps.common.viewsets import AdminModelViewSet
from apps.core.api.admin.serializers import (
    AdminAppReleaseSerializer,
    DashboardSummarySerializer,
    DashboardTimeseriesPointSerializer,
)
from apps.core.models.app_release import AppRelease
from apps.orders.models import Order, OrderStatus, Review


def _period_counts(queryset, field: str) -> dict:
    """Jami / bugun / 7 kun / 30 kun kesimidagi sanoq."""
    now = timezone.now()
    today = now.replace(hour=0, minute=0, second=0, microsecond=0)
    return {
        "total": queryset.count(),
        "today": queryset.filter(**{f"{field}__gte": today}).count(),
        "week": queryset.filter(**{f"{field}__gte": now - timedelta(days=7)}).count(),
        "month": queryset.filter(**{f"{field}__gte": now - timedelta(days=30)}).count(),
    }


class AdminDashboardSummaryView(APIView):
    """
    Bosh sahifa kartalari.

    Bitta so'rovda beriladi — panel ochilishida 6 ta alohida so'rov
    yubormasligi uchun.
    """

    permission_classes = [IsAdmin]
    serializer_class = DashboardSummarySerializer

    @extend_schema(
        summary="Dashboard — umumiy ko'rsatkichlar",
        tags=["admin:dashboard"],
        responses=DashboardSummarySerializer,
    )
    def get(self, request):
        orders = Order.objects.all()

        by_status = {
            row["status"]: row["count"]
            for row in orders.values("status").annotate(count=Count("id"))
        }
        status_labels = dict(OrderStatus.choices)

        revenue = (
            orders.filter(status=OrderStatus.COMPLETED).aggregate(
                total=Sum("calculated_price")
            )["total"]
            or 0
        )

        data = {
            "users": _period_counts(User.objects.all(), "date_joined"),
            "masters": _period_counts(
                MasterProfile.objects.all(), "created_at"
            ),
            "orders": _period_counts(orders, "created_at"),
            "orders_by_status": [
                {
                    "status": value,
                    "label": status_labels[value],
                    "count": by_status.get(value, 0),
                }
                for value in status_labels
            ],
            "pending_verification": MasterProfile.objects.filter(
                is_verified=False
            ).count(),
            "active_orders": orders.filter(
                status__in=[OrderStatus.PUBLISHED, OrderStatus.ASSIGNED]
            ).count(),
            "completed_revenue": int(revenue),
            "average_rating": Review.objects.aggregate(avg=Avg("rating"))["avg"],
        }
        return Response(DashboardSummarySerializer(data).data)


class AdminDashboardTimeseriesView(APIView):
    """Grafik uchun kunlik qator: `?days=30` (standart 30, eng ko'pi 365)."""

    permission_classes = [IsAdmin]
    serializer_class = DashboardTimeseriesPointSerializer

    @extend_schema(
        summary="Dashboard — kunlik grafik",
        tags=["admin:dashboard"],
        parameters=[
            OpenApiParameter(
                "days", int, description="Necha kunlik qator (1-365)", required=False
            )
        ],
        responses=DashboardTimeseriesPointSerializer(many=True),
    )
    def get(self, request):
        try:
            days = int(request.query_params.get("days", 30))
        except (TypeError, ValueError):
            days = 30
        days = max(1, min(days, 365))

        since = timezone.now() - timedelta(days=days)

        def by_day(queryset, field):
            rows = (
                queryset.filter(**{f"{field}__gte": since})
                .annotate(day=TruncDate(field))
                .values("day")
                .annotate(count=Count("id"))
            )
            return {row["day"]: row["count"] for row in rows}

        order_map = by_day(Order.objects.all(), "created_at")
        user_map = by_day(User.objects.all(), "date_joined")

        start = (timezone.now() - timedelta(days=days - 1)).date()
        points = [
            {
                "date": day,
                "orders": order_map.get(day, 0),
                "users": user_map.get(day, 0),
            }
            for day in (start + timedelta(days=i) for i in range(days))
        ]
        return Response(DashboardTimeseriesPointSerializer(points, many=True).data)


@extend_schema_view(
    list=extend_schema(summary="Ilova versiyalari", tags=["admin:releases"]),
    create=extend_schema(summary="Versiya qo'shish", tags=["admin:releases"]),
    partial_update=extend_schema(summary="Versiyani tahrirlash", tags=["admin:releases"]),
    destroy=extend_schema(summary="Versiyani o'chirish", tags=["admin:releases"]),
)
class AdminAppReleaseViewSet(AdminModelViewSet):
    """Majburiy/tavsiyaviy yangilanish sozlamalari (`/api/v1/app-version/`)."""

    serializer_class = AdminAppReleaseSerializer
    queryset = AppRelease.objects.all()
    filterset_fields = ["app", "platform", "is_active"]
    ordering_fields = ["app", "platform", "updated_at"]
    ordering = ["app", "platform"]
