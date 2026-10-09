"""
CHAT SAHIFALASH (foydalanuvchi talabi 2026-09-05).

Ilgari `GET .../messages/` HAR SAFAR butun tarixni qaytarardi — chat
ochilganda ham, har yangi xabar signalida ham, soket o'lik bo'lsa har
5 soniyada ham.

Qulflanadigan shartnoma:
  * `limit`         — eng SO'NGGI shuncha xabar;
  * `before=<id>`   — o'sha xabardan OLDINGI sahifa;
  * `after=<id>`    — o'sha xabardan KEYINGILARI (jonli yangilanish);
  * javob DOIM vaqt bo'yicha O'SISH tartibida va DOIM oddiy massiv;
  * parametrsiz so'rov — BUTUN tarix (do'kondagi ESKI ilovalar uchun);
  * `before` va `after` birga berilmaydi;
  * chegara serverda — mijoz cheksiz `limit` so'rab ololmaydi.
"""

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.orders.models import ChatMessage, ChatThread, Order


class ChatPaginationTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.client_user = User.objects.create_user(
            phone_number="+998900000101", full_name="Mijoz"
        )
        cls.master = User.objects.create_user(
            phone_number="+998900000102", full_name="Usta", is_master=True
        )
        order = Order.objects.create(
            client=cls.client_user, title="Rom", assigned_master=cls.master
        )
        cls.thread = ChatThread.objects.create(order=order, master=cls.master)
        # 120 ta xabar — bir sahifadan ko'p.
        cls.messages = [
            ChatMessage.objects.create(
                thread=cls.thread, sender=cls.master, text=f"xabar-{i}"
            )
            for i in range(1, 121)
        ]

    def setUp(self):
        self.api = APIClient()
        self.api.force_authenticate(self.client_user)

    @property
    def url(self):
        return f"/api/v1/client/chat/threads/{self.thread.pk}/messages/"

    def get(self, **params):
        return self.api.get(self.url, params)

    def texts(self, response):
        return [row["text"] for row in response.data]

    # ── Javob shakli ────────────────────────────────────────────
    def test_javob_ODDIY_MASSIV_bolib_qoladi(self):
        # Do'kondagi eski ilovalar aynan massiv kutadi.
        response = self.get(limit=5)
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.data, list)

    def test_PARAMETRSIZ_soro_butun_tarixni_beradi(self):
        # ESKI ilovalar sahifalashni bilmaydi — ular uchun hech nima
        # o'zgarmasligi kerak.
        self.assertEqual(len(self.get().data), 120)

    # ── limit: chat ochilganda ──────────────────────────────────
    def test_limit__ENG_SONGGI_sahifa(self):
        response = self.get(limit=50)

        self.assertEqual(len(response.data), 50)
        self.assertEqual(self.texts(response)[0], "xabar-71")
        self.assertEqual(self.texts(response)[-1], "xabar-120")

    def test_javob_OSISH_tartibida(self):
        # Ilova ro'yxatni teskari ko'rsatadi; ma'lumot esa eskidan yangiga.
        ids = [row["id"] for row in self.get(limit=10).data]
        self.assertEqual(ids, sorted(ids))

    def test_xabar_KAM_bolsa_borini_beradi(self):
        ChatMessage.objects.filter(thread=self.thread).exclude(
            pk__in=[m.pk for m in self.messages[:3]]
        ).delete()

        self.assertEqual(len(self.get(limit=50).data), 3)

    # ── before: tepaga surilganda ───────────────────────────────
    def test_before__OLDINGI_sahifa(self):
        cursor = self.messages[70].pk  # "xabar-71"
        response = self.get(before=cursor, limit=50)

        self.assertEqual(len(response.data), 50)
        self.assertEqual(self.texts(response)[0], "xabar-21")
        self.assertEqual(self.texts(response)[-1], "xabar-70")

    def test_before__kursorning_OZI_kirmaydi(self):
        cursor = self.messages[70].pk
        ids = [row["id"] for row in self.get(before=cursor, limit=50).data]
        self.assertNotIn(cursor, ids)

    def test_before__ENG_BOSHIDA_bosh_royxat(self):
        # Ilova shu bo'sh javobdan "boshiga yetdik" degan xulosa chiqaradi.
        first = self.messages[0].pk
        self.assertEqual(self.get(before=first, limit=50).data, [])

    def test_ketma_ket_sahifalar_BUTUN_tarixni_qoplaydi(self):
        seen = []
        page = self.get(limit=50).data
        while page:
            seen = [row["text"] for row in page] + seen
            page = self.get(before=page[0]["id"], limit=50).data

        self.assertEqual(len(seen), 120)
        self.assertEqual(seen[0], "xabar-1")
        self.assertEqual(seen[-1], "xabar-120")
        self.assertEqual(len(set(seen)), 120, "takror yo'q")

    # ── after: jonli yangilanish ────────────────────────────────
    def test_after__FAQAT_yangilari(self):
        cursor = self.messages[117].pk  # "xabar-118"
        response = self.get(after=cursor)

        self.assertEqual(self.texts(response), ["xabar-119", "xabar-120"])

    def test_after__YANGISI_YOQ_bolsa_bosh(self):
        # Eng qimmat holat: har signalda 120 ta emas, NOLTA qator o'qiladi.
        last = self.messages[-1].pk
        self.assertEqual(self.get(after=last).data, [])

    def test_after__yangi_xabar_kelsa_faqat_U_qaytadi(self):
        last = self.messages[-1].pk
        ChatMessage.objects.create(
            thread=self.thread, sender=self.master, text="yangi"
        )

        self.assertEqual(self.texts(self.get(after=last)), ["yangi"])

    # ── Chegaralar va xatolar ───────────────────────────────────
    def test_CHEKSIZ_limit_sorab_bolmaydi(self):
        # Mijoz server xotirasini yeya olmasin.
        self.assertEqual(self.get(limit=100000).status_code, 400)

    def test_nol_limit__400(self):
        self.assertEqual(self.get(limit=0).status_code, 400)

    def test_before_va_after_BIRGA__400(self):
        cursor = self.messages[10].pk
        self.assertEqual(
            self.get(before=cursor, after=cursor).status_code, 400
        )

    def test_notogri_kursor__400(self):
        self.assertEqual(self.get(before="kecha").status_code, 400)

    def test_BEGONA_suhbat__403(self):
        stranger = User.objects.create_user(phone_number="+998900000103")
        self.api.force_authenticate(stranger)
        self.assertEqual(self.get(limit=10).status_code, 403)

    # ── Regressiya ──────────────────────────────────────────────
    def test_sahifalash_OQILDI_belgisini_buzmaydi(self):
        ChatMessage.objects.filter(thread=self.thread).update(is_read=False)

        self.get(limit=10)

        unread = ChatMessage.objects.filter(
            thread=self.thread, is_read=False
        ).exclude(sender=self.client_user).count()
        self.assertEqual(unread, 0)
