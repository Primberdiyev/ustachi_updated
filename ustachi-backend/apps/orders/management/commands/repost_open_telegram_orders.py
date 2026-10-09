"""Repost currently open public orders after their channel posts were deleted."""

import re
import time
from urllib.parse import urlparse

import requests
from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone

from apps.common import telegram
from apps.orders.models import Order, OrderStatus


def channel_order_posts(channel_url: str) -> dict[int, int]:
    """Return message ID to order ID from the public channel history."""
    parsed = urlparse(channel_url)
    if parsed.hostname not in {"t.me", "www.t.me"}:
        raise CommandError("TELEGRAM_ORDERS_CHANNEL_URL ommaviy t.me kanaliga ishora qilishi kerak")
    slug = parsed.path.strip("/")
    if not re.fullmatch(r"[A-Za-z0-9_]+", slug):
        raise CommandError("Telegram kanal username'i topilmadi")

    url = f"https://t.me/s/{slug}"
    posted: dict[int, int] = {}
    before = None
    for _ in range(100):
        try:
            response = requests.get(
                url, params={"before": before} if before else None, timeout=15
            )
            response.raise_for_status()
        except requests.RequestException as exc:
            raise CommandError(f"Telegram kanal tarixi o'qilmadi: {exc}") from exc
        page = response.text
        if "tgme_channel_info" not in page:
            raise CommandError("Telegram kanal sahifasi kutilgan formatda emas")
        messages = list(re.finditer(rf'data-post="{re.escape(slug)}/(\d+)"', page))
        if not messages:
            break
        for index, match in enumerate(messages):
            end = messages[index + 1].start() if index + 1 < len(messages) else len(page)
            fragment = page[match.end():end]
            order_ids = set(re.findall(r"/app/order/(\d+)/", fragment))
            if len(order_ids) == 1:
                posted[int(match.group(1))] = int(order_ids.pop())
        oldest = min(int(match.group(1)) for match in messages)
        if oldest <= 1 or oldest == before:
            break
        before = oldest
    else:
        raise CommandError("Telegram kanal tarixini to'liq o'qib bo'lmadi")
    return posted


def channel_order_ids(channel_url: str) -> set[int]:
    """Read public channel pages so rerunning the command skips posted orders."""
    return set(channel_order_posts(channel_url).values())


class Command(BaseCommand):
    help = "Repost currently open public orders with category photos; --dry-run previews."

    def add_arguments(self, parser):
        parser.add_argument("--dry-run", action="store_true", help="List orders without posting")

    def handle(self, *args, **options):
        channel = telegram._orders_channel_id()
        if not channel:
            raise CommandError("TELEGRAM_ORDERS_CHANNEL_ID sozlanmagan")
        if not options["dry_run"] and not telegram._is_enabled(channel):
            raise CommandError("Telegram bot tokeni yoki kanal ID sozlanmagan")

        orders = list(
            Order.objects.filter(
                is_public=True,
                status=OrderStatus.PUBLISHED,
                expires_at__gt=timezone.now(),
            )
            .select_related("specialty", "region", "district")
            .order_by("pk")
        )
        existing = channel_order_ids(settings.TELEGRAM_ORDERS_CHANNEL_URL)
        sent = skipped = failed = 0
        for order in orders:
            if order.pk in existing:
                skipped += 1
                self.stdout.write(f"SKIP #{order.pk}: kanalda mavjud")
                continue
            code = order.specialty.code if order.specialty else None
            image = telegram._order_image_path(code)
            caption = telegram._order_text(order)
            if image is None or len(caption) > 1024:
                skipped += 1
                self.stdout.write(f"SKIP #{order.pk}: rasm yoki caption mos emas")
                continue
            if options["dry_run"]:
                sent += 1
                self.stdout.write(f"PREVIEW #{order.pk}: {code} — {image.name}")
                continue
            if telegram.send_order_now(caption, code, channel, fallback_to_text=False):
                sent += 1
                existing.add(order.pk)
                self.stdout.write(self.style.SUCCESS(f"SENT #{order.pk}: {code}"))
            else:
                failed += 1
                self.stderr.write(f"FAILED #{order.pk}: {code}")
            time.sleep(1)

        self.stdout.write(
            f"{'Ready' if options['dry_run'] else 'Sent'}: {sent}; skipped: {skipped}; failed: {failed}"
        )
        if failed:
            raise CommandError(f"{failed} ta buyurtma yuborilmadi; qayta ishga tushirish mumkin")
