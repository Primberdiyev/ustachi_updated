"""
"POLVON TEXNIKA" (usta qarori 2026-09-26).

Qoidalar:
  1. 16 ta texnika katalogda, `group="texnika"`, kalkulyatorsiz.
  2. Biz narx ham, birlik ham QO'YMAYMIZ: har texnika egasi o'zi birlik
     tanlaydi (soat, kun, reys, metr, km, m³, tonna) va narxini yozadi.
  3. Bitta texnikaga ko'pi bilan 2 ta birlik ("soatiga + km ga").
  4. Mijoz ustaning narxini O'Z birligi bilan ko'radi.
  5. Oddiy yo'nalishlar (g'isht, zina...) o'zgarmaydi.
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, MasterSpecialtyRate, User

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/auth/"


class TexnikaCatalogTests(TestCase):
    def test_16_ta_texnika_guruhda_birliksiz(self):
        rows = [
            r for r in APIClient().get(f"{CLIENT}specialties/").data
            if r.get("group") == "texnika"
        ]
        self.assertEqual(len(rows), 16)
        for r in rows:
            self.assertTrue(r["unit_by_master"], r["code"])
            self.assertEqual(r["unit"], "", r["code"])
            self.assertEqual(r["calculator"], "", r["code"])
        codes = {r["code"] for r in rows}
        self.assertIn("texnika_avtokran", codes)  # tomga plita qo'yish
        self.assertIn("texnika_samosval", codes)

    def test_oddiy_yonalish_ozgarmaydi(self):
        rows = {r["code"]: r for r in APIClient().get(f"{CLIENT}specialties/").data}
        self.assertEqual(rows["gisht"]["group"], "")
        self.assertFalse(rows["gisht"]["unit_by_master"])
        self.assertEqual(rows["gisht"]["unit"], "dona")


class TexnikaRatesTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.kran = MasterSpecialty.objects.get(code="texnika_avtokran")
        self.samosval = MasterSpecialty.objects.get(code="texnika_samosval")
        self.gisht = MasterSpecialty.objects.get(code="gisht")
        self.user = User.objects.create_user(
            phone_number="+998903334455", full_name="Kranchi", is_active=True
        )
        self.user.is_master = True
        self.user.save(update_fields=["is_master"])
        self.profile = MasterProfile.objects.create(
            user=self.user, specialty=self.kran, experience_years=7
        )
        self.profile.specialties.set([self.kran, self.samosval, self.gisht])
        self.api.force_authenticate(self.user)

    def _put(self, rates):
        return self.api.put(f"{MASTER}profile/rates/", {"rates": rates}, format="json")

    def test_ega_ozi_birlik_tanlaydi_ikkitagacha(self):
        r = self._put([
            {"specialty": self.kran.pk, "unit": "soat", "price": 350_000},
            {"specialty": self.kran.pk, "unit": "km", "price": 15_000},
            {"specialty": self.samosval.pk, "unit": "reys", "price": 400_000},
        ])
        self.assertEqual(r.status_code, 200, r.data)
        got = {(x["code"], x["unit"], x["price"]) for x in r.data}
        self.assertEqual(got, {
            ("texnika_avtokran", "soat", 350_000),
            ("texnika_avtokran", "km", 15_000),
            ("texnika_samosval", "reys", 400_000),
        })

    def test_uchta_birlik_mumkin_emas(self):
        r = self._put([
            {"specialty": self.kran.pk, "unit": "soat", "price": 1},
            {"specialty": self.kran.pk, "unit": "km", "price": 1},
            {"specialty": self.kran.pk, "unit": "kun", "price": 1},
        ])
        self.assertEqual(r.status_code, 400)
        self.assertFalse(MasterSpecialtyRate.objects.exists())

    def test_bir_xil_birlik_ikki_marta_mumkin_emas(self):
        r = self._put([
            {"specialty": self.kran.pk, "unit": "soat", "price": 1},
            {"specialty": self.kran.pk, "unit": "soat", "price": 2},
        ])
        self.assertEqual(r.status_code, 400)

    def test_birliksiz_yoki_notanish_birlik_rad_etiladi(self):
        self.assertEqual(self._put([{"specialty": self.kran.pk, "price": 1}]).status_code, 400)
        self.assertEqual(
            self._put([{"specialty": self.kran.pk, "unit": "litr", "price": 1}]).status_code, 400
        )

    def test_oddiy_yonalishda_birlik_yonalishniki(self):
        # G'ishtchi "soat" yuborsa ham — birlik "dona" bo'lib qoladi.
        r = self._put([{"specialty": self.gisht.pk, "unit": "soat", "price": 1500}])
        self.assertEqual(r.status_code, 200, r.data)
        self.assertEqual(r.data[0]["unit"], "dona")
        self.assertEqual(MasterSpecialtyRate.objects.get().unit, "")

    def test_mijoz_ustaning_birligini_koradi(self):
        self._put([
            {"specialty": self.kran.pk, "unit": "soat", "price": 350_000},
            {"specialty": self.kran.pk, "unit": "km", "price": 15_000},
        ])
        client = User.objects.create_user(phone_number="+998903334466", is_active=True)
        api = APIClient()
        api.force_authenticate(client)
        profile = api.get(f"{CLIENT}masters/{self.user.pk}/").data
        units = {(x["code"], x["unit"]) for x in profile["rates"]}
        self.assertEqual(units, {("texnika_avtokran", "soat"), ("texnika_avtokran", "km")})

    def test_birlik_almashsa_eskisi_ochadi(self):
        self._put([{"specialty": self.kran.pk, "unit": "soat", "price": 1}])
        self._put([{"specialty": self.kran.pk, "unit": "kun", "price": 2}])
        self.assertEqual(
            list(MasterSpecialtyRate.objects.values_list("unit", "price")), [("kun", 2)]
        )
