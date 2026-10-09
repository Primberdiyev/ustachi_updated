"""
Yangi ochiq buyurtmalar ommaviy kanalga, yangi foydalanuvchilar esa admin
guruhining "Foydalanuvchilar" topigiga yuboriladi.

QOIDALAR (push bilan bir xil):
  * Bu — qulaylik, MAJBURIYAT EMAS. Telegram ishlamasa ham HTTP so'rov
    muvaffaqiyatli tugashi kerak: har xato yutiladi, faqat jurnalga yoziladi.
  * Yuborish FON OQIMIDA va tranzaksiya COMMIT bo'lgandan KEYIN — so'rov
    Telegram javobini kutmaydi, bekor bo'lgan yozuv haqida xabar ketmaydi.
  * Token yoki chat ID bo'sh bo'lsa — jimgina o'chadi (lokal/testlar).

Sozlash (`.env`):
    TELEGRAM_BOT_TOKEN=123456:ABC...
    TELEGRAM_CHAT_ID=-1001234567890
    TELEGRAM_USERS_TOPIC_ID=3
    TELEGRAM_ORDERS_CHANNEL_ID=@ustachi_buyurtmalar
"""

import html
import json
import logging
import re
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import requests
from django.conf import settings
from django.db import close_old_connections, transaction
from django.utils.text import slugify

logger = logging.getLogger(__name__)

API_URL = "https://api.telegram.org/bot{token}/sendMessage"
PHOTO_API_URL = "https://api.telegram.org/bot{token}/sendPhoto"
EDIT_MEDIA_API_URL = "https://api.telegram.org/bot{token}/editMessageMedia"
EDIT_CAPTION_API_URL = "https://api.telegram.org/bot{token}/editMessageCaption"
EDIT_TEXT_API_URL = "https://api.telegram.org/bot{token}/editMessageText"
ORDER_IMAGES_DIR = Path(__file__).resolve().parent / "telegram_images"

# Bitta oqim yetadi va xabarlar TARTIB bilan boradi.
_pool = ThreadPoolExecutor(max_workers=1, thread_name_prefix="telegram")


def _run_with_db_connection(func, *args):
    close_old_connections()
    try:
        return func(*args)
    finally:
        close_old_connections()


def _admin_chat_id():
    return getattr(settings, "TELEGRAM_CHAT_ID", "")


def _orders_channel_id():
    return getattr(settings, "TELEGRAM_ORDERS_CHANNEL_ID", "")


def _is_enabled(chat_id=None) -> bool:
    """`chat_id` berilmasa — admin guruhi tekshiriladi."""
    if chat_id is None:
        chat_id = _admin_chat_id()
    return bool(
        getattr(settings, "TELEGRAM_ENABLED", True)
        and getattr(settings, "TELEGRAM_BOT_TOKEN", "")
        and chat_id
    )


def send_now(text: str, topic_id: int | None = None, chat_id=None) -> bool:
    """Xabarni DARHOL yuboradi. Xato tashqariga chiqmaydi.

    `chat_id` berilmasa — admin guruhiga (TELEGRAM_CHAT_ID).
    """
    if chat_id is None:
        chat_id = _admin_chat_id()
    if not _is_enabled(chat_id):
        return False
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "HTML",
        "disable_web_page_preview": True,
    }
    if topic_id:
        payload["message_thread_id"] = topic_id
    try:
        response = requests.post(
            API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
            json=payload,
            timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
        )
        if not response.ok:
            logger.warning(
                "Telegram xabar yuborilmadi (%s): %s",
                response.status_code,
                response.text[:300],
            )
            return False
        return True
    except Exception as exc:
        logger.warning("Telegram xabar yuborilmadi: %s", exc)
        return False


def send(text: str, topic_id: int | None = None, chat_id=None) -> None:
    """Tranzaksiya commit bo'lgach, fon oqimida yuboradi."""
    if chat_id is None:
        chat_id = _admin_chat_id()
    if not _is_enabled(chat_id):
        return

    def _dispatch():
        if getattr(settings, "TELEGRAM_BACKGROUND", True):
            _pool.submit(send_now, text, topic_id, chat_id)
        else:
            send_now(text, topic_id, chat_id)

    transaction.on_commit(_dispatch)


