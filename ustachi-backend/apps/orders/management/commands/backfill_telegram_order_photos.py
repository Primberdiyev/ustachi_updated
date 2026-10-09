"""Add category photos to already published order posts in the Telegram channel."""

import json

from django.core.management.base import BaseCommand, CommandError

from apps.common import telegram
from apps.orders.models import Order


class Command(BaseCommand):
    help = "Preview or edit historical text-only Telegram order posts with category photos."

    def add_arguments(self, parser):
        parser.add_argument("--apply", action="store_true", help="Edit the channel posts; default is preview only")
        parser.add_argument("--mapping", type=str, help="Path to a message_to_order JSON file")

    def handle(self, *args, **options):
        path = options["mapping"] or telegram.ORDER_IMAGES_DIR / "channel_posts_2026-09-28.json"
        try:
            with open(path, encoding="utf-8") as source:
                mapping = json.load(source)
        except (OSError, ValueError) as exc:
            raise CommandError(f"Mapping o'qilmadi: {exc}") from exc

        channel = mapping.get("channel")
        if channel != telegram._orders_channel_id():
            raise CommandError("Mapping kanali va TELEGRAM_ORDERS_CHANNEL_ID mos emas")
        if options["apply"] and not telegram._is_enabled(channel):
            raise CommandError("Telegram bot tokeni yoki kanal ID sozlanmagan")
        if not isinstance(mapping.get("message_to_order"), dict):
            raise CommandError("Mappingda message_to_order topilmadi")

        sent = skipped = failed = 0
        for message_id, order_id in sorted(
            mapping["message_to_order"].items(), key=lambda pair: int(pair[0])
        ):
            order = Order.objects.select_related("specialty", "region", "district").filter(pk=order_id).first()
            image = telegram._order_image_path(order.specialty.code if order and order.specialty else None)
            if not order or not order.is_public or not image or len(telegram._order_text(order)) > 1024:
                skipped += 1
                self.stdout.write(f"SKIP post {message_id}, order {order_id}")
                continue
            if not options["apply"]:
                self.stdout.write(f"PREVIEW post {message_id}, order {order_id}: {image.name}")
                sent += 1
                continue
            if telegram.edit_order_post_now(order, int(message_id), channel):
                self.stdout.write(self.style.SUCCESS(f"EDITED post {message_id}, order {order_id}"))
                sent += 1
            else:
                self.stderr.write(f"FAILED post {message_id}, order {order_id}")
                failed += 1
        self.stdout.write(f"{'Edited' if options['apply'] else 'Ready'}: {sent}; skipped: {skipped}; failed: {failed}")
