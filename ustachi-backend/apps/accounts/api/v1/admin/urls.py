"""`/api/v1/admin/` — foydalanuvchi va usta resurslari.

Autentifikatsiya (`/api/v1/admin/auth/`) ALOHIDA modulda:
`apps/accounts/api/v1/urls/admin.py`.
"""

from django.urls import include, path
from rest_framework.routers import DefaultRouter

from apps.accounts.api.v1.admin.views import (
    AdminMasterProfileViewSet,
    AdminMasterSpecialtyViewSet,
    AdminUserViewSet,
)

app_name = "admin_accounts"

router = DefaultRouter()
router.register("users", AdminUserViewSet, basename="user")
router.register("masters", AdminMasterProfileViewSet, basename="master")
router.register("specialties", AdminMasterSpecialtyViewSet, basename="specialty")

urlpatterns = [
    path("", include(router.urls)),
]
