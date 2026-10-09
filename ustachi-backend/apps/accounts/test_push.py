"""
FCM push testlari — qurilma tokeni API'si va yuborish mantiqi.

Firebase'ga HAQIQIY so'rov yuborilmaydi: `messaging.send_each_for_multicast`
o'rniga soxta javob qo'yiladi. Tekshirilayotgani — QAYSI tokenlar tanlanadi,
yaroqsizi o'chiriladimi va bildirishnoma push'ni qo'zg'atadimi.
"""

from unittest.mock import patch

from django.db.utils import OperationalError
from django.test import TestCase, override_settings
from rest_framework.test import APIClient

from apps.accounts.models import DevicePlatform, DeviceToken, User
from apps.accounts.services import push
from apps.orders.models import NotificationType
from apps.orders.services import notify

CLIENT_AUTH = "/api/v1/client/auth/"
MASTER_AUTH = "/api/v1/master/auth/"


class FakeResult:
    def __init__(self, success=True, exception=None):
        self.success = success
        self.exception = exception


class FakeBatchResponse:
    def __init__(self, responses):
        self.responses = responses
        self.success_count = sum(1 for r in responses if r.success)


def _fake_send(results_by_token=None):
    """`send_each_for_multicast` o'rnini bosadi va chaqiruvlarni yozib boradi."""
    calls = []

    def sender(message, app=None):
        calls.append(message)
        results = [
            (results_by_token or {}).get(t, FakeResult()) for t in message.tokens
        ]
        return FakeBatchResponse(results)

    sender.calls = calls
    return sender


class DeviceTokenAPITests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.user = User.objects.create_user(
            phone_number="+998901112233", is_active=True
        )
        self.other = User.objects.create_user(
            phone_number="+998901112244", is_active=True
        )
        self.api.force_authenticate(self.user)

    def test_register_creates_token(self):
        response = self.api.post(
            f"{CLIENT_AUTH}devices/",
            {"token": "tok-1", "platform": "android", "device_name": "Pixel"},
            format="json",
        )
        self.assertEqual(response.status_code, 201)
        device = DeviceToken.objects.get(token="tok-1")
        self.assertEqual(device.user, self.user)
        self.assertTrue(device.is_active)
        self.assertEqual(device.platform, DevicePlatform.ANDROID)

    def test_register_is_idempotent(self):
        for _ in range(3):
            self.api.post(
                f"{CLIENT_AUTH}devices/", {"token": "tok-1"}, format="json"
            )
        self.assertEqual(DeviceToken.objects.filter(token="tok-1").count(), 1)

    def test_register_moves_token_to_new_owner(self):
        # Bir telefondan boshqa odam kirdi — push eski egasiga ketmasligi kerak.
        DeviceToken.objects.create(user=self.other, token="tok-1")

        response = self.api.post(
            f"{CLIENT_AUTH}devices/", {"token": "tok-1"}, format="json"
        )
        self.assertEqual(response.status_code, 201)

        device = DeviceToken.objects.get(token="tok-1")
        self.assertEqual(device.user, self.user)
        self.assertEqual(DeviceToken.objects.count(), 1)

    def test_register_requires_auth(self):
        self.api.force_authenticate(None)
        response = self.api.post(
            f"{CLIENT_AUTH}devices/", {"token": "tok-1"}, format="json"
        )
        self.assertEqual(response.status_code, 401)

    def test_register_rejects_empty_token(self):
        response = self.api.post(f"{CLIENT_AUTH}devices/", {}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_delete_removes_only_own_token(self):
        DeviceToken.objects.create(user=self.user, token="tok-mine")
        DeviceToken.objects.create(user=self.other, token="tok-other")

        response = self.api.post(
            f"{CLIENT_AUTH}devices/delete/", {"token": "tok-other"}, format="json"
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["deleted"], 0)

        response = self.api.post(
            f"{CLIENT_AUTH}devices/delete/", {"token": "tok-mine"}, format="json"
        )
        self.assertEqual(response.data["deleted"], 1)
        self.assertFalse(DeviceToken.objects.filter(token="tok-mine").exists())

    def test_master_namespace_has_same_endpoint(self):
        self.user.is_master = True
        self.user.save(update_fields=["is_master"])
        response = self.api.post(
            f"{MASTER_AUTH}devices/", {"token": "tok-master"}, format="json"
        )
        self.assertEqual(response.status_code, 201)


@override_settings(FCM_ENABLED=True, FCM_BACKGROUND=False)
class PushSendingTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone_number="+998901112233", is_active=True
        )
        self.api = APIClient()

    def test_sends_only_to_active_tokens_of_given_users(self):
        other = User.objects.create_user(phone_number="+998901112255", is_active=True)
        DeviceToken.objects.create(user=self.user, token="live")
        DeviceToken.objects.create(user=self.user, token="dead", is_active=False)
        DeviceToken.objects.create(user=other, token="someone-else")

        sender = _fake_send()
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            push.send_to_user(self.user, "Salom", "Matn", {"order_id": 7})

        self.assertEqual(len(sender.calls), 1)
        self.assertEqual(sender.calls[0].tokens, ["live"])
        # FCM `data` faqat string qabul qiladi.
        self.assertEqual(sender.calls[0].data, {"order_id": "7"})

    def test_no_tokens_means_no_request(self):
        sender = _fake_send()
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            push.send_to_user(self.user, "Salom")
        self.assertEqual(sender.calls, [])

    def test_unregistered_token_is_deactivated(self):
        from firebase_admin import messaging

        DeviceToken.objects.create(user=self.user, token="gone")
        DeviceToken.objects.create(user=self.user, token="ok")

        sender = _fake_send(
            {
                "gone": FakeResult(
                    success=False, exception=messaging.UnregisteredError("yo'q")
                )
            }
        )
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            push.send_to_user(self.user, "Salom")

        self.assertFalse(DeviceToken.objects.get(token="gone").is_active)
        self.assertTrue(DeviceToken.objects.get(token="ok").is_active)

    def test_other_errors_keep_the_token(self):
        # Tarmoq/payload xatosi tokenni aybdor qilmaydi — aks holda bitta
        # nosozlik hamma qurilmani o'chirib yuborardi.
        DeviceToken.objects.create(user=self.user, token="keep")
        sender = _fake_send(
            {"keep": FakeResult(success=False, exception=ValueError("tarmoq"))}
        )
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            push.send_to_user(self.user, "Salom")

        self.assertTrue(DeviceToken.objects.get(token="keep").is_active)

    def test_notification_triggers_push(self):
        DeviceToken.objects.create(user=self.user, token="live")
        sender = _fake_send()
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            notify(self.user, NotificationType.CHAT_MESSAGE, "Yangi xabar", "Salom")

        self.assertEqual(len(sender.calls), 1)
        message = sender.calls[0]
        self.assertEqual(message.notification.title, "Yangi xabar")
        self.assertEqual(message.data["topic"], NotificationType.CHAT_MESSAGE)

    def test_firebase_down_does_not_break_the_flow(self):
        DeviceToken.objects.create(user=self.user, token="live")
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast",
            side_effect=RuntimeError("firebase o'chgan"),
        ):
            notification = notify(
                self.user, NotificationType.ORDER_STAGE, "Bosqich", "…"
            )
        # Bildirishnoma baribir yozildi.
        self.assertIsNotNone(notification.pk)

    @override_settings(FCM_ENABLED=False)
    def test_disabled_setting_skips_sending(self):
        DeviceToken.objects.create(user=self.user, token="live")
        sender = _fake_send()
        with patch.object(push, "_get_app", return_value=object()), patch(
            "firebase_admin.messaging.send_each_for_multicast", sender
        ):
            push.send_to_user(self.user, "Salom")
        self.assertEqual(sender.calls, [])


