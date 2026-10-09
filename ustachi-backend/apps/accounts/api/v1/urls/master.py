from django.urls import path

from apps.accounts.models import AppKind
from apps.accounts.api.v1.master_views import (
    MasterNotesView,
    MasterProfileView,
    MasterRatesView,
    MasterSpecialtyListView,
    MasterWorkSampleDetailView,
    MasterWorkSampleListCreateView,
)
from apps.accounts.api.v1.views import (
    CustomTokenRefreshView,
    DeviceDeleteView,
    DeviceRegisterView,
    LogoutView,
    MeView,
    SendCodeView,
    VerifyOTPView,
)
from apps.accounts.api.v1.telegram_auth import TelegramAuthExchangeView


class MasterVerifyOTPView(VerifyOTPView):
    """OTP tasdiqlangач usta roli beriladi (mijozlik saqlanadi)."""

    grants_master = True


app_name = "master_auth"

urlpatterns = [
    # Bot bitta (`webhook/` faqat client namespace'ida ro'yxatlangan);
    # exchange esa har ikkala ilova o'z granti bilan chaqiradi.
    path("telegram/exchange/", TelegramAuthExchangeView.as_view(), name="telegram-exchange"),
    path("send-code/", SendCodeView.as_view(), name="send-code"),
    path("verify-code/", MasterVerifyOTPView.as_view(), name="verify-code"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token-refresh"),
    path("me/", MeView.as_view(), name="me"),
    # ── FCM push (qurilma tokeni) ────────────────────────────────
    path("devices/", DeviceRegisterView.as_view(app=AppKind.MASTER),
         name="device-register"),
    path("devices/delete/", DeviceDeleteView.as_view(), name="device-delete"),
    # ── Usta profili ─────────────────────────────────────────────
    path("specialties/", MasterSpecialtyListView.as_view(), name="specialties"),
    # Yo'nalish bo'yicha narxlar (g'isht donasi, zina metri, elektrik nuqtasi).
    path("profile/rates/", MasterRatesView.as_view(), name="profile-rates"),
    path("profile/notes/", MasterNotesView.as_view(), name="profile-notes"),
    path("profile/", MasterProfileView.as_view(), name="profile"),
    path("profile/work-samples/", MasterWorkSampleListCreateView.as_view(),
         name="work-samples"),
    path("profile/work-samples/<int:pk>/", MasterWorkSampleDetailView.as_view(),
         name="work-sample-detail"),
]
