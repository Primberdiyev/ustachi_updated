from types import SimpleNamespace

from django.test import SimpleTestCase, TestCase
from rest_framework.exceptions import ValidationError

from apps.accounts.api.v1.serializers import MasterSpecialtyRateSerializer
from apps.orders.api.v1.serializers import OrderCreateSerializer, OrderResponseSerializer
from apps.orders.penthouse_pricing import CODE, VARIANT, applies, quote


class PenthousePricingTests(SimpleTestCase):
    def setUp(self):
        self.specialty = SimpleNamespace(code=CODE, pk=1)

    def test_dimensions_and_all_in_price(self):
        self.assertEqual(quote({'length_m': 10, 'width_m': 10}), (100, 42400000))
        self.assertEqual(quote({'length_m': '6.5', 'width_m': 4}), (26, 11024000))

    def test_server_replaces_client_supplied_price(self):
        result = OrderCreateSerializer().validate({'specialty': self.specialty,
            'calculated_price': 1, 'proposal': {'length_m': 10, 'width_m': 10, 'total_price': 1}})
        self.assertEqual(result['calculated_price'], 42400000)
        self.assertTrue(result['proposal']['includes_labor'])
        self.assertEqual(result['proposal']['unit_price'], 424000)

    def test_invalid_dimensions_rejected(self):
        for value in [0, -1, 'NaN', 'Infinity', 'bad', 1001, None]:
            with self.assertRaises(ValueError):
                quote({'length_m': value, 'width_m': 10})

    def test_no_master_rate_added(self):
        order = SimpleNamespace(specialty=self.specialty, proposal={}, calculated_price=42400000)
        response = SimpleNamespace(order=order)
        serializer = OrderResponseSerializer()
        self.assertEqual(serializer.get_service_total(response), 42400000)
        with self.assertRaises(ValidationError):
            MasterSpecialtyRateSerializer().validate({'specialty': self.specialty, 'price': 100})

    def test_other_roof_methods_still_accept_master_rates(self):
        roof = SimpleNamespace(code='tom', pk=2)
        self.assertFalse(applies(roof, {'variant': 'Terak + shifer'}))
        self.assertTrue(applies(roof, {'variant': VARIANT}))
        attrs = {'specialty': roof, 'price': 100}
        self.assertEqual(MasterSpecialtyRateSerializer().validate(attrs), attrs)

    def test_old_roof_entry_cannot_create_penthouse_order(self):
        with self.assertRaises(ValidationError):
            OrderCreateSerializer().validate({
                'specialty': SimpleNamespace(code='tom', pk=2),
                'proposal': {'variant': VARIANT, 'roof_house_length_m': 10,
                             'roof_house_width_m': 10},
            })


class PenthouseSpecialistTests(TestCase):
    def test_only_specialist_receives_public_penthouse_order(self):
        from apps.accounts.models import User, MasterProfile, MasterSpecialty
        from apps.orders.models import Order
        from apps.orders.visibility import public_orders_q, masters_for_order_q
        from apps.locations.models import Region

        roof = MasterSpecialty.objects.get(code='tom')
        penthouse = MasterSpecialty.objects.get(code=CODE)
        self.assertFalse(roof.variants.filter(name=VARIANT).exists())
        self.assertNotEqual(roof.pk, penthouse.pk)
        region = Region.objects.create(name='Toshkent (pent)')
        client = User.objects.create(username='pent_client', phone_number='+998901111101', region=region)
        roofer = User.objects.create(username='roofer', phone_number='+998901111102', is_master=True, region=region)
        specialist = User.objects.create(username='pent_specialist', phone_number='+998901111103', is_master=True, region=region)
        MasterProfile.objects.create(user=roofer, specialty=roof, experience_years=3)
        MasterProfile.objects.create(user=specialist, specialty=penthouse, experience_years=3)
        order = Order.objects.create(client=client, specialty=penthouse, title='Penthaus', is_public=True, region=region)
        self.assertFalse(order.is_visible_to(roofer))
        self.assertTrue(order.is_visible_to(specialist))
        self.assertFalse(Order.objects.filter(public_orders_q(roofer), pk=order.pk).exists())
        self.assertTrue(Order.objects.filter(public_orders_q(specialist), pk=order.pk).exists())
        recipients = User.objects.filter(masters_for_order_q(order))
        self.assertFalse(recipients.filter(pk=roofer.pk).exists())
        self.assertTrue(recipients.filter(pk=specialist.pk).exists())
