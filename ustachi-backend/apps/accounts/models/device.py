"""
Qurilma tokenlari — FCM push manzillari.

Bitta foydalanuvchida bir nechta qurilma bo'lishi mumkin (telefon + planshet),
shuning uchun token ALOHIDA yozuv. `token` UNIKAL: qurilma egasi almashsa
(chiqdi → boshqa odam kirdi) yozuv YANGI foydalanuvchiga o'tadi, aks holda
push eski egasiga ketib qolardi.
"""

from django.db import models
from django.utils import timezone


class DevicePlatform(models.TextChoices):
    ANDROID = "android", "Android"
    IOS = "ios", "iOS"
    WEB = "web", "Web"


class AppKind(models.TextChoices):
    """Ilova turi; bo'sh qiymat mavjud eski qurilmalarni bildiradi."""

    CLIENT = "client", "Mijoz ilovasi"
    MASTER = "master", "Usta ilovasi"


def app_filter(app: str, field: str = "app"):
    """Berilgan ilova va ilovasi hali belgilanmagan eski yozuvlar."""
    from django.db.models import Q

    if not app:
        return Q()
    return Q(**{field: app}) | Q(**{field: ""})


class DeviceToken(models.Model):
    UZ_TITLE = "Qurilma tokeni"

    user = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="device_tokens",
        verbose_name="Foydalanuvchi",
    )
    token = models.CharField(
        max_length=255, unique=True, verbose_name="FCM token"
    )
    platform = models.CharField(
        max_length=16,
        choices=DevicePlatform.choices,
        default=DevicePlatform.ANDROID,
        verbose_name="Platforma",
    )
    # Ilova yuboradigan qurilma nomi — admin panelda kim qayerdan kirganini
    # ajratish uchun (majburiy emas).
    device_name = models.CharField(
        max_length=100, blank=True, default="", verbose_name="Qurilma"
    )
    app = models.CharField(
        max_length=8,
        choices=AppKind.choices,
        blank=True,
        default="",
        verbose_name="Ilova",
    )
    # FCM "token yaroqsiz" degan javob bergach False bo'ladi — o'chirilmaydi,
    # chunki tarix (qachon qaysi qurilma bo'lgani) admin uchun foydali.
    is_active = models.BooleanField(default=True, verbose_name="Faol")
    created_at = models.DateTimeField(auto_now_add=True)
    last_seen_at = models.DateTimeField(default=timezone.now, verbose_name="Oxirgi faollik")

    class Meta:
        ordering = ["-last_seen_at"]
        verbose_name = "Qurilma tokeni"
        verbose_name_plural = "Qurilma tokenlari"
        indexes = [models.Index(fields=["user", "is_active"])]

    def __str__(self):
        app = f" · {self.get_app_display()}" if self.app else ""
        return f"{self.user} — {self.get_platform_display()}{app}"
