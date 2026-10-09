"""
PUSH TAYYORLIGI — bir joyda uchta shart.

Push jimgina o'chib qolishi mumkin: kalit fayli bo'lmasa, `FCM_ENABLED`
o'chirilgan bo'lsa yoki qurilma jadvali sxemasi eskirgan bo'lsa. Uchalasi
ham xato bermay, shunchaki "yubormaydi" — shuning uchun ularni KO'Z bilan
ko'rish kerak.

Ishlatish (serverda):  env/bin/python scripts/check_push.py
"""

import os
import sys

import django

# Skript `scripts/` ichida — loyiha ildizi import yo'liga qo'shiladi, aks
# holda `config.settings` topilmaydi (qaysi katalogdan chaqirilishidan
# qat'i nazar ishlasin).
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.conf import settings  # noqa: E402
from django.db import connection  # noqa: E402


def line(label: str, value) -> None:
    print(f"  {label:<22} {value}")


def main() -> int:
    problems = []

    print("\n> Firebase kaliti")
    path = getattr(settings, "FIREBASE_CREDENTIALS", "") or ""
    exists = bool(path) and os.path.exists(path)
    line("yo'l", path or "(berilmagan)")
    line("fayl mavjud", "HA" if exists else "YO'Q")
    if not exists:
        problems.append(
            "Firebase kaliti topilmadi. Konsoldan service-account JSON olib, "
            f"'{path}' ga qo'ying yoki .env da FIREBASE_CREDENTIALS ni ko'rsating."
        )

    print("\n> Sozlama")
    enabled = getattr(settings, "FCM_ENABLED", True)
    line("FCM_ENABLED", enabled)
    if not enabled:
        problems.append("FCM_ENABLED=False — push ataylab o'chirilgan.")

    print("\n> Qurilma jadvali")
    try:
        with connection.cursor() as cursor:
            cols = [
                c.name
                for c in connection.introspection.get_table_description(
                    cursor, "accounts_devicetoken"
                )
            ]
        line("ustunlar", ", ".join(cols))
        if "device_name" not in cols:
            problems.append(
                "Jadval eskirgan (device_name yo'q) — `manage.py migrate` kerak."
            )
    except Exception as exc:
        line("xato", exc)
        problems.append("Qurilma jadvali o'qilmadi — migratsiya qilinmagan.")
        cols = []

    if cols:
        from apps.accounts.models import DeviceToken

        total = DeviceToken.objects.count()
        active = DeviceToken.objects.filter(is_active=True).count()
        line("tokenlar", f"{total} ta (faol: {active})")
        if total == 0:
            problems.append(
                "Hech qanday token yo'q — ilovalar hali ro'yxatdan o'tkazmagan "
                "(login qilingan qurilmada tekshiring)."
            )

    print("\n> Xulosa")
    if problems:
        for p in problems:
            print(f"  [!] {p}")
        return 1
    print("  [ok] Push yuborishga tayyor.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
