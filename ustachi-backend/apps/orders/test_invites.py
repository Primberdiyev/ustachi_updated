"""
USTA TANLASH (shaxsiy taklif) testlari.

Foydalanuvchi talabi (2026-08-07): hisob tugagach mijozda ikki yo'l bo'lsin —
e'lonni hammaga berish YOKI ustalar ro'yxatidan o'zi yoqtirganini tanlab,
buyurtmani aynan unga yuborish.

Shu yerda qulflanadigan QOIDALAR:
  1. `master_ids` bilan yaratilgan e'lon YOPIQ — boshqa usta uni ko'rmaydi
     va javob bera olmaydi (ochiq e'lon xulqi esa O'ZGARMAYDI).
  2. Taklif hudud filtridan QAT'IY NAZAR yetib boradi — mijoz ustani ataylab
     tanlagan.
  3. Usta qabul qilsa oddiy javob (`OrderResponse`) yoziladi va oqim
     o'zgarishsiz davom etadi; rad etsa mijozga xabar ketadi.
  4. Mijoz istagan payt e'lonni hammaga ocha oladi (bir tomonlama).
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import (
    InviteStatus,
    Notification,
    NotificationType,
    Order,
    OrderInvite,
    OrderResponse,
    OrderStatus,
    ResponseStatus,
)
from apps.locations.models import Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"


class InviteFlowTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.other_region = Region.objects.create(name="Samarqand")
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]

        self.client_user = self._user("+998901110001", "Mijoz", region=self.region)
        self.chosen = self._master("+998901110002", "Tanlangan Usta", self.region)
        self.other = self._master("+998901110003", "Boshqa Usta", self.region)
        self.far = self._master("+998901110004", "Uzoq Usta", self.other_region)

    # ───────── yordamchilar ─────────
    def _user(self, phone, name, region=None):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=region
        )

    def _master(self, phone, name, region=None):
        user = self._user(phone, name, region=region)
        user.is_master = True
        user.save(update_fields=["is_master"])
        MasterProfile.objects.create(
            user=user, specialty=self.specialty, experience_years=5
        )
        return user

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _create(self, master_ids=None):
        payload = {
            "title": "2 qanotli oq deraza",
            "proposal": {"material": 0},
            "calculated_price": 4_280_636,
            "region": self.region.pk,
            "address": "Chilonzor 5",
        }
        if master_ids is not None:
            payload["master_ids"] = master_ids
        return self._as(self.client_user).post(
            f"{CLIENT}orders/", payload, format="json"
        )

    # ───────── yaratish ─────────
    def test_order_with_master_ids_is_private_and_only_invited_is_notified(self):
        response = self._create([self.chosen.pk])
        self.assertEqual(response.status_code, 201, response.data)
        self.assertFalse(response.data["is_public"])
        self.assertEqual(len(response.data["invites"]), 1)
        self.assertEqual(
            response.data["invites"][0]["master"]["id"], self.chosen.pk
        )
        self.assertEqual(response.data["invites"][0]["status"], InviteStatus.PENDING)

        # Tanlangan ustaga SHAXSIY taklif; boshqasiga hech narsa.
        self.assertTrue(
            Notification.objects.filter(
                user=self.chosen, type=NotificationType.ORDER_INVITE
            ).exists()
        )
        self.assertFalse(Notification.objects.filter(user=self.other).exists())

    def test_master_without_region_gets_nothing(self):
        """
        FAQAT O'Z VILOYATI (7-qoida, 2026-09-26): viloyati ko'rsatilmagan usta
        ochiq e'lonni na feed'da ko'radi, na xabar oladi. Ilgari u HAMMA
        viloyat e'lonlarini olardi — e'lonlar boshqa viloyatga oqib ketardi.
        Feed va xabar bir xil qoidada (2026-08-08 saboq).
        """
        homeless = self._master("+998901110007", "Hududsiz Usta", None)
        self.assertIsNone(homeless.region_id)

        self._create()

        self.assertFalse(
            Notification.objects.filter(user=homeless).exists(),
            "viloyatsiz usta boshqa viloyat e'lonini olmasin",
        )
        feed = self._as(homeless).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(feed.data), 0)

    def test_order_without_region_goes_to_nobody(self):
        """Viloyati yo'q e'lon hech bir viloyatga tegishli emas — hech kimga."""
        self.client_user.region = None
        self.client_user.save(update_fields=["region"])
        response = self._as(self.client_user).post(
            f"{CLIENT}orders/",
            {"title": "Deraza", "proposal": {"material": 0}, "calculated_price": 1},
            format="json",
        )
        self.assertEqual(response.status_code, 201, response.data)
        self.assertIsNone(response.data["region"])
        self.assertFalse(
            Notification.objects.filter(type=NotificationType.ORDER_PUBLISHED).exists()
        )

    def test_whole_region_is_notified_regardless_of_district(self):
        """Oddiy e'lon TUMANGA qaramaydi — viloyatdagi hamma ustaga boradi."""
        from apps.locations.models import City

        a = City.objects.create(name="Chilonzor", region=self.region)
        b = City.objects.create(name="Yunusobod", region=self.region)
        self.client_user.district = a
        self.client_user.save(update_fields=["district"])
        self.other.district = b
        self.other.save(update_fields=["district"])

        self._create()

        self.assertTrue(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_PUBLISHED
            ).exists(),
            "shu viloyatning boshqa tumanidagi usta ham olishi kerak",
        )
        self.assertFalse(Notification.objects.filter(user=self.far).exists())

    def test_rom_public_order_does_not_notify_master_from_another_region(self):
        """Eshik-rom ochiq buyurtma boshqa viloyatga tarqalmaydi."""
        self._create()
        self.assertFalse(
            Notification.objects.filter(user=self.far).exists(),
            "rom buyurtma boshqa viloyat ustasiga ketmasin",
        )

    def test_public_order_still_works_exactly_as_before(self):
        """Eski yo'l (usta tanlanmagan) — hech narsa o'zgarmasin."""
        response = self._create()
        self.assertEqual(response.status_code, 201, response.data)
        self.assertTrue(response.data["is_public"])
        self.assertEqual(response.data["invites"], [])
        self.assertTrue(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_PUBLISHED
            ).exists()
        )

    def test_unknown_or_non_master_id_is_rejected(self):
        response = self._create([self.client_user.pk])
        self.assertEqual(response.status_code, 400)
        self.assertEqual(Order.objects.count(), 0)

    # ───────── ko'rinish ─────────
    def test_private_order_hidden_from_other_masters_but_visible_to_invited(self):
        self._create([self.chosen.pk])

        mine = self._as(self.chosen).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(mine.data), 1)
        self.assertTrue(mine.data[0]["is_invited"])
        self.assertEqual(mine.data[0]["invite_status"], InviteStatus.PENDING)

        theirs = self._as(self.other).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(theirs.data), 0)

    def test_invite_reaches_master_in_another_region(self):
        """Hudud filtri taklifni TO'SMAYDI — mijoz ataylab tanlagan."""
        self._create([self.far.pk])
        feed = self._as(self.far).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(feed.data), 1)
        self.assertTrue(feed.data[0]["is_invited"])

    def test_public_order_is_not_marked_as_invited(self):
        self._create()
        feed = self._as(self.other).get(f"{MASTER}orders/feed/")
        self.assertFalse(feed.data[0]["is_invited"])
        self.assertIsNone(feed.data[0]["invite_status"])

    def test_uninvited_master_cannot_respond_to_private_order(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        response = self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(response.status_code, 400)
        self.assertEqual(OrderResponse.objects.count(), 0)

    def test_invited_master_sees_order_detail_before_answering(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        detail = self._as(self.chosen).get(f"{MASTER}orders/{order_id}/")
        self.assertEqual(detail.status_code, 200)

        forbidden = self._as(self.other).get(f"{MASTER}orders/{order_id}/")
        self.assertEqual(forbidden.status_code, 403)

    # ───────── javob / rad etish ─────────
    def test_accepting_invite_writes_response_and_closes_invite(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        response = self._as(self.chosen).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(response.status_code, 200, response.data)

        invite = OrderInvite.objects.get(order_id=order_id, master=self.chosen)
        self.assertEqual(invite.status, InviteStatus.ACCEPTED)
        self.assertTrue(
            Notification.objects.filter(
                user=self.client_user, type=NotificationType.ORDER_RESPONSE
            ).exists()
        )

    def test_declining_invite_notifies_client_and_keeps_order_open(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        response = self._as(self.chosen).post(
            f"{MASTER}orders/{order_id}/decline/",
            {"reason": "Bandman"},
            format="json",
        )
        self.assertEqual(response.status_code, 200, response.data)

        invite = OrderInvite.objects.get(order_id=order_id, master=self.chosen)
        self.assertEqual(invite.status, InviteStatus.DECLINED)
        self.assertEqual(invite.decline_reason, "Bandman")

        order = Order.objects.get(pk=order_id)
        self.assertEqual(order.status, OrderStatus.PUBLISHED)
        self.assertTrue(
            Notification.objects.filter(
                user=self.client_user, type=NotificationType.ORDER_INVITE_DECLINED
            ).exists()
        )

    def test_declining_after_accepting_withdraws_the_response(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        self._as(self.chosen).post(f"{MASTER}orders/{order_id}/respond/", {}, format="json")
        self._as(self.chosen).post(f"{MASTER}orders/{order_id}/decline/", {}, format="json")

        response = OrderResponse.objects.get(order_id=order_id, master=self.chosen)
        self.assertEqual(response.status, ResponseStatus.WITHDRAWN)

    def test_master_without_invite_cannot_decline(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        response = self._as(self.other).post(
            f"{MASTER}orders/{order_id}/decline/", {}, format="json"
        )
        self.assertEqual(response.status_code, 400)

    # ───────── mijozning keyingi harakatlari ─────────
    def test_client_can_invite_more_masters_later(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        response = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/invite/",
            {"master_ids": [self.other.pk]},
            format="json",
        )
        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(len(response.data["invites"]), 2)

        feed = self._as(self.other).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(feed.data), 1)

    def test_repeated_invite_does_not_duplicate(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/invite/",
            {"master_ids": [self.chosen.pk]},
            format="json",
        )
        self.assertEqual(OrderInvite.objects.filter(order_id=order_id).count(), 1)

    def test_client_opens_private_order_to_everyone(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        self.assertEqual(len(self._as(self.other).get(f"{MASTER}orders/feed/").data), 0)

        response = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/publish/", {}, format="json"
        )
        self.assertEqual(response.status_code, 200, response.data)
        self.assertTrue(response.data["is_public"])
        # Taklif tarixi saqlanadi.
        self.assertEqual(len(response.data["invites"]), 1)

        self.assertEqual(len(self._as(self.other).get(f"{MASTER}orders/feed/").data), 1)
        self.assertTrue(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_PUBLISHED
            ).exists()
        )

    # ───────── bekor qilish ─────────
    def test_cancel_hides_order_from_masters_and_tells_the_engaged_ones(self):
        """
        Mijoz bekor qilsa e'lon ustalar ro'yxatidan CHIQIB KETADI, taklif
        bergan usta esa buni BILADI (foydalanuvchi talabi 2026-08-08).
        """
        order_id = self._create().data["id"]
        # Bitta usta taklif berdi, ikkinchisi shunchaki ro'yxatda ko'rdi.
        self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        Notification.objects.all().delete()  # faqat bekor xabarini ko'ramiz

        cancelled = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/cancel/", {"reason": "Fikrim o'zgardi"},
            format="json",
        )
        self.assertEqual(cancelled.status_code, 200, cancelled.data)
        self.assertEqual(cancelled.data["status"], OrderStatus.CANCELLED)

        # 1) Ro'yxatdan yo'qoladi — IKKALA usta uchun ham.
        self.assertEqual(
            len(self._as(self.other).get(f"{MASTER}orders/feed/").data), 0
        )
        self.assertEqual(
            len(self._as(self.chosen).get(f"{MASTER}orders/feed/").data), 0
        )

        # 2) Taklif bergan usta XABAR oladi.
        self.assertTrue(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_CANCELLED
            ).exists()
        )
        # 3) Shunchaki ko'rgan ustaga xabar ketmaydi (shovqin bo'lmasin).
        self.assertFalse(
            Notification.objects.filter(user=self.chosen).exists()
        )

    def test_cancel_tells_invited_master_and_closes_the_invite(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        Notification.objects.all().delete()

        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/cancel/", {}, format="json"
        )

        self.assertTrue(
            Notification.objects.filter(
                user=self.chosen, type=NotificationType.ORDER_CANCELLED
            ).exists(),
            "shaxsan tanlangan usta javob kutib o'tirmasin",
        )
        invite = OrderInvite.objects.get(order_id=order_id, master=self.chosen)
        self.assertEqual(invite.status, InviteStatus.DECLINED)
        self.assertEqual(len(self._as(self.chosen).get(f"{MASTER}orders/feed/").data), 0)

    def test_cancelled_order_cannot_be_answered(self):
        order_id = self._create().data["id"]
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/cancel/", {}, format="json"
        )
        response = self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(response.status_code, 400)

    def test_engaged_master_is_told_only_once(self):
        """Ham tanlangan, ham javob bergan usta BITTA xabar oladi."""
        order_id = self._create().data["id"]
        self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        responses = self._as(self.client_user).get(
            f"{CLIENT}orders/{order_id}/responses/"
        )
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{responses.data[0]['id']}/choose/",
            {}, format="json",
        )
        Notification.objects.all().delete()

        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/cancel/", {}, format="json"
        )
        self.assertEqual(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_CANCELLED
            ).count(),
            1,
        )

    # ───────── usta tanlangach ─────────
    def test_chosen_order_disappears_for_everyone_else(self):
        """
        Mijoz bitta usta bilan kelishgach e'lon QOLGANLARGA ko'rinmaydi
        (foydalanuvchi talabi 2026-08-08).
        """
        order_id = self._create().data["id"]
        self._as(self.chosen).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        responses = self._as(self.client_user).get(
            f"{CLIENT}orders/{order_id}/responses/"
        ).data
        mine = next(r for r in responses if r["master"]["id"] == self.chosen.pk)

        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{mine['id']}/choose/",
            {}, format="json",
        )

        # Tanlanmagan usta uchun e'lon ro'yxatdan chiqib ketadi.
        self.assertEqual(
            len(self._as(self.other).get(f"{MASTER}orders/feed/").data), 0
        )
        # Tanlangan usta ham OCHIQ e'lonlar ro'yxatida ko'rmaydi — buyurtma
        # endi uning "Shaxsiy buyurtmalari"da.
        self.assertEqual(
            len(self._as(self.chosen).get(f"{MASTER}orders/feed/").data), 0
        )
        assigned = self._as(self.chosen).get(f"{MASTER}orders/?scope=assigned")
        self.assertEqual(len(assigned.data), 1)

        # Tanlanmagan usta javob bera olmaydi.
        again = self._as(self.other).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(again.status_code, 400)

    def test_choosing_closes_pending_invites_and_tells_those_masters(self):
        """Javob bermagan, lekin SHAXSAN taklif qilingan usta ham biladi."""
        order_id = self._create([self.chosen.pk, self.other.pk]).data["id"]
        self._as(self.chosen).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        responses = self._as(self.client_user).get(
            f"{CLIENT}orders/{order_id}/responses/"
        ).data
        Notification.objects.all().delete()

        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{responses[0]['id']}/choose/",
            {}, format="json",
        )

        self.assertTrue(
            Notification.objects.filter(
                user=self.other, type=NotificationType.ORDER_NOT_CHOSEN
            ).exists()
        )
        self.assertEqual(
            OrderInvite.objects.get(order_id=order_id, master=self.other).status,
            InviteStatus.DECLINED,
        )
        # Tanlangan ustaning taklifi javob berilganda ACCEPTED bo'lgan.
        self.assertEqual(
            OrderInvite.objects.get(order_id=order_id, master=self.chosen).status,
            InviteStatus.ACCEPTED,
        )

    def test_only_owner_can_invite_or_publish(self):
        order_id = self._create([self.chosen.pk]).data["id"]
        stranger = self._user("+998901110009", "Begona")

        self.assertEqual(
            self._as(stranger)
            .post(
                f"{CLIENT}orders/{order_id}/invite/",
                {"master_ids": [self.other.pk]},
                format="json",
            )
            .status_code,
            404,
        )
        self.assertEqual(
            self._as(stranger)
            .post(f"{CLIENT}orders/{order_id}/publish/", {}, format="json")
            .status_code,
            404,
        )
