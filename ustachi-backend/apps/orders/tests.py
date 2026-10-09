"""
Buyurtma marketplace testlari — TO'LIQ OQIM va holat mashinasi qoidalari.

Model (foydalanuvchi qarori 2026-07-26): mijoz E'LON qiladi → ustalar
"qabul qilaman" deydi (NARXSIZ) → chatda kelishadi → mijoz bittasini
tanlaydi → 5 bosqich → yakun → baho.
"""


from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import (
    ChatThread,
    Notification,
    NotificationType,
    Order,
    OrderResponse,
    OrderStage,
    OrderStatus,
    ResponseStatus,
    Review,
)
from apps.locations.models import City, Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"


class OrderFlowTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.other_region = Region.objects.create(name="Samarqand")
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]

        self.client_user = self._user("+998901112233", "Mijoz", region=self.region)
        self.master1 = self._master("+998901112244", "Usta Bir", region=self.region)
        self.master2 = self._master("+998901112255", "Usta Ikki", region=self.region)
        self.far_master = self._master(
            "+998901112266", "Uzoq Usta", region=self.other_region
        )

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

    def _create_order(self, **extra):
        payload = {
            "title": "2 bo'lmali deraza",
            "description": "2-qavat, lift yo'q",
            "proposal": {"type": "window", "width_mm": 1500, "height_mm": 1400},
            "calculated_price": 4_280_636,
            "address": "Chilonzor 5",
            **extra,
        }
        return self._as(self.client_user).post(
            f"{CLIENT}orders/", payload, format="json"
        )

    # ───────── e'lon ─────────
    def test_client_publishes_order_and_masters_are_notified(self):
        response = self._create_order()
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["status"], OrderStatus.PUBLISHED)
        # Mijoz hisobi o'zgarmas hujjat sifatida saqlanadi.
        self.assertEqual(response.data["calculated_price"], 4_280_636)
        self.assertIsNotNone(response.data["expires_at"])

        # Eshik-rom ochiq e'loni shu viloyatdagi rom ustalariga boradi.
        self.assertTrue(
            Notification.objects.filter(
                user=self.master1, type=NotificationType.ORDER_PUBLISHED
            ).exists()
        )
        self.assertFalse(Notification.objects.filter(user=self.far_master).exists())
        # Mijozning o'ziga xabar ketmaydi.
        self.assertFalse(Notification.objects.filter(user=self.client_user).exists())

    def test_rom_order_is_visible_to_the_whole_region_but_not_other_regions(self):
        self._create_order(region=self.region.pk)
        feed = self._as(self.master1).get(f"{MASTER}orders/feed/")
        self.assertEqual(feed.status_code, 200)
        self.assertEqual(len(feed.data), 1)
        self.assertIsNone(feed.data[0]["my_response_status"])

        far = self._as(self.far_master).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(far.data), 0)

    def test_rom_order_reaches_other_districts_in_the_same_region(self):
        order_district = City.objects.create(name="Qo'qon", region=self.region)
        master_district = City.objects.create(name="Marg'ilon", region=self.region)
        self.master1.district = master_district
        self.master1.save(update_fields=["district"])

        response = self._create_order(
            region=self.region.pk, district=order_district.pk
        )
        self.assertEqual(response.status_code, 201, response.data)
        order_id = response.data["id"]

        feed = self._as(self.master1).get(f"{MASTER}orders/feed/")
        self.assertIn(order_id, [o["id"] for o in feed.data])
        self.assertTrue(
            Notification.objects.filter(
                user=self.master1, order_id=order_id,
                type=NotificationType.ORDER_PUBLISHED,
            ).exists()
        )
        answer = self._as(self.master1).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(answer.status_code, 200, answer.data)

        outside_region = self._as(self.far_master).post(
            f"{MASTER}orders/{order_id}/respond/", {}, format="json"
        )
        self.assertEqual(outside_region.status_code, 400, outside_region.data)

    def test_client_is_not_master_forbidden_on_feed(self):
        response = self._as(self.client_user).get(f"{MASTER}orders/feed/")
        self.assertEqual(response.status_code, 403)

    # ───────── javob ─────────
    def test_master_responds_without_price_and_thread_opens(self):
        order_id = self._create_order().data["id"]
        response = self._as(self.master1).post(
            f"{MASTER}orders/{order_id}/respond/",
            {"message": "Ertaga o'lchov olaman"},
            format="json",
        )
        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(response.data["status"], ResponseStatus.INTERESTED)
        # Javobda NARX maydoni umuman yo'q — kelishuv chatda.
        self.assertNotIn("price", response.data)
        # Savdolashuv uchun suhbat darhol ochiladi.
        self.assertIsNotNone(response.data["thread_id"])
        self.assertTrue(
            ChatThread.objects.filter(order_id=order_id, master=self.master1).exists()
        )
        # Mijozga xabar.
        self.assertTrue(
            Notification.objects.filter(
                user=self.client_user, type=NotificationType.ORDER_RESPONSE
            ).exists()
        )

    def test_master_cannot_respond_twice_creates_single_row(self):
        order_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        self.assertEqual(
            OrderResponse.objects.filter(order_id=order_id, master=self.master1).count(),
            1,
        )

    def test_master_cannot_respond_to_own_order(self):
        # Usta ham mijoz bo'la oladi — o'z e'loniga javob bermasin.
        self.api.force_authenticate(user=self.master1)
        created = self.api.post(
            f"{CLIENT}orders/",
            {"title": "O'ziniki", "calculated_price": 100},
            format="json",
        )
        response = self._as(self.master1).post(
            f"{MASTER}orders/{created.data['id']}/respond/", {}
        )
        self.assertEqual(response.status_code, 400)

    def test_master_withdraws_response(self):
        order_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        response = self._as(self.master1).post(f"{MASTER}orders/{order_id}/withdraw/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["status"], ResponseStatus.WITHDRAWN)
        # Voz kechganlar mijoz ro'yxatida ko'rinmaydi.
        listing = self._as(self.client_user).get(f"{CLIENT}orders/{order_id}/responses/")
        self.assertEqual(len(listing.data), 0)

    # ───────── tanlash ─────────
    def test_client_chooses_master_others_rejected(self):
        order_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        self._as(self.master2).post(f"{MASTER}orders/{order_id}/respond/", {})

        responses = self._as(self.client_user).get(
            f"{CLIENT}orders/{order_id}/responses/"
        )
        self.assertEqual(len(responses.data), 2)
        # Usta kartasida reyting/tajriba bo'ladi (mijoz tanlov qilishi uchun).
        self.assertIn("rating", responses.data[0]["master"])
        self.assertEqual(responses.data[0]["master"]["experience_years"], 5)

        chosen_id = next(
            r["id"] for r in responses.data if r["master"]["id"] == self.master1.pk
        )
        result = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{chosen_id}/choose/"
        )
        self.assertEqual(result.status_code, 200, result.data)
        self.assertEqual(result.data["status"], OrderStatus.ASSIGNED)
        self.assertEqual(result.data["stage"], OrderStage.ACCEPTED)
        self.assertEqual(result.data["stage_step"], 1)
        self.assertEqual(result.data["assigned_master"]["id"], self.master1.pk)

        self.assertEqual(
            OrderResponse.objects.get(order_id=order_id, master=self.master2).status,
            ResponseStatus.REJECTED,
        )
        self.assertTrue(
            Notification.objects.filter(
                user=self.master1, type=NotificationType.ORDER_CHOSEN
            ).exists()
        )
        self.assertTrue(
            Notification.objects.filter(
                user=self.master2, type=NotificationType.ORDER_NOT_CHOSEN
            ).exists()
        )

    def test_cannot_choose_twice(self):
        order_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        rid = OrderResponse.objects.get(order_id=order_id).pk
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{rid}/choose/"
        )
        again = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{rid}/choose/"
        )
        self.assertEqual(again.status_code, 400)

    def test_other_client_cannot_see_or_choose(self):
        order_id = self._create_order().data["id"]
        stranger = self._user("+998900000000", "Begona")
        response = self._as(stranger).get(f"{CLIENT}orders/{order_id}/")
        self.assertEqual(response.status_code, 404)

    # ───────── bosqichlar ─────────
    def _assigned_order(self):
        order_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        rid = OrderResponse.objects.get(order_id=order_id).pk
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{rid}/choose/"
        )
        return order_id

    def test_rom_order_has_two_stages_then_completes(self):
        """ROM: qabul → o'lchov → YAKUN (foydalanuvchi qarori 2026-09-23)."""
        order_id = self._assigned_order()

        measured = self._as(self.master1).post(
            f"{MASTER}orders/{order_id}/advance/", {"note": "o'lchov olindi"}
        )
        self.assertEqual(measured.status_code, 200, measured.data)
        self.assertEqual(measured.data["stage"], OrderStage.MEASURED)
        self.assertEqual(measured.data["stage_step"], 2)
        self.assertEqual(measured.data["stage_total"], 2)

        # O'lchovdan keyin DARHOL yakunlanadi — oraliq bosqich yo'q.
        final = self._as(self.master1).post(f"{MASTER}orders/{order_id}/advance/")
        self.assertEqual(final.data["status"], OrderStatus.COMPLETED)
        self.assertIsNotNone(final.data["completed_at"])
        self.assertTrue(
            Notification.objects.filter(
                user=self.client_user, type=NotificationType.ORDER_COMPLETED
            ).exists()
        )
        # Tarixda ikki bosqich: qabul + o'lchov.
        self.assertEqual(len(final.data["stage_events"]), 2)

    def test_legacy_stage_order_can_be_finished(self):
        """Eski zanjirda qolgan buyurtma bir bosishda yakunlanadi."""
        order_id = self._assigned_order()
        Order.objects.filter(pk=order_id).update(stage=OrderStage.PRODUCTION)

        final = self._as(self.master1).post(f"{MASTER}orders/{order_id}/advance/")
        self.assertEqual(final.status_code, 200, final.data)
        self.assertEqual(final.data["status"], OrderStatus.COMPLETED)

    def test_other_master_cannot_advance(self):
        order_id = self._assigned_order()
        response = self._as(self.master2).post(f"{MASTER}orders/{order_id}/advance/")
        self.assertEqual(response.status_code, 403)

    def test_cannot_advance_unassigned_order(self):
        order_id = self._create_order().data["id"]
        response = self._as(self.master1).post(f"{MASTER}orders/{order_id}/advance/")
        self.assertEqual(response.status_code, 400)

    # ───────── bekor qilish / muddat ─────────
    def test_client_cancels_and_master_notified(self):
        order_id = self._assigned_order()
        response = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/cancel/", {"reason": "Fikrim o'zgardi"}
        )
        self.assertEqual(response.data["status"], OrderStatus.CANCELLED)
        self.assertTrue(
            Notification.objects.filter(
                user=self.master1, type=NotificationType.ORDER_CANCELLED
            ).exists()
        )

    def test_expired_order_leaves_feed_and_rejects_response(self):
        order_id = self._create_order().data["id"]
        Order.objects.filter(pk=order_id).update(
            expires_at=timezone.now() - timezone.timedelta(hours=1)
        )
        feed = self._as(self.master1).get(f"{MASTER}orders/feed/")
        self.assertEqual(len(feed.data), 0)

        response = self._as(self.master1).post(f"{MASTER}orders/{order_id}/respond/", {})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            Order.objects.get(pk=order_id).status, OrderStatus.EXPIRED
        )

    # ───────── baho ─────────
    def test_review_only_after_completion_and_once(self):
        order_id = self._assigned_order()
        # Yakunlanmagan buyurtmaga baho berib bo'lmaydi.
        early = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/review/", {"rating": 5}
        )
        self.assertEqual(early.status_code, 400)

        for _ in range(5):
            self._as(self.master1).post(f"{MASTER}orders/{order_id}/advance/")

        review = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/review/",
            {"rating": 5, "comment": "Zo'r ish"},
            format="json",
        )
        self.assertEqual(review.status_code, 201, review.data)
        self.assertEqual(Review.objects.count(), 1)
        self.assertTrue(
            Notification.objects.filter(
                user=self.master1, type=NotificationType.REVIEW_RECEIVED
            ).exists()
        )

        twice = self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/review/", {"rating": 3}
        )
        self.assertEqual(twice.status_code, 400)

    def test_review_updates_master_rating_in_response_card(self):
        order_id = self._assigned_order()
        for _ in range(5):
            self._as(self.master1).post(f"{MASTER}orders/{order_id}/advance/")
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/review/", {"rating": 4}, format="json"
        )

        # Yangi buyurtmada o'sha usta kartasida reyting ko'rinadi.
        new_id = self._create_order().data["id"]
        self._as(self.master1).post(f"{MASTER}orders/{new_id}/respond/", {})
        responses = self._as(self.client_user).get(f"{CLIENT}orders/{new_id}/responses/")
        self.assertEqual(responses.data[0]["master"]["rating"], 4.0)
        self.assertEqual(responses.data[0]["master"]["reviews_count"], 1)

    def test_master_search_by_phone_number(self):
        """
        Mijoz ustani TELEFON RAQAMI bilan ham topa oladi (talab 2026-08-08):
        ismini eslamasa ham raqamini bilsa yetadi.
        """
        url = f"{CLIENT}masters/"

        # To'liq raqam, mamlakat kodisiz va ajratkichlar bilan — uchalasi ham.
        for term in ("+998901112244", "901112244", "90 111 22 44"):
            found = self._as(self.client_user).get(url, {"search": term})
            self.assertEqual(found.status_code, 200, term)
            ids = [m["id"] for m in found.data]
            self.assertIn(self.master1.pk, ids, f"'{term}' bo'yicha topilmadi")
            self.assertNotIn(self.master2.pk, ids, term)

        # Ism bo'yicha qidiruv AVVALGIDEK ishlaydi.
        by_name = self._as(self.client_user).get(url, {"search": "Usta Bir"})
        self.assertEqual([m["id"] for m in by_name.data], [self.master1.pk])

        # Juda qisqa raqam bilan hamma topilib ketmasin.
        short = self._as(self.client_user).get(url, {"search": "99"})
        self.assertEqual(len(short.data), 0)



class ChatTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]
        # Bir viloyat — e'lon faqat shu viloyat ustasiga ko'rinadi.
        region = Region.objects.create(name="Toshkent (chat)")
        self.client_user = User.objects.create_user(
            phone_number="+998901110001", full_name="Mijoz", is_active=True,
            region=region,
        )
        self.master = User.objects.create_user(
            phone_number="+998901110002", full_name="Usta", is_active=True,
            region=region,
        )
        self.master.is_master = True
        self.master.save(update_fields=["is_master"])
        MasterProfile.objects.create(
            user=self.master, specialty=specialty, experience_years=3
        )
        self.stranger = User.objects.create_user(
            phone_number="+998901110003", full_name="Begona", is_active=True
        )

        self.api.force_authenticate(user=self.client_user)
        self.order_id = self.api.post(
            f"{CLIENT}orders/",
            {"title": "Eshik", "calculated_price": 1000},
            format="json",
        ).data["id"]
        self.api.force_authenticate(user=self.master)
        self.thread_id = self.api.post(
            f"{MASTER}orders/{self.order_id}/respond/", {}
        ).data["thread_id"]

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def test_both_sides_exchange_messages(self):
        sent = self._as(self.master).post(
            f"{MASTER}chat/threads/{self.thread_id}/messages/",
            {"text": "Assalomu alaykum, narxni kelishamizmi?"},
            format="json",
        )
        self.assertEqual(sent.status_code, 201, sent.data)
        self.assertTrue(sent.data["is_mine"])

        # Mijozga xabar bildirishnomasi keldi.
        self.assertTrue(
            Notification.objects.filter(
                user=self.client_user, type=NotificationType.CHAT_MESSAGE
            ).exists()
        )

        history = self._as(self.client_user).get(
            f"{CLIENT}chat/threads/{self.thread_id}/messages/"
        )
        self.assertEqual(len(history.data), 1)
        self.assertFalse(history.data[0]["is_mine"])

        reply = self._as(self.client_user).post(
            f"{CLIENT}chat/threads/{self.thread_id}/messages/",
            {"text": "Ha, 5 million bo'ladimi?"},
            format="json",
        )
        self.assertEqual(reply.status_code, 201)

    def test_thread_list_shows_peer_and_unread(self):
        self._as(self.master).post(
            f"{MASTER}chat/threads/{self.thread_id}/messages/",
            {"text": "Salom"},
            format="json",
        )
        threads = self._as(self.client_user).get(f"{CLIENT}chat/threads/")
        self.assertEqual(len(threads.data), 1)
        self.assertEqual(threads.data[0]["peer"]["full_name"], "Usta")
        self.assertEqual(threads.data[0]["unread_count"], 1)
        self.assertEqual(threads.data[0]["last_message"]["text"], "Salom")

        # Tarixni ochgach o'qilgan bo'ladi.
        self._as(self.client_user).get(
            f"{CLIENT}chat/threads/{self.thread_id}/messages/"
        )
        threads = self._as(self.client_user).get(f"{CLIENT}chat/threads/")
        self.assertEqual(threads.data[0]["unread_count"], 0)

    def test_stranger_cannot_read_or_write(self):
        read = self._as(self.stranger).get(
            f"{CLIENT}chat/threads/{self.thread_id}/messages/"
        )
        self.assertEqual(read.status_code, 403)
        write = self._as(self.stranger).post(
            f"{CLIENT}chat/threads/{self.thread_id}/messages/",
            {"text": "hey"},
            format="json",
        )
        self.assertEqual(write.status_code, 403)

    def test_empty_message_rejected(self):
        response = self._as(self.master).post(
            f"{MASTER}chat/threads/{self.thread_id}/messages/",
            {"text": "   "},
            format="json",
        )
        self.assertEqual(response.status_code, 400)


class NotificationTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.user = User.objects.create_user(
            phone_number="+998901110009", full_name="Foydalanuvchi", is_active=True
        )
        for i in range(3):
            Notification.objects.create(
                user=self.user,
                type=NotificationType.ORDER_STAGE,
                title=f"Xabar {i}",
            )
        self.api.force_authenticate(user=self.user)

    def test_list_with_unread_count(self):
        response = self.api.get(f"{CLIENT}notifications/")
        self.assertEqual(response.data["unread_count"], 3)
        self.assertEqual(len(response.data["results"]), 3)

    def test_mark_one_and_all_read(self):
        first = Notification.objects.filter(user=self.user).first()
        self.api.post(f"{CLIENT}notifications/{first.pk}/read/")
        self.assertEqual(
            self.api.get(f"{CLIENT}notifications/").data["unread_count"], 2
        )

        self.api.post(f"{CLIENT}notifications/read-all/")
        self.assertEqual(
            self.api.get(f"{CLIENT}notifications/").data["unread_count"], 0
        )

    def test_only_own_notifications(self):
        other = User.objects.create_user(
            phone_number="+998901110010", full_name="Boshqa", is_active=True
        )
        self.api.force_authenticate(user=other)
        self.assertEqual(
            self.api.get(f"{CLIENT}notifications/").data["unread_count"], 0
        )


