"""
YO'NALISH (soha) bo'yicha ko'rinish — foydalanuvchi talabi 2026-08-13.

Platforma endi faqat rom emas: mijoz istalgan soha bo'yicha e'lon beradi
(tom yopish, g'isht, suvoq...), e'lon esa FAQAT o'sha soha ustalariga
ko'rinadi va push ham faqat ularga boradi.

⚠️ ENG MUHIM TEST — `test_feed_va_xabar_BIR XIL`: feed (usta→e'lonlar) va
bildirishnoma (e'lon→ustalar) qoidalari ajralib ketmasin. 2026-08-08 da
aynan shu ajralishdan xato chiqqan edi (usta e'lonni ro'yxatda ko'rib
turardi, lekin xabar kelmasdi), shuning uchun ikkalasi bitta manbadan
(`apps/orders/visibility.py`) o'qiydi va shu yerda BIRGA sinaladi.
"""

from unittest.mock import patch

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import Notification, NotificationType, Order
from apps.locations.models import Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"


class SpecialtyVisibilityTests(TestCase):
    """Feed · bildirishnoma · javob berish — uchalasi bir xil qoidada."""

    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.other_region = Region.objects.create(name="Samarqand")

        self.rom = MasterSpecialty.objects.get(code="rom")
        self.tom = MasterSpecialty.objects.get(code="tom")
        self.gisht = MasterSpecialty.objects.get(code="gisht")

        self.client_user = self._user("+998901110001", "Mijoz", self.region)
        # Bir sohali ustalar
        self.rom_master = self._master("+998901110002", "Rom usta", [self.rom])
        self.tom_master = self._master("+998901110003", "Tom usta", [self.tom])
        # KO'P sohali usta (foydalanuvchi qarori: usta bir nechta soha oladi)
        self.multi = self._master("+998901110004", "Ko'p soha", [self.tom, self.gisht])

    # ───────────────────────── yordamchilar ─────────────────────────
    def _user(self, phone, name, region=None):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=region
        )

    def _master(self, phone, name, specialties, region=None):
        user = self._user(phone, name, region=region or self.region)
        user.is_master = True
        user.save(update_fields=["is_master"])
        profile = MasterProfile.objects.create(
            user=user, specialty=specialties[0], experience_years=5
        )
        profile.specialties.set(specialties)
        return user

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _order(self, specialty=None, region=None, master_ids=None):
        payload = {
            "title": "Ish",
            "description": "-",
            "address": "Chilonzor",
        }
        if specialty is not None:
            payload["specialty"] = specialty.pk
        if master_ids:
            payload["master_ids"] = master_ids
        resp = self._as(self.client_user).post(
            f"{CLIENT}orders/", payload, format="json"
        )
        assert resp.status_code == 201, resp.data
        return Order.objects.get(pk=resp.data["id"])

    def _feed_ids(self, master):
        return [o["id"] for o in self._as(master).get(f"{MASTER}orders/feed/").data]

    def _notified_ids(self, order):
        return set(
            Notification.objects.filter(
                order=order, type=NotificationType.ORDER_PUBLISHED
            ).values_list("user_id", flat=True)
        )

    # ───────────────────────── testlar ─────────────────────────
    def test_elon_FAQAT_soha_ustalariga_boradi(self):
        order = self._order(specialty=self.tom)

        notified = self._notified_ids(order)
        self.assertIn(self.tom_master.pk, notified)
        self.assertIn(self.multi.pk, notified, "ko'p sohali usta ham oladi")
        self.assertNotIn(
            self.rom_master.pk, notified, "boshqa soha ustasiga xabar ketmasin"
        )

    def test_feed_va_xabar_AYNI_to_plamni_beradi(self):
        """Ikki qoida ajralib ketmasin (2026-08-08 xatosi)."""
        for specialty in (self.rom, self.tom, self.gisht):
            with self.subTest(specialty=specialty.code):
                order = self._order(specialty=specialty)
                notified = self._notified_ids(order)
                for master in (self.rom_master, self.tom_master, self.multi):
                    self.assertEqual(
                        order.pk in self._feed_ids(master),
                        master.pk in notified,
                        f"{master.full_name}: feed va xabar ajralib ketdi "
                        f"({specialty.code})",
                    )

    def test_boshqa_soha_ustasi_feedda_KO_RMAYDI(self):
        order = self._order(specialty=self.tom)

        self.assertIn(order.pk, self._feed_ids(self.tom_master))
        self.assertNotIn(order.pk, self._feed_ids(self.rom_master))

    def test_boshqa_soha_ustasi_JAVOB_BERA_OLMAYDI(self):
        order = self._order(specialty=self.tom)

        resp = self._as(self.rom_master).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_boshqa_soha_ustasi_public_buyurtmani_koradi_lekin_javob_bera_olmaydi(self):
        order = self._order(specialty=self.tom)

        detail = self._as(self.rom_master).get(f"{MASTER}orders/{order.pk}/")
        self.assertEqual(detail.status_code, 200, detail.data)
        self.assertEqual(detail.data["id"], order.pk)
        self.assertFalse(detail.data["viewer_is_assigned"])

        response = self._as(self.rom_master).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(response.status_code, 400, response.data)

    def test_TAKLIF_qilingan_usta_soha_mos_bo_lmasa_ham_ko_radi(self):
        """Mijoz ATAYIN tanlagan — chegara qo'yilsa tanlovi bekor bo'lardi."""
        order = self._order(specialty=self.tom, master_ids=[self.rom_master.pk])

        self.assertIn(order.pk, self._feed_ids(self.rom_master))
        resp = self._as(self.rom_master).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)

    def test_profilsiz_usta_ochiq_elon_KO_RMAYDI(self):
        """Yo'nalishi yo'q usta har soha e'loniga ko'milib qolmasin."""
        empty = self._user("+998901110009", "Profilsiz", self.region)
        empty.is_master = True
        empty.save(update_fields=["is_master"])

        order = self._order(specialty=self.tom)

        self.assertNotIn(order.pk, self._feed_ids(empty))
        self.assertNotIn(empty.pk, self._notified_ids(order))

    def test_specialty_yo_q_usta_soha_tanlanmagan_elon_ko_rmaydi(self):
        """Profili bo'lgan lekin specialty tanlangan emas usta — soha e'lonini ko'rmaydi."""
        # Profili bor, lekin specialty bo'sh
        no_spec = self._user("+998901110011", "Specialty yo'q", self.region)
        no_spec.is_master = True
        no_spec.save(update_fields=["is_master"])
        profile = MasterProfile.objects.create(
            user=no_spec, specialty=self.rom, experience_years=1
        )
        profile.specialties.clear()  # Specialty yo'q qilamiz

        order = self._order(specialty=self.tom)

        # QOIDA 3: Profilini to'ldirmagan (yo'nalishi yo'q) usta ochiq e'lon KO'RMAYDI
        self.assertNotIn(order.pk, self._feed_ids(no_spec))
        self.assertNotIn(no_spec.pk, self._notified_ids(order))

    def test_yo_nalishsiz_kelgan_elon_ROM_bo_ladi(self):
        """ESKI mijoz ilovasi bu maydonni bilmaydi — e'loni rom bo'lib qoladi."""
        order = self._order()  # specialty yuborilmaydi

        self.assertEqual(order.specialty, self.rom)
        self.assertIn(self.rom_master.pk, self._notified_ids(order))
        self.assertNotIn(self.tom_master.pk, self._notified_ids(order))

    def test_hudud_qoidasi_soha_bilan_birga_ishlaydi(self):
        far = self._master(
            "+998901110010", "Uzoq tom", [self.tom], region=self.other_region
        )
        order = self._order(specialty=self.tom)  # mijoz hududi: Toshkent

        notified = self._notified_ids(order)
        self.assertIn(self.tom_master.pk, notified)
        self.assertNotIn(far.pk, notified, "boshqa viloyat")
        self.assertNotIn(order.pk, self._feed_ids(far))

        detail = self._as(far).get(f"{MASTER}orders/{order.pk}/")
        self.assertEqual(detail.status_code, 200, detail.data)
        response = self._as(far).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(response.status_code, 400, response.data)

    @patch("apps.orders.services.push.send_to_users")
    def test_push_soha_ichida_accepts_orders_bilan_cheklanadi(self, send):
        """Qoida o'zgarmadi: yozuv hammaga, PUSH faqat qabul qiluvchiga."""
        profile = self.multi.master_profile
        profile.accepts_orders = False
        profile.save(update_fields=["accepts_orders"])

        order = self._order(specialty=self.tom)

        self.assertIn(self.multi.pk, self._notified_ids(order), "yozuv boradi")
        # `send_to_users` User obyektlarini oladi — id'ga o'giramiz.
        pushed = {u.pk for u in (send.call_args.args[0] if send.call_args else [])}
        self.assertNotIn(self.multi.pk, pushed, "push ketmasin")
        self.assertIn(self.tom_master.pk, pushed)


class SpecialtyCatalogTests(TestCase):
    """Katalog — ikkala ilova ham shu ro'yxatdan tanlaydi."""

    def setUp(self):
        self.api = APIClient()

    def test_katalog_kodlari_bilan_keladi(self):
        resp = self.api.get(f"{CLIENT}specialties/")
        self.assertEqual(resp.status_code, 200)
        codes = {row["code"] for row in resp.data}
        self.assertIn("rom", codes)
        self.assertIn("tom", codes)
        self.assertIn("mardikor", codes)
        self.assertGreaterEqual(len(resp.data), 17)

    def test_mijoz_va_usta_bir_xil_katalogni_koradi(self):
        client_rows = self.api.get(f"{CLIENT}specialties/").data
        master_rows = self.api.get(f"{MASTER}auth/specialties/").data
        self.assertEqual(
            [r["code"] for r in client_rows], [r["code"] for r in master_rows]
        )
