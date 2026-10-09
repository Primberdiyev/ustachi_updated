"""
TOM YOPISH KALKULYATORI (usta talabi 2026-09-21).

Hisobning o'zi mijoz ilovasida (`RoofCalculator`: uy o'lchami → tom
maydoni); server faqat kalkulyator turini va material birikmalarining
1 m² MATERIAL narxini beradi. Narxlar QO'LDA quriladi — admin narxni
o'zgartirsa test yiqilmaydi.

Muhimi: variant NOMI — ilova va server o'rtasidagi kalit. Ilovadagi
`RoofMaterial.variantName` shu nom bilan bir xil bo'lmasa narx topilmaydi.
"""

from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import CalculatorKind, MasterSpecialty, SpecialtyVariant

CLIENT = "/api/v1/client/"

#: Ilovadagi `RoofMaterial` ro'yxati (2026-09-21) — nomlar AYNAN shunday.
APP_MATERIALS = [
    "Terak + shifer",
    "Terak + tunuka",
    "Sasna + shifer",
    "Sasna + tunuka",
    "Sasna + cherepitsa",
    "Tayyor plita",
    "Profnastil",
]


class RoofCatalogApiTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.tom = MasterSpecialty.objects.create(
            name="Tom (test)",
            code="tom-test",
            unit="m²",
            calculator=CalculatorKind.ROOF,
            # Mijoz ko'rgan narx faqat MATERIAL: yopish haqini usta qo'yadi.
            variant_price_is_material=True,
        )

    def row(self):
        response = self.api.get(f"{CLIENT}specialties/")
        self.assertEqual(response.status_code, 200)
        return {r["code"]: r for r in response.data}["tom-test"]

    def test_kalkulyator_turi_va_material_narxi_keladi(self):
        SpecialtyVariant.objects.create(
            specialty=self.tom, name="Sasna + tunuka", price=Decimal("180000")
        )
        row = self.row()
        self.assertEqual(row["calculator"], "roof")
        self.assertTrue(row["variant_price_is_material"])
        variant = row["variants"][0]
        self.assertEqual(variant["name"], "Sasna + tunuka")
        self.assertEqual(variant["price"], Decimal("180000.00"))

    def test_narxi_kiritilmagan_material_ham_keladi(self):
        # Narx 0 — ilova "narxi hali kiritilmagan" deb ko'rsatadi va u
        # bilan buyurtma bermaydi (2026-09-21: narxlarni usta keyin aytadi).
        SpecialtyVariant.objects.create(
            specialty=self.tom, name="Tayyor plita", price=Decimal("0")
        )
        self.assertEqual(self.row()["variants"][0]["price"], Decimal("0.00"))


class RoofMigrationTests(TestCase):
    """`tom` yo'nalishi katalogda bo'lsa — kalkulyatori va materiallari bor."""

    def test_tom_yonalishi_roof_kalkulyatori_bilan(self):
        tom = MasterSpecialty.objects.filter(code="tom").first()
        if tom is None:  # katalog seed'i bu bazada ishlamagan
            self.skipTest("tom yo'nalishi yo'q")
        self.assertEqual(tom.calculator, CalculatorKind.ROOF)
        self.assertTrue(tom.variant_price_is_material)
        # Ilovadagi materiallarning HAMMASI adminkada bor bo'lishi kerak:
        # aks holda mijoz tanlagan materialning narxi topilmaydi.
        names = set(tom.variants.values_list("name", flat=True))
        self.assertTrue(set(APP_MATERIALS) <= names, names)