def _order_image_path(specialty_code: str | None) -> Path | None:
    """Only use a bundled cover with a safe, exact specialty code."""
    if not specialty_code or not re.fullmatch(r"[a-z0-9_]+", specialty_code):
        return None
    path = ORDER_IMAGES_DIR / f"{specialty_code}.jpg"
    return path if path.is_file() else None


def send_order_now(
    text: str, specialty_code: str | None, chat_id, *, fallback_to_text: bool = True
) -> bool:
    """Send a category photo with the existing order copy as its caption."""
    if not _is_enabled(chat_id):
        return False
    image_path = _order_image_path(specialty_code)
    if image_path is None or len(text) > 1024:
        return send_now(text, chat_id=chat_id) if fallback_to_text else False

    try:
        with image_path.open("rb") as photo:
            response = requests.post(
                PHOTO_API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
                data={"chat_id": chat_id, "caption": text, "parse_mode": "HTML"},
                files={"photo": (image_path.name, photo, "image/jpeg")},
                timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
            )
        if response.ok:
            return True
        logger.warning(
            "Telegram rasmli buyurtma yuborilmadi (%s): %s",
            response.status_code,
            response.text[:300],
        )
        return send_now(text, chat_id=chat_id) if fallback_to_text else False
    except Exception as exc:
        # A timeout may occur after Telegram accepted the photo. Avoid a duplicate post.
        logger.warning("Telegram rasmli buyurtma holati noma'lum: %s", exc)
        return False


def _publish_order_now(order_id: int, chat_id) -> None:
    """Publish an order and remember the message so later changes can edit it."""
    from apps.orders.models import Order

    order = Order.objects.select_related("region", "district", "specialty").filter(pk=order_id).first()
    if not order or not order.is_public or order.telegram_message_id:
        return
    caption = _order_text(order)
    image_path = _order_image_path(order.specialty.code if order.specialty else None)
    is_photo = image_path is not None and len(caption) <= 1024
    try:
        if is_photo:
            with image_path.open("rb") as photo:
                response = requests.post(
                    PHOTO_API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
                    data={"chat_id": chat_id, "caption": caption, "parse_mode": "HTML"},
                    files={"photo": (image_path.name, photo, "image/jpeg")},
                    timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
                )
            if not response.ok:
                # Telegram rejected the photo; the text version can still be posted.
                is_photo = False
        if not is_photo:
            response = requests.post(
                API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
                json={"chat_id": chat_id, "text": caption, "parse_mode": "HTML", "disable_web_page_preview": True},
                timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
            )
        if not response.ok:
            logger.warning("Telegram order #%s not published (%s): %s", order_id, response.status_code, response.text[:300])
            return
        message_id = response.json().get("result", {}).get("message_id")
        if isinstance(message_id, int):
            Order.objects.filter(pk=order_id).update(
                telegram_message_id=message_id, telegram_post_is_photo=is_photo
            )
            _refresh_order_post_now(order_id, chat_id, published_text=caption)
        else:
            logger.warning("Telegram order #%s published without a message ID", order_id)
    except Exception as exc:
        # A timeout may happen after Telegram accepted the post. Do not retry blindly.
        logger.warning("Telegram order #%s publication state unknown: %s", order_id, exc)


def send_order(text: str, specialty_code: str | None, chat_id, *, order_id: int | None = None) -> None:
    """Publish after commit and off the HTTP request thread."""
    if not _is_enabled(chat_id):
        return

    def _dispatch():
        task = (lambda: _publish_order_now(order_id, chat_id)) if order_id else (
            lambda: send_order_now(text, specialty_code, chat_id)
        )
        if getattr(settings, "TELEGRAM_BACKGROUND", True):
            _pool.submit(_run_with_db_connection, task)
        else:
            task()

    transaction.on_commit(_dispatch)


