from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    # ── Asosiy landing sahifasi (bosh sahifa) ──
    path("", include("apps.core.urls")),
    path("admin/", admin.site.urls),
    # ── Ommaviy HTML sahifa: akkauntni o'chirish (ilovaga kirmasdan) ──
    path("account/", include("apps.accounts.web.urls")),
    # ── Ilova versiyasi (auth talab qilmaydi: majburiy yangilanish
    #    login ekranidan OLDIN ham ko'rsatilishi kerak) ──
    path("api/v1/", include("apps.core.api.urls")),
    path("api/v1/client/auth/", include("apps.accounts.api.v1.urls.client")),
    path("api/", include("apps.locations.urls")),
    path("api/v1/master/auth/", include("apps.accounts.api.v1.urls.master")),
    path("api/v1/admin/auth/", include("apps.accounts.api.v1.urls.admin")),
    # ── Admin panel API (alohida frontend repo: usta-top-admin) ──
    #    Yangi admin endpoint qo'shsangiz `config/schema_urls_admin.py`
    #    ga ham qo'shing — panel schema'dan client generatsiya qiladi.
    path("api/v1/admin/", include("apps.accounts.api.v1.admin.urls")),
    path("api/v1/admin/", include("apps.orders.api.v1.admin.urls")),
    path("api/v1/admin/", include("apps.core.api.admin.urls")),
    path("api/v1/admin/catalog/", include("apps.locations.api.v1.admin.urls")),
    # ── Buyurtma marketplace (e'lon → javob → chat → bosqichlar → baho) ──
    path("api/v1/client/", include("apps.orders.api.v1.urls.client")),
    path("api/v1/master/", include("apps.orders.api.v1.urls.master")),
    path(
        "api/schema/client/",
        SpectacularAPIView.as_view(
            urlconf="config.schema_urls_client",
            custom_settings={
                "TITLE": "Usta Top Client API",
            },
        ),
        name="schema-client",
    ),
    path(
        "api/schema/master/",
        SpectacularAPIView.as_view(
            urlconf="config.schema_urls_master",
            custom_settings={
                "TITLE": "Usta Top Master API",
            },
        ),
        name="schema-master",
    ),
    path(
        "api/schema/admin/",
        SpectacularAPIView.as_view(
            urlconf="config.schema_urls_admin",
            custom_settings={
                "TITLE": "Usta Top Admin API",
            },
        ),
        name="schema-admin",
    ),
    path(
        "api/docs/client/",
        SpectacularSwaggerView.as_view(url_name="schema-client"),
        name="swagger-client",
    ),
    path(
        "api/docs/master/",
        SpectacularSwaggerView.as_view(url_name="schema-master"),
        name="swagger-master",
    ),
    path(
        "api/docs/admin/",
        SpectacularSwaggerView.as_view(url_name="schema-admin"),
        name="swagger-admin",
    ),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
