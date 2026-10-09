"""Telegram client login through own-contact verification and one-time grants."""
import logging
import re
import secrets
from datetime import timedelta

import requests
from django.conf import settings
from django.db import transaction
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import (
    TelegramAuthFlow, TelegramAuthGrant, User,
)
from apps.common import telegram

logger = logging.getLogger(__name__)
FLOW_TTL = timedelta(minutes=10)
GRANT_TTL = timedelta(minutes=5)
MAX_STARTS_PER_FLOW = 5
MAX_GRANTS_PER_WINDOW = 3


def _bot_call(method, payload):
    token = getattr(settings, "TELEGRAM_AUTH_BOT_TOKEN", "")
    if not token:
        return False
    try:
        response = requests.post(
            f"https://api.telegram.org/bot{token}/{method}",
            json=payload,
            timeout=getattr(settings, "TELEGRAM_TIMEOUT", 10),
        )
        if not response.ok:
            logger.warning("Telegram auth bot %s failed: HTTP %s", method, response.status_code)
        return response.ok
    except requests.RequestException:
        logger.exception("Telegram auth bot request failed")
        return False


def _say(chat_id, text, reply_markup=None):
    payload = {"chat_id": chat_id, "text": text}
    if reply_markup:
        payload["reply_markup"] = reply_markup
    _bot_call("sendMessage", payload)


def _normalize_phone(raw):
    digits = re.sub(r"\D", "", raw or "")
    if len(digits) == 9:
        digits = "998" + digits
    return "+" + digits if len(digits) == 12 and digits.startswith("998") else None


def _start(chat_id, telegram_user_id, grants_master):
    now = timezone.now()
    with transaction.atomic():
        flow = TelegramAuthFlow.objects.select_for_update().filter(
            telegram_user_id=telegram_user_id,
        ).first()
        if flow and flow.expires_at > now and flow.attempts >= MAX_STARTS_PER_FLOW:
            limited = True
        else:
            limited = False
            if flow is None:
                TelegramAuthFlow.objects.create(
                    telegram_user_id=telegram_user_id, chat_id=chat_id,
                    step="phone", attempts=1, expires_at=now + FLOW_TTL,
                    grants_master=grants_master,
                )
            else:
                if flow.expires_at <= now:
                    flow.attempts = 0
                    flow.expires_at = now + FLOW_TTL
                flow.chat_id = chat_id
                flow.phone_number = ""
                flow.step = "phone"
                flow.attempts += 1
                flow.grants_master = grants_master
                flow.save()
    if limited:
        _say(chat_id, "Juda ko‘p urinish. 10 daqiqadan keyin qayta urinib ko‘ring.")
        return
    app_name = "Ustachi Pro (usta)" if grants_master else "Ustachi mijoz"
    _say(
        chat_id,
        f"{app_name} ilovasida ro‘yxatdan o‘tishni boshlaymiz. "
        "Raqamingizni ulashish uchun pastdagi tugmani bosing. Raqamingiz "
        "faqat akkauntni tasdiqlash uchun ishlatiladi.",
        {"keyboard": [[{"text": "📱 Telefon raqamimni yuborish", "request_contact": True}]],
         "resize_keyboard": True, "one_time_keyboard": True},
    )


def _ask_which_app(chat_id):
    # Deep-link parametri Telegram tomonidan yetkazilmagan (masalan, bot bilan
    # avvaldan suhbat bo'lgan qaytgan foydalanuvchi) — taxmin qilish o'rniga
    # ANIQ so'raymiz, aks holda oldingi ilova tanlovi noto'g'ri qo'llanishi
    # mumkin (mijoz uchun sinalgan foydalanuvchi usta ilovasida ham mijoz
    # sifatida ochilib qolgan xato shu yerdan kelib chiqqan edi).
    _say(
        chat_id,
        "Qaysi ilova uchun ro'yxatdan o'tmoqchisiz?",
        {"inline_keyboard": [
            [{"text": "Ustachi (mijoz)", "callback_data": "auth_app:client"}],
            [{"text": "Ustachi Pro (usta)", "callback_data": "auth_app:master"}],
        ]},
    )


def _handle_callback(callback_query):
    callback_id = callback_query.get("id")
    if callback_id:
        _bot_call("answerCallbackQuery", {"callback_query_id": callback_id})
    data = callback_query.get("data") or ""
    message = callback_query.get("message") or {}
    chat = message.get("chat") or {}
    chat_id = chat.get("id")
    sender = callback_query.get("from") or {}
    telegram_user_id = sender.get("id")
    if not chat_id or not telegram_user_id or chat.get("type") != "private" or chat_id != telegram_user_id:
        return
    if data == "auth_app:client":
        _start(chat_id, telegram_user_id, False)
    elif data == "auth_app:master":
        _start(chat_id, telegram_user_id, True)


