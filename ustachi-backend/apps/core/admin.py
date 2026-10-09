from django.contrib import admin
from rest_framework_simplejwt.token_blacklist.models import (
    BlacklistedToken,
    OutstandingToken,
)
from unfold.admin import ModelAdmin
from unfold.contrib.filters.admin import ChoicesDropdownFilter
from unfold.decorators import display

from apps.core.models import AppRelease

# SimpleJWT o'z modellarini admin'ga O'ZI qo'shadi ("Token blacklist" bo'limi).
# Ular xizmat jadvallari — qo'lda tahrirlanmaydi, faqat menyuni to'ldiradi.
# `apps.core` INSTALLED_APPS da `token_blacklist` dan KEYIN turadi, shuning
# uchun bu yerda ular allaqachon ro'yxatdan o'tgan bo'ladi.
for _service_model in (BlacklistedToken, OutstandingToken):
    if admin.site.is_registered(_service_model):
        admin.site.unregister(_service_model)


@admin.register(AppRelease)
class AppReleaseAdmin(ModelAdmin):
    """
    «Yangi versiya chiqdi» oynasini SHU YERDAN boshqariladi.

    Har chiqarishda kodga tegilmaydi: `latest_version` yangilanadi, kerak
    bo'lsa `min_version` ko'tariladi — qolgani o'z-o'zidan ishlaydi.
    """

    list_display = ("app_label", "platform_label", "latest_version", "min_label", "state")
    list_filter = (
        ("app", ChoicesDropdownFilter),
        ("platform", ChoicesDropdownFilter),
        "is_active",
    )
    # Ikkala kalit ham qator YARATILGANDAN keyin o'zgarmaydi: har (ilova,
    # platforma) juftligiga bittadan qator bo'ladi va ular migratsiyada
    # allaqachon yaratilgan.
    readonly_fields = ("updated_at",)
    fieldsets = (
        (
            "Qaysi ilova",
            {"fields": ("app", "platform", "is_active")},
        ),
        (
            "Versiyalar",
            {
                "fields": ("latest_version", "min_version"),
                "description": (
                    "«Oxirgi versiya» — yangilashni TAKLIF qiladi (foydalanuvchi "
                    "«Keyinroq» deya oladi).<br>"
                    "«Eng past versiya» — yangilashga MAJBUR qiladi, oyna "
                    "yopilmaydi. Bo'sh qoldirilsa majburiy rejim ishlamaydi."
                ),
            },
        ),
        (
            "Yangilash havolasi",
            {
                "fields": ("store_url",),
                "description": "«Yangilash» tugmasi aynan shu manzilni ochadi.",
            },
        ),
        (
            "Nima yangilandi",
            {
                "fields": ("notes",),
                "description": (
                    "Har bir yangilik — alohida qator. "
                    "<b>Bo'sh qoldirish mumkin</b>: ilova o'zining umumiy "
                    "matnini ko'rsatadi."
                ),
            },
        ),
        ("Xizmat", {"fields": ("updated_at",)}),
    )

    @display(description="Ilova", header=True)
    def app_label(self, obj: AppRelease) -> list[str]:
        return [obj.get_app_display(), obj.get_platform_display()]

    @display(description="Platforma")
    def platform_label(self, obj: AppRelease) -> str:
        return obj.get_platform_display()

    @display(description="Majburiy chegara")
    def min_label(self, obj: AppRelease) -> str:
        return obj.min_version or "— (o'chiq)"

    @display(
        description="Holat",
        label={"Yoqilgan": "success", "O'chiq": "danger", "Havolasiz": "warning"},
    )
    def state(self, obj: AppRelease) -> str:
        if not obj.is_active:
            return "O'chiq"
        if not obj.store_url:
            return "Havolasiz"
        return "Yoqilgan"