def edit_order_post_now(order, message_id: int, chat_id) -> bool:
    """Replace one existing channel text post with its specialty photo."""
    if not _is_enabled(chat_id) or not order.is_public:
        return False
    image_path = _order_image_path(order.specialty.code if order.specialty else None)
    caption = _order_text(order)
    if image_path is None or len(caption) > 1024:
        return False
    media = {"type": "photo", "media": "attach://photo", "caption": caption, "parse_mode": "HTML"}
    try:
        with image_path.open("rb") as photo:
            response = requests.post(
                EDIT_MEDIA_API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
                data={"chat_id": chat_id, "message_id": message_id, "media": json.dumps(media)},
                files={"photo": (image_path.name, photo, "image/jpeg")},
                timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
            )
        if response.ok:
            return True
        logger.warning("Telegram post #%s tahrirlanmadi (%s): %s", message_id, response.status_code, response.text[:300])
    except Exception as exc:
        logger.warning("Telegram post #%s tahrirlanmadi: %s", message_id, exc)
    return False


def edit_order_caption_now(order, message_id: int, chat_id) -> bool:
    """Refresh a photo post's caption without uploading its image again."""
    if not _is_enabled(chat_id) or not order.is_public:
        return False
    caption = _order_text(order)
    if len(caption) > 1024:
        return False
    try:
        payload = {
            "chat_id": chat_id,
            "message_id": message_id,
            "caption": caption,
            "parse_mode": "HTML",
        }
        response = _edit_with_rate_limit_retry(
            EDIT_CAPTION_API_URL.format(token=settings.TELEGRAM_BOT_TOKEN), payload
        )
        if response.ok:
            return True
        if response.status_code == 400 and "message is not modified" in response.text.lower():
            return True
        logger.warning(
            "Telegram post #%s caption yangilanmadi (%s): %s",
            message_id,
            response.status_code,
            response.text[:300],
        )
    except Exception as exc:
        logger.warning("Telegram post #%s caption yangilanmadi: %s", message_id, exc)
    return False


def edit_order_text_now(order, message_id: int, chat_id) -> bool:
    """Refresh an order post that was published without a photo."""
    if not _is_enabled(chat_id) or not order.is_public:
        return False
    try:
        response = _edit_with_rate_limit_retry(
            EDIT_TEXT_API_URL.format(token=settings.TELEGRAM_BOT_TOKEN),
            {
                "chat_id": chat_id, "message_id": message_id,
                "text": _order_text(order), "parse_mode": "HTML", "disable_web_page_preview": True,
            },
        )
        if response.ok or (response.status_code == 400 and "message is not modified" in response.text.lower()):
            return True
        logger.warning("Telegram order text #%s not updated (%s): %s", message_id, response.status_code, response.text[:300])
    except Exception as exc:
        logger.warning("Telegram order text #%s not updated: %s", message_id, exc)
    return False


def _edit_with_rate_limit_retry(url: str, payload: dict):
    """Respect Telegram's retry_after once for bursts of channel edits."""
    for attempt in range(2):
        response = requests.post(
            url, json=payload, timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10)
        )
        if response.status_code != 429 or attempt:
            return response
        try:
            wait_seconds = int(response.json().get("parameters", {}).get("retry_after", 0))
        except (TypeError, ValueError):
            wait_seconds = 0
        if not 1 <= wait_seconds <= 60:
            return response
        time.sleep(wait_seconds + 1)


def _refresh_order_post_now(order_id: int, chat_id, *, published_text: str | None = None) -> None:
    from apps.orders.models import Order

    order = Order.objects.select_related("region", "district", "specialty").filter(pk=order_id).first()
    if not order or not order.is_public or not order.telegram_message_id:
        return
    caption = _order_text(order)
    if caption == published_text:
        return
    if order.telegram_post_is_photo and len(caption) > 1024:
        logger.warning("Telegram order #%s caption exceeds 1024 characters", order_id)
        return
    if order.telegram_post_is_photo:
        edit_order_caption_now(order, order.telegram_message_id, chat_id)
        return
    edit_order_text_now(order, order.telegram_message_id, chat_id)


def refresh_order_post(order_id: int) -> None:
    """Queue a fresh edit after the business transaction commits."""
    channel = _orders_channel_id()
    if not _is_enabled(channel):
        return

    def _dispatch():
        if getattr(settings, "TELEGRAM_BACKGROUND", True):
            _pool.submit(_run_with_db_connection, _refresh_order_post_now, order_id, channel)
        else:
            _refresh_order_post_now(order_id, channel)

    transaction.on_commit(_dispatch)