class PushNeverBreaksTheCallerTests(TestCase):
    """
    PUSH ASOSIY AMALNI YIQITMASLIGI SHART.

    2026-08-05 da produksiyada aynan shu buzilgan edi: qurilma tokenlari
    jadvali sxemasi eskirib qolgan (`no such column: device_name`), va o'sha
    xato `send_to_users` ichidagi so'rovdan otilib, CHAT XABARINI yuborishni
    ham 500 qilib qo'ygan. Bildirishnoma yo'lidagi har qanday nosozlik
    JIMGINA yutilishi kerak.
    """

    def test_db_xatosi_yutiladi(self):
        from apps.accounts.services import push

        user = User.objects.create_user(
            phone_number="+998900000900", is_active=True
        )
        with patch(
            "apps.accounts.models.DeviceToken.objects.filter",
            side_effect=OperationalError("no such column: device_name"),
        ):
            sent = push.send_to_users([user], "Sarlavha", "Matn")
        self.assertEqual(sent, 0)

    def test_push_yiqilsa_ham_bildirishnoma_saqlanadi(self):
        """Chat xabari yuborilaveradi — 2026-08-05 dagi 500 takrorlanmasin."""
        from apps.orders.models import Notification

        user = User.objects.create_user(
            phone_number="+998900000901", is_active=True
        )
        with patch(
            "apps.accounts.services.push.send_to_user",
            side_effect=OperationalError("jadval eskirgan"),
        ):
            notification = notify(user, NotificationType.CHAT_MESSAGE, "Xabar")

        self.assertIsNotNone(notification)
        self.assertTrue(
            Notification.objects.filter(user=user, title="Xabar").exists()
        )
