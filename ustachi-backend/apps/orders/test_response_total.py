"""
"SHU USTANI CHAQIRSAM QANCHA?" — usta stavkasidan jami (foydalanuvchi 2026-08-31).

Kafelda ish haqi USTANING m² STAVKASI: kafelchi pol, devor va sokl uchun
uchta alohida narx kiritadi.

Qulflanadigan shartnoma:
  * kafel buyurtmasida jami = material + maydon × ustaning SHU TURDAGI
    stavkasi;
  * har usta o'z stavkasi bilan boshqacha jami ko'rsatadi (mijoz shu
    raqam bo'yicha taqqoslaydi);
  * usta o'sha turga narx qo'ymagan bo'lsa — narx KO'RSATILMAYDI (`None`),
    yolg'on raqam chiqmaydi;
  * material bayrog'i yo'q sohalarda (rom, asfalt...) stavka yo'li ISHLAMAYDI.
"""

from decimal import Decimal

from django.test import TestCase
from django.utils import timezone

from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyRate,
    SpecialtyVariant,
    User,
)
from apps.orders import response_total
from apps.orders.models import Order, OrderStatus


class KafelRateTotalTests(TestCase):
    """Kafel — jami ustaning m² stavkasidan chiqadi."""

    def setUp(self):
        self.kafel = MasterSpecialty.objects.create(
            name="Kafel (test)",
            code="kafel-test",
            unit="m²",
            calculator="variant",
            variant_price_is_material=True,
        )
        self.pol = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Pol kafeli", size="40×40 sm",
            price=Decimal("45000"), order=0,
        )
        self.sokl = SpecialtyVariant.objects.create(
            specialty=self.kafel, name="Sokl kafeli", size="60×120 sm",
            price=Decimal("125000"), order=2,
        )
        self.client_user = User.objects.create(
            username="mijoz-t", phone_number="+998900000001"
        )

    def master(self, phone, rates: dict[SpecialtyVariant, int]):
        """Stavkalari bilan usta yaratadi."""
        user = User.objects.create(
            username=f"usta-{phone[-4:]}", phone_number=phone, is_master=True
        )
        profile = MasterProfile.objects.create(
            user=user, specialty=self.kafel, experience_years=3
        )
        for variant, price in rates.items():
            MasterSpecialtyRate.objects.create(
                profile=profile, specialty=self.kafel, variant=variant,
                price=price,
            )
        return user

    def order(self, variant_name="Pol kafeli", area=20, material=900_000):
        return Order.objects.create(
            client=self.client_user,
            title="Kafel",
            status=OrderStatus.PUBLISHED,
            specialty=self.kafel,
            calculated_price=material,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={
                "calculator": "variant",
                "variant": variant_name,
                "area_m2": area,
                "unit": "m²",
                "cost_price": material,
            },
        )

    def test_jami_material_va_ustaning_stavkasidan(self):
        # 20 m² pol kafeli: material 20×45 000 = 900 000,
        # ish haqi 20×60 000 = 1 200 000 → jami 2 100 000.
        order = self.order()
        usta = self.master("+998900000010", {self.pol: 60_000})

        self.assertEqual(response_total.total_by_rate(order, usta), 2_100_000)

    def test_har_usta_OZ_stavkasi_bilan(self):
        # Mijoz aynan shu farq bo'yicha ustalarni taqqoslaydi.
        order = self.order()
        arzon = self.master("+998900000011", {self.pol: 40_000})
        qimmat = self.master("+998900000012", {self.pol: 90_000})

        self.assertEqual(response_total.total_by_rate(order, arzon), 1_700_000)
        self.assertEqual(response_total.total_by_rate(order, qimmat), 2_700_000)

    def test_TUR_boyicha_stavka_tanlanadi(self):
        # Sokl kafeli buyurtmasiga POL stavkasi qo'llanmasligi kerak.
        usta = self.master(
            "+998900000013", {self.pol: 60_000, self.sokl: 150_000}
        )
        sokl_order = self.order(
            variant_name="Sokl kafeli", area=10, material=1_250_000
        )

        self.assertEqual(
            response_total.total_by_rate(sokl_order, usta),
            1_250_000 + 10 * 150_000,
        )

    def test_usta_SHU_turga_narx_qoymagan__narx_YOQ(self):
        # Faqat pol narxi bor, buyurtma esa sokl — yolg'on raqam bermaymiz.
        usta = self.master("+998900000014", {self.pol: 60_000})
        sokl_order = self.order(variant_name="Sokl kafeli")

        self.assertIsNone(response_total.total_by_rate(sokl_order, usta))

    def test_kasrli_maydon_yaxlitlanadi(self):
        order = self.order(area="12.5", material=562_500)
        usta = self.master("+998900000015", {self.pol: 60_000})

        # 12.5 × 60 000 = 750 000
        self.assertEqual(
            response_total.total_by_rate(order, usta), 562_500 + 750_000
        )

    def test_sonlar_SATR_bolib_kelsa_ham(self):
        order = self.order(area="20")
        usta = self.master("+998900000016", {self.pol: 60_000})
        self.assertEqual(response_total.total_by_rate(order, usta), 2_100_000)

    def test_maydon_yoq__stavka_yoli_ISHLATILMAYDI(self):
        order = self.order()
        order.proposal = dict(order.proposal, area_m2=0)
        order.save(update_fields=["proposal"])

        self.assertFalse(response_total.uses_master_rate(order))


