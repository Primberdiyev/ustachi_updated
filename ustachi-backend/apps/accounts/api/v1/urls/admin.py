from django.urls import path

from apps.accounts.api.v1.views import (
    CustomTokenRefreshView,
    LoginView,
    LogoutView,
    MeView,
)

# Admin login. Faqat `is_superuser=True` foydalanuvchilar kira oladi.
# Public ro'yxatdan o'tish yo'q — admin faqat createsuperuser yoki
# admin paneli orqali yaratiladi.
app_name = "admin_auth"

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token-refresh"),
    path("me/", MeView.as_view(), name="me"),
]
