"""
Admin panel OpenAPI schema'sining URL manbai (`/api/schema/admin/`).

Frontend (alohida repo: `usta-top-admin`) tipli API client'ni AYNAN shu
schema'dan generatsiya qiladi. Yangi admin endpoint qo'shsangiz uni SHU
YERGA ham qo'shing — aks holda panelda ko'rinmaydi.

Manzillar `config/urls.py` dagilar bilan bir xil bo'lishi SHART.
"""

from django.urls import include, path


urlpatterns = [
    path("api/v1/admin/auth/", include("apps.accounts.api.v1.urls.admin")),
    path("api/v1/admin/", include("apps.accounts.api.v1.admin.urls")),
    path("api/v1/admin/", include("apps.orders.api.v1.admin.urls")),
    path("api/v1/admin/", include("apps.core.api.admin.urls")),
    path("api/v1/admin/catalog/", include("apps.locations.api.v1.admin.urls")),
]