class MasterPublicProfileTests(TestCase):
    """Mijoz ustani TANLASHDAN OLDIN u haqida to'liq ma'lumot ko'radi."""

    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]

        self.client_user = User.objects.create_user(
            phone_number="+998901230001",
            full_name="Mijoz",
            is_active=True,
            region=self.region,
        )
        self.master = User.objects.create_user(
            phone_number="+998901230002",
            full_name="Usta Aka",
            is_active=True,
            region=self.region,
        )
        self.master.is_master = True
        self.master.save(update_fields=["is_master"])
        self.profile = MasterProfile.objects.create(
            user=self.master,
            specialty=self.specialty,
            experience_years=7,
            bio="10 yildan beri rom bilan ishlayman",
        )

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def test_profile_shows_experience_bio_and_stats(self):
        response = self._as(self.client_user).get(f"{CLIENT}masters/{self.master.pk}/")
        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(response.data["full_name"], "Usta Aka")
        self.assertEqual(response.data["specialty"], self.specialty.name)
        self.assertEqual(response.data["experience_years"], 7)
        self.assertIn("rom bilan ishlayman", response.data["bio"])
        self.assertEqual(response.data["completed_orders"], 0)
        self.assertEqual(response.data["reviews_count"], 0)
        self.assertIsNone(response.data["rating"])
        self.assertEqual(response.data["work_samples"], [])
        self.assertEqual(response.data["reviews"], [])

    def test_reviews_and_rating_appear_after_completed_work(self):
        # To'liq oqim: e'lon → javob → tanlash → 5 bosqich → baho.
        order_id = self._as(self.client_user).post(
            f"{CLIENT}orders/",
            {"title": "Deraza", "calculated_price": 1000},
            format="json",
        ).data["id"]
        self._as(self.master).post(f"{MASTER}orders/{order_id}/respond/", {})
        rid = OrderResponse.objects.get(order_id=order_id).pk
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/responses/{rid}/choose/"
        )
        for _ in range(5):
            self._as(self.master).post(f"{MASTER}orders/{order_id}/advance/")
        self._as(self.client_user).post(
            f"{CLIENT}orders/{order_id}/review/",
            {"rating": 5, "comment": "Juda ozoda ishladi"},
            format="json",
        )

        response = self._as(self.client_user).get(f"{CLIENT}masters/{self.master.pk}/")
        self.assertEqual(response.data["rating"], 5.0)
        self.assertEqual(response.data["reviews_count"], 1)
        self.assertEqual(response.data["completed_orders"], 1)
        self.assertEqual(len(response.data["reviews"]), 1)
        review = response.data["reviews"][0]
        self.assertEqual(review["comment"], "Juda ozoda ishladi")
        self.assertEqual(review["client_name"], "Mijoz")

    def test_phone_is_public(self):
        """
        TELEFON RAQAM OCHIQ (foydalanuvchi qarori 2026-08-08).

        Ilgari u faqat usta shu mijozning buyurtmasiga javob berganidan
        keyin berilardi. Endi mijoz ro'yxatdan ham, profildan ham ko'rib
        to'g'ridan-to'g'ri qo'ng'iroq qila oladi.
        """
        # Hech qanday aloqa yo'q — baribir ko'rinadi.
        profile = self._as(self.client_user).get(
            f"{CLIENT}masters/{self.master.pk}/"
        )
        self.assertEqual(profile.data["phone_number"], "+998901230002")

        # RO'YXAT kartasida ham.
        listed = self._as(self.client_user).get(f"{CLIENT}masters/")
        card = next(m for m in listed.data if m["id"] == self.master.pk)
        self.assertEqual(card["phone_number"], "+998901230002")

    def test_non_master_returns_404(self):
        other = User.objects.create_user(
            phone_number="+998901230003", full_name="Oddiy", is_active=True
        )
        response = self._as(self.client_user).get(f"{CLIENT}masters/{other.pk}/")
        self.assertEqual(response.status_code, 404)

    def test_inactive_master_profile_returns_404(self):
        self.master.is_active = False
        self.master.save(update_fields=["is_active"])
        response = self._as(self.client_user).get(f"{CLIENT}masters/{self.master.pk}/")
        self.assertEqual(response.status_code, 404)

    def test_public_rates_include_variant_and_preserve_legacy_fields(self):
        from apps.accounts.models import MasterSpecialtyRate, SpecialtyVariant

        variant = SpecialtyVariant.objects.create(
            specialty=self.specialty, name="Pol", price=1000,
        )
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.specialty, variant=variant, price=25000,
        )
        for url in (f"{CLIENT}masters/{self.master.pk}/", f"{CLIENT}masters/"):
            with self.subTest(url=url):
                response = self._as(self.client_user).get(url)
                data = response.data if isinstance(response.data, dict) else response.data[0]
                rate = data["rates"][0]
                self.assertEqual(rate["name"], f"{self.specialty.name} — Pol")
                self.assertEqual(rate["specialty_name"], self.specialty.name)
                self.assertEqual(rate["variant_name"], "Pol")
                self.assertEqual(rate["variant"], variant.pk)
                self.assertEqual(rate["code"], self.specialty.code)
                self.assertEqual(rate["price"], 25000)

    def test_selected_specialty_rates_come_first_without_losing_other_rates(self):
        from apps.accounts.models import MasterSpecialtyRate

        other = MasterSpecialty.objects.get(code="elektrik")
        self.profile.specialties.add(other)
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.specialty, price=10000,
        )
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=other, price=20000,
        )
        response = self._as(self.client_user).get(f"{CLIENT}masters/?specialty={other.pk}")
        rates = response.data[0]["rates"]
        self.assertEqual(len(rates), 2)
        self.assertEqual(rates[0]["specialty"], other.pk)
        self.assertEqual(rates[0]["price"], 20000)


