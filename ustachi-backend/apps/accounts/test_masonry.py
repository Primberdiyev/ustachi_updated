"""
G'ISHT TERISH KALKULYATORI (usta qarori 2026-09-17).

Hisobning o'zi mijoz ilovasida (`MasonryCalculator`); server faqat g'isht
turlarini (o'lcham, 1 dona narxi, terish haqi) katalog API'si orqali beradi.
Narxlar QO'LDA quriladi — admin narxni o'zgartirsa test yiqilmaydi.
"""

from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import CalculatorKind, MasterSpecialty, SpecialtyBrick

CLIENT = "/api/v1/client/"


class MasonryCatalogApiTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.gisht = MasterSpecialty.objects.create(
            name="G'isht (test)",
            code="gisht-test",
            unit="dona",
            calculator=CalculatorKind.MASONRY,
        )

    def row(self):
        response = self.api.get(f"{CLIENT}specialties/")
        self.assertEqual(response.status_code, 200)
        return {r["code"]: r for r in response.data}["gisht-test"]

    def test_gisht_turlari_olchami_va_narxlari_bilan_keladi(self):
        SpecialtyBrick.objects.create(
            specialty=self.gisht,
            name="Pishgan g'isht",
            price=Decimal("1200"),
        )
        row = self.row()
        self.assertEqual(row["calculator"], "masonry")
        brick = row["bricks"][0]
        self.assertEqual(brick["name"], "Pishgan g'isht")
        self.assertEqual(brick["kind"], "pishgan")
        self.assertEqual(
            (brick["length_mm"], brick["width_mm"], brick["height_mm"], brick["joint_mm"]),
            (250, 125, 88, 10),
        )
        # Raqam bo'lib ketadi, satr emas — ilova darhol hisoblaydi.
        self.assertEqual(brick["price"], Decimal("1200.00"))
        self.assertEqual(brick["waste_pct"], Decimal("1.80"))
        self.assertEqual(brick["mortar_per_brick"], Decimal("0.00"))
        # Terish haqi mijozga YUBORILMAYDI — uni har usta o'zi qo'yadi.
        self.assertNotIn("labor_price", brick)
        # Usta ilovasi shu tur uchun narx so'raydi.
        self.assertEqual([v["name"] for v in row["variants"]], ["Pishgan g'isht"])
        # Amaliyotdagi son kiritilmagan — ilova o'lchamdan hisoblaydi.
        self.assertIsNone(brick["bricks_per_m2_half"])

    def test_gisht_turi_yoq__bosh_royxat(self):
        # Ilova bo'sh ro'yxatda hisobni ko'rsatmaydi.
        self.assertEqual(self.row()["bricks"], [])

    def test_boshqa_yonalishlarda_bricks_bosh(self):
        MasterSpecialty.objects.create(name="Tom (test)", code="tom-test", unit="m²")
        response = self.api.get(f"{CLIENT}specialties/")
        tom = {r["code"]: r for r in response.data}["tom-test"]
        self.assertEqual(tom["bricks"], [])
