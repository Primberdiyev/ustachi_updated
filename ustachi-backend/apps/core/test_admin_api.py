"""
Admin panel API — smoke testlar.

Ikkita narsani ushlaydi:
  1. RUXSAT — admin bo'lmagan hech kim `/api/v1/admin/` ga kira olmaydi.
     Bu eng muhim tekshiruv: panel endpointlari mijoz/usta tokeni bilan
     ochilib qolsa butun ma'lumot bazasi ochilgan bo'ladi.
  2. QUERYSET — har bir ro'yxat sahifasi haqiqatan ochiladi. `annotate`
     ichidagi noto'g'ri bog'lanish nomi (`related_name`) `manage.py check`
     dan o'tib ketadi va faqat so'rov paytida yorilib chiqadi.
"""

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.locations.models import Region
from apps.orders.models import Order, OrderStatus, Review

ADMIN = "/api/v1/admin/"

#: Har bir ro'yxat endpointi. Yangi viewset qo'shsangiz shu yerga qo'shing.
LIST_ENDPOINTS = [
    "users/",
    "masters/",
    "specialties/",
    "orders/",
    "reviews/",
    "chats/",
    "releases/",
    "dashboard/summary/",
    "dashboard/timeseries/",
    "catalog/regions/",
    "catalog/cities/",
]


class AdminApiAccessTests(TestCase):
    """Kim kira oladi."""

    def setUp(self):
        self.api = APIClient()
        self.admin = User.objects.create_superuser(
            username="admin1", password="parol12345", phone_number="+998900000001"
        )
        self.master = User.objects.create_user(
            phone_number="+998900000002", password=None, is_active=True, is_master=True
        )

    def test_anonim_kira_olmaydi(self):
        for path in LIST_ENDPOINTS:
            with self.subTest(path=path):
                self.assertEqual(self.api.get(ADMIN + path).status_code, 401)

    def test_usta_kira_olmaydi(self):
        self.api.force_authenticate(self.master)
        for path in LIST_ENDPOINTS:
            with self.subTest(path=path):
                self.assertEqual(self.api.get(ADMIN + path).status_code, 403)

    def test_admin_hamma_royxatni_ocha_oladi(self):
        self.api.force_authenticate(self.admin)
        for path in LIST_ENDPOINTS:
            with self.subTest(path=path):
                self.assertEqual(self.api.get(ADMIN + path).status_code, 200)


