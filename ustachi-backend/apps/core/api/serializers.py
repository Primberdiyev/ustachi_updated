"""Ilova versiyasi so'rovi va javobi."""

from rest_framework import serializers

from apps.core.models import AppPlatform, parse_version


class AppVersionQuerySerializer(serializers.Serializer):
    """Ilova yuboradigan ikki qiymat: qaysi platforma va qaysi versiya."""

    platform = serializers.ChoiceField(choices=AppPlatform.choices)
    version = serializers.CharField(max_length=20)

    def validate_version(self, value: str) -> str:
        if parse_version(value) is None:
            raise serializers.ValidationError(
                "Versiyani o'qib bo'lmadi: 1.2.3 shaklida bo'lsin."
            )
        return value


class AppVersionSerializer(serializers.Serializer):
    """
    Javob. Ilova buni O'ZI talqin qilmaydi — `status` tayyor qaror.

    Matnlar bu yerda YO'Q (sarlavha, tugma yozuvlari): ular ilovaning
    tarjima fayllarida turadi, shunda har til o'z matnini oladi. Serverdan
    faqat O'ZGARADIGAN narsa keladi: versiya, havola va ixtiyoriy izohlar.
    """

    status = serializers.CharField()
    current_version = serializers.CharField()
    latest_version = serializers.CharField()
    store_url = serializers.CharField()
    notes = serializers.ListField(child=serializers.CharField())
