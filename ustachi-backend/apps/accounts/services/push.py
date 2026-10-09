"""
FCM push — TELEFON EKRANIDAGI xabar (firebase-admin orqali).

Ikki xil "bildirishnoma" bor va ular ARALASHMAYDI:
  * in-app yozuv + WebSocket hodisasi — `apps.orders.realtime` (ilova ochiq
    bo'lganda darhol ko'rinadi);
  * FCM push — SHU MODUL (ilova YOPIQ bo'lsa ham telefonda chiqadi).

QOIDALAR:
  * Push — qulaylik, MAJBURIYAT EMAS. Firebase ishlamasa ham HTTP so'rov
    muvaffaqiyatli tugashi kerak, shuning uchun har xato yutiladi va
    faqat jurnalga yoziladi.
  * Yuborish FON OQIMIDA bajariladi. FCM har token uchun alohida HTTPS
    so'rov qiladi — 200 ustaga e'lon yuborishni so'rov ichida kutib tursak,
    mijoz javobni bir necha soniya kutardi.
  * Faqat FCM "bu token endi yo'q" degan aniq xatoda token o'chiriladi
    (`is_active=False`). Boshqa xatolar (tarmoq, noto'g'ri payload) tokenni
    aybdor qilmaydi — aks holda bitta payload xatosi HAMMA tokenni o'chirib
    yuborardi.

Sozlash (`.env`):
    FIREBASE_CREDENTIALS=/home/pc2/usta_top/secrets/firebase-admin.json
    FCM_ENABLED=True
"""

import logging
import os
import threading
from concurrent.futures import ThreadPoolExecutor

from django.conf import settings
from django.db import close_old_connections

logger = logging.getLogger(__name__)

# firebase-admin ilovasi nomi — Django ichida boshqa Firebase ilovasi bo'lsa
# to'qnashmasin (default nomdan atay foydalanmaymiz).
APP_NAME = "usta_top"

# FCM bitta multicast so'rovida ko'pi bilan shuncha token qabul qiladi.
MAX_TOKENS_PER_BATCH = 500

_lock = threading.Lock()
_app = None
_init_failed = False

# Kichik pool: push yuborish tarmoqqa bog'liq (CPU emas), 4 ta oqim yetadi.
_pool = ThreadPoolExecutor(max_workers=4, thread_name_prefix="fcm")


# ───────────────────────── Firebase ulanishi ─────────────────────────


def _get_app():
    """
    firebase-admin ilovasini BIR MARTA ishga tushiradi (lazy).

    Kalit fayli bo'lmasa — push JIMGINA o'chiriladi (lokal ishlash va
    testlar Firebase'siz ham davom etaveradi).
    """
    global _app, _init_failed

    if _app is not None or _init_failed:
        return _app

    with _lock:
        if _app is not None or _init_failed:
            return _app

        if not getattr(settings, "FCM_ENABLED", True):
            logger.info("FCM o'chirilgan (FCM_ENABLED=False).")
            _init_failed = True
            return None

        path = str(getattr(settings, "FIREBASE_CREDENTIALS", "") or "")
        if not path or not os.path.exists(path):
            logger.warning("FCM o'chirilgan: hisob kaliti topilmadi (%s).", path or "—")
            _init_failed = True
            return None

        try:
            import firebase_admin
            from firebase_admin import credentials

            try:
                _app = firebase_admin.get_app(APP_NAME)
            except ValueError:
                _app = firebase_admin.initialize_app(
                    credentials.Certificate(path), name=APP_NAME
                )
        except Exception as exc:  # pragma: no cover — noto'g'ri kalit/paket
            logger.error("FCM ishga tushmadi: %s", exc)
            _init_failed = True

    return _app


def reset_app_cache() -> None:
    """Testlar uchun: keyingi chaqiruvda Firebase qaytadan ulanadi."""
    global _app, _init_failed
    with _lock:
        _app = None
        _init_failed = False


# ───────────────────────── Yuborish ─────────────────────────


def send_to_user(
    user, title: str, body: str = "", data: dict | None = None, app: str = ""
) -> int:
    """Bitta foydalanuvchining faol qurilmalariga push (`app` bo'yicha)."""
    return send_to_users([user], title, body, data, app=app)


