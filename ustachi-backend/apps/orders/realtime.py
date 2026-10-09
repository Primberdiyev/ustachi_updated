"""
REAL-TIME (WebSocket) yuborish — bitta yo'l.

Server hodisani MIJOZ/USTAga darhol turtadi (push); ilova davriy so'rov
qilmaydi. Hodisa YENGIL: faqat "nima o'zgardi" (topic + id) beriladi, ilova
esa o'sha resursni REST orqali qayta o'qiydi. Shu sabab serializerlar
takrorlanmaydi va WebSocket uzilib qolsa ham ma'lumot to'g'ri qoladi.

Yo'l: `push()` → kanal qatlami (Redis) → `EventsConsumer.app_event()` →
telefondagi ochiq WebSocket.

Kanal qatlami sozlanmagan bo'lsa (mas. eski deploy) — JIMGINA o'tkazib
yuboriladi, ya'ni REST oqim baribir ishlayveradi.
"""

import logging

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)


APPS = ("client", "master")


def user_group(user_id: int, app: str = "") -> str:
    """Ilova bo'yicha kanal; bo'sh app — eski, umumiy kanal."""
    return f"user_{user_id}_{app}" if app else f"user_{user_id}"


def push(user_id: int, payload: dict, app: str = "") -> bool:
    """
    Foydalanuvchiga hodisa yuboradi.

    Xato yuz bersa ilova ISHLASHDAN TO'XTAMASLIGI kerak — real-time bu
    qulaylik, majburiyat emas: xato log'ga yoziladi va `False` qaytadi.

    `"type": "app.event"` — Channels shu nom bo'yicha consumer'dagi
    `app_event()` metodini topadi.
    """
    channel_layer = get_channel_layer()
    if channel_layer is None:
        return False

    groups = [user_group(user_id)]
    groups.extend(user_group(user_id, target) for target in ((app,) if app else APPS))
    message = {"type": "app.event", "payload": payload}
    try:
        for group in groups:
            async_to_sync(channel_layer.group_send)(group, message)
        return True
    except Exception as exc:  # pragma: no cover — infratuzilma xatosi
        # `%r` — `TimeoutError()` ning matni bo'sh, `%s` bilan log quruq qolardi.
        logger.warning("real-time push yuborilmadi: %r", exc)
        return False
