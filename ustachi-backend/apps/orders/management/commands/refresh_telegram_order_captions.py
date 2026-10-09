"""Update existing order photo captions with the current compact link row."""

import time

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from apps.common import telegram
from apps.orders.management.commands.repost_open_telegram_orders import channel_order_posts
from apps.orders.models import Order


class Command(BaseCommand):
    help = "Refresh order photo captions in the public Telegram channel."

    def add_arguments(self, parser):
        parser.add_argument("--dry-run", action="store_true", help="List posts without editing")

    def handle(self, *args, **options):
        channel = telegram._orders_channel_id()
        if not channel:
            raise CommandError("TELEGRAM_ORDERS_CHANNEL_ID sozlanmagan")
        if not options["dry_run"] and not telegram._is_enabled(channel):
            raise CommandError("Telegram bot tokeni yoki kanal ID sozlanmagan")

        posts = channel_order_posts(settings.TELEGRAM_ORDERS_CHANNEL_URL)
        updated = skipped = failed = 0
        for message_id, order_id in sorted(posts.items()):
            order = (
                Order.objects.select_related("specialty", "region", "district")
                .filter(pk=order_id)
                .first()
            )
            if not order or not order.is_public or len(telegram._order_text(order)) > 4096:
                skipped += 1
                self.stdout.write(f"SKIP post {message_id}, order #{order_id}")
                continue
            if options["dry_run"]:
                updated += 1
                self.stdout.write(f"PREVIEW post {message_id}, order #{order_id}")
                continue
            is_photo = telegram.edit_order_caption_now(order, message_id, channel)
            edited = is_photo or telegram.edit_order_text_now(order, message_id, channel)
            if edited:
                Order.objects.filter(pk=order_id).update(
                    telegram_message_id=message_id, telegram_post_is_photo=is_photo
                )
                updated += 1
                self.stdout.write(self.style.SUCCESS(f"UPDATED post {message_id}, order #{order_id}"))
            else:
                failed += 1
                self.stderr.write(f"FAILED post {message_id}, order #{order_id}")
            time.sleep(3)

        self.stdout.write(
            f"{'Ready' if options['dry_run'] else 'Updated'}: {updated}; "
            f"skipped: {skipped}; failed: {failed}"
        )
        if failed:
            raise CommandError(f"{failed} ta caption yangilanmadi")
