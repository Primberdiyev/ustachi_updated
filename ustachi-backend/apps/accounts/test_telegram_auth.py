from datetime import timedelta
from unittest.mock import patch

from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient

from apps.accounts.models import TelegramAuthFlow, TelegramAuthGrant, User


class TelegramAuthExchangeTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(phone_number="+998901234567", password=None, is_active=True)
        self.url = "/api/v1/client/auth/telegram/exchange/"

    def test_grant_can_be_exchanged_once(self):
        code = "random-one-time-code"
        TelegramAuthGrant.objects.create(
            user=self.user,
            digest=TelegramAuthGrant.digest_for(code),
            is_new_user=True,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        response = self.client.post(self.url, {"code": code}, format="json")

        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.data["is_new_user"])
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertEqual(self.client.post(self.url, {"code": code}, format="json").status_code, 400)

    def test_expired_grant_is_rejected(self):
        code = "expired-code"
        TelegramAuthGrant.objects.create(
            user=self.user,
            digest=TelegramAuthGrant.digest_for(code),
            expires_at=timezone.now() - timedelta(seconds=1),
        )

        self.assertEqual(self.client.post(self.url, {"code": code}, format="json").status_code, 400)

    def test_staff_grant_is_rejected_even_if_role_changes_after_issue(self):
        code = "issued-before-promotion"
        TelegramAuthGrant.objects.create(
            user=self.user, digest=TelegramAuthGrant.digest_for(code),
            expires_at=timezone.now() + timedelta(minutes=5),
        )
        self.user.is_staff = True
        self.user.save(update_fields=["is_staff"])

        self.assertEqual(self.client.post(self.url, {"code": code}, format="json").status_code, 403)

    def test_landing_page_does_not_cache_or_leak_code_as_referrer(self):
        response = self.client.get("/app/auth/telegram/example-code/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response["Cache-Control"], "no-store")
        self.assertEqual(response["Referrer-Policy"], "no-referrer")
        self.assertIn(b"com.ustachi.mijoz", response.content)

    def test_master_landing_page_points_to_pro_app(self):
        response = self.client.get("/app/auth/master-telegram/example-code/")

        self.assertEqual(response.status_code, 200)
        self.assertIn(b"com.ustachi.pro", response.content)
        self.assertIn(b"app/auth/master-telegram/example-code/", response.content)
        self.assertNotIn(b"com.ustachi.mijoz", response.content)


@override_settings(TELEGRAM_AUTH_WEBHOOK_SECRET="test-webhook-secret")
class TelegramAuthWebhookTests(TestCase):
    url = "/api/v1/client/auth/telegram/webhook/"

    def test_secret_header_is_required(self):
        response = APIClient().post(self.url, {}, format="json")
        self.assertEqual(response.status_code, 403)

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_start_creates_short_lived_phone_flow(self, say):
        response = APIClient().post(
            self.url,
            {"message": {"from": {"id": 77}, "chat": {"id": 77, "type": "private"}, "text": "/start client_register"}},
            format="json",
            HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN="test-webhook-secret",
        )

        self.assertEqual(response.status_code, 200)
        flow = TelegramAuthFlow.objects.get(telegram_user_id=77)
        self.assertEqual(flow.step, "phone")
        self.assertGreater(flow.expires_at, timezone.now())
        say.assert_called_once()

    def send_update(self, message):
        return APIClient().post(
            self.url, {"message": message}, format="json",
            HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN="test-webhook-secret",
        )

    def start(self, telegram_id=77):
        return self.send_update({
            "from": {"id": telegram_id},
            "chat": {"id": telegram_id, "type": "private"},
            "text": "/start client_register",
        })

    def contact(self, telegram_id=77, contact_id=77, phone="+998901234567"):
        return self.send_update({
            "from": {"id": telegram_id},
            "chat": {"id": telegram_id, "type": "private"},
            "contact": {"user_id": contact_id, "phone_number": phone},
        })

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_own_contact_creates_user_and_grant_without_sms(self, say, send_sms):
        self.start()
        self.contact()

        user = User.objects.get(phone_number="+998901234567")
        self.assertEqual(user.telegram_auth_user_id, 77)
        self.assertTrue(TelegramAuthGrant.objects.filter(user=user, is_new_user=True).exists())
        self.assertEqual(TelegramAuthFlow.objects.get(telegram_user_id=77).step, "done")
        self.assertIn("/app/auth/telegram/", say.call_args.args[2]["inline_keyboard"][0][0]["url"])
        send_sms.assert_not_called()

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_existing_client_is_bound_without_sms(self, say, send_sms):
        user = User.objects.create_user(phone_number="+998901234567", password=None)
        self.start()
        self.contact()

        user.refresh_from_db()
        self.assertEqual(user.telegram_auth_user_id, 77)
        self.assertTrue(TelegramAuthGrant.objects.filter(user=user, is_new_user=False).exists())
        send_sms.assert_not_called()

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_contact_requires_active_start_and_sender_ownership(self, say):
        self.contact()
        self.assertEqual(TelegramAuthGrant.objects.count(), 0)
        self.start()
        self.contact(contact_id=88)
        self.assertEqual(TelegramAuthGrant.objects.count(), 0)
        self.contact(contact_id=None)
        self.assertEqual(TelegramAuthGrant.objects.count(), 0)

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_bound_phone_rejects_another_telegram_account(self, say):
        user = User.objects.create_user(
            phone_number="+998901234567", password=None, telegram_auth_user_id=88,
        )
        self.start()
        self.contact()

        self.assertEqual(TelegramAuthGrant.objects.count(), 0)
        user.refresh_from_db()
        self.assertEqual(user.telegram_auth_user_id, 88)

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_staff_account_cannot_use_telegram_login(self, say):
        User.objects.create_user(phone_number="+998901234567", password=None, is_staff=True)
        self.start()
        self.contact()

        self.assertEqual(TelegramAuthGrant.objects.count(), 0)

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_repeated_contact_does_not_create_more_grants(self, say):
        self.start()
        self.contact()
        self.contact()

        self.assertEqual(TelegramAuthGrant.objects.count(), 1)

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_repeated_starts_are_limited(self, say):
        for _ in range(6):
            self.start()

        flow = TelegramAuthFlow.objects.get(telegram_user_id=77)
        self.assertEqual(flow.attempts, 5)
        self.assertIn("Juda ko‘p urinish", say.call_args.args[1])

    def start_master(self, telegram_id=77):
        return self.send_update({
            "from": {"id": telegram_id},
            "chat": {"id": telegram_id, "type": "private"},
            "text": "/start master_register",
        })

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_master_start_creates_new_user_as_master(self, say, send_sms):
        self.start_master()
        self.contact()

        user = User.objects.get(phone_number="+998901234567")
        self.assertTrue(user.is_master)
        self.assertTrue(TelegramAuthGrant.objects.filter(user=user, is_new_user=True).exists())
        self.assertIn("/app/auth/master-telegram/", say.call_args.args[2]["inline_keyboard"][0][0]["url"])
        send_sms.assert_not_called()

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_master_start_upgrades_existing_client_without_losing_client_role(self, say, send_sms):
        user = User.objects.create_user(phone_number="+998901234567", password=None, is_active=True)
        self.assertFalse(user.is_master)
        self.start_master()
        self.contact()

        user.refresh_from_db()
        self.assertTrue(user.is_master)  # usta roli qo'shildi
        self.assertTrue(TelegramAuthGrant.objects.filter(user=user, is_new_user=False).exists())

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_client_start_does_not_grant_master_role(self, say):
        self.start()  # payload: client_register
        self.contact()

        user = User.objects.get(phone_number="+998901234567")
        self.assertFalse(user.is_master)
        self.assertIn("/app/auth/telegram/", say.call_args.args[2]["inline_keyboard"][0][0]["url"])
        self.assertNotIn("master-telegram", say.call_args.args[2]["inline_keyboard"][0][0]["url"])

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_bare_start_asks_which_app_instead_of_guessing(self, say):
        # Deep-link payloadsiz `/start` (masalan, bot bilan avval suhbat
        # bo'lgan qaytgan foydalanuvchida Telegram payloadni yetkazmagan) —
        # taxmin QILINMAYDI, aniq tanlov so'raladi va flow YARATILMAYDI.
        self.send_update({
            "from": {"id": 77}, "chat": {"id": 77, "type": "private"}, "text": "/start",
        })

        say.assert_called_once()
        self.assertIn("inline_keyboard", say.call_args.args[2])
        self.assertFalse(TelegramAuthFlow.objects.filter(telegram_user_id=77).exists())

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_restart_without_payload_asks_which_app_and_does_not_touch_flow(self, say):
        self.start_master()
        say.reset_mock()
        # `/restart` payloadsiz — oldingi tanlov (usta) endi SUKUTAN
        # qo'llanmaydi, aniq so'raladi; joriy flow o'zgarishsiz qoladi.
        self.send_update({
            "from": {"id": 77}, "chat": {"id": 77, "type": "private"}, "text": "/restart",
        })

        say.assert_called_once()
        self.assertIn("inline_keyboard", say.call_args.args[2])
        flow = TelegramAuthFlow.objects.get(telegram_user_id=77)
        self.assertTrue(flow.grants_master)

    def callback(self, data, telegram_id=77):
        return APIClient().post(
            self.url,
            {"callback_query": {
                "id": "cbq-1",
                "from": {"id": telegram_id},
                "message": {"chat": {"id": telegram_id, "type": "private"}},
                "data": data,
            }},
            format="json",
            HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN="test-webhook-secret",
        )

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._bot_call")
    def test_callback_query_master_choice_starts_master_flow(self, bot_call, send_sms):
        bot_call.return_value = True
        self.send_update({
            "from": {"id": 77}, "chat": {"id": 77, "type": "private"}, "text": "/start",
        })
        response = self.callback("auth_app:master")
        self.contact()

        self.assertEqual(response.status_code, 200)
        bot_call.assert_any_call("answerCallbackQuery", {"callback_query_id": "cbq-1"})
        user = User.objects.get(phone_number="+998901234567")
        self.assertTrue(user.is_master)
        send_sms.assert_not_called()

    @patch("apps.accounts.services.sms.send_otp_sms")
    @patch("apps.accounts.api.v1.telegram_auth._bot_call")
    def test_callback_query_client_choice_starts_client_flow(self, bot_call, send_sms):
        bot_call.return_value = True
        self.send_update({
            "from": {"id": 77}, "chat": {"id": 77, "type": "private"}, "text": "/start",
        })
        self.callback("auth_app:client")
        self.contact()

        user = User.objects.get(phone_number="+998901234567")
        self.assertFalse(user.is_master)
        send_sms.assert_not_called()

    @patch("apps.accounts.api.v1.telegram_auth._bot_call")
    def test_callback_query_from_foreign_chat_is_ignored(self, bot_call):
        bot_call.return_value = True
        response = APIClient().post(
            self.url,
            {"callback_query": {
                "id": "cbq-2",
                "from": {"id": 77},
                "message": {"chat": {"id": 999, "type": "private"}},
                "data": "auth_app:master",
            }},
            format="json",
            HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN="test-webhook-secret",
        )

        self.assertEqual(response.status_code, 200)
        self.assertFalse(TelegramAuthFlow.objects.filter(telegram_user_id=77).exists())

    @patch("apps.accounts.api.v1.telegram_auth._say")
    def test_grants_are_limited_per_bound_telegram_user(self, say):
        for _ in range(3):
            self.start()
            self.contact()
        self.start()
        self.contact()

        self.assertEqual(TelegramAuthGrant.objects.count(), 3)
        self.assertIn("Juda ko‘p urinish", say.call_args.args[1])
