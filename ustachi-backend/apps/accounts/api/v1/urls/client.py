from django.urls import path

from apps.accounts.models import AppKind
from apps.accounts.api.v1.views import (
    CustomTokenRefreshView,
    DeviceDeleteView,
    DeviceRegisterView,
    LogoutView,
    MeView,
    SendCodeView,
    VerifyOTPView,
)
from apps.accounts.api.v1.telegram_auth import (
    TelegramAuthExchangeView,
    TelegramAuthWebhookView,
)

# HAMMA foydalanuvchi mijoz (client) — bu namespace hech qanday qo'shimcha rol
# talab qilmaydi va bermaydi. Register va login BITTA oqim: send-code → verify-code.
app_name = "client_auth"

urlpatterns = [
    path("telegram/webhook/", TelegramAuthWebhookView.as_view(), name="telegram-webhook"),
    path("telegram/exchange/", TelegramAuthExchangeView.as_view(), name="telegram-exchange"),
    path("send-code/", SendCodeView.as_view(), name="send-code"),
    path("verify-code/", VerifyOTPView.as_view(), name="verify-code"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token-refresh"),
    path("me/", MeView.as_view(), name="me"),
    # ── FCM push (qurilma tokeni) ────────────────────────────────
    path("devices/", DeviceRegisterView.as_view(app=AppKind.CLIENT),
         name="device-register"),
    path("devices/delete/", DeviceDeleteView.as_view(), name="device-delete"),
]
