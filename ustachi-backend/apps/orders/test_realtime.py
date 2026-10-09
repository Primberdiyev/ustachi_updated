"""
REAL-TIME (WebSocket) testlari.

Tekshiriladi: token bilan ulanish, tokensiz rad etilishi, va eng muhimi —
holat o'zgarganda (usta javob berdi / mijoz tanladi / yangi xabar) hodisa
ilovaga DARHOL yetib borishi.
"""

from channels.routing import URLRouter
from channels.testing.websocket import WebsocketCommunicator
from django.test import TransactionTestCase
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders import services
from apps.orders.models import ChatThread, NotificationType, Order
from apps.orders.routing import websocket_urlpatterns
from apps.orders.ws_auth import JWTAuthMiddleware
from apps.locations.models import Region

application = JWTAuthMiddleware(URLRouter(websocket_urlpatterns))


def access_token(user) -> str:
    return str(RefreshToken.for_user(user).access_token)


class RealtimeEventsTests(TransactionTestCase):
    """
    `TransactionTestCase` — consumer boshqa oqimda (thread) ishlaydi, shuning
    uchun oddiy `TestCase` tranzaksiyasidagi ma'lumot unga ko'rinmasdi.
    """

    def setUp(self):
        specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]
        # Bir viloyat — e'lon faqat shu viloyat ustasiga ko'rinadi.
        self.region = Region.objects.create(name="Toshkent (rt)")
        self.client_user = User.objects.create_user(
            phone_number="+998905550001", full_name="Mijoz", is_active=True,
            region=self.region,
        )
        self.master = User.objects.create_user(
            phone_number="+998905550002", full_name="Usta", is_active=True,
            region=self.region,
        )
        self.master.is_master = True
        self.master.save(update_fields=["is_master"])
        MasterProfile.objects.create(
            user=self.master, specialty=specialty, experience_years=4
        )
        # Token SINXRON kontekstda yaratiladi — `for_user()` DBga yozadi.
        self.client_token = access_token(self.client_user)
        self.master_token = access_token(self.master)

    async def _connect(self, token: str):
        communicator = WebsocketCommunicator(
            application, f"/ws/events/?token={token}"
        )
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        # Birinchi xabar — "connected" tasdig'i.
        hello = await communicator.receive_json_from(timeout=3)
        self.assertEqual(hello["topic"], "connected")
        return communicator

    async def test_connect_requires_valid_token(self):
        bad = WebsocketCommunicator(application, "/ws/events/?token=yaroqsiz")
        connected, _ = await bad.connect()
        self.assertFalse(connected)
        await bad.disconnect()

        missing = WebsocketCommunicator(application, "/ws/events/")
        connected, _ = await missing.connect()
        self.assertFalse(connected)
        await missing.disconnect()

    async def test_master_response_reaches_client_instantly(self):
        from channels.db import database_sync_to_async

        order = await database_sync_to_async(Order.objects.create)(
            client=self.client_user, title="Deraza", calculated_price=1000,
            region=self.region,
        )
        c = await self._connect(self.client_token)

        # Usta javob berdi — mijozga hodisa ketishi kerak.
        await database_sync_to_async(services.respond_to_order)(
            order, self.master, "Qabul qilaman"
        )

        event = await c.receive_json_from(timeout=3)
        self.assertEqual(event["topic"], NotificationType.ORDER_RESPONSE)
        self.assertEqual(event["order_id"], order.pk)
        self.assertEqual(event["unread_count"], 1)
        await c.disconnect()

    async def test_chat_message_event_carries_thread_id(self):
        from channels.db import database_sync_to_async

        order = await database_sync_to_async(Order.objects.create)(
            client=self.client_user, title="Eshik", calculated_price=1
        )
        thread = await database_sync_to_async(ChatThread.objects.create)(
            order=order, master=self.master
        )
        c = await self._connect(self.client_token)

        await database_sync_to_async(services.send_message)(
            thread, self.master, "Assalomu alaykum"
        )

        event = await c.receive_json_from(timeout=3)
        self.assertEqual(event["topic"], NotificationType.CHAT_MESSAGE)
        self.assertEqual(event["thread_id"], thread.pk)
        await c.disconnect()

    async def test_event_goes_only_to_its_owner(self):
        from channels.db import database_sync_to_async

        order = await database_sync_to_async(Order.objects.create)(
            client=self.client_user, title="Deraza", calculated_price=1,
            region=self.region,
        )
        # USTA ulandi — mijozga tegishli hodisani OLMASLIGI kerak.
        master_socket = await self._connect(self.master_token)

        await database_sync_to_async(services.respond_to_order)(
            order, self.master, ""
        )

        self.assertTrue(await master_socket.receive_nothing(timeout=1))
        await master_socket.disconnect()