class MasterListTests(TestCase):
    """
    Mijozdagi "Ustalar" ro'yxati — REAL ma'lumot.

    Faqat faol, kasbiy profili va yo'nalishi mavjud ustalar ko'rinadi.
    """

    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.other_region = Region.objects.create(name="Samarqand")
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]
        # Yo'nalish nomi ustaning ISMIGA o'xshamasligi kerak — aks holda
        # "yo'nalish bo'yicha topildi"mi yoki "ism bo'yicha"mi, bilib
        # bo'lmaydi.
        self.specialty2 = MasterSpecialty.objects.get_or_create(
            name="Darvoza-panjara ustasi"
        )[0]

        self.client_user = User.objects.create_user(
            phone_number="+998901240001", full_name="Mijoz", is_active=True,
            region=self.region,
        )
        # (a) Profili TO'LIQ usta
        self.full = self._master("+998901240002", "To'liq Usta", self.region)
        MasterProfile.objects.create(
            user=self.full, specialty=self.specialty, experience_years=7,
            bio="tajribali",
        )
        # (b) Profilsiz usta — ilovaga endi kirgan
        self.bare = self._master("+998901240003", "Yangi Usta", self.other_region)
        # (c) Boshqa yo'nalish
        self.doors = self._master("+998901240004", "Sardor Usta", self.region)
        MasterProfile.objects.create(
            user=self.doors, specialty=self.specialty2, experience_years=3,
        )

    def _master(self, phone, name, region):
        user = User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=region,
        )
        user.is_master = True
        user.save(update_fields=["is_master"])
        return user

    def _get(self, query=""):
        self.api.force_authenticate(user=self.client_user)
        return self.api.get(f"{CLIENT}masters/{query}")

    def test_only_masters_with_professional_profile_are_listed(self):
        response = self._get()
        self.assertEqual(response.status_code, 200, response.data)
        names = {m["full_name"] for m in response.data}
        self.assertEqual(names, {"To'liq Usta", "Sardor Usta"})

    def test_client_is_not_listed_as_master(self):
        names = {m["full_name"] for m in self._get().data}
        self.assertNotIn("Mijoz", names)

    def test_card_carries_professional_fields(self):
        card = next(m for m in self._get().data if m["full_name"] == "To'liq Usta")
        self.assertEqual(card["specialty"], self.specialty.name)
        self.assertEqual(card["experience_years"], 7)
        self.assertEqual(card["region_name"], "Toshkent")
        self.assertEqual(card["completed_orders"], 0)
        self.assertEqual(card["reviews_count"], 0)
        self.assertIsNone(card["rating"])
        self.assertEqual(card["work_samples_count"], 0)

    def test_inactive_master_is_excluded_even_with_profile(self):
        self.full.is_active = False
        self.full.save(update_fields=["is_active"])
        for query in ("", "?search=To'liq", f"?specialty={self.specialty.pk}"):
            with self.subTest(query=query):
                self.assertNotIn(self.full.pk, {m["id"] for m in self._get(query).data})

    def test_incomplete_master_is_excluded_from_search_and_region_filter(self):
        for query in ("?search=Yangi", f"?region={self.other_region.pk}"):
            with self.subTest(query=query):
                self.assertEqual(self._get(query).data, [])

    def test_master_becomes_visible_after_completing_profile(self):
        MasterProfile.objects.create(
            user=self.bare, specialty=self.specialty, experience_years=0,
        )
        self.assertIn(self.bare.pk, {m["id"] for m in self._get().data})

    def test_client_with_profile_but_without_master_role_is_excluded(self):
        MasterProfile.objects.create(
            user=self.client_user, specialty=self.specialty, experience_years=2,
        )
        self.assertNotIn(self.client_user.pk, {m["id"] for m in self._get().data})

    def test_filter_by_region_and_specialty(self):
        by_region = {m["full_name"] for m in self._get(f"?region={self.region.pk}").data}
        self.assertEqual(by_region, {"To'liq Usta", "Sardor Usta"})

        by_spec = {
            m["full_name"] for m in self._get(f"?specialty={self.specialty2.pk}").data
        }
        self.assertEqual(by_spec, {"Sardor Usta"})

    def test_search_matches_name_and_specialty(self):
        # Ustaning ismida "Darvoza" YO'Q — demak u AYNAN yo'nalish nomi
        # bo'yicha topildi.
        self.assertEqual(
            {m["full_name"] for m in self._get("?search=Darvoza").data},
            {"Sardor Usta"},
            "yo'nalish nomi bo'yicha ham topilishi kerak",
        )
        self.assertEqual(
            {m["full_name"] for m in self._get("?search=Sardor").data}, {"Sardor Usta"}
        )

    def test_anonymous_cannot_list(self):
        self.assertEqual(APIClient().get(f"{CLIENT}masters/").status_code, 401)

    def test_pagination_is_opt_in_and_pages_preserve_legacy_cards(self):
        # Same timestamps must still have a deterministic tie-breaker.
        User.objects.filter(pk=self.doors.pk).update(date_joined=self.full.date_joined)
        legacy = self._get().data
        self.assertIsInstance(legacy, list)
        self.assertEqual(len(legacy), 2)
        first = self._get("?page=1&page_size=1")
        second = self._get("?page=2&page_size=1")
        self.assertEqual(first.status_code, 200)
        self.assertEqual(first.data["next_page"], 2)
        self.assertIsNone(second.data["next_page"])
        self.assertEqual(first.data["results"] + second.data["results"], legacy)
        self.assertEqual(self._get("?page=3&page_size=1").data,
                         {"results": [], "next_page": None})
        # Merely passing page_size must not change the released-client contract.
        self.assertEqual(self._get("?page_size=1").data, legacy)

    def test_pagination_applies_filters_before_slicing(self):
        for query in (
            f"specialty={self.specialty2.pk}",
            "search=Sardor",
            f"region={self.other_region.pk}",
        ):
            with self.subTest(query=query):
                legacy = self._get(f"?{query}").data
                paged = self._get(f"?page=1&page_size=1&{query}")
                self.assertEqual(paged.status_code, 200)
                self.assertEqual(paged.data["results"], legacy)
                self.assertIsNone(paged.data["next_page"])

    def test_invalid_pagination_returns_400_not_500(self):
        for query in ("page=0", "page=-1", "page=abc", "page=1.5",
                      "page=1&page_size=0", "page=1&page_size=101"):
            with self.subTest(query=query):
                self.assertEqual(self._get(f"?{query}").status_code, 400)

    def test_default_page_limits_cards_without_truncating_legacy_list(self):
        for i in range(21):
            master = self._master(f"+998907770{i:03d}", f"Usta {i}", self.region)
            MasterProfile.objects.create(
                user=master, specialty=self.specialty, experience_years=0,
            )
        self.assertEqual(len(self._get().data), 23)
        page = self._get("?page=1").data
        self.assertEqual(len(page["results"]), 20)
        self.assertEqual(page["next_page"], 2)
        last = self._get("?page=2").data
        self.assertEqual(len(last["results"]), 3)
        self.assertIsNone(last["next_page"])


