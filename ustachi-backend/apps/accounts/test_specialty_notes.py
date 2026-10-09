"""
NARX O'RNIGA USTA IZOHI (usta qarori 2026-09-28).

Tom, santexnik, darvoza-panjara, payvandchi va dush kabinasida ish mijoz
talabiga qarab har xil — ustadan narx so'ralmaydi, u erkin matn yozadi:
"Qanday tomni necha pulga yopasiz?".

Qoidalar:
  1. Beshala yo'nalish `note_by_master`, narx so'ralmaydi.
  2. Usta izohni saqlaydi; bo'sh matn — izoh o'chadi.
  3. Izoh faqat ustaning O'Z yo'nalishiga va faqat izohli yo'nalishga.
  4. Eski ilova stavka yuborsa — saqlanmaydi, so'rov yiqilmaydi.
  5. Mijoz izohni ko'radi; eski stavka unga ham, jami narxga ham chiqmaydi.
  6. Boshqa yo'nalishlar (g'isht) avvalgidek narx bilan.
"""

from types import SimpleNamespace

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyNote,
    MasterSpecialtyRate,
    User,
)
from apps.orders import response_total
from apps.orders.api.v1.serializers import OrderResponseSerializer

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/auth/"
NOTE_CODES = ("tom", "santexnik", "darvoza", "payvand", "hammom")


class NoteCatalogTests(TestCase):
    def test_beshala_yonalish_izohli_narx_soralmaydi(self):
        rows = {r["code"]: r for r in APIClient().get(f"{CLIENT}specialties/").data}
        for code in NOTE_CODES:
            self.assertTrue(rows[code]["note_by_master"], code)
            self.assertIn("necha pulga", rows[code]["unit_question"], code)
            self.assertFalse(MasterSpecialty.objects.get(code=code).asks_rate, code)
        self.assertFalse(rows["gisht"]["note_by_master"])
        self.assertTrue(MasterSpecialty.objects.get(code="gisht").asks_rate)


class NoteApiTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.tom = MasterSpecialty.objects.get(code="tom")
        self.santexnik = MasterSpecialty.objects.get(code="santexnik")
        self.gisht = MasterSpecialty.objects.get(code="gisht")
        self.darvoza = MasterSpecialty.objects.get(code="darvoza")
        self.user = User.objects.create_user(
            phone_number="+998903334466", full_name="Tomchi", is_active=True
        )
        self.user.is_master = True
        self.user.save(update_fields=["is_master"])
        self.profile = MasterProfile.objects.create(
            user=self.user, specialty=self.tom, experience_years=10
        )
        self.profile.specialties.set([self.tom, self.santexnik, self.gisht])
        self.api.force_authenticate(self.user)

    def _put(self, notes):
        return self.api.put(f"{MASTER}profile/notes/", {"notes": notes}, format="json")

    def test_izoh_saqlanadi_va_profilda_qaytadi(self):
        text = "Sasna + shifer — 1 m² 30 000 so'm, profnastil — 25 000 so'm."
        r = self._put([{"specialty": self.tom.pk, "text": text}])
        self.assertEqual(r.status_code, 200, r.data)
        self.assertEqual(r.data[0]["text"], text)
        profile = self.api.get(f"{MASTER}profile/").data
        self.assertEqual(profile["notes"][0]["code"], "tom")
        self.assertEqual(profile["notes"][0]["text"], text)

    def test_bosh_matn_va_royxatda_yoq_izoh_ochadi(self):
        self._put([
            {"specialty": self.tom.pk, "text": "Tom"},
            {"specialty": self.santexnik.pk, "text": "Kotyol"},
        ])
        r = self._put([
            {"specialty": self.tom.pk, "text": "   "},
        ])
        self.assertEqual(r.status_code, 200, r.data)
        self.assertEqual(r.data, [])
        self.assertFalse(MasterSpecialtyNote.objects.filter(profile=self.profile).exists())

    def test_ozga_tegishli_bolmagan_yonalishga_izoh_yoq(self):
        r = self._put([{"specialty": self.darvoza.pk, "text": "Darvoza"}])
        self.assertEqual(r.status_code, 400)

    def test_narxli_yonalishga_izoh_yoq(self):
        r = self._put([{"specialty": self.gisht.pk, "text": "G'isht"}])
        self.assertEqual(r.status_code, 400)

    def test_eski_ilova_stavka_yuborsa_saqlanmaydi_yiqilmaydi(self):
        variant = self.tom.variants.first()
        r = self.api.put(f"{MASTER}profile/rates/", {"rates": [
            {"specialty": self.tom.pk, "variant": variant.pk, "price": 30_000},
            {"specialty": self.gisht.pk, "price": 1_500},
        ]}, format="json")
        self.assertEqual(r.status_code, 200, r.data)
        codes = [row["code"] for row in r.data]
        self.assertEqual(codes, ["gisht"])

    def test_mijoz_izohni_koradi_eski_stavkani_emas(self):
        variant = self.tom.variants.first()
        # Migratsiyadan oldin qolgan eski stavka.
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.tom, variant=variant, price=30_000
        )
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.gisht, price=1_500
        )
        self._put([{"specialty": self.tom.pk, "text": "1 m² — 30 000 so'm"}])

        client = User.objects.create_user(phone_number="+998903334477", is_active=True)
        api = APIClient()
        api.force_authenticate(client)
        data = api.get(f"{CLIENT}masters/{self.user.pk}/").data
        self.assertEqual([r["code"] for r in data["rates"]], ["gisht"])
        self.assertEqual(data["notes"], [
            {"code": "tom", "name": self.tom.name, "text": "1 m² — 30 000 so'm"}
        ])
        card = next(c for c in api.get(f"{CLIENT}masters/").data if c["id"] == self.user.pk)
        self.assertEqual(card["notes"][0]["code"], "tom")

    def test_kasbiy_malumot_saqlanganda_belgilar_ochmaydi(self):
        # REGRESSIYA (2026-09-28): sahifa profilni multipart POST bilan
        # saqlaydi va belgilarni yubormaydi — DRF ularni `False` deb o'qib,
        # "Buyurtma qabul qilaman", "Ta'mirga chiqaman" va materiallarni
        # o'chirib yuborardi.
        flags = ["accepts_orders", "does_repairs", "does_plastic",
                 "does_aluminium", "does_termo"]
        # Nusxaning o'zida (so'rov `user.master_profile` keshidan o'qiydi).
        for f in flags:
            setattr(self.profile, f, True)
        self.profile.save()
        r = self.api.post(f"{MASTER}profile/", {
            "specialty": self.tom.pk,
            "specialties": [self.tom.pk, self.gisht.pk],
            "experience_years": 11,
            "bio": "",
        }, format="multipart")
        self.assertEqual(r.status_code, 200, r.data)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.experience_years, 11)
        for f in flags:
            self.assertTrue(getattr(self.profile, f), f)

    def test_tom_buyurtmasida_jami_hisoblanmaydi(self):
        variant = self.tom.variants.first()
        MasterSpecialtyRate.objects.create(
            profile=self.profile, specialty=self.tom, variant=variant, price=30_000
        )
        order = SimpleNamespace(
            specialty=self.tom,
            specialty_id=self.tom.pk,
            proposal={"calculator": "variant", "engine": "roof",
                      "variant": variant.name, "area_m2": 100},
            cost_base=33_000_000,
            calculated_price=33_000_000,
        )
        self.assertFalse(response_total.uses_master_rate(order))
        response = SimpleNamespace(order=order, master=self.user)
        self.assertIsNone(OrderResponseSerializer().get_service_total(response))
