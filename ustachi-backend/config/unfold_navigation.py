"""
Unfold admin panelining yon menyusi (sidebar) va muhit belgisi.

Nima uchun alohida modul: `settings.py` app registry tayyor bo'lmasdan
o'qiladi — u yerda `reverse()` ham, modellarga murojaat ham qilib bo'lmaydi.
Unfold `SIDEBAR["navigation"]` qiymatini import yo'li sifatida qabul qiladi va
HAR SO'ROVDA chaqiradi, shuning uchun bu yerda hammasi mumkin.
"""

from django.conf import settings
from django.http import HttpRequest
from django.urls import reverse_lazy


def _model_item(
    model: str,
    icon: str,
    title: str | None = None,
) -> dict:
    """
    Menyu bandi — model changelist'iga havola.

    `model` — "app_label.modelname" (kichik harflarda). Ruxsat tekshiruvi
    `view_<model>` bo'yicha: huquqi yo'q xodimga band KO'RINMAYDI (havolani
    bosgach 403 olishdan ko'ra yaxshiroq).
    """
    app_label, model_name = model.split(".")

    return {
        "title": title or _verbose_name_plural(app_label, model_name),
        "icon": icon,
        "link": reverse_lazy(f"admin:{app_label}_{model_name}_changelist"),
        "permission": lambda request, perm=f"{app_label}.view_{model_name}": (
            request.user.has_perm(perm)
        ),
    }


def _verbose_name_plural(app_label: str, model_name: str) -> str:
    """Model Meta'sidagi o'zbekcha nom — menyuda takrorlab yozmaslik uchun."""
    from django.apps import apps

    return apps.get_model(app_label, model_name)._meta.verbose_name_plural.capitalize()



def sidebar_navigation(request: HttpRequest) -> list[dict]:
    """Yon menyu. Guruhlar domen bo'yicha: odamlar → buyurtmalar → hududlar."""
    return [
        {
            "title": "Boshqaruv",
            "items": [
                {
                    "title": "Bosh sahifa",
                    "icon": "dashboard",
                    "link": reverse_lazy("admin:index"),
                },
                _model_item("core.apprelease", "system_update"),
            ],
        },
        {
            "title": "Foydalanuvchilar",
            "separator": True,
            "items": [
                _model_item("accounts.user", "person"),
                _model_item("accounts.masterprofile", "engineering"),
                _model_item("accounts.masterspecialty", "category"),
                _model_item("auth.group", "shield_person", title="Guruhlar"),
            ],
        },
        {
            "title": "Buyurtmalar",
            "separator": True,
            "items": [
                _model_item("orders.order", "receipt_long"),
                _model_item("orders.masterorder", "construction"),
                _model_item("orders.review", "star"),
                _model_item("orders.exclusiveterritory", "pin_drop"),
            ],
        },
        {
            "title": "Hududlar",
            "separator": True,
            "items": [
                _model_item("locations.region", "map"),
                _model_item("locations.city", "location_city"),
            ],
        },
    ]


def environment_callback(request: HttpRequest) -> list[str]:
    """
    Sarlavhadagi muhit yorlig'i: [matn, rang].

    Production'da ko'rinmaydi — faqat DEBUG rejimida ogohlantiradi, shunda
    "qaysi bazaga ulanib turibman?" degan savol tug'ilmaydi.
    """
    if settings.DEBUG:
        return ["Ishlab chiqish (DEBUG)", "warning"]
    return []