class ResponseServicePriceTests(TestCase):
    """
    Usta javobidagi `service_total`: stavka bo'yicha hisoblab bo'lmaydigan
    yo'nalishda u `null` — narx chatda kelishiladi.
    """

    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.specialty = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )[0]
        self.client_user = User.objects.create_user(
            phone_number="+998905550001", full_name="Mijoz",
            is_active=True, region=self.region,
        )
        self.master = User.objects.create_user(
            phone_number="+998905550002", full_name="Usta",
            is_active=True, region=self.region,
        )
        self.master.is_master = True
        self.master.save(update_fields=["is_master"])
        self.profile = MasterProfile.objects.create(
            user=self.master,
            specialty=self.specialty,
            experience_years=5,
        )

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _order(self, material=0, price=1_000_000):
        proposal = {"type": "window", "material": material}
        resp = self._as(self.client_user).post(
            f"{CLIENT}orders/",
            {
                "title": "Deraza",
                "description": "-",
                "proposal": proposal,
                "calculated_price": price,
                "address": "Chilonzor",
            },
            format="json",
        )
        assert resp.status_code in (200, 201), resp.data
        return resp.data["id"]

    def _responses(self, order_id):
        return self._as(self.client_user).get(
            f"{CLIENT}orders/{order_id}/responses/"
        )

    def test_rom_javobida_service_total_NULL(self):
        for price in (0, 1_000_000):
            with self.subTest(price=price):
                order_id = self._order(material=0, price=price)
                self._as(self.master).post(f"{MASTER}orders/{order_id}/respond/", {})
                data = self._responses(order_id).data
                rows = data["results"] if isinstance(data, dict) else data
                self.assertIsNone(rows[0]["service_total"])
                self.assertNotIn("benefit_percent", rows[0])
