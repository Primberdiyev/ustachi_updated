"""
MAYDON BO'YICHA NARX — pog'onali stavka (asfalt, foydalanuvchi 2026-08-29).

Qulflanadigan shartnoma:
  * pog'ona TANLANADI, ustiga qo'shilmaydi — maydon qaysi pog'onaga tushsa,
    BUTUN maydon o'sha stavkada;
  * "100 m² gacha" chegarasiga 100 ning O'ZI ham kiradi;
  * cheksiz pog'ona (`up_to_area=None`) — eng katta maydonlar uchun;
  * sozlama xato bo'lsa (cheksiz pog'ona yo'q) narx `None` qaytadi —
    mijozga yolg'on raqam ko'rsatilmaydi;
  * katalog API'si `calculator` va `area_tiers` ni beradi, ya'ni ILOVA
    ham AYNAN shu qoidada hisoblay oladi.

⚠️ Narxlar bu yerda QO'LDA quriladi, migratsiyadagi seed'ga tayanilmaydi:
admin narxni o'zgartirsa test yiqilmasligi kerak.
"""

from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import CalculatorKind, MasterSpecialty, SpecialtyAreaTier
from apps.accounts.services import area_pricing
from apps.accounts.services.area_pricing import AreaTier

CLIENT = "/api/v1/client/"


def tiers(*rows) -> list[AreaTier]:
    """`(chegara, narx)` juftlaridan pog'onalar. Chegara `None` — cheksiz."""
    return [
        AreaTier(
            up_to_area=None if limit is None else Decimal(str(limit)),
            price=Decimal(str(price)),
        )
        for limit, price in rows
    ]


#: Foydalanuvchi bergan narxlar: 100 m² gacha 100 000, undan yuqori 75 000.
ASFALT = tiers((100, 100_000), (None, 75_000))


class AreaPriceRuleTests(TestCase):
    """Sof hisob — DB ham, tarmoq ham yo'q."""

    def calc(self, area, rows=None):
        return area_pricing.calculate(rows or ASFALT, Decimal(str(area)))

    def test_kichik_maydon_qimmat_stavkada(self):
        result = self.calc(80)
        self.assertEqual(result.unit_price, Decimal("100000"))
        self.assertEqual(result.total, 8_000_000)

    def test_chegaraning_OZI_pastki_pogonada(self):
        # "100 m² gacha" — 100 ning o'zi ham shu pog'onada.
        result = self.calc(100)
        self.assertEqual(result.unit_price, Decimal("100000"))
        self.assertEqual(result.total, 10_000_000)

    def test_chegaradan_oshsa_arzon_stavka_BUTUN_maydonga(self):
        # Pog'ona TANLANADI: 150 m² ning hammasi 75 000 dan.
        result = self.calc(150)
        self.assertEqual(result.unit_price, Decimal("75000"))
        self.assertEqual(result.total, 11_250_000)

    def test_chegaradan_bir_birlik_oshgani_ham_arzon_stavkada(self):
        result = self.calc("100.5")
        self.assertEqual(result.unit_price, Decimal("75000"))
        self.assertEqual(result.total, 7_537_500)

    def test_kasrli_maydon_butun_somga_yaxlitlanadi(self):
        result = self.calc("12.345")
        self.assertEqual(result.total, 1_234_500)

    def test_nol_va_manfiy_maydon__narx_YOQ(self):
        self.assertIsNone(self.calc(0))
        self.assertIsNone(self.calc(-5))

    def test_cheksiz_pogona_YOQ__katta_maydonga_narx_topilmaydi(self):
        # Sozlama xatosi: 100 dan oshganiga pog'ona yo'q. Yolg'on raqam
        # ko'rsatgandan ko'ra narxsiz qoldirgan ma'qul.
        only_small = tiers((100, 100_000))
        self.assertIsNone(self.calc(150, only_small))
        self.assertIsNotNone(self.calc(90, only_small))

    def test_pogonalar_TARTIBSIZ_kiritilsa_ham_togri_ishlaydi(self):
        shuffled = tiers((None, 75_000), (100, 100_000))
        self.assertEqual(self.calc(80, shuffled).unit_price, Decimal("100000"))
        self.assertEqual(self.calc(150, shuffled).unit_price, Decimal("75000"))

    def test_uchta_pogona(self):
        three = tiers((50, 120_000), (200, 90_000), (None, 60_000))
        self.assertEqual(self.calc(50, three).unit_price, Decimal("120000"))
        self.assertEqual(self.calc(51, three).unit_price, Decimal("90000"))
        self.assertEqual(self.calc(200, three).unit_price, Decimal("90000"))
        self.assertEqual(self.calc(201, three).unit_price, Decimal("60000"))


