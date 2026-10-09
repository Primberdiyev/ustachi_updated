"""
Versiya tekshiruvi — ikkala ilova uchun.

Yo'l ilovaning o'z bo'limida (`client/` va `master/`), chunki ilovalarda
manzillar shu prefiks bilan yig'iladi va so'rovda "men kimman" deb
qo'shimcha parametr yuborish shart bo'lmasin.
"""

from django.urls import path

from apps.core.api.views import ClientAppVersionView, MasterAppVersionView

app_name = "core_api"

urlpatterns = [
    path("client/app-version/", ClientAppVersionView.as_view(), name="client-app-version"),
    path("master/app-version/", MasterAppVersionView.as_view(), name="master-app-version"),
]