# ───────────────────────── Hodisa xabarlari ─────────────────────────


def _e(value) -> str:
    return html.escape(str(value)) if value not in (None, "") else "—"


def _money(value) -> str:
    return f"{int(value or 0):,}".replace(",", " ") + " so'm"


def _location(obj) -> str:
    parts = [str(p) for p in (obj.region, obj.district) if p]
    if obj.address:
        parts.append(obj.address)
    return ", ".join(parts)


def _order_app_link(order) -> str:
    base_url = getattr(settings, "APP_LINK_BASE_URL", "https://ustachi.uz")
    return f"{base_url.rstrip('/')}/app/order/{order.pk}/"


def _order_text(order) -> str:
    """Ommaviy kanal kartasi: mijoz va aniq manzil ma'lumotlari yo'q."""
    kind = "🔧 Ta’mir ishi" if order.is_repair else "🆕 Yangi buyurtma"
    region_name = re.sub(r"\s+viloyati$", "", str(order.region), flags=re.IGNORECASE) if order.region else ""
    location = ", ".join(str(p) for p in (region_name, order.district) if p)
    lines = [
        kind,
        f"<b>#{_e(order.pk)} · {_e(order.title)}</b>",
        "",
        f"🛠 Yo‘nalish: {_e(order.specialty.name if order.specialty else None)}",
        f"📍 Hudud: {_e(location)}",
    ]
    region_tag = slugify(region_name).replace("-", "_")
    specialty_tag = slugify(order.specialty.code).replace("-", "_") if order.specialty else ""
    tags = [f"#{tag}" for tag in (region_tag, specialty_tag) if tag]
    lines.extend([
        f"📋 Holat: {_e(order.get_status_display())}",
        f"📨 Takliflar soni: {order.responses.exclude(status='withdrawn').count()}",
    ])
    if order.calculated_price > 0:
        lines.append(f"💰 Mijoz hisobi: {_money(order.calculated_price)}")
    elif order.is_repair:
        lines.append("💬 Narx usta bilan kelishiladi")
    links = [f'🔗 <a href="{_e(_order_app_link(order))}">Buyurtma</a>']
    app_url = getattr(settings, "MASTER_APP_STORE_URL", "")
    if app_url:
        links.append(f'📲 <a href="{_e(app_url)}">Ilova</a>')
    channel_url = getattr(settings, "TELEGRAM_ORDERS_CHANNEL_URL", "")
    if channel_url:
        links.append(f'📢 <a href="{_e(channel_url)}">Kanal</a>')
    lines += ["", " | ".join(links)]
    if tags:
        lines += ["", " ".join(tags)]
    return "\n".join(lines)


def notify_new_order(order) -> None:
    """Faqat hammaga ochiq buyurtmani kanalga yuboradi."""
    channel = _orders_channel_id()
    if order.is_public and _is_enabled(channel):
        # Bitta ustaga biriktirilgan hudud e'loni kanalga chiqmaydi
        # (`orders/visibility.py`, 8-qoida).
        from apps.orders import visibility

        if visibility.territory_owner_id(order) is not None:
            return
        specialty_code = order.specialty.code if order.specialty else None
        send_order(_order_text(order), specialty_code, channel, order_id=order.pk)


def notify_new_user(user) -> None:
    """Yangi foydalanuvchi → "Foydalanuvchilar" topigi."""
    if not _is_enabled():
        return
    role = "Usta" if user.is_master else "Mijoz"
    lines = [
        f"<b>👤 Yangi foydalanuvchi #{user.pk}</b>",
        "",
        f"📱 Telefon: {_e(user.phone_number)}",
        f"🏷 Rol: {role}",
    ]
    if user.full_name:
        lines.append(f"Ism: {_e(user.full_name)}")
    location = _location(user)
    if location:
        lines.append(f"📍 Manzil: {_e(location)}")
    send("\n".join(lines), getattr(settings, "TELEGRAM_USERS_TOPIC_ID", None))
