"""
MIJOZ va USTA ilovasi xabarlari AJRATILADI (2026-09-26).

Muammo: bitta odam (bitta telefon raqami = bitta `User`) ikkala ilovaga
kirsa, har yangi buyurtma, javob, chat xabari IKKALA ilovada ham chiqardi —
chunki push tokeni, qo'ng'iroqcha ro'yxati va WebSocket kanali ilovani
ajratmasdi.

Shu yerda qulflanadigan QOIDALAR:
  1. Token qaysi ilovaniki — ro'yxatdan o'tgan MANZILDAN olinadi.
  2. Har xabar turi o'z ilovasiga: oluvchi buyurtma MIJOZI bo'lsa — mijoz
     ilovasi, aks holda — usta ilovasi (chat ham shunday).
  3. Ilovasi noma'lum ESKI token/yozuv hamma xabarni oladi — o'tish davrida
     hech kim bildirishnomasiz qolmaydi.
  4. Qo'ng'iroqcha ro'yxati, o'qilmaganlar soni va "hammasini o'qidim" —
     faqat o'z ilovasiniki.
  5. WebSocket: `?app=` bilan ulangan ilova faqat o'zinikini oladi, eski
     (`app` siz) ulanish avvalgidek hammasini.
"""

from unittest.mock import patch

from channels.routing import URLRouter
from channels.testing.websocket import WebsocketCommunicator
from django.test import TestCase, TransactionTestCase
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import AppKind, DeviceToken, MasterProfile, MasterSpecialty, User
from apps.accounts.services import push
from apps.orders import services
from apps.orders.models import (
    ChatThread,
    Notification,
    NotificationType,
    Order,
    OrderStatus,
)
from apps.orders.routing import websocket_urlpatterns
from apps.orders.ws_auth import JWTAuthMiddleware

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"

# Har tokenning nomi qaysi ilovaniki ekanini aytadi — tekshiruv o'qilishi oson.
CLIENT_TOKEN = "tok-client"
MASTER_TOKEN = "tok-master"
LEGACY_TOKEN = "tok-legacy"


class _Base(TestCase):
    """
    Asosiy qahramon — `dual`: u HAM mijoz (o'z buyurtmasi bor), HAM usta
    (boshqa buyurtmaga javob beradi). Ikkala ilovada ham tokeni bor.
    """

    def setUp(self):
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Rom ustasi"}
        )[0]
        self.dual = self._master("+998907770001", "Ikki rolli")
        self.other_client = self._user("+998907770002", "Boshqa mijoz")
        self.other_master = self._master("+998907770003", "Boshqa usta")

        # dual — mijoz sifatida
        self.own_order = Order.objects.create(
            client=self.dual, title="O'z derazam", calculated_price=100
        )
        # dual — usta sifatida (boshqa mijozning buyurtmasi)
        self.work_order = Order.objects.create(
            client=self.other_client, title="Mijoz eshigi", calculated_price=200
        )

        DeviceToken.objects.create(user=self.dual, token=CLIENT_TOKEN, app=AppKind.CLIENT)
        DeviceToken.objects.create(user=self.dual, token=MASTER_TOKEN, app=AppKind.MASTER)

        self.sent = []  # har push chaqiruvidagi tokenlar ro'yxati
        patcher = patch.object(push, "send_to_tokens", side_effect=self._capture)
        patcher.start()
        self.addCleanup(patcher.stop)

    # ───────── yordamchilar ─────────
    def _user(self, phone, name):
        return User.objects.create_user(phone_number=phone, full_name=name, is_active=True)

    def _master(self, phone, name):
        user = self._user(phone, name)
        user.is_master = True
        user.save(update_fields=["is_master"])
        MasterProfile.objects.create(user=user, specialty=self.specialty, experience_years=3)
        return user

    def _capture(self, tokens, title, body="", data=None):
        self.sent.append(sorted(tokens))
        return len(tokens)

    def assertPushedOnlyTo(self, token):
        """Oxirgi push faqat shu tokenga (dual'ning boshqa ilovasiga emas)."""
        self.assertTrue(self.sent, "push umuman yuborilmadi")
        self.assertEqual(self.sent[-1], [token])

    def notes(self, user, ntype):
        return Notification.objects.filter(user=user, type=ntype)


# ═════════════════════════ 1. Token ro'yxati ═════════════════════════


class DeviceRegistrationTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.user = User.objects.create_user(phone_number="+998907771001", is_active=True)
        self.user.is_master = True
        self.user.save(update_fields=["is_master"])
        self.api.force_authenticate(self.user)

    def test_client_url_marks_token_as_client_app(self):
        r = self.api.post(f"{CLIENT}auth/devices/", {"token": "a"}, format="json")
        self.assertEqual(r.status_code, 201)
        self.assertEqual(DeviceToken.objects.get(token="a").app, AppKind.CLIENT)
        self.assertEqual(r.data["app"], AppKind.CLIENT)

    def test_master_url_marks_token_as_master_app(self):
        r = self.api.post(f"{MASTER}auth/devices/", {"token": "b"}, format="json")
        self.assertEqual(r.status_code, 201)
        self.assertEqual(DeviceToken.objects.get(token="b").app, AppKind.MASTER)

    def test_same_person_keeps_one_token_per_app(self):
        self.api.post(f"{CLIENT}auth/devices/", {"token": "a"}, format="json")
        self.api.post(f"{MASTER}auth/devices/", {"token": "b"}, format="json")
        self.assertEqual(
            dict(DeviceToken.objects.filter(user=self.user).values_list("token", "app")),
            {"a": AppKind.CLIENT, "b": AppKind.MASTER},
        )

    def test_app_cannot_be_forged_from_request_body(self):
        # Ilova "men ustaman" deb yubora olmaydi — manzil hal qiladi.
        self.api.post(
            f"{CLIENT}auth/devices/", {"token": "a", "app": "master"}, format="json"
        )
        self.assertEqual(DeviceToken.objects.get(token="a").app, AppKind.CLIENT)

    def test_old_token_gets_its_app_on_next_registration(self):
        # O'tish davri: eski token (ilovasi noma'lum) ilova qayta ochilganda
        # belgilanadi.
        DeviceToken.objects.create(user=self.user, token="old")
        self.api.post(f"{MASTER}auth/devices/", {"token": "old"}, format="json")
        self.assertEqual(DeviceToken.objects.get(token="old").app, AppKind.MASTER)


# ═════════════════════════ 2. Push tanlovi ═════════════════════════


class PushFilterTests(_Base):
    def test_client_push_skips_master_app(self):
        push.send_to_user(self.dual, "x", app=AppKind.CLIENT)
        self.assertPushedOnlyTo(CLIENT_TOKEN)

    def test_master_push_skips_client_app(self):
        push.send_to_user(self.dual, "x", app=AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)

    def test_legacy_token_still_gets_everything(self):
        DeviceToken.objects.create(user=self.dual, token=LEGACY_TOKEN)
        push.send_to_user(self.dual, "x", app=AppKind.CLIENT)
        self.assertEqual(self.sent[-1], sorted([CLIENT_TOKEN, LEGACY_TOKEN]))
        push.send_to_user(self.dual, "x", app=AppKind.MASTER)
        self.assertEqual(self.sent[-1], sorted([MASTER_TOKEN, LEGACY_TOKEN]))

    def test_without_app_goes_to_all_devices(self):
        push.send_to_user(self.dual, "x")
        self.assertEqual(self.sent[-1], sorted([CLIENT_TOKEN, MASTER_TOKEN]))


# ═════════════════════ 3. Har xabar turi — o'z ilovasiga ═════════════════════


class AudienceRuleTests(_Base):
    def test_rule(self):
        self.assertEqual(services.audience_app(self.dual, self.own_order), AppKind.CLIENT)
        self.assertEqual(services.audience_app(self.dual, self.work_order), AppKind.MASTER)
        self.assertEqual(services.audience_app(self.dual, None), "")


