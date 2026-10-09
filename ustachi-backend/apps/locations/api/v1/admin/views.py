"""Admin panel — manzil CRUD."""
from django.db.models import Count
from drf_spectacular.utils import extend_schema, extend_schema_view

from apps.common.viewsets import AdminModelViewSet
from apps.locations.api.v1.admin.serializers import (
    AdminCitySerializer,
    AdminRegionSerializer,
)
from apps.locations.models import City, Region


@extend_schema_view(list=extend_schema(summary="Viloyatlar", tags=["admin:catalog"]))
class AdminRegionViewSet(AdminModelViewSet):
    serializer_class = AdminRegionSerializer
    search_fields = ["name"]
    ordering_fields = ["name", "id"]
    ordering = ["name"]

    def get_queryset(self):
        return Region.objects.annotate(
            cities_count=Count("cities", distinct=True),
            users_count=Count("users", distinct=True),
        )


@extend_schema_view(list=extend_schema(summary="Tuman/shaharlar", tags=["admin:catalog"]))
class AdminCityViewSet(AdminModelViewSet):
    serializer_class = AdminCitySerializer
    queryset = City.objects.select_related("region")
    filterset_fields = ["region"]
    search_fields = ["name"]
    ordering_fields = ["name", "id"]
    ordering = ["name"]
