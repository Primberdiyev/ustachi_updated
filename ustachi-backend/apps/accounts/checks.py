"""
PUSH TAYYORLIGI — Django tekshiruvi (`manage.py check`, har `runserver`da).

Nega kerak: push ataylab "yumshoq" qurilgan — kalit fayli bo'lmasa
`apps.accounts.services.push` JIMGINA hech narsa yubormaydi va HTTP so'rov
baribir muvaffaqiyatli tugaydi. Bu to'g'ri qaror (bildirishnoma asosiy
amalni yiqitmasligi kerak), lekin yon ta'siri yomon: server oylab push
yubormay turadi va buni HECH KIM sezmaydi — foydalanuvchi esa
"bildirishnoma kelmayapti" deydi.

Shu sabab nosozlik SERVER ISHGA TUSHGANDA ekranga chiqadi. Bu OGOHLANTIRISH
(`Warning`), xato emas: kalitsiz ham server to'liq ishlaydi.

O'chirish (ataylab push'siz muhit, masalan CI):
    SILENCED_SYSTEM_CHECKS = ["push.W001", "push.W002"]
yoki `.env` da `FCM_ENABLED=False` — u holda tekshiruv W002 bilan faqat
"ataylab o'chirilgan" deb eslatadi.
"""

import os

from django.conf import settings
from django.core.checks import Warning as CheckWarning
from django.core.checks import register


@register()
def check_push_ready(app_configs, **kwargs):
    """FCM yuborishga tayyormi — kalit fayli va sozlama."""
    if not getattr(settings, "FCM_ENABLED", True):
        return [
            CheckWarning(
                "FCM push O'CHIRILGAN (FCM_ENABLED=False).",
                hint="Telefon bildirishnomalari yuborilmaydi. Ataylab shunday "
                "bo'lsa e'tibor bermang.",
                id="push.W002",
            )
        ]

    path = str(getattr(settings, "FIREBASE_CREDENTIALS", "") or "")
    if path and os.path.exists(path):
        return []

    return [
        CheckWarning(
            "FCM push YUBORILMAYDI — Firebase xizmat akkaunti kaliti topilmadi.",
            hint=(
                f"Kutilgan yo'l: {path or '(berilmagan)'}\n"
                "1) Firebase Console → Project settings → Service accounts → "
                "Generate new private key;\n"
                "2) faylni shu yo'lga qo'ying (yoki .env da FIREBASE_CREDENTIALS "
                "ni ko'rsating);\n"
                "3) tekshirish: python scripts/check_push.py, so'ng "
                "python manage.py send_test_push --user <ID>.\n"
                "Ilova ichidagi bildirishnomalar va WebSocket bunga bog'liq emas "
                "— ular kalitsiz ham ishlaydi."
            ),
            id="push.W001",
        )
    ]
