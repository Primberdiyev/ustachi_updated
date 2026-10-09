"""
`seed_demo_accounts` testlari — do'kon moderatori uchun 2 ta hisob.

Eng muhim ikki xossa:
  1. moderator OTP bilan KIRA OLADI va ro'yxatdan o'tish oqimiga
     TUSHMAYDI (`is_new_user=False`);
  2. `seed_mock_users --remove` bu hisoblarni O'CHIRMAYDI — aks holda
     namoyish ma'lumotini tozalash ilovani do'kon ko'rigida yiqitardi.
"""

from io import StringIO

from django.core.management import call_command
from django.test import TestCase, override_settings
from rest_framework.test import APIClient

from apps.accounts.management.commands.seed_demo_accounts import DEMO_PREFIX
from apps.accounts.models import MasterProfile, MasterSpecialtyRate, User
from apps.locations.models import City, Region

DEMO_MASTER_PHONE = "+998917777777"
DEMO_MASTER_CODE = "777777"
DEMO_CLIENT_PHONE = "+998918888888"
DEMO_CLIENT_CODE = "888888"


@override_settings(
    OTP_DEMO_PHONE=DEMO_MASTER_PHONE,
    OTP_DEMO_CODE=DEMO_MASTER_CODE,
    OTP_DEMO_PHONE_CLIENT=DEMO_CLIENT_PHONE,
    OTP_DEMO_CODE_CLIENT=DEMO_CLIENT_CODE,
)
class SeedDemoAccountsTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        region = Region.objects.create(name="Toshkent shahri")
        City.objects.create(name="Yunusobod tumani", region=region)

    def _seed(self, **kwargs):
        # `interactive=False` SHART: testda DEBUG=False bo'lgani uchun buyruq
        # tasdiq so'raydi va test javob yoza olmay yiqilardi (qarang
        # `seed_demo_accounts._confirm_on_production`).
        kwargs.setdefault("interactive", False)
        call_command("seed_demo_accounts", stdout=StringIO(), stderr=StringIO(), **kwargs)

    # ── yaratish ─────────────────────────────────────────────────────
    def test_creates_exactly_two_accounts(self):
        self._seed()

        self.assertEqual(User.objects.filter(username__startswith=DEMO_PREFIX).count(), 2)
        self.assertTrue(User.objects.get(username="demo_master").is_master)
        self.assertFalse(User.objects.get(username="demo_client").is_master)

    def test_master_profile_is_filled(self):
        """Moderator bo'sh profil emas, ishlaydigan ilovani ko'rsin."""
        self._seed()

        profile = MasterProfile.objects.get(user__username="demo_master")
        self.assertTrue(profile.is_verified)
        self.assertTrue(profile.bio)
        self.assertTrue(profile.company_name)
        self.assertGreater(profile.experience_years, 0)
        self.assertGreaterEqual(profile.specialties.count(), 2)
        self.assertTrue(profile.rates.exists())
        self.assertFalse(MasterSpecialtyRate.objects.filter(price__lte=0).exists())

    def test_accounts_use_configured_demo_phones(self):
        self._seed()

        self.assertEqual(
            User.objects.get(username="demo_master").phone_number, DEMO_MASTER_PHONE
        )
        self.assertEqual(
            User.objects.get(username="demo_client").phone_number, DEMO_CLIENT_PHONE
        )

    def test_second_run_creates_no_duplicates(self):
        self._seed()
        pks = set(User.objects.values_list("pk", flat=True))

        self._seed()

        self.assertEqual(set(User.objects.values_list("pk", flat=True)), pks)
        self.assertEqual(User.objects.filter(username__startswith=DEMO_PREFIX).count(), 2)

    # ── moderator haqiqatan kira oladimi ─────────────────────────────
    def test_reviewer_can_log_in_without_onboarding(self):
        """Asosiy tekshiruv: `is_new_user=False` va JWT qaytadi."""
        self._seed()
        client = APIClient()

        for namespace, phone, code in (
            ("master", DEMO_MASTER_PHONE, DEMO_MASTER_CODE),
            ("client", DEMO_CLIENT_PHONE, DEMO_CLIENT_CODE),
        ):
            base = f"/api/v1/{namespace}/auth/"
            send = client.post(base + "send-code/", {"phone_number": phone}, format="json")
            self.assertEqual(send.status_code, 200, namespace)

            verify = client.post(
                base + "verify-code/",
                {"phone_number": phone, "code": code},
                format="json",
            )
            self.assertEqual(verify.status_code, 200, namespace)
            body = verify.json()
            self.assertFalse(body["is_new_user"], f"{namespace}: onboarding'ga tushdi")
            self.assertTrue(body["access"])

    def test_wrong_code_is_rejected(self):
        self._seed()
        client = APIClient()
        base = "/api/v1/master/auth/"
        client.post(base + "send-code/", {"phone_number": DEMO_MASTER_PHONE}, format="json")

        verify = client.post(
            base + "verify-code/",
            {"phone_number": DEMO_MASTER_PHONE, "code": "000000"},
            format="json",
        )

        self.assertEqual(verify.status_code, 400)

    # ── mock seeder bilan ajratilganligi ─────────────────────────────
    def test_mock_purge_does_not_touch_demo_accounts(self):
        """ENG MUHIM: namoyish ma'lumotini tozalash moderatorni qulflab qo'ymasin."""
        self._seed()
        call_command("seed_mock_users", masters=3, clients=2, interactive=False,
                     stdout=StringIO(), stderr=StringIO())

        call_command("seed_mock_users", remove=True, interactive=False,
                     stdout=StringIO(), stderr=StringIO())

        self.assertEqual(User.objects.filter(username__startswith="mock_").count(), 0)
        self.assertEqual(User.objects.filter(username__startswith=DEMO_PREFIX).count(), 2)
        self.assertTrue(MasterProfile.objects.filter(user__username="demo_master").exists())

    # ── o'chirish ────────────────────────────────────────────────────
    def test_remove_deletes_demo_accounts(self):
        self._seed()

        self._seed(remove=True)

        self.assertEqual(User.objects.filter(username__startswith=DEMO_PREFIX).count(), 0)
        self.assertFalse(MasterProfile.objects.filter(user__username="demo_master").exists())

    def test_remove_on_empty_db_is_noop(self):
        out = StringIO()
        call_command("seed_demo_accounts", remove=True, interactive=False,
                     stdout=out, stderr=StringIO())

        self.assertIn("topilmadi", out.getvalue())

    # ── sozlama xatolari ─────────────────────────────────────────────
    @override_settings(OTP_DEMO_PHONE="", OTP_DEMO_PHONE_CLIENT="")
    def test_missing_demo_phone_settings_raise(self):
        from django.core.management.base import CommandError

        with self.assertRaises(CommandError):
            self._seed()

    @override_settings(
        OTP_DEMO_PHONE=DEMO_MASTER_PHONE, OTP_DEMO_PHONE_CLIENT=DEMO_MASTER_PHONE
    )
    def test_identical_demo_phones_raise(self):
        """Do'kon ikkala ilovani ALOHIDA hisob bilan tekshiradi."""
        from django.core.management.base import CommandError

        with self.assertRaises(CommandError):
            self._seed()