class AvailabilityPushTests(TransactionTestCase):
    """
    "Buyurtma qabul qilaman" tugmasi (`MasterProfile.accepts_orders`).

    O'CHIQ bo'lsa: PUSH bormaydi, LEKIN bildirishnoma ro'yxatida va ochiq
    e'lonlar feed'ida ko'rinaveradi (foydalanuvchi qoidasi 2026-07-27).
    """

    def setUp(self):
        from apps.locations.models import Region

        specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]
        self.region = Region.objects.create(name="Toshkent")
        self.client_user = User.objects.create_user(
            phone_number="+998906660001",
            full_name="Mijoz",
            is_active=True,
            region=self.region,
        )

        def make_master(phone, accepts):
            u = User.objects.create_user(
                phone_number=phone, full_name=f"Usta {phone[-1]}",
                is_active=True, region=self.region,
            )
            u.is_master = True
            u.save(update_fields=["is_master"])
            MasterProfile.objects.create(
                user=u, specialty=specialty, experience_years=3,
                accepts_orders=accepts,
            )
            return u

        self.ready = make_master("+998906660002", True)
        self.busy = make_master("+998906660003", False)
        self.ready_token = access_token(self.ready)
        self.busy_token = access_token(self.busy)

    async def _connect(self, token):
        c = WebsocketCommunicator(application, f"/ws/events/?token={token}")
        connected, _ = await c.connect()
        self.assertTrue(connected)
        await c.receive_json_from(timeout=3)  # "connected"
        return c

    async def test_push_flag_follows_availability(self):
        from channels.db import database_sync_to_async

        ready_socket = await self._connect(self.ready_token)
        busy_socket = await self._connect(self.busy_token)

        order = await database_sync_to_async(Order.objects.create)(
            client=self.client_user,
            title="Deraza",
            calculated_price=100,
            region=self.region,
        )
        await database_sync_to_async(services.notify_masters_of_new_order)(order)

        # Qabul qiluvchi usta — push: True
        ready_event = await ready_socket.receive_json_from(timeout=3)
        self.assertEqual(ready_event["topic"], NotificationType.ORDER_PUBLISHED)
        self.assertTrue(ready_event["push"])

        # Qabul qilmayotgan usta — hodisa KELADI (qo'ng'iroqcha uchun),
        # lekin push: False (telefon ekraniga chiqmaydi).
        busy_event = await busy_socket.receive_json_from(timeout=3)
        self.assertEqual(busy_event["topic"], NotificationType.ORDER_PUBLISHED)
        self.assertFalse(busy_event["push"])

        await ready_socket.disconnect()
        await busy_socket.disconnect()

    def test_notification_row_exists_for_both(self):
        from apps.orders.models import Notification

        order = Order.objects.create(
            client=self.client_user,
            title="Eshik",
            calculated_price=1,
            region=self.region,
        )
        services.notify_masters_of_new_order(order)

        # IKKALASIDA ham bildirishnoma bor — ro'yxatda ko'rinadi.
        for master in (self.ready, self.busy):
            self.assertTrue(
                Notification.objects.filter(
                    user=master, type=NotificationType.ORDER_PUBLISHED
                ).exists(),
                msg=f"{master} uchun bildirishnoma yo'q",
            )

    def test_busy_master_still_sees_order_in_feed(self):
        from rest_framework.test import APIClient

        order = Order.objects.create(
            client=self.client_user,
            title="Eshik",
            calculated_price=1,
            region=self.region,
        )
        api = APIClient()
        api.force_authenticate(user=self.busy)
        feed = api.get("/api/v1/master/orders/feed/")
        self.assertEqual(feed.status_code, 200)
        self.assertEqual([o["id"] for o in feed.data], [order.pk])