class MasonryRateTotalTests(TestCase):
    """
    G'isht terish (usta qarori 2026-09-17): mijoz g'isht soni va material
    tannarxini ko'radi, har usta O'Z 1 dona terish narxi bilan jami beradi.
    """

    def setUp(self):
        from apps.accounts.models import SpecialtyBrick

        self.gisht = MasterSpecialty.objects.create(
            name="G'isht (test)",
            code="gisht-test",
            unit="dona",
            calculator="masonry",
            variant_price_is_material=True,
        )
        self.xom = SpecialtyBrick.objects.create(
            specialty=self.gisht, kind="xom", name="Xom g'isht",
            bricks_per_m2_half=Decimal("40"), price=Decimal("800"),
        )
        self.client_user = User.objects.create(
            username="mijoz-g", phone_number="+998900000003"
        )

    def master(self, phone, price):
        user = User.objects.create(
            username=f"usta-{phone[-4:]}", phone_number=phone, is_master=True
        )
        profile = MasterProfile.objects.create(
            user=user, specialty=self.gisht, experience_years=3
        )
        MasterSpecialtyRate.objects.create(
            profile=profile, specialty=self.gisht, variant=self.xom.variant,
            price=price,
        )
        return user

    def order(self, laid=2400, total=2444):
        return Order.objects.create(
            client=self.client_user,
            title="G'isht",
            status=OrderStatus.PUBLISHED,
            specialty=self.gisht,
            calculated_price=total * 800,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={
                "calculator": "variant",
                "engine": "masonry",
                "variant": "Xom g'isht",
                "area_m2": 30,
                "masonry_bricks_laid": laid,
                "masonry_bricks_total": total,
            },
        )

    def test_gisht_turi_uchun_variant_ozi_yaratiladi(self):
        variant = self.xom.variant
        self.assertIsNotNone(variant)
        self.assertEqual(variant.name, "Xom g'isht")
        self.assertEqual(variant.size, "250×125×88 mm")

    def test_nomi_ozgarsa_variant_ham_ozgaradi(self):
        self.xom.name = "Xom g'isht (yangi)"
        self.xom.save()
        self.xom.variant.refresh_from_db()
        self.assertEqual(self.xom.variant.name, "Xom g'isht (yangi)")
        self.assertEqual(SpecialtyVariant.objects.filter(specialty=self.gisht).count(), 1)

    def test_jami__material_va_TERILADIGAN_gisht_x_ustaning_narxi(self):
        # 30 m², bir g'isht: 2400 teriladi, +1,8% → 2444 olinadi.
        # Material 2444 × 800 = 1 955 200; terish 2400 × 700 = 1 680 000.
        order = self.order()
        usta = self.master("+998900000020", 700)
        self.assertTrue(response_total.uses_master_rate(order))
        self.assertEqual(
            response_total.total_by_rate(order, usta), 1_955_200 + 1_680_000
        )

    def test_har_usta_OZ_narxi_bilan(self):
        order = self.order()
        arzon = self.master("+998900000021", 500)
        qimmat = self.master("+998900000022", 900)
        self.assertEqual(response_total.total_by_rate(order, arzon), 1_955_200 + 1_200_000)
        self.assertEqual(response_total.total_by_rate(order, qimmat), 1_955_200 + 2_160_000)

    def test_gisht_soni_yoq__stavka_yoli_ISHLATILMAYDI(self):
        self.assertFalse(response_total.uses_master_rate(self.order(laid=0)))

    def test_gisht_turi_ochirilsa_variant_ham_ochadi(self):
        variant_id = self.xom.variant_id
        self.xom.delete()
        self.assertFalse(SpecialtyVariant.objects.filter(pk=variant_id).exists())


