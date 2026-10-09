"""`/api/v1/admin/` — dashboard va ilova versiyalari."""

from django.urls import include, path
from rest_framework.routers import DefaultRouter

from apps.core.api.admin.views import (
    AdminAppReleaseViewSet,
    AdminDashboardSummaryView,
    AdminDashboardTimeseriesView,
)

app_name = "admin_core"

router = DefaultRouter()
router.register("releases", AdminAppReleaseViewSet, basename="release")

urlpatterns = [
    path("dashboard/summary/", AdminDashboardSummaryView.as_view(), name="dashboard-summary"),
    path(
        "dashboard/timeseries/",
        AdminDashboardTimeseriesView.as_view(),
        name="dashboard-timeseries",
    ),
    path("", include(router.urls)),
]
