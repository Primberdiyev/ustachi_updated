"""Kuzatuv kamerasi o'rnatish va ta'mirlash yo'nalishi (2026-10-02)."""
from django.test import TestCase

from apps.accounts.models import MasterSpecialty
from apps.accounts.models.master import SPECIALTY_CATALOG


class KameraSpecialtyTests(TestCase):
    def test_migration_seeds_active_specialty_without_price(self):
        kamera = MasterSpecialty.objects.get(code="kamera")
        self.assertEqual(kamera.name, "Kuzatuv kamerasi o'rnatish va ta'mirlash")
        self.assertTrue(kamera.is_active)
        # Hisob-kitob yo'q: mijoz buyurtma beradi, narx chatda kelishiladi —
        # kalkulyator ham, ustadan so'raladigan stavka ham yo'q.
        self.assertEqual(kamera.calculator, "")
        self.assertFalse(kamera.has_calculator)
        self.assertEqual(kamera.unit, "")
        self.assertFalse(kamera.asks_rate)

    def test_catalog_lists_it(self):
        self.assertIn("kamera", [code for _, code, *_ in SPECIALTY_CATALOG])
