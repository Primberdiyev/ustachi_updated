import hashlib

from django.conf import settings
from django.db import models


class TelegramAuthFlow(models.Model):
    """Short-lived state for the Telegram own-contact verification conversation."""

    telegram_user_id = models.BigIntegerField(unique=True)
    chat_id = models.BigIntegerField()
    phone_number = models.CharField(max_length=20, blank=True)
    step = models.CharField(max_length=12, default="phone")
    attempts = models.PositiveSmallIntegerField(default=0)
    # Bot bitta: `/start client_register` (mijoz) yoki `/start master_register`
    # (usta). Kontakt kelganda shu bayroqqa qarab `is_master` beriladi.
    grants_master = models.BooleanField(default=False)
    expires_at = models.DateTimeField()
    updated_at = models.DateTimeField(auto_now=True)


class TelegramAuthGrant(models.Model):
    """One-time exchange key; only its digest is stored in the database."""

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    digest = models.CharField(max_length=64, unique=True)
    is_new_user = models.BooleanField(default=False)
    expires_at = models.DateTimeField()
    consumed_at = models.DateTimeField(null=True, blank=True)

    @staticmethod
    def digest_for(code: str) -> str:
        return hashlib.sha256(code.encode("utf-8")).hexdigest()
