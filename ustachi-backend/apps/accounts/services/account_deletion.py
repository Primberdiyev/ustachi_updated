"""
Akkauntni o'chirish — FAQAT OTP tasdiqlangandan KEYIN chaqiriladi.

Bu yerda tekshiruv YO'Q: chaqiruvchi (web sahifa yoki boshqa oqim) kodni
allaqachon tekshirgan bo'lishi shart. Servis faqat o'chirish ishini bajaradi.
"""

import logging

from django.db import transaction

from apps.accounts.models import DeviceToken, PhoneOTP

logger = logging.getLogger(__name__)


@transaction.atomic
def delete_user_account(user) -> dict:
    """
    Foydalanuvchini va unga bog'liq ma'lumotlarni butunlay o'chiradi.

    Django CASCADE orqali birga ketadi: usta profili va ish namunalari,
    mijozning e'lonlari, javoblar, chat xabarlari, bildirishnomalar, JWT
    refresh tokenlari. Ustaga BIRIKTIRILGAN buyurtmalar o'chmaydi — ularda
    `assigned_master` SET_NULL bo'lgani uchun mijozning tarixi saqlanadi.

    Telefon raqami ham o'chadi, ya'ni o'sha raqam bilan keyinchalik YANGI
    (bo'sh) akkaunt ochish mumkin — eski ma'lumotlar qaytmaydi.
    """
    phone_number = user.phone_number
    user_id = user.pk

    # Push tokenlari: CASCADE baribir o'chiradi, lekin aniq bo'lsin —
    # o'chirilgan akkauntga bildirishnoma ketib qolmasligi kerak.
    DeviceToken.objects.filter(user=user).delete()

    # Shu raqamga tegishli ishlatilmagan kodlar ham keraksiz bo'lib qoladi.
    if phone_number:
        PhoneOTP.objects.filter(phone_number=phone_number).delete()

    user.delete()

    logger.info("Akkaunt o'chirildi: id=%s, phone=%s", user_id, phone_number)
    return {"user_id": user_id, "phone_number": phone_number}
