import json
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from unittest.mock import patch

from django.core.management import call_command
from django.test import SimpleTestCase, TestCase, override_settings

from apps.common import telegram
from apps.orders import services
from apps.orders.models import OrderStatus


def _order(is_public=True):
    return SimpleNamespace(
        pk=42,
        title="Deraza <ta'mir>",
        is_repair=False,
        is_public=is_public,
        specialty=SimpleNamespace(name="Rom", code="rom"),
        client=SimpleNamespace(full_name="Maxfiy mijoz", phone_number="+998901234567"),
        region="Toshkent",
        district="Chilonzor",
        address="Maxfiy ko'cha 12",
        description="Maxfiy izoh +998901234567",
        calculated_price=150000,
        telegram_message_id=None,
        telegram_post_is_photo=False,
        status=OrderStatus.PUBLISHED,
        get_status_display=lambda: "E'lon qilingan",
        responses=SimpleNamespace(exclude=lambda **kwargs: SimpleNamespace(count=lambda: 2)),
    )


@override_settings(
    TELEGRAM_ENABLED=True,
    TELEGRAM_BOT_TOKEN="test-token",
    TELEGRAM_CHAT_ID="-100-admin",
    TELEGRAM_ORDERS_CHANNEL_ID="@ustachi_buyurtmalar",
    TELEGRAM_USERS_TOPIC_ID=3,
)
class OrderChannelTests(SimpleTestCase):
    @patch("apps.common.telegram.send_order")
    def test_public_order_goes_only_to_channel_without_private_details(self, send_order):
        telegram.notify_new_order(_order())

        send_order.assert_called_once()
        message = send_order.call_args.args[0]
        self.assertEqual(send_order.call_args.args[1:], ("rom", "@ustachi_buyurtmalar"))
        self.assertEqual(send_order.call_args.kwargs, {"order_id": 42})
        self.assertTrue(message.startswith("🆕 Yangi buyurtma\n<b>#42 · Deraza &lt;ta&#x27;mir&gt;</b>\n"))
        self.assertIn("Toshkent, Chilonzor", message)
        self.assertTrue(message.endswith("\n#toshkent #rom"))
        self.assertIn("📋 Holat: E&#x27;lon qilingan", message)
        self.assertIn("📨 Takliflar soni: 2", message)
        self.assertIn("Deraza &lt;ta&#x27;mir&gt;", message)
        self.assertIn("💰 Mijoz hisobi: 150 000 so'm", message)
        self.assertIn(">Buyurtma</a> | 📲", message)
        self.assertIn('href="https://ustachi.uz/app/order/42/"', message)
        self.assertIn(
            'href="https://play.google.com/store/apps/details?id=com.ustachi.pro"',
            message,
        )
        self.assertIn('href="https://t.me/ustachi_buyurtmalar"', message)
        self.assertIn(">Ilova</a> | 📢", message)
        self.assertIn(">Kanal</a>", message)
        self.assertNotIn("Maxfiy", message)
        self.assertNotIn("+998901234567", message)

    @patch("apps.common.telegram.send_order")
    def test_region_tag_omits_viloyati_suffix(self, send_order):
        order = _order()
        order.region = "Toshkent viloyati"

        telegram.notify_new_order(order)

        message = send_order.call_args.args[0]
        self.assertIn("📍 Hudud: Toshkent, Chilonzor", message)
        self.assertTrue(message.endswith("\n#toshkent #rom"))
        self.assertNotIn("viloyati", message)
        self.assertNotIn("#toshkent_viloyati", message)

    @patch("apps.common.telegram.send_order")
    def test_repair_post_explains_price_arrangement(self, send_order):
        order = _order()
        order.is_repair = True
        order.calculated_price = 0

        telegram.notify_new_order(order)

        message = send_order.call_args.args[0]
        self.assertTrue(message.startswith("🔧 Ta’mir ishi\n<b>#42 · Deraza &lt;ta&#x27;mir&gt;</b>\n"))
        self.assertIn("💬 Narx usta bilan kelishiladi", message)
        self.assertNotIn("Mijoz hisobi", message)

    @patch("apps.common.telegram.send_order")
    def test_invite_only_order_is_not_posted(self, send_order):
        telegram.notify_new_order(_order(is_public=False))
        send_order.assert_not_called()

    @override_settings(TELEGRAM_ORDERS_CHANNEL_ID="")
    @patch("apps.common.telegram.send_order")
    def test_empty_channel_disables_order_post(self, send_order):
        telegram.notify_new_order(_order())
        send_order.assert_not_called()

    @override_settings(
        MASTER_APP_STORE_URL="https://example.com/app?a=1&b=2",
        TELEGRAM_ORDERS_CHANNEL_URL="https://example.com/channel?a=1&b=2",
    )
    @patch("apps.common.telegram.send_order")
    def test_configured_links_are_html_escaped(self, send_order):
        telegram.notify_new_order(_order())
        message = send_order.call_args.args[0]
        self.assertIn('href="https://example.com/app?a=1&amp;b=2"', message)
        self.assertIn('href="https://example.com/channel?a=1&amp;b=2"', message)

    @patch("apps.common.telegram.send")
    def test_new_user_still_goes_to_admin_topic(self, send):
        user = SimpleNamespace(
            pk=7,
            is_master=False,
            phone_number="+998901234567",
            full_name="Mijoz",
            region="Toshkent",
            district="Chilonzor",
            address="",
        )

        telegram.notify_new_user(user)

        send.assert_called_once()
        self.assertEqual(send.call_args.args[1], 3)
        self.assertEqual(send.call_args.kwargs, {})

    @patch("apps.common.telegram.requests.post")
    def test_category_cover_is_sent_as_photo_with_existing_caption(self, post):
        post.return_value.ok = True
        with TemporaryDirectory() as directory, patch.object(
            telegram, "ORDER_IMAGES_DIR", Path(directory)
        ):
            (Path(directory) / "rom.jpg").write_bytes(b"photo")
            self.assertTrue(telegram.send_order_now("<b>Order</b>", "rom", "@ustachi_buyurtmalar"))

        self.assertTrue(post.call_args.args[0].endswith("/sendPhoto"))
        self.assertEqual(post.call_args.kwargs["data"], {
            "chat_id": "@ustachi_buyurtmalar",
            "caption": "<b>Order</b>",
            "parse_mode": "HTML",
        })
        self.assertEqual(post.call_args.kwargs["files"]["photo"][0], "rom.jpg")

    @patch("apps.common.telegram._refresh_order_post_now")
    @patch("apps.common.telegram.requests.post")
    @patch("apps.orders.models.Order.objects")
    def test_published_post_id_is_saved_for_later_edits(self, objects, post, refresh):
        order = _order()
        objects.select_related.return_value.filter.return_value.first.return_value = order
        post.return_value.ok = True
        post.return_value.json.return_value = {"result": {"message_id": 24}}
        with TemporaryDirectory() as directory, patch.object(
            telegram, "ORDER_IMAGES_DIR", Path(directory)
        ):
            (Path(directory) / "rom.jpg").write_bytes(b"photo")
            telegram._publish_order_now(42, "@ustachi_buyurtmalar")

        objects.filter.return_value.update.assert_called_once_with(
            telegram_message_id=24, telegram_post_is_photo=True
        )
        refresh.assert_called_once()

    @patch("apps.common.telegram.edit_order_caption_now")
    @patch("apps.orders.models.Order.objects")
    def test_refresh_edits_current_caption(self, objects, edit):
        order = _order()
        order.telegram_message_id = 24
        order.telegram_post_is_photo = True
        order.get_status_display = lambda: "Usta tanlangan"
        objects.select_related.return_value.filter.return_value.first.return_value = order

        telegram._refresh_order_post_now(42, "@ustachi_buyurtmalar")

        edit.assert_called_once()
        self.assertIn("Usta tanlangan", telegram._order_text(edit.call_args.args[0]))

    @patch("apps.common.telegram.requests.post")
    def test_text_order_post_can_be_edited(self, post):
        post.return_value.ok = True

        self.assertTrue(telegram.edit_order_text_now(_order(), 24, "@ustachi_buyurtmalar"))

        self.assertTrue(post.call_args.args[0].endswith("/editMessageText"))
        self.assertEqual(post.call_args.kwargs["json"]["message_id"], 24)

    @patch("apps.common.telegram.time.sleep")
    @patch("apps.common.telegram.requests.post")
    def test_caption_edit_retries_telegram_rate_limit(self, post, sleep):
        limited = SimpleNamespace(
            ok=False, status_code=429,
            json=lambda: {"parameters": {"retry_after": 2}},
        )
        success = SimpleNamespace(ok=True, status_code=200)
        post.side_effect = [limited, success]

        self.assertTrue(telegram.edit_order_caption_now(_order(), 24, "@ustachi_buyurtmalar"))

        self.assertEqual(post.call_count, 2)
        sleep.assert_called_once_with(3)

    @patch("apps.common.telegram.send_now")
    def test_unknown_or_unsafe_category_uses_text(self, send_now):
        send_now.return_value = True
        self.assertTrue(telegram.send_order_now("Order", "../rom", "@ustachi_buyurtmalar"))
        send_now.assert_called_once_with("Order", chat_id="@ustachi_buyurtmalar")

    @patch("apps.common.telegram.send_now")
    @patch("apps.common.telegram.requests.post")
    def test_rejected_photo_falls_back_to_text(self, post, send_now):
        post.return_value.ok = False
        post.return_value.status_code = 400
        post.return_value.text = "Bad Request"
        send_now.return_value = True
        with TemporaryDirectory() as directory, patch.object(
            telegram, "ORDER_IMAGES_DIR", Path(directory)
        ):
            (Path(directory) / "rom.jpg").write_bytes(b"photo")
            self.assertTrue(telegram.send_order_now("Order", "rom", "@ustachi_buyurtmalar"))
        send_now.assert_called_once_with("Order", chat_id="@ustachi_buyurtmalar")

    @patch("apps.common.telegram.requests.post")
    def test_existing_post_can_be_replaced_with_category_photo(self, post):
        post.return_value.ok = True
        with TemporaryDirectory() as directory, patch.object(
            telegram, "ORDER_IMAGES_DIR", Path(directory)
        ):
            (Path(directory) / "rom.jpg").write_bytes(b"photo")
            self.assertTrue(telegram.edit_order_post_now(_order(), 24, "@ustachi_buyurtmalar"))

        self.assertTrue(post.call_args.args[0].endswith("/editMessageMedia"))
        self.assertEqual(post.call_args.kwargs["data"]["message_id"], 24)
        media = json.loads(post.call_args.kwargs["data"]["media"])
        self.assertEqual(media["media"], "attach://photo")
        self.assertIn("Deraza &lt;ta&#x27;mir&gt;", media["caption"])
        self.assertNotIn("Maxfiy", media["caption"])

    @patch("apps.orders.management.commands.backfill_telegram_order_photos.Order.objects.select_related")
    @patch("apps.common.telegram.edit_order_post_now")
    def test_historical_post_preview_does_not_edit_channel(self, edit_post, select_related):
        select_related.return_value.filter.return_value.first.return_value = _order()
        with TemporaryDirectory() as directory, patch.object(
            telegram, "ORDER_IMAGES_DIR", Path(directory)
        ):
            (Path(directory) / "rom.jpg").write_bytes(b"photo")
            mapping = Path(directory) / "posts.json"
            mapping.write_text(json.dumps({
                "channel": "@ustachi_buyurtmalar",
                "message_to_order": {"24": 42},
            }))
            output = StringIO()
            call_command("backfill_telegram_order_photos", mapping=str(mapping), stdout=output)

        self.assertIn("PREVIEW post 24, order 42: rom.jpg", output.getvalue())
        edit_post.assert_not_called()


class OrderPublicationTests(TestCase):
    @patch("apps.orders.services.telegram.notify_new_order")
    @patch("apps.orders.services.notify_masters_of_new_order")
    def test_opening_invite_only_order_posts_to_channel_once(self, notify_masters, notify_channel):
        order = _order(is_public=False)
        order.status = OrderStatus.PUBLISHED
        order.save = lambda **kwargs: None

        services.open_order_to_everyone(order)
        services.open_order_to_everyone(order)

        self.assertTrue(order.is_public)
        notify_masters.assert_called_once_with(order)
        notify_channel.assert_called_once_with(order)