def _handle_update(update):
    if "callback_query" in update:
        _handle_callback(update["callback_query"])
        return
    message = update.get("message") or {}
    sender = message.get("from") or {}
    chat_id = (message.get("chat") or {}).get("id")
    telegram_user_id = sender.get("id")
    if not chat_id or not telegram_user_id:
        return
    if (message.get("chat") or {}).get("type") != "private":
        return
    if chat_id != telegram_user_id:
        return
    text = (message.get("text") or "").strip()
    if text.startswith("/start") or text == "/restart":
        payload = text[len("/start"):].strip() if text.startswith("/start") else ""
        if payload:
            _start(chat_id, telegram_user_id, payload == "master_register")
        else:
            _ask_which_app(chat_id)
        return

    contact = message.get("contact")
    if contact:
        if contact.get("user_id") != telegram_user_id:
            _say(chat_id, "Iltimos, o‘zingizning telefon raqamingizni yuboring.")
            return
        phone = _normalize_phone(contact.get("phone_number"))
        if not phone:
            _say(chat_id, "O‘zbekiston telefon raqamini yuboring (+998 ...). /start ni bosing.")
            return
        denied = None
        code = None
        with transaction.atomic():
            flow = TelegramAuthFlow.objects.select_for_update().filter(
                telegram_user_id=telegram_user_id, chat_id=chat_id,
                step="phone", expires_at__gt=timezone.now(),
            ).first()
            if flow:
                user = User.objects.select_for_update().filter(phone_number=phone).first()
                is_new_user = user is None
                if user and (user.is_staff or user.is_superuser):
                    denied = "Bu akkaunt uchun Telegram orqali kirish mavjud emas. Ilovadagi SMS orqali kiring."
                elif user and user.telegram_auth_user_id not in (None, telegram_user_id):
                    denied = "Bu raqam boshqa Telegram akkauntiga biriktirilgan. Ilovadagi SMS orqali kiring."
                elif User.objects.filter(telegram_auth_user_id=telegram_user_id).exclude(phone_number=phone).exists():
                    denied = "Bu Telegram akkaunti boshqa raqamga biriktirilgan. Yordam xizmatiga murojaat qiling."
                elif user and TelegramAuthGrant.objects.filter(
                    user=user, expires_at__gte=timezone.now() - (FLOW_TTL - GRANT_TTL),
                ).count() >= MAX_GRANTS_PER_WINDOW:
                    denied = "Juda ko‘p urinish. 10 daqiqadan keyin qayta urinib ko‘ring."
                else:
                    if is_new_user:
                        user = User.objects.create_user(
                            phone_number=phone, password=None, is_active=True,
                            is_master=flow.grants_master, telegram_auth_user_id=telegram_user_id,
                        )
                        transaction.on_commit(lambda: telegram.notify_new_user(user))
                    else:
                        updated = []
                        if not user.is_active:
                            user.is_active = True
                            updated.append("is_active")
                        if user.telegram_auth_user_id is None:
                            user.telegram_auth_user_id = telegram_user_id
                            updated.append("telegram_auth_user_id")
                        if flow.grants_master and not user.is_master:
                            user.is_master = True  # usta roli QO'SHILADI (mijozlik saqlanadi)
                            updated.append("is_master")
                        if updated:
                            user.save(update_fields=updated)
                    code = secrets.token_urlsafe(32)
                    TelegramAuthGrant.objects.create(
                        user=user, digest=TelegramAuthGrant.digest_for(code),
                        is_new_user=is_new_user, expires_at=timezone.now() + GRANT_TTL,
                    )
                    flow.step = "done"
                    flow.save(update_fields=["step", "updated_at"])
        if denied:
            _say(chat_id, denied, {"remove_keyboard": True})
            return
        if code is None:
            _say(chat_id, "Sessiya tugadi. Ro‘yxatdan o‘tishni boshlash uchun /start ni bosing.")
            return
        base = getattr(settings, "APP_LINK_BASE_URL", "https://ustachi.uz").rstrip("/")
        path = "app/auth/master-telegram" if flow.grants_master else "app/auth/telegram"
        store_url = settings.MASTER_APP_STORE_URL if flow.grants_master else settings.CLIENT_APP_STORE_URL
        _say(chat_id, "Telefon raqamingiz Telegram orqali tasdiqlandi. Ilovada profilingizni yakunlang.", {
            "inline_keyboard": [
                [{"text": "Ustachi ilovasini ochish", "url": f"{base}/{path}/{code}/"}],
                [{"text": "Ilova o‘rnatilmaganmi? Play Market", "url": store_url}],
            ],
        })
        return

    _say(chat_id, "Ro‘yxatdan o‘tishni boshlash uchun /start ni bosing.")


class TelegramAuthWebhookView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        secret = getattr(settings, "TELEGRAM_AUTH_WEBHOOK_SECRET", "")
        if not secret or request.headers.get("X-Telegram-Bot-Api-Secret-Token") != secret:
            return Response(status=status.HTTP_403_FORBIDDEN)
        try:
            _handle_update(request.data)
        except Exception:
            logger.exception("Telegram auth update failed")
            return Response({"ok": False}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"ok": True})


class TelegramAuthExchangeView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        code = request.data.get("code", "")
        if not isinstance(code, str) or len(code) > 100:
            return Response({"error": "Noto‘g‘ri kod."}, status=status.HTTP_400_BAD_REQUEST)
        with transaction.atomic():
            grant = TelegramAuthGrant.objects.select_for_update().filter(
                digest=TelegramAuthGrant.digest_for(code), consumed_at__isnull=True,
                expires_at__gt=timezone.now(),
            ).select_related("user").first()
            if not grant:
                return Response(
                    {"error": "Havola eskirgan yoki ishlatilgan. Botda /start ni bosing."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if not grant.user.is_active or grant.user.is_staff or grant.user.is_superuser:
                return Response(
                    {"error": "Bu akkaunt uchun Telegram orqali kirish mavjud emas."},
                    status=status.HTTP_403_FORBIDDEN,
                )
            grant.consumed_at = timezone.now()
            grant.save(update_fields=["consumed_at"])
            refresh = RefreshToken.for_user(grant.user)
            return Response({
                "access": str(refresh.access_token), "refresh": str(refresh),
                "roles": grant.user.roles, "is_master": grant.user.is_master,
                "is_admin": grant.user.is_superuser, "is_new_user": grant.is_new_user,
            })
