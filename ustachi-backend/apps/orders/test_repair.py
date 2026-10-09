"""
TA'MIR E'LONI — foydalanuvchi talabi 2026-09-21.

Mijoz ilovadagi "Ta'mir" bo'limidan e'lon beradi (`is_repair=True`), narx
hisoblanmaydi. Bunday e'lon FAQAT "Ta'mirga chiqaman" degan ustaga
(`MasterProfile.does_repairs`) ko'rinadi va push ham faqat ularga boradi.

⚠️ `test_specialty.py` dagi kabi: FEED va XABAR bir manbadan
(`apps/orders/visibility.py`) o'qiydi — shu yerda birga sinaladi.
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.orders.models import Notification, NotificationType, Order
from apps.locations.models import Region

CLIENT = "/api/v1/client/"
MASTER = "/api/v1/master/"


class RepairVisibilityTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent")
        self.rom = MasterSpecialty.objects.get(code="rom")

        self.client_user = self._user("+998901220001", "Mijoz")
        # Ikkalasi ham ROM ustasi, farqi faqat "ta'mirga chiqaman"da.
        self.repairer = self._master("+998901220002", "Ta'mirchi", repairs=True)
        self.builder = self._master("+998901220003", "Faqat yangi", repairs=False)

    def _user(self, phone, name):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, region=self.region
        )

    def _master(self, phone, name, *, repairs):
        user = self._user(phone, name)
        user.is_master = True
        user.save(update_fields=["is_master"])
        profile = MasterProfile.objects.create(
            user=user, specialty=self.rom, experience_years=5, does_repairs=repairs
        )
        profile.specialties.set([self.rom])
        return user

    def _as(self, user):
        self.api.force_authenticate(user=user)
        return self.api

    def _order(self, *, repair, master_ids=None):
        payload = {
            "title": "Rom ta'miri" if repair else "Yangi rom",
            "description": "-",
            "address": "Chilonzor",
            "specialty": self.rom.pk,
            "is_repair": repair,
        }
        if master_ids:
            payload["master_ids"] = master_ids
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
    def test_tamir_eloni_faqat_tamirga_chiqadigan_ustaga(self):
        order = self._order(repair=True)

        self.assertTrue(order.is_repair)
        self.assertIn(order.pk, self._feed_ids(self.repairer))
        self.assertNotIn(order.pk, self._feed_ids(self.builder))

        notified = self._notified_ids(order)
        self.assertIn(self.repairer.pk, notified)
        self.assertNotIn(self.builder.pk, notified, "ta'mirga chiqmaydiganga xabar ketmasin")

    def test_oddiy_elon_hammaga_oldingidek(self):
        order = self._order(repair=False)

        self.assertFalse(order.is_repair)
        for master in (self.repairer, self.builder):
            self.assertIn(order.pk, self._feed_ids(master), master.full_name)
            self.assertIn(master.pk, self._notified_ids(order), master.full_name)

    def test_feed_va_xabar_AYNI_to_plamni_beradi(self):
        """Ikki qoida ajralib ketmasin (2026-08-08 xatosi)."""
        for repair in (True, False):
            with self.subTest(repair=repair):
                order = self._order(repair=repair)
                notified = self._notified_ids(order)
                for master in (self.repairer, self.builder):
                    self.assertEqual(
                        order.pk in self._feed_ids(master),
                        master.pk in notified,
                        f"{master.full_name}: feed va xabar ajralib ketdi",
                    )

    def test_tamirga_chiqmaydigan_usta_JAVOB_BERA_OLMAYDI(self):
        order = self._order(repair=True)

        resp = self._as(self.builder).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_tamirga_chiqmaydigan_ustani_TANLAB_BO_LMAYDI(self):
        """
        Usta talabi 2026-09-21: "ta'mirlayman" tugmasini o'chirgan ustani
        mijoz tanlay olmaydi. Ilova bunday ustani ro'yxatda ko'rsatmaydi,
        server esa taklifni YOZMAYDI (eski ilova yoki belgi keyin
        o'chirilgan bo'lsa).
        """
        order = self._order(repair=True, master_ids=[self.builder.pk])

        self.assertFalse(order.invites.filter(master=self.builder).exists())
        self.assertNotIn(order.pk, self._feed_ids(self.builder))
        resp = self._as(self.builder).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_TAKLIF_qilingan_tamirchi_ustani_ko_radi(self):
        """Ta'mirga chiqadigan usta esa taklifni oladi (1-qoida)."""
        order = self._order(repair=True, master_ids=[self.repairer.pk])

        self.assertIn(order.pk, self._feed_ids(self.repairer))
        resp = self._as(self.repairer).post(
            f"{MASTER}orders/{order.pk}/respond/", {}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)

    def test_usta_belgini_ilovadan_yoqadi(self):
        """"Ta'mirga chiqaman" tugmachasi serverga SAQLANISHI kerak."""
        resp = self._as(self.builder).patch(
            f"{MASTER}auth/profile/", {"does_repairs": True}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertTrue(resp.data["does_repairs"])
        self.builder.master_profile.refresh_from_db()
        self.assertTrue(self.builder.master_profile.does_repairs)

    def test_elonda_tamir_belgisi_ustaga_korinadi(self):
        """Usta kartada bu yangi ish emasligini DARHOL bilsin."""
        order = self._order(repair=True)
        feed = self._as(self.repairer).get(f"{MASTER}orders/feed/").data
        row = next(o for o in feed if o["id"] == order.pk)
        self.assertTrue(row["is_repair"])


class RepairCatalogTests(TestCase):
    """Ta'mir sohalari va muammolar ro'yxati (2026-10-09) — `specialties/` da."""

    URL = f"{CLIENT}specialties/"

    def _rows(self):
        return {row["code"]: row for row in APIClient().get(self.URL).data}

    def test_santexnikda_tamir_bor_va_muammolar_tartibi_bilan(self):
        row = self._rows()["santexnik"]
        self.assertTrue(row["has_repair"])
        self.assertEqual(
            dict(row["repair_problems"][0]),
            {
                "code": "kran",
                "title": "Kran yoki smesitel",
                "hint": "Oqyapti, tomchilayapti yoki almashtirish kerak",
            },
        )
        self.assertGreaterEqual(len(row["repair_problems"]), 6)

    def test_tamirsiz_sohada_royxat_bosh(self):
        row = self._rows()["gisht"]
        self.assertFalse(row["has_repair"])
        self.assertEqual(row["repair_problems"], [])

    def test_ochirilgan_muammo_va_belgi_olingan_soha_chiqmaydi(self):
        from apps.accounts.models import SpecialtyRepairProblem

        SpecialtyRepairProblem.objects.filter(specialty__code="santexnik", code="kran").update(is_active=False)
        MasterSpecialty.objects.filter(code="elektrik").update(has_repair=False)
        rows = self._rows()
        self.assertNotIn("kran", [p["code"] for p in rows["santexnik"]["repair_problems"]])
        self.assertEqual(rows["elektrik"]["repair_problems"], [])

    def test_santexnik_tamiri_faqat_shu_tumandagi_tamirchiga(self):
        from apps.locations.models import City

        region = Region.objects.create(name="Farg'ona")
        here, there = (City.objects.create(name=n, region=region) for n in ("Quva", "Rishton"))
        plumbing = MasterSpecialty.objects.get(code="santexnik")

        def master(phone, district, repairs):
            user = User.objects.create_user(
                phone_number=phone, full_name=phone, is_active=True, region=region, district=district
            )
            user.is_master = True
            user.save(update_fields=["is_master"])
            profile = MasterProfile.objects.create(
                user=user, specialty=plumbing, experience_years=3, does_repairs=repairs
            )
            profile.specialties.set([plumbing])
            return user

        near = master("+998901330001", here, True)
        master("+998901330002", there, True)
        master("+998901330003", here, False)
        client = User.objects.create_user(
            phone_number="+998901330009", is_active=True, region=region, district=here
        )

        api = APIClient()
        api.force_authenticate(client)
        resp = api.post(
            f"{CLIENT}orders/",
            {
                "title": "Santexnik ta'miri", "description": "-", "address": "-", "specialty": plumbing.pk,
                "region": region.pk, "district": here.pk, "is_repair": True,
                "proposal": {"engine": "repair", "repair_problems": ["kran"]},
            },
            format="json",
        )
        self.assertEqual(resp.status_code, 201, resp.data)
        notified = set(
            Notification.objects.filter(
                order_id=resp.data["id"], type=NotificationType.ORDER_PUBLISHED
            ).values_list("user_id", flat=True)
        )
        self.assertEqual(notified, {near.pk})