class ToClientAppTests(_Base):
    """dual — o'z buyurtmasining MIJOZI: xabarlar faqat mijoz ilovasiga."""

    def test_master_responded(self):
        services.respond_to_order(self.own_order, self.other_master)
        note = self.notes(self.dual, NotificationType.ORDER_RESPONSE).get()
        self.assertEqual(note.app, AppKind.CLIENT)
        self.assertPushedOnlyTo(CLIENT_TOKEN)

    def test_invite_declined(self):
        services.invite_masters(self.own_order, [self.other_master])
        services.decline_invite(self.own_order, self.other_master, "band")
        note = self.notes(self.dual, NotificationType.ORDER_INVITE_DECLINED).get()
        self.assertEqual(note.app, AppKind.CLIENT)
        self.assertPushedOnlyTo(CLIENT_TOKEN)

    def test_stage_and_completion(self):
        response = services.respond_to_order(self.own_order, self.other_master)
        services.choose_master(self.own_order, response)
        self.own_order.refresh_from_db()
        services.advance_stage(self.own_order, self.other_master)
        self.assertEqual(
            self.notes(self.dual, NotificationType.ORDER_STAGE).get().app, AppKind.CLIENT
        )
        self.assertPushedOnlyTo(CLIENT_TOKEN)

        # Oxirigacha surib, yakunlaymiz.
        self.own_order.refresh_from_db()
        while self.own_order.status != OrderStatus.COMPLETED:
            services.advance_stage(self.own_order, self.other_master)
            self.own_order.refresh_from_db()
        self.assertEqual(
            self.notes(self.dual, NotificationType.ORDER_COMPLETED).get().app,
            AppKind.CLIENT,
        )
        self.assertPushedOnlyTo(CLIENT_TOKEN)

    def test_admin_cancel_informs_client_app(self):
        services.cancel_order(self.own_order, self.other_master, "admin", force=True)
        note = self.notes(self.dual, NotificationType.ORDER_CANCELLED).get()
        self.assertEqual(note.app, AppKind.CLIENT)
        self.assertPushedOnlyTo(CLIENT_TOKEN)

    def test_chat_from_master(self):
        thread = ChatThread.objects.create(order=self.own_order, master=self.other_master)
        services.send_message(thread, self.other_master, "Salom")
        note = self.notes(self.dual, NotificationType.CHAT_MESSAGE).get()
        self.assertEqual(note.app, AppKind.CLIENT)
        self.assertPushedOnlyTo(CLIENT_TOKEN)


class ToMasterAppTests(_Base):
    """dual — boshqa buyurtmaning USTASI: xabarlar faqat usta ilovasiga."""

    def test_new_public_order(self):
        order = Order.objects.create(
            client=self.other_client, title="Yangi e'lon", calculated_price=1
        )
        services.notify_masters_of_new_order(order)
        note = self.notes(self.dual, NotificationType.ORDER_PUBLISHED).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertEqual(self.sent[-1], [MASTER_TOKEN])

    def test_personal_invite(self):
        services.invite_masters(self.work_order, [self.dual])
        note = self.notes(self.dual, NotificationType.ORDER_INVITE).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)

    def test_chosen(self):
        response = services.respond_to_order(self.work_order, self.dual)
        services.choose_master(self.work_order, response)
        note = self.notes(self.dual, NotificationType.ORDER_CHOSEN).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)

    def test_not_chosen(self):
        services.respond_to_order(self.work_order, self.dual)
        winner = services.respond_to_order(self.work_order, self.other_master)
        services.choose_master(self.work_order, winner)
        note = self.notes(self.dual, NotificationType.ORDER_NOT_CHOSEN).get()
        self.assertEqual(note.app, AppKind.MASTER)

    def test_invited_but_not_chosen(self):
        services.invite_masters(self.work_order, [self.dual])
        winner = services.respond_to_order(self.work_order, self.other_master)
        services.choose_master(self.work_order, winner)
        note = self.notes(self.dual, NotificationType.ORDER_NOT_CHOSEN).get()
        self.assertEqual(note.app, AppKind.MASTER)

    def test_cancelled_by_client(self):
        services.respond_to_order(self.work_order, self.dual)
        services.cancel_order(self.work_order, self.other_client)
        note = self.notes(self.dual, NotificationType.ORDER_CANCELLED).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)

    def test_review(self):
        response = services.respond_to_order(self.work_order, self.dual)
        services.choose_master(self.work_order, response)
        self.work_order.refresh_from_db()
        while self.work_order.status != OrderStatus.COMPLETED:
            services.advance_stage(self.work_order, self.dual)
            self.work_order.refresh_from_db()
        services.leave_review(self.work_order, self.other_client, 5)
        note = self.notes(self.dual, NotificationType.REVIEW_RECEIVED).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)

    def test_chat_from_client(self):
        thread = ChatThread.objects.create(order=self.work_order, master=self.dual)
        services.send_message(thread, self.other_client, "Qachon kelasiz?")
        note = self.notes(self.dual, NotificationType.CHAT_MESSAGE).get()
        self.assertEqual(note.app, AppKind.MASTER)
        self.assertPushedOnlyTo(MASTER_TOKEN)


# ═════════════════════════ 4. Qo'ng'iroqcha ═════════════════════════


