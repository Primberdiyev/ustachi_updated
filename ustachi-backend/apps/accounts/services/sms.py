import logging
import threading
from typing import Any, Callable

import requests
from django.conf import settings
from django.core.cache import cache
from django.db import connections

logger = logging.getLogger(__name__)

# Eskiz tokeni ~30 kun amal qiladi. Uni cache'da saqlaymiz: har bir process
# restart / Gunicorn worker qayta-qayta login qilmasligi uchun. TTL xavfsizlik
# uchun 30 kundan biroz kam olindi.
ESKIZ_TOKEN_CACHE_KEY = "eskiz:auth_token"
ESKIZ_TOKEN_CACHE_TTL = 60 * 60 * 24 * 25  # 25 kun (soniyada)

# Eskiz kabinetida tasdiqlangan shablon bilan AYNAN mos bo'lishi shart.
OTP_MESSAGE_TEMPLATE = "Ustachi ilovasidan ro‘yxatdan o‘tish uchun tasdiqlash kodi: {code}"


class EskizSMSService:
    BASE_URL = "https://notify.eskiz.uz/api"

    def __init__(self) -> None:
        self.email = getattr(settings, "ESKIZ_EMAIL", None)
        self.password = getattr(settings, "ESKIZ_PASSWORD", None)
        self.default_from = getattr(settings, "ESKIZ_FROM", "4546")
        self.timeout = int(getattr(settings, "ESKIZ_TIMEOUT", 15))

    @property
    def is_configured(self) -> bool:
        return bool(self.email and self.password)

    # --- Token (cache orqali; worker'lar o'rtasida umumiy, restartdan omon) ---
    @property
    def token(self) -> str | None:
        return cache.get(ESKIZ_TOKEN_CACHE_KEY)

    def _store_token(self, token: str) -> None:
        cache.set(ESKIZ_TOKEN_CACHE_KEY, token, ESKIZ_TOKEN_CACHE_TTL)

    def _clear_token(self) -> None:
        cache.delete(ESKIZ_TOKEN_CACHE_KEY)

    def _normalize_phone(self, phone_number: str) -> str:
        return phone_number.lstrip("+")

    def _auth_headers(self) -> dict[str, str]:
        headers = {"Accept": "application/json"}
        token = self.token
        if token:
            headers["Authorization"] = f"Bearer {token}"
        return headers

    def authenticate(self) -> str | None:
        if not self.is_configured:
            return None
        try:
            response = requests.post(
                f"{self.BASE_URL}/auth/login",
                data={"email": self.email, "password": self.password},
                timeout=self.timeout,
            )
            response.raise_for_status()
            token = response.json().get("data", {}).get("token")
            if token:
                self._store_token(token)
            return token
        except requests.RequestException:
            logger.exception("Eskiz authentication failed.")
            return None

    def refresh_token(self) -> str | None:
        if not self.token:
            return self.authenticate()
        try:
            response = requests.patch(
                f"{self.BASE_URL}/auth/refresh",
                headers=self._auth_headers(),
                timeout=self.timeout,
            )
            response.raise_for_status()
            token = response.json().get("data", {}).get("token")
            if token:
                self._store_token(token)
                return token
        except requests.RequestException:
            logger.exception("Eskiz token refresh failed.")
        return self.authenticate()

    def _request(
        self,
        method: str,
        endpoint: str,
        *,
        data: dict[str, Any] | None = None,
        retry_on_auth_error: bool = True,
    ) -> dict[str, Any] | None:
        if not self.token and not self.authenticate():
            return None

        url = f"{self.BASE_URL}{endpoint}"
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=self._auth_headers(),
                data=data,
                timeout=self.timeout,
            )
            if response.status_code in (401, 403) and retry_on_auth_error:
                # Cache'dagi token eskirgan — tozalab, qaytadan login qilamiz.
                self._clear_token()
                if self.authenticate():
                    return self._request(method, endpoint, data=data, retry_on_auth_error=False)
            response.raise_for_status()
            return response.json() if response.text else {}
        except requests.RequestException:
            logger.exception("Eskiz request failed: %s %s", method, endpoint)
            return None
        except ValueError:
            logger.exception("Eskiz returned non-JSON response: %s %s", method, endpoint)
            return None

    def send_sms(self, phone_number: str, message: str) -> bool:
        if not self.is_configured:
            logger.info("[DEV SMS] To: %s | Message: %s", phone_number, message)
            return True

        payload = {
            "mobile_phone": self._normalize_phone(phone_number),
            "message": message,
            "from": self.default_from,
        }
        return self._request("POST", "/message/sms/send", data=payload) is not None


_sms_service = EskizSMSService()


def sms_service_is_configured() -> bool:
    return _sms_service.is_configured


def _run_in_background(target: Callable[..., Any], *args: Any, **kwargs: Any) -> None:
    """Vazifani HTTP so'rovini bloklamasdan fon oqimida bajaradi (fire-and-forget)."""

    def _runner() -> None:
        try:
            target(*args, **kwargs)
        except Exception:  # fon oqimidagi istisno so'rovni buzmasligi uchun yutamiz
            logger.exception("Background SMS task failed.")
        finally:
            # Thread'da (cache DB backend orqali) ochilgan ulanishlarni yopamiz.
            connections.close_all()

    threading.Thread(target=_runner, daemon=True).start()


def send_otp_sms(phone_number: str, code: str) -> bool:
    """OTP kodini fon oqimida yuboradi. Chaqiruvchini bloklamaydi."""
    message = OTP_MESSAGE_TEMPLATE.format(code=code)
    _run_in_background(_sms_service.send_sms, phone_number, message)
    return True
