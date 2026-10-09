"""
USTANING VARIANT BO'YICHA NARXLARI — kafel (foydalanuvchi 2026-08-31).

Kafelchi bitta yo'nalishga UCHTA stavka kiritadi: pol, devor va sokl
kafelini bosish bir xil ish emas. Shu paytgacha usta har yo'nalishga
BITTA narx qo'yardi.

Qulflanadigan shartnoma:
  * bitta yo'nalishga bir nechta variant narxi saqlanadi (biri
    ikkinchisini O'CHIRMAYDI — eski "yo'nalish bo'yicha o'chirish"
    mantiqi aynan shunday qilardi);
  * variant boshqa yo'nalishniki bo'lsa — 400;
  * ro'yxatdan chiqarilgan variant narxi o'chadi;
  * variantsiz sohalar AVVALGIDEK ishlaydi (regressiya yo'q).
"""

from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyRate,
    SpecialtyVariant,
    User,
)

RATES_URL = "/api/v1/master/auth/profile/rates/"


class VariantRateTests(TestCase):
    def setUp(self):
        self.kafel = MasterSpecialty.objects.create(
            name="Kafel (test)", code="kafel-r", unit="m²",
            calculator="variant", variant_price_is_material=True,
        )
        self.pol = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Pol kafeli", price=Decimal("45000"),
            order=0,
        )
        self.devor = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Devor kafeli", price=Decimal("50000"),
            order=1,
        )
        self.sokl = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Sokl kafeli", price=Decimal("125000"),
            order=2,
        )
        self.gisht = MasterSpecialty.objects.create(
            name="G'isht (test)", code="gisht-r", unit="dona"
        )

        self.user = User.objects.create(
            username="usta-r", phone_number="+998911111111", is_master=True
        )
        self.profile = MasterProfile.objects.create(
            user=self.user, specialty=self.kafel, experience_years=5
        )
        self.profile.specialties.add(self.kafel, self.gisht)

        self.api = APIClient()
        self.api.force_authenticate(self.user)

    def put(self, rates):
        return self.api.put(RATES_URL, {"rates": rates}, format="json")

    def test_UCHTA_variant_narxi_birga_saqlanadi(self):
        response = self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 60000},
            {"specialty": self.kafel.pk, "variant": self.devor.pk, "price": 70000},
            {"specialty": self.kafel.pk, "variant": self.sokl.pk, "price": 150000},
        ])

        self.assertEqual(response.status_code, 200)
        self.assertEqual(self.profile.rates.count(), 3)
        saved = dict(
            self.profile.rates.values_list("variant__name", "price")
        )
        self.assertEqual(saved, {
            "Pol kafeli": 60000,
            "Devor kafeli": 70000,
            "Sokl kafeli": 150000,
        })

    def test_javobda_variant_NOMI_qaytadi(self):
        response = self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 60000},
        ])
        row = response.data[0]
        self.assertEqual(row["variant"], self.pol.pk)
        self.assertEqual(row["variant_name"], "Pol kafeli")
        self.assertEqual(row["unit"], "m²")

    def test_royxatdan_chiqarilgan_variant_narxi_OCHADI(self):
        self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 60000},
            {"specialty": self.kafel.pk, "variant": self.sokl.pk, "price": 150000},
        ])
        # Endi faqat pol yuboriladi — sokl o'chishi kerak.
        self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 65000},
        ])

        self.assertEqual(
            list(self.profile.rates.values_list("variant__name", "price")),
            [("Pol kafeli", 65000)],
        )

    def test_BEGONA_variant__400(self):
        boshqa = MasterSpecialty.objects.create(
            name="Boshqa (test)", code="boshqa-r", unit="m²"
        )
        begona = SpecialtyVariant.objects.create(
            specialty=boshqa, name="Begona", price=Decimal("1000")
        )

        response = self.put([
            {"specialty": self.kafel.pk, "variant": begona.pk, "price": 1000},
        ])

        self.assertEqual(response.status_code, 400)
        self.assertEqual(self.profile.rates.count(), 0)

    def test_VARIANTSIZ_soha_avvalgidek(self):
        response = self.put([
            {"specialty": self.gisht.pk, "price": 1500},
        ])

        self.assertEqual(response.status_code, 200)
        rate = self.profile.rates.get()
        self.assertIsNone(rate.variant_id)
        self.assertEqual(rate.price, 1500)

    def test_variantli_va_variantsiz_ARALASH(self):
        self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 60000},
            {"specialty": self.gisht.pk, "price": 1500},
        ])
        self.assertEqual(self.profile.rates.count(), 2)

    def test_narx_YANGILANADI_dublikat_yaratmaydi(self):
        self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 60000},
        ])
        self.put([
            {"specialty": self.kafel.pk, "variant": self.pol.pk, "price": 80000},
        ])

        self.assertEqual(self.profile.rates.count(), 1)
        self.assertEqual(self.profile.rates.get().price, 80000)

    def test_OZ_yonalishi_bolmagan_soha__400(self):
        yot = MasterSpecialty.objects.create(
            name="Yot (test)", code="yot-r", unit="m²"
        )
        response = self.put([{"specialty": yot.pk, "price": 5000}])
        self.assertEqual(response.status_code, 400)


class VariantRateModelTests(TestCase):
    """Baza darajasidagi qoidalar."""

    def setUp(self):
        self.kafel = MasterSpecialty.objects.create(
            name="Kafel (m)", code="kafel-m", unit="m²"
        )
        self.pol = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Pol", price=Decimal("45000")
        )
        user = User.objects.create(
            username="usta-m", phone_number="+998922222222", is_master=True
        )
        self.profile = MasterProfile.objects.create(
            user=user, specialty=self.kafel, experience_years=1
        )

    def test_bir_variantga_IKKI_narx_yozilmaydi(self):
        from django.db import IntegrityError, transaction

        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.kafel, variant=self.pol,
            price=60000,
        )
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                MasterSpecialtyRate.objects.create(
                    profile=self.profile, specialty=self.kafel,
                    variant=self.pol, price=70000,
                )

    def test_VARIANTSIZ_narx_ham_bittadan_ortmaydi(self):
        from django.db import IntegrityError, transaction

        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.kafel, price=1000
        )
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                MasterSpecialtyRate.objects.create(
                    profile=self.profile, specialty=self.kafel, price=2000
                )
