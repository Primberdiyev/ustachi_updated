"""
USTANING NARXI — yo'nalish bo'yicha, o'lchov birligida (2026-08-13).

Foydalanuvchi talabi: "usta ma'lumotni to'ldirishda tanlagan sohaga qarab
qanchadan ishlashini so'rashi kerak — g'ishtni donasini, zinani metrini,
elektrikni tochkasini, polni kvadratini". Mijoz shu bilan ustalarni bir xil
o'lchovda taqqoslaydi.
"""

from unittest.mock import patch

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyRate,
    User,
)

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/auth/"


class SpecialtyUnitTests(TestCase):
    """Katalogda har sohaning O'LCHOVI va SAVOLI bor."""

    def setUp(self):
        self.api = APIClient()

    def test_katalogda_birlik_va_savol_keladi(self):
        rows = {r["code"]: r for r in self.api.get(f"{CLIENT}specialties/").data}

        self.assertEqual(rows["gisht"]["unit"], "dona")
        self.assertEqual(rows["zina"]["unit"], "metr")
        self.assertEqual(rows["elektrik"]["unit"], "nuqta")
        self.assertEqual(rows["pol"]["unit"], "m²")
        self.assertEqual(rows["mardikor"]["unit"], "kun")
        # Savol SOHA TILIDA — usta o'ylab o'tirmasin.
        self.assertIn("g'ishtni", rows["gisht"]["unit_question"].lower())

    def test_ROM_da_narx_SO_RALMAYDI(self):
        # Rom narxini kalkulyator hisoblaydi; mebel har loyihaga qarab.
        rows = {r["code"]: r for r in self.api.get(f"{CLIENT}specialties/").data}

        self.assertEqual(rows["rom"]["unit"], "")
        self.assertEqual(rows["mebel"]["unit"], "")


@patch("apps.accounts.api.v1.views.send_otp_sms")
class MasterRatesTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.gisht = MasterSpecialty.objects.get(code="gisht")
        self.zina = MasterSpecialty.objects.get(code="zina")
        self.rom = MasterSpecialty.objects.get(code="rom")
        self.tom = MasterSpecialty.objects.get(code="tom")

        self.user = User.objects.create_user(
            phone_number="+998901112233", full_name="Usta", is_active=True
        )
        self.user.is_master = True
        self.user.save(update_fields=["is_master"])
        self.profile = MasterProfile.objects.create(
            user=self.user, specialty=self.gisht, experience_years=5
        )
        self.profile.specialties.set([self.gisht, self.zina, self.rom])
        self.api.force_authenticate(user=self.user)

    def _put(self, rates):
        return self.api.put(
            f"{MASTER}profile/rates/", {"rates": rates}, format="json"
        )

    def test_narx_saqlanadi_va_birlik_bilan_qaytadi(self, _sms):
        resp = self._put([
            {"specialty": self.gisht.pk, "price": 1500},
            {"specialty": self.zina.pk, "price": 350000},
        ])
        self.assertEqual(resp.status_code, 200, resp.data)

        rows = {r["code"]: r for r in resp.data}
        self.assertEqual(rows["gisht"]["price"], 1500)
        self.assertEqual(rows["gisht"]["unit"], "dona")
        self.assertEqual(rows["zina"]["unit"], "metr")

    def test_narx_YANGILANADI_dublikat_yaratmaydi(self, _sms):
        self._put([{"specialty": self.gisht.pk, "price": 1500}])
        self._put([{"specialty": self.gisht.pk, "price": 1800}])

        rates = MasterSpecialtyRate.objects.filter(profile=self.profile)
        self.assertEqual(rates.count(), 1)
        self.assertEqual(rates.first().price, 1800)

    def test_royxatdan_TUSHGAN_narx_ochiriladi(self, _sms):
        """Usta sohani tashlab ketsa eski narxi osilib qolmasin."""
        self._put([
            {"specialty": self.gisht.pk, "price": 1500},
            {"specialty": self.zina.pk, "price": 350000},
        ])
        resp = self._put([{"specialty": self.gisht.pk, "price": 1500}])

        self.assertEqual([r["code"] for r in resp.data], ["gisht"])

    def test_BIRLIKSIZ_yonalishga_narx_saqlanmaydi(self, _sms):
        # Rom — kalkulyator hisoblaydi.
        resp = self._put([{"specialty": self.rom.pk, "price": 999}])

        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data, [])

    def test_O_ZINIKI_bo_lmagan_yonalishga_narx_qo_yib_bo_lmaydi(self, _sms):
        # Usta tom yo'nalishini tanlamagan — u yerda narx e'lon qilishi
        # mijozni chalg'itardi.
        resp = self._put([{"specialty": self.tom.pk, "price": 100000}])

        self.assertEqual(resp.status_code, 400, resp.data)

    def test_manfiy_narx_RAD_etiladi(self, _sms):
        self.assertEqual(
            self._put([{"specialty": self.gisht.pk, "price": -5}]).status_code,
            400,
        )

    def test_profilsiz_usta_narx_yozolmaydi(self, _sms):
        other = User.objects.create_user(
            phone_number="+998901112244", full_name="Yangi", is_active=True
        )
        other.is_master = True
        other.save(update_fields=["is_master"])
        self.api.force_authenticate(user=other)

        self.assertEqual(
            self._put([{"specialty": self.gisht.pk, "price": 1500}]).status_code,
            400,
        )

    def test_profil_javobida_narxlar_keladi(self, _sms):
        self._put([{"specialty": self.gisht.pk, "price": 1500}])

        resp = self.api.get(f"{MASTER}profile/")
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data["rates"][0]["price"], 1500)
        self.assertEqual(resp.data["rates"][0]["unit"], "dona")

    def test_MIJOZ_usta_kartasida_narxni_koradi(self, _sms):
        self._put([{"specialty": self.gisht.pk, "price": 1500}])

        client_user = User.objects.create_user(
            phone_number="+998905550001", full_name="Mijoz", is_active=True
        )
        api = APIClient()
        api.force_authenticate(user=client_user)

        card = next(
            row for row in api.get(f"{CLIENT}masters/").data
            if row["id"] == self.user.pk
        )
        self.assertEqual(card["rates"][0]["price"], 1500)
        self.assertEqual(card["rates"][0]["unit"], "dona")

        profile = api.get(f"{CLIENT}masters/{self.user.pk}/").data
        self.assertEqual(profile["rates"][0]["code"], "gisht")
