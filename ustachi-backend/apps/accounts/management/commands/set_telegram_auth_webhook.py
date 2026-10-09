import requests
from django.conf import settings
from django.core.management.base import BaseCommand, CommandError


class Command(BaseCommand):
    help = "Register the Telegram auth bot webhook using configured environment values."

    def handle(self, *args, **options):
        token = getattr(settings, "TELEGRAM_AUTH_BOT_TOKEN", "")
        secret = getattr(settings, "TELEGRAM_AUTH_WEBHOOK_SECRET", "")
        base = getattr(settings, "APP_LINK_BASE_URL", "").rstrip("/")
        if not token or not secret or not base.startswith("https://"):
            raise CommandError("Set TELEGRAM_AUTH_BOT_TOKEN, TELEGRAM_AUTH_WEBHOOK_SECRET and HTTPS APP_LINK_BASE_URL first.")
        if len(secret) < 32 or not all(c.isalnum() or c in "_-" for c in secret):
            raise CommandError("TELEGRAM_AUTH_WEBHOOK_SECRET must be 32+ chars using A-Z, a-z, 0-9, _ or -.")
        url = f"{base}/api/v1/client/auth/telegram/webhook/"
        try:
            response = requests.post(
                f"https://api.telegram.org/bot{token}/setWebhook",
                json={"url": url, "secret_token": secret, "allowed_updates": ["message", "callback_query"]},
                timeout=15,
            )
            response.raise_for_status()
            result = response.json()
        except requests.RequestException as exc:
            raise CommandError("Telegram webhook registration failed.") from exc
        if not result.get("ok"):
            raise CommandError("Telegram rejected webhook registration.")
        self.stdout.write(self.style.SUCCESS(f"Webhook registered: {url}"))
