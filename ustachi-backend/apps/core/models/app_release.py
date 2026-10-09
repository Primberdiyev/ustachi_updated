"""
ILOVA VERSIYALARI — «yangi versiya chiqdi» oynasining YAGONA manbasi.

Nima uchun server hal qiladi: taqqoslash mantig'i ilovaga yozilsa, uni
o'zgartirish uchun ilovani QAYTA CHIQARISH kerak bo'lardi — ya'ni eski
versiyadagilar hech qachon yangilanmagan qoidani ishlatib yuraverardi.
Bu yerda esa admin bitta maydonni o'zgartiradi va qoida DARHOL hammaga
tegishli bo'ladi.

Ilova o'z versiyasini yuboradi, server uch javobdan birini qaytaradi:
  * `up_to_date` — hech narsa ko'rsatilmaydi;
  * `optional`   — «Keyinroq» tugmasi bor oyna;
  * `required`   — yopib bo'lmaydigan oyna (eski versiya API bilan
    ishlamay qolganda).
"""

from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator
from django.db import models
from packaging.version import InvalidVersion, Version

#: `1`, `1.2`, `1.2.3`, `1.2.3.4` — do'konlardagi odatiy shakl.
VERSION_VALIDATOR = RegexValidator(
    r"^\d+(\.\d+){0,3}$",
    "Versiya faqat raqam va nuqtadan iborat bo'lsin: 1.2.3",
)


class UpdateStatus(models.TextChoices):
    """Ilovaga qaytariladigan javob."""

    UP_TO_DATE = "up_to_date", "Yangi"
    OPTIONAL = "optional", "Ixtiyoriy"
    REQUIRED = "required", "Majburiy"


class AppKind(models.TextChoices):
    CLIENT = "client", "Ustachi (mijoz)"
    MASTER = "master", "Ustachi Pro (usta)"


class AppPlatform(models.TextChoices):
    ANDROID = "android", "Android"
    IOS = "ios", "iOS"


def parse_version(raw: str) -> Version | None:
    """Versiya → taqqoslanadigan obyekt. Tushunarsiz bo'lsa `None`."""
    try:
        return Version(raw)
    except InvalidVersion:
        return None


class AppRelease(models.Model):
    UZ_TITLE = "Ilova versiyasi"

    app = models.CharField(
        max_length=16, choices=AppKind.choices, verbose_name="Ilova"
    )
    platform = models.CharField(
        max_length=16, choices=AppPlatform.choices, verbose_name="Platforma"
    )
    latest_version = models.CharField(
        max_length=20,
        validators=[VERSION_VALIDATOR],
        verbose_name="Oxirgi versiya",
        help_text="Do'konda turgan eng yangi versiya, masalan 1.2.3.",
    )
    # Bo'sh = majburiy yangilash O'CHIQ. Ataylab shunday: majburiy rejim
    # odamni ilovadan butunlay chiqarib qo'yadi, u tasodifan yoqilmasin.
    min_version = models.CharField(
        max_length=20,
        blank=True,
        default="",
        validators=[VERSION_VALIDATOR],
        verbose_name="Eng past ruxsat etilgan versiya",
        help_text=(
            "Bundan PAST versiyalarda oyna yopilmaydi — ilovadan "
            "foydalanib bo'lmaydi. Bo'sh qoldirilsa majburiy yangilash "
            "ishlamaydi."
        ),
    )
    store_url = models.URLField(
        max_length=500,
        blank=True,
        default="",
        verbose_name="Yangilash havolasi",
        help_text=(
            "«Yangilash» tugmasi shu manzilni ochadi: Play Market, App "
            "Store yoki to'g'ridan-to'g'ri APK."
        ),
    )
    # HAR QATOR — bitta band. Bo'sh qoldirilsa ilova o'zining tayyor
    # matnini ko'rsatadi, ya'ni ro'yxatni har safar to'ldirish SHART emas.
    notes = models.TextField(
        blank=True,
        default="",
        verbose_name="Nima yangilandi",
        help_text=(
            "Har bir yangilik — ALOHIDA QATOR. Bo'sh qoldirsangiz ilova "
            "umumiy matn ko'rsatadi, oyna baribir to'g'ri ishlaydi."
        ),
    )
    is_active = models.BooleanField(
        default=False,
        verbose_name="Yoqilgan",
        help_text="O'chirilsa hech kimga yangilanish oynasi chiqmaydi.",
    )
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Ilova versiyasi"
        verbose_name_plural = "Ilova versiyalari"
        ordering = ["app", "platform"]
        constraints = [
            models.UniqueConstraint(
                fields=["app", "platform"], name="uniq_app_release_per_platform"
            )
        ]

    def __str__(self) -> str:
        return f"{self.get_app_display()} · {self.get_platform_display()} · {self.latest_version}"

    # ── Tekshiruvlar ────────────────────────────────────────────────
    def clean(self) -> None:
        super().clean()
        errors: dict[str, str] = {}

        latest = parse_version(self.latest_version)
        if latest is None:
            errors["latest_version"] = "Versiyani o'qib bo'lmadi."

        minimum = None
        if self.min_version:
            minimum = parse_version(self.min_version)
            if minimum is None:
                errors["min_version"] = "Versiyani o'qib bo'lmadi."

        if latest is not None and minimum is not None and minimum > latest:
            errors["min_version"] = (
                "Eng past versiya oxirgi versiyadan yuqori bo'lishi mumkin emas — "
                "bunda HAMMA foydalanuvchi qulflanib qolardi."
            )

        # Havolasiz yoqilgan qator — «Yangilash» tugmasi hech qayerga olib
        # bormaydi. Majburiy rejimda bu ilovani butunlay ishlatib
        # bo'lmaydigan qilib qo'yadi.
        if self.is_active and not self.store_url:
            errors["store_url"] = (
                "Yangilash havolasisiz yoqib bo'lmaydi — tugma bosilganda "
                "foydalanuvchi hech qayerga o'tmaydi."
            )

        if errors:
            raise ValidationError(errors)

    # ── Mantiq ──────────────────────────────────────────────────────
    def notes_lines(self) -> list[str]:
        """«Nima yangilandi» bandlari. Bo'sh bo'lsa — bo'sh ro'yxat."""
        return [line.strip() for line in self.notes.splitlines() if line.strip()]

    def status_for(self, current: Version) -> str:
        """
        Ilovadagi versiya uchun javob.

        Yoqilmagan yoki havolasiz qator — HECH NARSA ko'rsatilmaydi:
        yarim to'ldirilgan sozlama foydalanuvchini bosib bo'lmaydigan
        tugma bilan qoldirgandan ko'ra, jim turgani yaxshi.
        """
        if not self.is_active or not self.store_url:
            return UpdateStatus.UP_TO_DATE

        minimum = parse_version(self.min_version) if self.min_version else None
        if minimum is not None and current < minimum:
            return UpdateStatus.REQUIRED

        latest = parse_version(self.latest_version)
        if latest is not None and current < latest:
            return UpdateStatus.OPTIONAL

        return UpdateStatus.UP_TO_DATE
