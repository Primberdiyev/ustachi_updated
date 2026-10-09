"""
«Yangi versiya bormi?» — ikkala ilova ochilganda shu yerga murojaat qiladi.

Auth TALAB QILINMAYDI: majburiy yangilanish kirishdan OLDIN ham
ko'rsatilishi kerak, aks holda eski ilovadagi odam login ekranida
qulflanib qolardi va nima qilishni bilmasdi.
"""

from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.core.api.serializers import AppVersionQuerySerializer, AppVersionSerializer
from apps.core.models import AppKind, AppRelease, UpdateStatus, parse_version


class BaseAppVersionView(APIView):
    """Qaysi ilova ekani URL'dan ma'lum — so'rovda yuborilmaydi."""

    permission_classes = [AllowAny]
    authentication_classes: list = []
    app: str

    def get(self, request):
        query = AppVersionQuerySerializer(data=request.query_params)
        query.is_valid(raise_exception=True)
        platform = query.validated_data["platform"]
        current_raw = query.validated_data["version"]

        release = AppRelease.objects.filter(app=self.app, platform=platform).first()

        # Qator yo'q / o'chirilgan / eski — hamma holatda BIR XIL javob:
        # "hammasi joyida". Ilova hech qachon bo'sh oyna ko'rsatmaydi.
        if release is None:
            return Response(
                AppVersionSerializer(
                    {
                        "status": UpdateStatus.UP_TO_DATE,
                        "current_version": current_raw,
                        "latest_version": current_raw,
                        "store_url": "",
                        "notes": [],
                    }
                ).data
            )

        status = release.status_for(parse_version(current_raw))
        is_update = status != UpdateStatus.UP_TO_DATE

        return Response(
            AppVersionSerializer(
                {
                    "status": status,
                    "current_version": current_raw,
                    "latest_version": release.latest_version,
                    # Yangilanish yo'q bo'lsa havola ham keraksiz — ilovaga
                    # ishlatilmaydigan ma'lumot yubormaymiz.
                    "store_url": release.store_url if is_update else "",
                    "notes": release.notes_lines() if is_update else [],
                }
            ).data
        )


@method_decorator(cache_page(60), name="dispatch")
class ClientAppVersionView(BaseAppVersionView):
    """Ustachi (mijoz)."""

    app = AppKind.CLIENT


@method_decorator(cache_page(60), name="dispatch")
class MasterAppVersionView(BaseAppVersionView):
    """Ustachi Pro (usta)."""

    app = AppKind.MASTER
