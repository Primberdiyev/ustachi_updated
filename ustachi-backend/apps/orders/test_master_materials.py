"""
USTA QAYSI MATERIALDA ISHLAYDI — foydalanuvchi talabi 2026-09-21.

"Men termo eshik yasay olmayman, shu joyini o'chirib qo'yaman va menga
termo zakazlar kelmaydi" (usta so'zi). Usta ilovasida uchta tugmacha:
plastik / alyuminiy / termo.

⚠️ ENG MUHIM TEST — `test_materialsiz_elon_YOQOLMAYDI`: e'lon suratida
`material` kaliti bo'lmasa (tom, g'isht, ta'mir) e'lon HAMMA ustaga
ko'rinishi kerak. JSON taqqoslashda "kalit yo'q" holati NULL beradi va
noto'g'ri yozilgan filtr bunday e'lonlarni jimgina yo'qotib qo'yardi.
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import Notification, NotificationType, Order
from apps.locations.models import Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"

PLASTIC, ALUMINIUM, TERMO = 0, 1, 2


class MasterMaterialsTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.rom = MasterSpecialty.objects.get(code="rom")
        self.tom = MasterSpecialty.objects.get(code="tom")

        self.client_user = self._user("+998901330001", "Mijoz")
        # Hammasini ko'taradigan usta va termo qilmaydigan usta.
        self.all_master = self._master("+998901330002", "Hammasi")
        self.no_termo = self._master("+998901330003", "Termosiz", termo=False)

    def _user(self, phone, name):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=self.region
        )

    def _master(self, phone, name, *, termo=True, plastic=True, aluminium=True):
        user = self._user(phone, name)
        user.is_master = True
        user.save(update_fields=["is_master"])
        profile = MasterProfile.objects.create(
            user=user,
            specialty=self.rom,
            experience_years=5,
            does_plastic=plastic,
            does_aluminium=aluminium,
            does_termo=termo,
        )
        profile.specialties.set([self.rom, self.tom])
        return user

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _order(self, *, material=None, specialty=None):
        payload = {
            "title": "Rom",
            "description": "-",
            "address": "Chilonzor",
            "specialty": (specialty or self.rom).pk,
        }
        if material is not None:
            payload["proposal"] = {"material": material, "shape": "deraza"}
        resp = self._as(self.client_user).post(f"{CLIENT}orders/", payload, format="json")
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
    def test_ochirilgan_material_elonini_KO_RMAYDI(self):
        order = self._order(material=TERMO)

        self.assertIn(order.pk, self._feed_ids(self.all_master))
        self.assertNotIn(order.pk, self._feed_ids(self.no_termo))

        notified = self._notified_ids(order)
        self.assertIn(self.all_master.pk, notified)
        self.assertNotIn(self.no_termo.pk, notified, "termo qilmaydiganga xabar ketmasin")

    def test_qolgan_materiallar_oldingidek_keladi(self):
        for material in (PLASTIC, ALUMINIUM):
            with self.subTest(material=material):
                order = self._order(material=material)
                self.assertIn(order.pk, self._feed_ids(self.no_termo))
                self.assertIn(self.no_termo.pk, self._notified_ids(order))

    def test_materialsiz_elon_YOQOLMAYDI(self):
        """Tom, g'isht, ta'mir — suratda material yo'q, hammaga ko'rinadi."""
        order = self._order(specialty=self.tom)

        for master in (self.all_master, self.no_termo):
            self.assertIn(order.pk, self._feed_ids(master), master.full_name)
            self.assertIn(master.pk, self._notified_ids(order), master.full_name)

    def test_feed_va_xabar_AYNI_to_plamni_beradi(self):
        for material in (PLASTIC, ALUMINIUM, TERMO, None):
            with self.subTest(material=material):
                order = self._order(material=material)
                notified = self._notified_ids(order)
                for master in (self.all_master, self.no_termo):
                    self.assertEqual(
                        order.pk in self._feed_ids(master),
                        master.pk in notified,
                        f"{master.full_name}: feed va xabar ajralib ketdi",
                    )

    def test_ochirilgan_materialda_JAVOB_BERA_OLMAYDI(self):
        order = self._order(material=TERMO)

        resp = self._as(self.no_termo).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_usta_tugmachani_ilovadan_ochiradi(self):
        resp = self._as(self.all_master).patch(
            f"{MASTER}auth/profile/", {"does_termo": False}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertFalse(resp.data["does_termo"])
        self.all_master.master_profile.refresh_from_db()
        self.assertFalse(self.all_master.master_profile.does_termo)
        # Qolganlari tegilmaydi.
        self.assertTrue(self.all_master.master_profile.does_plastic)
        self.assertTrue(self.all_master.master_profile.does_aluminium)

    def test_default_hammasi_YOQIQ(self):
        """Eski ustalar xulqi o'zgarmasin."""
        profile = self.all_master.master_profile
        self.assertTrue(profile.does_plastic)
        self.assertTrue(profile.does_aluminium)
        self.assertTrue(profile.does_termo)
