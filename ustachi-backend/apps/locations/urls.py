from django.urls import path

from .views import DistrictListView, RegionListView

urlpatterns = [
    # Manzil katalogi — ro'yxatdan o'tishda viloyat/tuman tanlash uchun.
    path("locations/regions", RegionListView.as_view(), name="region-list"),
    path("locations/districts", DistrictListView.as_view(), name="district-list"),
]