class AdminApiDataTests(TestCase):
    """Ma'lumot bor holatda javob shakli va amallar."""

    def setUp(self):
        self.api = APIClient()
        self.admin = User.objects.create_superuser(
            username="admin2", password="parol12345", phone_number="+998900000010"
        )
        self.api.force_authenticate(self.admin)

        self.region = Region.objects.create(name="Toshkent")
        # `get_or_create` — `get` EMAS: yo'nalishlar migratsiya ma'lumoti
        # bilan keladi, lekin `pytest --reuse-db` da suitedagi
        # `TransactionTestCase` (`apps/orders/test_realtime.py`) jadvalni
        # tozalab yuboradi va o'sha qatorlar qaytmaydi. Shunda bu fayl
        # DB holatiga bog'liq bo'lmay qoladi.
        self.specialty, _ = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )

        self.client_user = User.objects.create_user(
            phone_number="+998900000011",
            password=None,
            is_active=True,
            full_name="Mijoz Mijozov",
            region=self.region,
        )
        self.master_user = User.objects.create_user(
            phone_number="+998900000012",
            password=None,
            is_active=True,
            is_master=True,
            full_name="Usta Ustayev",
            region=self.region,
        )
        self.profile = MasterProfile.objects.create(
            user=self.master_user, specialty=self.specialty, experience_years=5
        )
        self.order = Order.objects.create(
            client=self.client_user,
            title="Rom ornatish",
            specialty=self.specialty,
            region=self.region,
            calculated_price=1_500_000,
            expires_at=timezone.now() + timezone.timedelta(hours=48),
        )

    def test_users_royxati_sahifalangan(self):
        response = self.api.get(ADMIN + "users/")
        self.assertEqual(response.status_code, 200)
        for key in ("count", "total_pages", "page", "page_size", "results"):
            self.assertIn(key, response.data)

    def test_users_rol_filtri(self):
        response = self.api.get(ADMIN + "users/?role=master")
        ids = [row["id"] for row in response.data["results"]]
        self.assertIn(self.master_user.id, ids)
        self.assertNotIn(self.client_user.id, ids)

    def test_user_bloklash(self):
        response = self.api.post(f"{ADMIN}users/{self.client_user.id}/block/")
        self.assertEqual(response.status_code, 200)
        self.client_user.refresh_from_db()
        self.assertFalse(self.client_user.is_active)

    def test_adminni_bloklab_bolmaydi(self):
        response = self.api.post(f"{ADMIN}users/{self.admin.id}/block/")
        self.assertEqual(response.status_code, 400)
        self.admin.refresh_from_db()
        self.assertTrue(self.admin.is_active)

    def test_ustani_tasdiqlash(self):
        response = self.api.post(f"{ADMIN}masters/{self.profile.id}/verify/")
        self.assertEqual(response.status_code, 200)
        self.profile.refresh_from_db()
        self.assertTrue(self.profile.is_verified)

    def test_buyurtma_kartochkasi(self):
        response = self.api.get(f"{ADMIN}orders/{self.order.id}/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["client"]["id"], self.client_user.id)
        self.assertIn("stage_events", response.data)
        self.assertIn("responses", response.data)

    def test_buyurtmani_majburiy_bekor_qilish(self):
        response = self.api.post(
            f"{ADMIN}orders/{self.order.id}/cancel/", {"reason": "Spam elon"}
        )
        self.assertEqual(response.status_code, 200)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, OrderStatus.CANCELLED)
        self.assertEqual(self.order.cancelled_reason, "Spam elon")
        # Mijoz xabardor qilinadi (o'zi so'ramagan bekor qilish).
        self.assertTrue(self.client_user.notifications.exists())

    def test_bekor_qilishda_sabab_shart(self):
        response = self.api.post(f"{ADMIN}orders/{self.order.id}/cancel/", {"reason": ""})
        self.assertEqual(response.status_code, 400)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, OrderStatus.PUBLISHED)

    def test_dashboard_summary(self):
        response = self.api.get(ADMIN + "dashboard/summary/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["orders"]["total"], 1)
        self.assertEqual(response.data["active_orders"], 1)
        self.assertEqual(response.data["pending_verification"], 1)

    def test_dashboard_timeseries_kun_soni(self):
        response = self.api.get(ADMIN + "dashboard/timeseries/?days=7")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 7)

    def test_bahoni_ochirish(self):
        review = Review.objects.create(
            order=self.order,
            client=self.client_user,
            master=self.master_user,
            rating=1,
            comment="Yomon",
        )
        response = self.api.delete(f"{ADMIN}reviews/{review.id}/")
        self.assertEqual(response.status_code, 204)
        self.assertFalse(Review.objects.filter(id=review.id).exists())

    def test_buyurtmani_tahrirlab_bolmaydi(self):
        """Buyurtma faqat o'qiladi — holat `cancel/` orqali o'zgaradi."""
        response = self.api.patch(
            f"{ADMIN}orders/{self.order.id}/", {"title": "Boshqa"}
        )
        self.assertEqual(response.status_code, 405)


class AdminLoginTests(TestCase):
    """`/api/v1/admin/auth/login/` — username + parol."""

    LOGIN = ADMIN + "auth/login/"

    def setUp(self):
        self.api = APIClient()
        self.admin = User.objects.create_superuser(
            username="admin_login", password="parol12345", phone_number="+998900000020"
        )

    def test_username_bilan_kiradi(self):
        response = self.api.post(
            self.LOGIN, {"username": "admin_login", "password": "parol12345"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertTrue(response.data["is_admin"])

    def test_notogri_parol(self):
        response = self.api.post(
            self.LOGIN, {"username": "admin_login", "password": "boshqa"}
        )
        self.assertEqual(response.status_code, 401)

    def test_yoq_username(self):
        response = self.api.post(
            self.LOGIN, {"username": "yoq_odam", "password": "parol12345"}
        )
        self.assertEqual(response.status_code, 401)

    def test_telefon_raqam_endi_qabul_qilinmaydi(self):
        """Eski maydon bilan so'rov 400 beradi — jimgina kirib ketmasin."""
        response = self.api.post(
            self.LOGIN, {"phone_number": "+998900000020", "password": "parol12345"}
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("username", response.data)

    def test_oddiy_foydalanuvchi_kira_olmaydi(self):
        User.objects.create_user(
            phone_number="+998900000021",
            password="parol12345",
            username="oddiy_user",
            is_active=True,
        )
        response = self.api.post(
            self.LOGIN, {"username": "oddiy_user", "password": "parol12345"}
        )
        self.assertEqual(response.status_code, 403)

    def test_faolsiz_admin_kira_olmaydi(self):
        self.admin.is_active = False
        self.admin.save(update_fields=["is_active"])
        response = self.api.post(
            self.LOGIN, {"username": "admin_login", "password": "parol12345"}
        )
        self.assertEqual(response.status_code, 403)