class StairRateTotalTests(TestCase):
    """
    Beton zina (usta ma'lumoti 2026-09-19): mijoz material narxini ko'radi
    (1 metr = 1 000 000), usta o'zining 1 metr quyish narxi bilan jami beradi.
    """

    def setUp(self):
        self.zina, _ = MasterSpecialty.objects.get_or_create(
            code="zina", defaults={"name": "Zina ustasi", "unit": "metr"}
        )
        self.zina.calculator = "area"
        self.zina.variant_price_is_material = True
        self.zina.save()
        self.client_user = User.objects.create(
            username="mijoz-z", phone_number="+998900000004"
        )

    def order(self, metres=4):
        return Order.objects.create(
            client=self.client_user,
            title="Zina",
            status=OrderStatus.PUBLISHED,
            specialty=self.zina,
            calculated_price=metres * 1_000_000,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={
                "calculator": "area",
                "area_m2": metres,
                "unit": "metr",
                "cost_price": metres * 1_000_000,
            },
        )

    def master(self, phone, price=None):
        user = User.objects.create(
            username=f"usta-{phone[-4:]}", phone_number=phone, is_master=True
        )
        profile = MasterProfile.objects.create(
            user=user, specialty=self.zina, experience_years=3
        )
        if price is not None:
            MasterSpecialtyRate.objects.create(
                profile=profile, specialty=self.zina, price=price
            )
        return user

    def test_jami__material_va_metr_x_ustaning_narxi(self):
        # 4 m: material 4 000 000 + 4 × 350 000 = 5 400 000.
        order = self.order()
        usta = self.master("+998900000030", 350_000)
        self.assertTrue(response_total.uses_master_rate(order))
        self.assertEqual(response_total.total_by_rate(order, usta), 5_400_000)

    def test_usta_zina_narxini_qoymagan__narx_YOQ(self):
        self.assertIsNone(
            response_total.total_by_rate(self.order(), self.master("+998900000031"))
        )

    def test_asfalt_kabi_ODDIY_maydon__stavka_yoli_EMAS(self):
        # Material bayrog'i yo'q maydon kalkulyatori — jami hisoblanmaydi.
        asfalt = MasterSpecialty.objects.create(
            name="Asfalt (test-z)", code="asfalt-z", unit="m²", calculator="area"
        )
        order = self.order()
        order.specialty = asfalt
        order.save(update_fields=["specialty"])
        self.assertFalse(response_total.uses_master_rate(order))


class RouteSelectionTests(TestCase):
    """Qaysi model tanlanishi — bayroqqa qarab."""

    def setUp(self):
        self.client_user = User.objects.create(
            username="mijoz-r", phone_number="+998900000002"
        )

    def make(self, **specialty_kwargs):
        specialty = MasterSpecialty.objects.create(
            name=f"Soha {specialty_kwargs.get('code')}", **specialty_kwargs
        )
        return Order.objects.create(
            client=self.client_user,
            title="Buyurtma",
            status=OrderStatus.PUBLISHED,
            specialty=specialty,
            calculated_price=100_000,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={
                "calculator": "variant",
                "variant": "Pol kafeli",
                "area_m2": 10,
            },
        )

    def test_material_bayrogi_YOQ__stavka_yoli_EMAS(self):
        # Yog'och eshik: variant bor, lekin narx YAKUNIY — stavka qo'shilmaydi.
        order = self.make(
            code="eshik-test", calculator="variant",
            variant_price_is_material=False,
        )
        self.assertFalse(response_total.uses_master_rate(order))

    def test_material_bayrogi_BOR__stavka_yoli(self):
        order = self.make(
            code="kafel-r", calculator="variant",
            variant_price_is_material=True,
        )
        self.assertTrue(response_total.uses_master_rate(order))

    def test_ROM_buyurtmasi__stavka_yoli_EMAS(self):
        rom = MasterSpecialty.objects.create(name="Rom (test)", code="rom-r")
        order = Order.objects.create(
            client=self.client_user,
            title="Rom",
            status=OrderStatus.PUBLISHED,
            specialty=rom,
            calculated_price=1_000_000,
            expires_at=timezone.now() + timezone.timedelta(days=1),
            proposal={"cost_price": 800_000, "width_mm": 1500},
        )
        self.assertFalse(response_total.uses_master_rate(order))
