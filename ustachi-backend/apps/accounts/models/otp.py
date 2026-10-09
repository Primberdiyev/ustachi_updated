import random
import string
from datetime import timedelta

from django.conf import settings
from django.db import models
from django.utils import timezone


class OTPPurpose(models.TextChoices):
    """
    Kod NIMA UCHUN yuborilgani. Maqsad ajratilmasa, kirish uchun kelgan kod
    bilan akkauntni o'chirib yuborish mumkin bo'lardi — shuning uchun kod
    tekshirilayotganda maqsad ham solishtiriladi.
    """

    AUTH = "auth", "Kirish / ro'yxatdan o'tish"
    DELETE_ACCOUNT = "delete_account", "Akkauntni o'chirish"


class PhoneOTP(models.Model):
    UZ_TITLE = "Telefon OTP"

    phone_number = models.CharField(max_length=20)
    code = models.CharField(max_length=6)
    purpose = models.CharField(
        max_length=20,
        choices=OTPPurpose.choices,
        default=OTPPurpose.AUTH,
        verbose_name="Maqsad",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Telefon OTP"
        verbose_name_plural = "Telefon OTPlar"

    def __str__(self):
        return f"OTP {self.phone_number}: {self.code}"

    def is_valid(self):
        return not self.is_used and self.expires_at > timezone.now()

    #: Demo hisob kodi uzoq amal qiladi — moderator ilovani bir necha kun
    #: davomida tekshirishi mumkin va har safar "kod eskirgan" chiqmasin.
    DEMO_TTL_DAYS = 365

    @staticmethod
    def _digits(value: str) -> str:
        """Faqat raqamlar — `+998 91 777 77 77` va `+998917777777` bir xil."""
        return "".join(ch for ch in (value or "") if ch.isdigit())

    @classmethod
    def demo_code_for(cls, phone_number: str):
        """
        Demo raqam bo'lsa — unga biriktirilgan kod, aks holda `None`.

        Ikki juftlik bor: usta ilovasi (`OTP_DEMO_PHONE`) va mijoz ilovasi
        (`OTP_DEMO_PHONE_CLIENT`) — do'kon moderatori ikkala ilovani ham
        ALOHIDA hisoblar bilan tekshiradi. Har raqamning O'Z kodi bor.
        """
        digits = cls._digits(phone_number)
        if not digits:
            return None
        pairs = (
            (
                getattr(settings, "OTP_DEMO_PHONE", ""),
                getattr(settings, "OTP_DEMO_CODE", "777777"),
            ),
            (
                getattr(settings, "OTP_DEMO_PHONE_CLIENT", ""),
                getattr(settings, "OTP_DEMO_CODE_CLIENT", "888888"),
            ),
        )
        for phone, code in pairs:
            if phone and cls._digits(phone) == digits:
                return code
        return None

    @classmethod
    def is_demo_phone(cls, phone_number: str) -> bool:
        """Do'kon moderatori uchun ajratilgan raqammi (settings'dan)."""
        return cls.demo_code_for(phone_number) is not None

    @classmethod
    def generate_otp(cls, phone_number, purpose=OTPPurpose.AUTH):
        from apps.accounts.services.sms import sms_service_is_configured

        # Faqat AYNI maqsaddagi eski kodlar kuydiriladi: o'chirish kodi
        # yuborilgani kirish kodini bekor qilmasligi kerak.
        cls.objects.filter(
            phone_number=phone_number, purpose=purpose, is_used=False
        ).update(is_used=True)

        # 1) DEMO raqamlar (Play/App Store moderatori): kod O'ZGARMAYDI va
        #    tez eskirmaydi.
        demo_code = cls.demo_code_for(phone_number)
        if demo_code is not None:
            return cls.objects.create(
                phone_number=phone_number,
                code=demo_code,
                purpose=purpose,
                expires_at=timezone.now() + timedelta(days=cls.DEMO_TTL_DAYS),
            )

        # 2) SMS xizmati SOZLANGAN (production) — doim tasodifiy kod.
        #    Sozlanmagan (lokal dev) — statik kod: real SMS ketmaydi, kod
        #    konsol/log orqali ma'lum. `OTP_STATIC_CODE` bilan o'zgartiriladi.
        if sms_service_is_configured():
            code = "".join(random.choices(string.digits, k=6))
        else:
            code = getattr(settings, "OTP_STATIC_CODE", "") or "111111"

        return cls.objects.create(
            phone_number=phone_number,
            code=code,
            purpose=purpose,
            expires_at=timezone.now() + timedelta(minutes=5),
        )
