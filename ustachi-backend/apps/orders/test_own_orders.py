"""
USTANING O'Z buyurtmalari — marketplace'dan mustaqil oqim.

`MasterOrder` butunlay alohida model: buyurtmachi ma'lumoti + chizma.

Asosiy qoidalar shu yerda qulflanadi:
  * usta ilovasi yuboradigan AYNAN shu shakl qabul qilinadi va ro'yxatda
    chizmasi bilan qaytadi; pul maydonlari yo'q;
  * `sync_client_id` bilan qayta yuborish DUBLIKAT yaratmaydi;
  * boshqa ustaning buyurtmasi ko'rinmaydi.
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.orders.models import MasterOrder, MasterOrderItem, MasterOrderStatus

MY_ORDERS = "/api/v1/master/my-orders/"


def item(**overrides):
    data = {
        "title": "1500 × 1600",
        "material_label": "Plastik",
        "width_mm": 1500,
        "height_mm": 1600,
        "qty": 1,
        "drawing": {"w": 1500, "h": 1600},
    }
    data.update(overrides)
    return data


def payload(**overrides):
    data = {
        "customer_name": "Aziz aka",
        "customer_phone": "+998901234567",
        "customer_address": "Chilonzor 9",
        "items": [item()],
    }
    data.update(overrides)
    return data


class OwnOrderBaseTests(TestCase):
    def setUp(self):
        self.api = APIClient()
        self.master = self._master("+998901112244", "Usta Bir")
        self.other_master = self._master("+998901112255", "Usta Ikki")
        self.api.force_authenticate(self.master)

    def _master(self, phone, name):
        return User.objects.create_user(
            phone_number=phone, full_name=name, is_active=True, is_master=True
        )


class OwnOrderCreateTests(OwnOrderBaseTests):
    #: Javobdagi kalitlar — ilova bilan kelishilgan shartnoma.
    ORDER_KEYS = {
        "id", "sync_client_id", "customer_name", "customer_phone",
        "customer_address", "deadline", "note", "product_count", "status",
        "status_label", "completed_at", "items", "created_at",
    }
    ITEM_KEYS = {
        "id", "position", "title", "material_label", "width_mm", "height_mm",
        "qty", "drawing",
    }

    def test_ilova_shaklidagi_sorov_yaratadi_va_royxatda_chizma_bilan_qaytadi(self):
        drawing = {"version": 2, "w": 1500, "h": 1600, "cells": [{"open": "turn"}]}
        body = {
            "sync_client_id": "draft-42",
            "customer_name": "Aziz aka",
            "customer_phone": "+998901234567",
            "customer_address": "Chilonzor 9",
            "deadline": "2026-11-01",
            "note": "2-qavat",
            "status": MasterOrderStatus.NEW,
            "items": [
                {
                    "position": 0,
                    "title": "1500 × 1600",
                    "material_label": "Plastik",
                    "width_mm": 1500,
                    "height_mm": 1600,
                    "qty": 2,
                    "drawing": drawing,
                }
            ],
        }

        created = self.api.post(MY_ORDERS, body, format="json")
        self.assertEqual(created.status_code, 201, created.data)

        listed = self.api.get(MY_ORDERS)
        self.assertEqual(listed.status_code, 200)
        self.assertEqual(len(listed.data), 1)
        order = listed.data[0]
        self.assertEqual(set(order), self.ORDER_KEYS)
        self.assertEqual(order["id"], created.data["id"])
        self.assertEqual(order["customer_name"], "Aziz aka")
        self.assertEqual(order["deadline"], "2026-11-01")
        self.assertEqual(order["note"], "2-qavat")
        self.assertEqual(order["status"], MasterOrderStatus.NEW)
        self.assertEqual(order["product_count"], 2)

        (row,) = order["items"]
        self.assertEqual(set(row), self.ITEM_KEYS)
        self.assertEqual(row["drawing"], drawing)
        self.assertEqual((row["width_mm"], row["height_mm"], row["qty"]), (1500, 1600, 2))

    def test_ixtiyoriy_maydonlarsiz_ham_yaratiladi(self):
        response = self.api.post(MY_ORDERS, payload(), format="json")

        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["status"], MasterOrderStatus.NEW)
        self.assertEqual(response.data["product_count"], 1)
        self.assertIsNone(response.data["deadline"])

    def test_pul_maydonlari_qabul_qilinmaydi_va_qaytmaydi(self):
        response = self.api.post(
            MY_ORDERS,
            payload(
                total_price=1,
                discount=1,
                prepaid=1,
                items=[item(unit_cost=1, unit_benefit=1, bom=[{"name": "x"}])],
            ),
            format="json",
        )

        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(set(response.data), self.ORDER_KEYS)
        self.assertEqual(set(response.data["items"][0]), self.ITEM_KEYS)

    def test_mahsulotsiz_buyurtma_400(self):
        response = self.api.post(MY_ORDERS, payload(items=[]), format="json")
        self.assertEqual(response.status_code, 400)

    def test_ism_majburiy(self):
        response = self.api.post(MY_ORDERS, payload(customer_name="  "), format="json")
        self.assertEqual(response.status_code, 400)

    def test_sanoq_nol_bolmaydi(self):
        response = self.api.post(
            MY_ORDERS, payload(items=[item(qty=0)]), format="json"
        )
        self.assertEqual(response.status_code, 400)

    def test_usta_bolmagan_foydalanuvchi_403(self):
        client_user = User.objects.create_user(
            phone_number="+998901119999", full_name="Mijoz", is_active=True
        )
        self.api.force_authenticate(client_user)
        response = self.api.post(MY_ORDERS, payload(), format="json")
        self.assertEqual(response.status_code, 403)


class OwnOrderIdempotencyTests(OwnOrderBaseTests):
    def test_ayni_sync_id_bilan_qayta_yuborish_dublikat_yaratmaydi(self):
        body = payload(sync_client_id="draft-1")

        first = self.api.post(MY_ORDERS, body, format="json")
        second = self.api.post(MY_ORDERS, body, format="json")

        self.assertEqual(MasterOrder.objects.count(), 1)
        self.assertEqual(first.data["id"], second.data["id"])
        # Mahsulot ham ikkilanmaydi.
        self.assertEqual(MasterOrderItem.objects.count(), 1)

    def test_sync_id_ustalar_orasida_toqnashmaydi(self):
        body = payload(sync_client_id="draft-1")
        self.api.post(MY_ORDERS, body, format="json")

        self.api.force_authenticate(self.other_master)
        self.api.post(MY_ORDERS, body, format="json")

        self.assertEqual(MasterOrder.objects.count(), 2)

    def test_sync_idsiz_ikki_sorov_ikki_buyurtma(self):
        self.api.post(MY_ORDERS, payload(), format="json")
        self.api.post(MY_ORDERS, payload(), format="json")
        self.assertEqual(MasterOrder.objects.count(), 2)


class OwnOrderAccessTests(OwnOrderBaseTests):
    def setUp(self):
        super().setUp()
        self.order_id = self.api.post(MY_ORDERS, payload(), format="json").data["id"]

    def test_royxatda_faqat_oz_buyurtmalari(self):
        self.api.force_authenticate(self.other_master)
        self.api.post(MY_ORDERS, payload(customer_name="Boshqa"), format="json")

        response = self.api.get(MY_ORDERS)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["customer_name"], "Boshqa")

    def test_boshqa_ustaning_buyurtmasi_404(self):
        self.api.force_authenticate(self.other_master)
        response = self.api.get(f"{MY_ORDERS}{self.order_id}/")
        self.assertEqual(response.status_code, 404)

    def test_boshqa_usta_ochira_olmaydi(self):
        self.api.force_authenticate(self.other_master)
        response = self.api.delete(f"{MY_ORDERS}{self.order_id}/")

        self.assertEqual(response.status_code, 404)
        self.assertTrue(MasterOrder.objects.filter(pk=self.order_id).exists())

    def test_status_boyicha_filtr(self):
        self.api.post(
            f"{MY_ORDERS}{self.order_id}/status/",
            {"status": MasterOrderStatus.DONE},
            format="json",
        )
        self.api.post(MY_ORDERS, payload(), format="json")

        done = self.api.get(MY_ORDERS, {"status": MasterOrderStatus.DONE})
        self.assertEqual(len(done.data), 1)
        self.assertEqual(done.data[0]["id"], self.order_id)


class OwnOrderUpdateTests(OwnOrderBaseTests):
    def setUp(self):
        super().setUp()
        self.order_id = self.api.post(MY_ORDERS, payload(), format="json").data["id"]

    def test_mahsulotlar_patch_bilan_almashtiriladi(self):
        response = self.api.patch(
            f"{MY_ORDERS}{self.order_id}/",
            {"items": [item(), item(qty=3, drawing={"w": 900, "h": 2100})]},
            format="json",
        )

        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(len(response.data["items"]), 2)
        self.assertEqual(response.data["product_count"], 4)
        self.assertEqual(response.data["items"][1]["drawing"], {"w": 900, "h": 2100})
        self.assertEqual(MasterOrderItem.objects.count(), 2)

    def test_izohni_patch_qilish_mahsulotlarga_tegmaydi(self):
        response = self.api.patch(
            f"{MY_ORDERS}{self.order_id}/", {"note": "Ertaga"}, format="json"
        )

        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(response.data["note"], "Ertaga")
        self.assertEqual(len(response.data["items"]), 1)

    def test_ochirish(self):
        response = self.api.delete(f"{MY_ORDERS}{self.order_id}/")

        self.assertEqual(response.status_code, 204)
        self.assertEqual(MasterOrder.objects.count(), 0)
        self.assertEqual(MasterOrderItem.objects.count(), 0)


class OwnOrderStatusTests(OwnOrderBaseTests):
    def setUp(self):
        super().setUp()
        self.order_id = self.api.post(MY_ORDERS, payload(), format="json").data["id"]

    def _set(self, status):
        return self.api.post(
            f"{MY_ORDERS}{self.order_id}/status/", {"status": status}, format="json"
        )

    def test_holatni_ozgartirish(self):
        response = self._set(MasterOrderStatus.IN_PROGRESS)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["status"], MasterOrderStatus.IN_PROGRESS)
        self.assertIsNone(response.data["completed_at"])

    def test_yakunlanganda_vaqt_qoyiladi_va_qaytsa_olinadi(self):
        done = self._set(MasterOrderStatus.DONE)
        self.assertIsNotNone(done.data["completed_at"])

        back = self._set(MasterOrderStatus.IN_PROGRESS)
        self.assertIsNone(back.data["completed_at"])

    def test_notogri_holat_400(self):
        response = self._set("kutilmagan")
        self.assertEqual(response.status_code, 400)


class OwnOrderMarketplaceIsolationTests(OwnOrderBaseTests):
    """Ikki model bir-biriga TEGMAYDI — regressiya qulfi."""

    def test_oz_buyurtma_marketplace_royxatiga_tushmaydi(self):
        self.api.post(MY_ORDERS, payload(), format="json")

        marketplace = self.api.get("/api/v1/master/orders/")
        self.assertEqual(marketplace.status_code, 200)
        self.assertEqual(marketplace.data, [])
