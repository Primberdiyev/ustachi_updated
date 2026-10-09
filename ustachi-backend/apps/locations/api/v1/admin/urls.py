"""Admin panel — manzil URL'lari (`/api/v1/admin/catalog/`)."""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from apps.locations.api.v1.admin.views import AdminCityViewSet, AdminRegionViewSet

app_name = "admin_catalog"

router = DefaultRouter()
router.register("regions", AdminRegionViewSet, basename="region")
router.register("cities", AdminCityViewSet, basename="city")

urlpatterns = [
    path("", include(router.urls)),
]
