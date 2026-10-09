"""
`seed_mock_users` buyrug'i testlari.

Bu buyruq PRODUCTION bazasida ham ishlatiladi, shuning uchun eng muhim
tekshiruv — HAQIQIY foydalanuvchiga tegmasligi va `--remove` bilan izsiz
o'chishi. Qolgani: idempotentlik va narx qoidalari (birligi yo'q
yo'nalishda narx yo'q, kafelda har variantga alohida).
"""

from io import StringIO

from django.core.management import call_command
from django.test import TestCase

from apps.accounts.management.commands.seed_mock_users import MOCK_PREFIX
from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyRate,
    SpecialtyVariant,
    User,
)
from apps.locations.models import City, Region


class SeedMockUsersTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Manzil katalogi — buyruq bo'sh katalogda ishlashdan bosh tortadi.
        region = Region.objects.create(name="Test viloyati")
        City.objects.create(name="Test tumani", region=region)

        # Haqiqiy foydalanuvchi: purge unga TEGMASLIGI kerak.
        cls.real_user = User.objects.create_user(
            phone_number="+998901234567", full_name="Haqiqiy Foydalanuvchi"
        )

    def _seed(self, **kwargs):
        # `interactive=False` SHART: Django testda DEBUG'ni majburan False
        # qiladi, buyruq esa "production baza ko'rinadi" deb tasdiq so'raydi.
        # Test javob yoza olmaydi va EOFError bilan yiqilardi — testda savol
        # umuman berilmasligi kerak (CI'dagi `--noinput` bilan bir xil).
        kwargs.setdefault("interactive", False)
        call_command("seed_mock_users", stdout=StringIO(), stderr=StringIO(), **kwargs)

    # ── yaratish ─────────────────────────────────────────────────────
    def test_creates_masters_and_clients(self):
        self._seed(masters=5, clients=3)

        self.assertEqual(User.objects.filter(is_master=True).count(), 5)
        self.assertEqual(
            User.objects.filter(username__startswith=MOCK_PREFIX).count(), 8
        )
        self.assertEqual(MasterProfile.objects.count(), 5)

    def test_mock_users_are_active_and_passwordless(self):
        """Haqiqiy usta/mijoz kabi: faqat OTP bilan kiradi."""
        self._seed(masters=2, clients=1)

        for user in User.objects.filter(username__startswith=MOCK_PREFIX):
            self.assertTrue(user.is_active, user.username)
            self.assertFalse(user.has_usable_password(), user.username)
            self.assertIsNotNone(user.region_id)
            self.assertIsNotNone(user.district_id)

    def test_primary_specialty_is_in_m2m(self):
        """`MasterProfile.save()` invarianti — e'lon ko'rinishi shunga tayanadi."""
        self._seed(masters=6, clients=0)

        for profile in MasterProfile.objects.all():
            self.assertIn(
                profile.specialty_id,
                profile.specialties.values_list("id", flat=True),
                f"{profile.user} asosiy yo'nalishi M2M da yo'q",
            )

    # ── narx qoidalari ───────────────────────────────────────────────
    def test_no_rate_for_specialties_without_unit(self):
        """Rom/mebel/landshaftda narx so'ralmaydi — yozuv ham bo'lmasin."""
        self._seed()

        without_unit = MasterSpecialty.objects.filter(unit="")
        self.assertTrue(without_unit.exists(), "test uchun birliksiz yo'nalish kerak")
        self.assertFalse(
            MasterSpecialtyRate.objects.filter(specialty__in=without_unit).exists()
        )

    def test_material_variant_specialty_gets_rate_per_variant(self):
        """Kafel: pol/devor/sokl — uchtasi alohida stavka."""
        self._seed()

        specialty = MasterSpecialty.objects.filter(
            variant_price_is_material=True
        ).first()
        if specialty is None:
            self.skipTest("variant_price_is_material yo'nalish katalogda yo'q")

        variant_count = SpecialtyVariant.objects.filter(specialty=specialty).count()
        for profile in MasterProfile.objects.filter(specialties=specialty):
            rates = profile.rates.filter(specialty=specialty)
            self.assertEqual(rates.count(), variant_count)
            self.assertFalse(rates.filter(variant__isnull=True).exists())

    def test_rates_are_positive(self):
        self._seed()

        self.assertTrue(MasterSpecialtyRate.objects.exists())
        self.assertFalse(MasterSpecialtyRate.objects.filter(price__lte=0).exists())

    # ── idempotentlik ────────────────────────────────────────────────
    def test_second_run_creates_no_duplicates(self):
        self._seed(masters=5, clients=3)
        first = set(User.objects.values_list("pk", flat=True))
        rates_before = MasterSpecialtyRate.objects.count()

        self._seed(masters=5, clients=3)

        self.assertEqual(set(User.objects.values_list("pk", flat=True)), first)
        self.assertEqual(MasterSpecialtyRate.objects.count(), rates_before)

    def test_prices_are_deterministic_across_runs(self):
        """Qayta seed narxlarni sakratmasin — sobit `RANDOM_SEED`."""
        self._seed(masters=5, clients=0)
        before = dict(
            MasterSpecialtyRate.objects.values_list("pk", "price")
        )

        self._seed(masters=5, clients=0)

        self.assertEqual(
            dict(MasterSpecialtyRate.objects.values_list("pk", "price")), before
        )

    # ── o'chirish ────────────────────────────────────────────────────
    def test_remove_deletes_only_mock_users(self):
        self._seed(masters=5, clients=3)

        self._seed(remove=True)

        self.assertEqual(
            User.objects.filter(username__startswith=MOCK_PREFIX).count(), 0
        )
        self.assertEqual(MasterProfile.objects.count(), 0)
        self.assertEqual(MasterSpecialtyRate.objects.count(), 0)
        # Haqiqiy foydalanuvchi joyida.
        self.assertTrue(User.objects.filter(pk=self.real_user.pk).exists())

    def test_remove_on_empty_db_is_noop(self):
        out = StringIO()
        call_command("seed_mock_users", remove=True, interactive=False,
                     stdout=out, stderr=StringIO())

        self.assertIn("topilmadi", out.getvalue())
        self.assertTrue(User.objects.filter(pk=self.real_user.pk).exists())

    def test_seed_after_remove_restores_data(self):
        self._seed(masters=5, clients=3)
        self._seed(remove=True)
        self._seed(masters=5, clients=3)

        self.assertEqual(MasterProfile.objects.count(), 5)
        self.assertEqual(
            User.objects.filter(username__startswith=MOCK_PREFIX).count(), 8
        )
