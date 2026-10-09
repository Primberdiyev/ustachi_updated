"""
BIRIKTIRILGAN HUDUD (8-qoida, foydalanuvchi talabi 2026-10-05).

Marg'ilon shahri, Farg'ona shahri, Qo'shtepa va Toshloq tumanlaridagi
ESHIK-ROM e'lonlari faqat bitta ustaga ko'rinadi va xabar ham faqat unga
boradi. Boshqa soha va boshqa tumanlar — avvalgidek.
"""

from io import StringIO

from django.core.management import call_command
from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import ExclusiveTerritory, Notification, NotificationType, Order
from apps.orders.territories import FERGANA_ROM_DISTRICTS, FERGANA_ROM_PHONE, find_district
from apps.locations.models import City, Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"


class ExclusiveTerritoryTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.fergana = Region.objects.create(name="Farg'ona viloyati")
        self.tashkent = Region.objects.create(name="Toshkent shahri")
        self.cities = {
            name: City.objects.create(name=name, region=self.fergana)
            for name in (*FERGANA_ROM_DISTRICTS, "Farg'ona tumani", "Quva tumani")
        }
        self.margilan = self.cities["Marg'ilon shahri"]
        self.quva = self.cities["Quva tumani"]

        self.rom = MasterSpecialty.objects.get(code="rom")
        self.tom = MasterSpecialty.objects.get(code="tom")

        self.client_user = self._user("+998901230001", "Mijoz", self.fergana)
        # Hudud egasi ATAYIN boshqa viloyatda: biriktirish viloyatga qaramaydi.
        self.owner = self._master(FERGANA_ROM_PHONE, "Hudud egasi", [self.rom], region=self.tashkent)
        self.local = self._master("+998901230002", "Marg'ilonlik usta", [self.rom], district=self.margilan)
        self.roofer = self._master("+998901230003", "Tomchi", [self.tom], district=self.margilan)

        call_command("assign_territory", stdout=StringIO())

    def _user(self, phone, name, region=None, district=None):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=region, district=district
        )

    def _master(self, phone, name, specialties, region=None, district=None):
        user = self._user(phone, name, region=region or self.fergana, district=district)
        user.is_master = True
        user.save(update_fields=["is_master"])
        profile = MasterProfile.objects.create(user=user, specialty=specialties[0], experience_years=5)
        profile.specialties.set(specialties)
        return user

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _order(self, specialty, district, **extra):
        payload = {
            "title": "Ish", "description": "-", "address": "-", "specialty": specialty.pk,
            "region": district.region_id, "district": district.pk, **extra,
        }
        resp = self._as(self.client_user).post(f"{CLIENT}orders/", payload, format="json")
        assert resp.status_code == 201, resp.data
        return Order.objects.get(pk=resp.data["id"])

    def _feed_ids(self, master):
        return [o["id"] for o in self._as(master).get(f"{MASTER}orders/feed/").data]

    def _notified_ids(self, order):
        return set(
            Notification.objects.filter(order=order, type=NotificationType.ORDER_PUBLISHED).values_list(
                "user_id", flat=True
            )
        )

    def _respond(self, master, order):
        return self._as(master).post(f"{MASTER}orders/{order.pk}/respond/", {}, format="json").status_code

    # ───────────────────────── testlar ─────────────────────────
    def test_tort_tuman_biriktirilgan(self):
        rows = ExclusiveTerritory.objects.filter(master=self.owner, specialty=self.rom)
        self.assertEqual(
            sorted(rows.values_list("district__name", flat=True)), sorted(FERGANA_ROM_DISTRICTS)
        )
        # "Farg'ona shahri" — "Farg'ona tumani" EMAS.
        self.assertFalse(rows.filter(district=self.cities["Farg'ona tumani"]).exists())

    def test_tort_tumandagi_rom_eloni_FAQAT_egasiga(self):
        for name in FERGANA_ROM_DISTRICTS:
            with self.subTest(district=name):
                order = self._order(self.rom, self.cities[name])
                self.assertEqual(self._notified_ids(order), {self.owner.pk})
                self.assertIn(order.pk, self._feed_ids(self.owner))
                self.assertNotIn(order.pk, self._feed_ids(self.local))
                self.assertEqual(self._respond(self.local, order), 400)
                self.assertEqual(self._respond(self.owner, order), 200)

    def test_boshqa_ustaga_havola_bilan_ham_ochilmaydi(self):
        order = self._order(self.rom, self.margilan)
        detail = lambda user: self._as(user).get(f"{MASTER}orders/{order.pk}/").status_code  # noqa: E731
        self.assertEqual(detail(self.local), 403)
        self.assertEqual(detail(self.roofer), 403)
        self.assertEqual(detail(self.owner), 200)
        # Oddiy tumandagi ochiq e'lon avvalgidek hammaga ochiladi.
        other = self._order(self.rom, self.quva)
        self.assertEqual(self._as(self.roofer).get(f"{MASTER}orders/{other.pk}/").status_code, 200)

    def test_telegram_kanaliga_chiqmaydi(self):
        from unittest.mock import patch

        from apps.common import telegram

        closed = self._order(self.rom, self.margilan)
        usual = self._order(self.rom, self.quva)
        with patch.object(telegram, "_is_enabled", return_value=True), patch.object(
            telegram, "_orders_channel_id", return_value="-100"
        ), patch.object(telegram, "send_order") as send:
            telegram.notify_new_order(closed)
            send.assert_not_called()
            telegram.notify_new_order(usual)
            self.assertEqual(send.call_count, 1)

    def test_tamir_eloni_ham_egasiga(self):
        """Egasi "ta'mirga chiqaman" demagan bo'lsa ham — hudud uniki."""
        order = self._order(self.rom, self.margilan, is_repair=True)
        self.assertEqual(self._notified_ids(order), {self.owner.pk})
        self.assertIn(order.pk, self._feed_ids(self.owner))
        self.assertNotIn(order.pk, self._feed_ids(self.local))

    def test_boshqa_soha_avvalgidek(self):
        order = self._order(self.tom, self.margilan)
        self.assertEqual(self._notified_ids(order), {self.roofer.pk})
        self.assertIn(order.pk, self._feed_ids(self.roofer))
        self.assertNotIn(order.pk, self._feed_ids(self.owner))

    def test_boshqa_tuman_avvalgidek(self):
        """Quva: viloyatdagi hamma rom ustasiga; boshqa viloyatdagi egasiga emas."""
        order = self._order(self.rom, self.quva)
        self.assertEqual(self._notified_ids(order), {self.local.pk})
        self.assertIn(order.pk, self._feed_ids(self.local))
        self.assertNotIn(order.pk, self._feed_ids(self.owner))

    def test_tumansiz_elon_avvalgidek(self):
        order = Order.objects.create(
            client=self.client_user, title="Ish", region=self.fergana, specialty=self.rom, is_public=True
        )
        self.assertIn(order.pk, self._feed_ids(self.local))
        self.assertTrue(order.is_visible_to(self.local))
        self.assertFalse(order.is_visible_to(self.owner))

    def test_feed_xabar_va_ruxsat_BIR_XIL(self):
        for specialty, district in (
            (self.rom, self.margilan), (self.rom, self.quva), (self.tom, self.margilan), (self.tom, self.quva),
        ):
            order = self._order(specialty, district)
            notified = self._notified_ids(order)
            for master in (self.owner, self.local, self.roofer):
                with self.subTest(specialty=specialty.code, district=district.name, master=master.full_name):
                    in_feed = order.pk in self._feed_ids(master)
                    self.assertEqual(in_feed, master.pk in notified)
                    self.assertEqual(in_feed, order.is_visible_to(master))

    def test_taklif_qilingan_usta_baribir_koradi(self):
        order = self._order(self.rom, self.margilan, master_ids=[self.local.pk])
        self.assertIn(order.pk, self._feed_ids(self.local))

    def test_nom_boyicha_topish(self):
        cities = list(City.objects.filter(region=self.fergana))
        self.assertEqual(find_district(cities, "Farg'ona shahri"), self.cities["Farg'ona shahri"])
        self.assertEqual(find_district(cities, "Marg‘ilon shahri"), self.margilan)
        short = City.objects.create(name="Toshloq", region=self.tashkent)
        self.assertEqual(find_district([short], "Toshloq tumani"), short)
        self.assertIsNone(find_district([self.cities["Farg'ona tumani"]], "Farg'ona shahri"))
