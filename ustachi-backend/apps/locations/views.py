from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.locations import models, serializers


class PublicView(APIView):
    """Ochiq (login'siz) o'qish manzillari: manzil ro'yxati.

    Ilova bularni kirishdan OLDIN ham so'raydi (ro'yxatdan o'tishda viloyat),
    shuning uchun token talab qilinmaydi va tekshirilmaydi.
    Faqat GET — yozish admin paneli orqali.
    """

    authentication_classes = []
    permission_classes = [AllowAny]


class RegionListView(PublicView):
    """Viloyatlar ro'yxati (manzil tanlash uchun). Faqat tumani bor viloyatlar."""

    def get(self, request):
        regions = models.Region.objects.filter(cities__isnull=False).distinct()
        return Response(serializers.RegionSerializer(regions, many=True).data)


class DistrictListView(PublicView):
    """Tuman/shaharlar. `?region=<id>` bilan viloyat bo'yicha filtrlanadi."""

    def get(self, request):
        qs = models.City.objects.filter(region__isnull=False)
        region_id = request.query_params.get("region")
        if region_id:
            qs = qs.filter(region_id=region_id)
        return Response(serializers.CitySerializer(qs, many=True).data)