class BellTests(_Base):
    def setUp(self):
        super().setUp()
        self.api = APIClient()
        self.api.force_authenticate(self.dual)
        services.respond_to_order(self.own_order, self.other_master)  # → mijoz
        services.invite_masters(self.work_order, [self.dual])  # → usta
        # Ilovasi noma'lum eski yozuv — ikkalasida ham ko'rinishi kerak.
        Notification.objects.create(
            user=self.dual, type=NotificationType.ORDER_STAGE, title="Eski"
        )

    def _titles(self, prefix):
        data = self.api.get(f"{prefix}notifications/").data
        return data["unread_count"], sorted(n["title"] for n in data["results"])

    def test_each_app_sees_only_its_own(self):
        self.assertEqual(self._titles(CLIENT), (2, ["Eski", "Usta javob berdi"]))
        self.assertEqual(self._titles(MASTER), (2, ["Eski", "Sizga taklif"]))

    def test_read_all_touches_only_this_app(self):
        self.api.post(f"{CLIENT}notifications/read-all/")
        self.assertEqual(self._titles(CLIENT)[0], 0)
        # Usta ilovasidagi taklif hali O'QILMAGAN.
        self.assertFalse(
            self.notes(self.dual, NotificationType.ORDER_INVITE).get().is_read
        )


# ═════════════════════════ 5. WebSocket ═════════════════════════

application = JWTAuthMiddleware(URLRouter(websocket_urlpatterns))


class RealtimeSeparationTests(TransactionTestCase):
    def setUp(self):
        specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Rom ustasi"}
        )[0]
        self.dual = User.objects.create_user(
            phone_number="+998907772001", full_name="Ikki rolli", is_active=True
        )
        self.dual.is_master = True
        self.dual.save(update_fields=["is_master"])
        MasterProfile.objects.create(user=self.dual, specialty=specialty, experience_years=2)
        self.other_client = User.objects.create_user(
            phone_number="+998907772002", full_name="Mijoz", is_active=True
        )
        self.other_master = User.objects.create_user(
            phone_number="+998907772003", full_name="Usta", is_active=True
        )
        self.other_master.is_master = True
        self.other_master.save(update_fields=["is_master"])
        self.own_order = Order.objects.create(
            client=self.dual, title="O'zimniki", calculated_price=1
        )
        self.work_order = Order.objects.create(
            client=self.other_client, title="Ishim", calculated_price=1
        )
        self.token = str(RefreshToken.for_user(self.dual).access_token)

    async def _connect(self, app=""):
        suffix = f"&app={app}" if app else ""
        c = WebsocketCommunicator(application, f"/ws/events/?token={self.token}{suffix}")
        connected, _ = await c.connect()
        self.assertTrue(connected)
        await c.receive_json_from(timeout=3)  # "connected"
        return c

    async def test_each_app_socket_gets_only_its_events(self):
        from channels.db import database_sync_to_async as db

        client_app = await self._connect("client")
        master_app = await self._connect("master")
        legacy = await self._connect()

        # Mijozga tegishli: usta javob berdi.
        await db(services.respond_to_order)(self.own_order, self.other_master)
        event = await client_app.receive_json_from(timeout=3)
        self.assertEqual(event["topic"], NotificationType.ORDER_RESPONSE)
        self.assertEqual(event["unread_count"], 1)
        self.assertTrue(await master_app.receive_nothing(timeout=0.5))
        self.assertEqual(
            (await legacy.receive_json_from(timeout=3))["topic"],
            NotificationType.ORDER_RESPONSE,
        )

        # Ustaga tegishli: shaxsiy taklif.
        await db(services.invite_masters)(self.work_order, [self.dual])
        event = await master_app.receive_json_from(timeout=3)
        self.assertEqual(event["topic"], NotificationType.ORDER_INVITE)
        # Usta ilovasining O'Z soni (mijoz ilovasidagi 1 ta qo'shilmaydi).
        self.assertEqual(event["unread_count"], 1)
        self.assertTrue(await client_app.receive_nothing(timeout=0.5))
        self.assertEqual(
            (await legacy.receive_json_from(timeout=3))["topic"],
            NotificationType.ORDER_INVITE,
        )

        for c in (client_app, master_app, legacy):
            await c.disconnect()

    async def test_unknown_app_value_falls_back_to_legacy_channel(self):
        from channels.db import database_sync_to_async as db

        weird = await self._connect("hacker")
        await db(services.respond_to_order)(self.own_order, self.other_master)
        event = await weird.receive_json_from(timeout=3)
        self.assertEqual(event["topic"], NotificationType.ORDER_RESPONSE)
        await weird.disconnect()
