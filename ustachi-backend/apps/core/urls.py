from django.urls import path
from django.views.generic import RedirectView

from apps.core.views import (
    android_assetlinks,
    app_telegram_auth_landing,
    app_telegram_master_auth_landing,
    app_order_landing,
    landing_page,
    robots_txt,
    sitemap_xml,
)

app_name = "core"

urlpatterns = [
    path(".well-known/assetlinks.json", android_assetlinks, name="android-assetlinks"),
    path("app/order/<int:order_id>/", app_order_landing, name="app-order-landing"),
    path("app/auth/telegram/<str:code>/", app_telegram_auth_landing, name="telegram-auth-landing"),
    path("app/auth/master-telegram/<str:code>/", app_telegram_master_auth_landing, name="telegram-auth-landing-master"),
    path("", landing_page, name="landing"),
    path("robots.txt", robots_txt, name="robots"),
    path("sitemap.xml", sitemap_xml, name="sitemap"),
    path(
        "favicon.ico",
        RedirectView.as_view(url="/static/landing/images/logo.png", permanent=True),
        name="favicon",
    ),
]