def send_to_users(
    users, title: str, body: str = "", data: dict | None = None, app: str = ""
) -> int:
    """
    Bir nechta foydalanuvchiga push. Qaytaradi: navbatga qo'yilgan token soni
    (yuborilgan emas — yuborish fon oqimida tugaydi).
    """
    from apps.accounts.models import DeviceToken
    from apps.accounts.models.device import app_filter

    user_ids = [u.pk if hasattr(u, "pk") else u for u in users]
    if not user_ids:
        return 0

    # Bu YERDA ham xato yutiladi: push — qulaylik, majburiyat emas.
    # 2026-08-05 da jadval sxemasi eskirib qolgani (`no such column:
    # device_name`) SHU so'rovda otilib, CHAT XABARINI yuborishni ham
    # buzgan edi — bildirishnoma yo'li asosiy amalni hech qachon
    # yiqitmasligi kerak.
    try:
        tokens = list(
            DeviceToken.objects.filter(
                app_filter(app), user_id__in=user_ids, is_active=True
            ).values_list("token", flat=True)
        )
    except Exception as exc:
        logger.warning("FCM: qurilma tokenlari o'qilmadi — %s", exc)
        return 0
    return send_to_tokens(tokens, title, body, data)


def send_to_tokens(
    tokens, title: str, body: str = "", data: dict | None = None
) -> int:
    """Tokenlar ro'yxatiga push (fon oqimida). Qaytaradi: token soni."""
    tokens = [t for t in dict.fromkeys(tokens) if t]  # takrorlarni olib tashlaymiz
    if not tokens:
        return 0
    if not getattr(settings, "FCM_ENABLED", True):
        return 0

    if getattr(settings, "FCM_BACKGROUND", True):
        _pool.submit(_send_guarded, tokens, title, body, data)
    else:
        _send_guarded(tokens, title, body, data)
    return len(tokens)


def _send_guarded(tokens, title, body, data) -> int:
    """Fon oqimidagi qobiq: xato HECH QACHON tashqariga chiqmaydi."""
    try:
        return send_now(tokens, title, body, data)
    except Exception as exc:  # pragma: no cover — kutilmagan xato
        logger.warning("FCM push yuborilmadi: %s", exc)
        return 0
    finally:
        # Fon oqimi o'z DB ulanishini ochgan bo'lishi mumkin — yopamiz.
        close_old_connections()


def send_now(tokens, title: str, body: str = "", data: dict | None = None) -> int:
    """
    SINXRON yuborish — natijani KUTADI. Testlar, management buyruqlari va
    admin "sinov push" uchun. Qaytaradi: qabul qilingan tokenlar soni.
    """
    from apps.accounts.models import DeviceToken

    app = _get_app()
    if app is None:
        return 0

    from firebase_admin import messaging

    # FCM `data` faqat STRING qabul qiladi (int yuborilsa xato beradi).
    payload = {k: str(v) for k, v in (data or {}).items() if v is not None}

    tokens = [t for t in dict.fromkeys(tokens) if t]
    sent = 0
    dead: list[str] = []

    for start in range(0, len(tokens), MAX_TOKENS_PER_BATCH):
        chunk = tokens[start : start + MAX_TOKENS_PER_BATCH]
        message = messaging.MulticastMessage(
            tokens=chunk,
            notification=messaging.Notification(title=title, body=body or None),
            data=payload,
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    sound="default",
                    # Flutter tomonda shu kanal yaratilishi kerak, aks holda
                    # Android 8+ da xabar ovozsiz/ko'rinmas bo'lib qoladi.
                    channel_id=getattr(settings, "FCM_ANDROID_CHANNEL", "usta_top"),
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(aps=messaging.Aps(sound="default"))
            ),
        )
        try:
            response = messaging.send_each_for_multicast(message, app=app)
        except Exception as exc:  # tarmoq/autentifikatsiya xatosi
            logger.warning("FCM so'rovi bajarilmadi: %s", exc)
            continue

        sent += response.success_count
        for token, result in zip(chunk, response.responses):
            if result.success:
                continue
            if _is_dead_token(result.exception):
                dead.append(token)
            else:
                logger.warning("FCM xatosi (%s...): %s", token[:12], result.exception)

    if dead:
        DeviceToken.objects.filter(token__in=dead).update(is_active=False)
        logger.info("FCM: %s ta yaroqsiz token o'chirildi.", len(dead))

    return sent


def _is_dead_token(exc) -> bool:
    """
    Token BOSHQA ishlatib bo'lmaydimi? (ilova o'chirilgan / token boshqa
    Firebase loyihasiniki). Faqat shu ikki xatoda token o'chiriladi —
    qolganlari vaqtinchalik yoki payload xatosi bo'lishi mumkin.
    """
    from firebase_admin import messaging

    return isinstance(
        exc, (messaging.UnregisteredError, messaging.SenderIdMismatchError)
    )