class AreaTierWarningTests(TestCase):
    """Adminka ogohlantirishlari — sozlama xatosi jimgina o'tmasin."""

    def test_cheksiz_pogona_yoq__ogohlantiradi(self):
        problems = area_pricing.tier_warnings(tiers((100, 100_000)))
        self.assertTrue(any("Cheksiz pog'ona yo'q" in p for p in problems))

    def test_chegaradan_oshganda_narx_tushib_ketsa__ogohlantiradi(self):
        # 100 m² = 10 mln, 101 m² = 7,5 mln — ataylab shunday, lekin admin
        # buni bilib tursin.
        problems = area_pricing.tier_warnings(ASFALT)
        self.assertTrue(any("TUSHIB" in p for p in problems))

    def test_narx_osib_boradigan_jadvalga_ogohlantirish_YOQ(self):
        # 100×1000 = 100 000 → 100×1500 = 150 000: kamaymaydi.
        rising = tiers((100, 1_000), (None, 1_500))
        self.assertEqual(area_pricing.tier_warnings(rising), [])

    def test_bosh_jadval__ogohlantirish_YOQ(self):
        self.assertEqual(area_pricing.tier_warnings([]), [])


class SpecialtyCalculatorApiTests(TestCase):
    """Katalog API'si ilovaga kalkulyator sozlamasini beradi."""

    def setUp(self):
        self.api = APIClient()
        self.asfalt = MasterSpecialty.objects.create(
            name="Asfalt (test)",
            code="asfalt-test",
            unit="m²",
            calculator=CalculatorKind.AREA,
        )
        SpecialtyAreaTier.objects.create(
            specialty=self.asfalt, up_to_area=Decimal("100"), price=Decimal("100000")
        )
        SpecialtyAreaTier.objects.create(
            specialty=self.asfalt, up_to_area=None, price=Decimal("75000")
        )
        self.tom = MasterSpecialty.objects.create(
            name="Tom (test)", code="tom-test", unit="m²"
        )

    def rows(self):
        response = self.api.get(f"{CLIENT}specialties/")
        self.assertEqual(response.status_code, 200)
        return {row["code"]: row for row in response.data}

    def test_kalkulyatorli_yonalish_pogonalari_bilan_keladi(self):
        row = self.rows()["asfalt-test"]
        self.assertEqual(row["calculator"], "area")
        self.assertEqual(
            [(t["up_to_area"], t["price"]) for t in row["area_tiers"]],
            [(Decimal("100.00"), Decimal("100000.00")),
             (None, Decimal("75000.00"))],
        )

    def test_pogonalar_TARTIBDA_keladi__cheksizi_oxirida(self):
        # Ilova birinchi mos pog'onani oladi, shuning uchun tartib muhim.
        limits = [t["up_to_area"] for t in self.rows()["asfalt-test"]["area_tiers"]]
        self.assertEqual(limits[-1], None)

    def test_kalkulyatorsiz_yonalish__bosh_maydonlar(self):
        row = self.rows()["tom-test"]
        self.assertEqual(row["calculator"], "")
        self.assertEqual(row["area_tiers"], [])

    def test_faol_bolmagan_yonalish_royxatga_tushmaydi(self):
        self.asfalt.is_active = False
        self.asfalt.save(update_fields=["is_active"])
        self.assertNotIn("asfalt-test", self.rows())

    def test_katalog_bitta_sorovda_yigiladi(self):
        # `prefetch_related` bo'lmasa har yo'nalishga alohida so'rov ketardi.
        MasterSpecialty.objects.create(name="Yana (test)", code="yana-test")
        # yo'nalishlar + pog'onalar + variantlar + g'isht turlari + ta'mir
        # muammolari (har biri BITTA so'rov)
        with self.assertNumQueries(5):
            self.api.get(f"{CLIENT}specialties/")


class SpecialtyModelTests(TestCase):
    def test_has_calculator(self):
        rom = MasterSpecialty.objects.create(
            name="Rom (test)", code="rom-test", calculator=CalculatorKind.ROM
        )
        plain = MasterSpecialty.objects.create(name="Oddiy (test)", code="oddiy-test")
        self.assertTrue(rom.has_calculator)
        self.assertFalse(plain.has_calculator)

    def test_tiers_for__modeldan_oqiydi(self):
        specialty = MasterSpecialty.objects.create(
            name="Maydon (test)", code="maydon-test", calculator=CalculatorKind.AREA
        )
        SpecialtyAreaTier.objects.create(
            specialty=specialty, up_to_area=None, price=Decimal("50000")
        )
        SpecialtyAreaTier.objects.create(
            specialty=specialty, up_to_area=Decimal("20"), price=Decimal("90000")
        )
        rows = area_pricing.tiers_for(specialty)
        result = area_pricing.calculate(rows, Decimal("10"))
        self.assertEqual(result.unit_price, Decimal("90000"))
