"""
G'ISHT BUYURTMASIDA TANNARX USTAGA KO'RSATILMAYDI (usta talabi 2026-09-19).

Qulflanadigan shartnoma:
  * usta feed'ida va buyurtma sahifasida `calculated_price = 0` va suratda
    pul kalitlari yo'q — usta faqat ishni va g'isht sonini ko'radi;
  * MIJOZ suratida hammasi joyida qoladi (material tannarxi unga kerak);
  * boshqa sohalar (kafel) TEGILMAYDI — ularda material narxi avvalgidek.
"""

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import Order, OrderStatus
from apps.locations.models import Region

MASTER = "/api/v1/master/"
CLIENT = "/api/v1/client/"

MASONRY_PROPOSAL = {
    "calculator": "variant",
    "engine": "masonry",
    "variant": "Pishgan g'isht",
    "variant_note": "Bino 15×10 · 2 qavat · 38,5 sm · 41 942 dona",
    "area_m2": 433.68,
    "unit": "m²",
    "cost_price": 51_080_200,
    "total_price": 51_080_200,
    "masonry_bricks_laid": 41_200,
    "masonry_bricks_total": 41_942,
    "masonry_brick_cost": 46_136_200,
    "masonry_mortar_cost": 4_944_000,
    "masonry_brick": {"name": "Pishgan g'isht", "price": 1100, "mortar_per_brick": 120},
}


class MasonryCostHiddenFromMasterTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.gisht = MasterSpecialty.objects.create(
            name="G'isht (test)", code="gisht-mv", unit="dona", calculator="masonry"
        )
        self.region = Region.objects.create(name="Toshkent (mv)")
        self.client_user = User.objects.create(
            username="mijoz-mv", phone_number="+998900000101",
            region=self.region, district_id=None,
        )
        self.master_user = User.objects.create(
            username="usta-mv", phone_number="+998900000102", is_master=True,
            region=self.region,
        )
        self.profile = MasterProfile.objects.create(
            user=self.master_user, specialty=self.gisht, experience_years=3
        )
        self.order = Order.objects.create(
            client=self.client_user,
            title="G'isht teruvchi — Pishgan g'isht · 433,68 m² · 41 942 dona",
            status=OrderStatus.PUBLISHED,
            region=self.region,
            specialty=self.gisht,
            calculated_price=51_080_200,
            is_public=True,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal=MASONRY_PROPOSAL,
        )

    def master_row(self):
        self.api.force_authenticate(self.master_user)
        response = self.api.get(f"{MASTER}orders/feed/")
        self.assertEqual(response.status_code, 200)
        rows = [r for r in response.data if r["id"] == self.order.id]
        self.assertEqual(len(rows), 1, "e'lon usta feed'ida ko'rinishi kerak")
        return rows[0]

    def test_usta_tannarxni_KORMAYDI(self):
        row = self.master_row()
        self.assertEqual(row["calculated_price"], 0)
        for key in ("cost_price", "total_price", "masonry_brick_cost",
                    "masonry_mortar_cost"):
            self.assertNotIn(key, row["proposal"])
        self.assertNotIn("price", row["proposal"]["masonry_brick"])

    def test_usta_ISHNI_va_gisht_sonini_koradi(self):
        row = self.master_row()
        self.assertEqual(row["proposal"]["variant"], "Pishgan g'isht")
        self.assertIn("41 942 dona", row["proposal"]["variant_note"])
        self.assertEqual(row["proposal"]["masonry_bricks_total"], 41_942)
        self.assertEqual(row["proposal"]["area_m2"], 433.68)

    def test_MIJOZ_tannarxni_koradi(self):
        self.api.force_authenticate(self.client_user)
        response = self.api.get(f"{CLIENT}orders/{self.order.id}/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["calculated_price"], 51_080_200)
        self.assertEqual(response.data["proposal"]["cost_price"], 51_080_200)

    def test_boshqa_sohada_tannarx_ORNIDA(self):
        # Kafel (material narxi) — usta avvalgidek tannarxni ko'radi.
        kafel = MasterSpecialty.objects.create(
            name="Kafel (test-mv)", code="kafel-mv", unit="m²",
            calculator="variant", variant_price_is_material=True,
        )
        # E'lon FAQAT o'z yo'nalishidagi ustaga ko'rinadi (`visibility.py`).
        self.profile.specialties.add(kafel)
        order = Order.objects.create(
            client=self.client_user,
            title="Kafel",
            status=OrderStatus.PUBLISHED,
            region=self.region,
            specialty=kafel,
            calculated_price=900_000,
            is_public=True,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={"calculator": "variant", "variant": "Pol kafeli",
                      "area_m2": 20, "cost_price": 900_000},
        )
        self.api.force_authenticate(self.master_user)
        rows = {r["id"]: r for r in self.api.get(f"{MASTER}orders/feed/").data}
        self.assertEqual(rows[order.id]["calculated_price"], 900_000)
        self.assertEqual(rows[order.id]["proposal"]["cost_price"], 900_000)
