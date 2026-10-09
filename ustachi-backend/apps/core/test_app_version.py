"""
ILOVA VERSIYASI — «yangi versiya chiqdi» oynasining qoidasi
(foydalanuvchi talabi 2026-09-05).

Qulflanadigan shartnoma:
  * `min_version` dan PAST — majburiy (oyna yopilmaydi);
  * `latest_version` dan past — ixtiyoriy («Keyinroq» bor);
  * teng yoki yuqori — hech narsa ko'rsatilmaydi;
  * `min_version` bo'sh — majburiy rejim UMUMAN ishlamaydi;
  * qator o'chirilgan yoki HAVOLASIZ — hech narsa ko'rsatilmaydi
    (bosib bo'lmaydigan tugma bilan qoldirmaymiz);
  * `notes` bo'sh bo'lishi MUMKIN — javob baribir to'g'ri;
  * so'rov auth talab qilmaydi (login ekranidan oldin ham kerak).
"""

from django.core.exceptions import ValidationError
from django.test import TestCase
from rest_framework.test import APIClient

from apps.core.models import AppRelease, UpdateStatus

CLIENT_URL = "/api/v1/client/app-version/"
MASTER_URL = "/api/v1/master/app-version/"


def release(**kwargs) -> AppRelease:
    defaults = {
        "app": "client",
        "platform": "android",
        "latest_version": "1.2.0",
        "min_version": "",
        "store_url": "https://play.google.com/store/apps/details?id=uz.ustachi.mijoz",
        "notes": "",
        "is_active": True,
    }
    defaults.update(kwargs)
    obj, _ = AppRelease.objects.update_or_create(
        app=defaults.pop("app"), platform=defaults.pop("platform"), defaults=defaults
    )
    return obj


class StatusRuleTests(TestCase):
    """Taqqoslash — modelning o'zida, tarmoqsiz."""

    def ask(self, current: str, **kwargs) -> str:
        from apps.core.models import parse_version

        return release(**kwargs).status_for(parse_version(current))

    def test_eski_versiya__IXTIYORIY(self):
        self.assertEqual(self.ask("1.1.9"), UpdateStatus.OPTIONAL)

    def test_AYNAN_oxirgi_versiya__hech_narsa(self):
        self.assertEqual(self.ask("1.2.0"), UpdateStatus.UP_TO_DATE)

    def test_oxirgidan_YUQORI_versiya__hech_narsa(self):
        # Test qurilmasidagi ilova do'kondagidan yangi bo'lishi mumkin.
        self.assertEqual(self.ask("1.3.0"), UpdateStatus.UP_TO_DATE)

    def test_min_versiyadan_past__MAJBURIY(self):
        self.assertEqual(
            self.ask("0.9.0", min_version="1.0.0"), UpdateStatus.REQUIRED
        )

    def test_min_versiyaning_OZI__majburiy_emas(self):
        # Chegara qamrab olmaydi: 1.0.0 «ruxsat etilgan eng past» demak.
        self.assertEqual(
            self.ask("1.0.0", min_version="1.0.0"), UpdateStatus.OPTIONAL
        )

    def test_min_versiya_BOSH__majburiy_ishlamaydi(self):
        # Eng muhim himoya: chegara qo'yilmaguncha hech kim qulflanmaydi.
        self.assertEqual(self.ask("0.0.1", min_version=""), UpdateStatus.OPTIONAL)

    def test_OCHIRILGAN_qator__hech_narsa(self):
        self.assertEqual(self.ask("0.0.1", is_active=False), UpdateStatus.UP_TO_DATE)

    def test_HAVOLASIZ_qator__hech_narsa(self):
        # Yoqilgan-u havolasi yo'q qator ham jim turadi.
        obj = release()
        AppRelease.objects.filter(pk=obj.pk).update(store_url="")
        obj.refresh_from_db()
        from apps.core.models import parse_version

        self.assertEqual(obj.status_for(parse_version("0.0.1")), UpdateStatus.UP_TO_DATE)

    def test_ikki_va_uch_bolakli_versiyalar_ARALASH(self):
        self.assertEqual(self.ask("1.2", latest_version="1.2.1"), UpdateStatus.OPTIONAL)
        self.assertEqual(self.ask("1.2.0", latest_version="1.2"), UpdateStatus.UP_TO_DATE)


class NotesTests(TestCase):
    """«Nima yangilandi» — TO'LDIRILMASLIGI mumkin."""

    def test_har_qator_ALOHIDA_band(self):
        obj = release(notes="Kafel narxlari\nBildirishnomalar tuzatildi")
        self.assertEqual(
            obj.notes_lines(), ["Kafel narxlari", "Bildirishnomalar tuzatildi"]
        )

    def test_bosh_qatorlar_TASHLANADI(self):
        obj = release(notes="\n  Birinchi  \n\n\nIkkinchi\n\n")
        self.assertEqual(obj.notes_lines(), ["Birinchi", "Ikkinchi"])

    def test_BOSH_izoh__bosh_royxat(self):
        self.assertEqual(release(notes="").notes_lines(), [])


class ValidationTests(TestCase):
    """Adminda xato sozlama SAQLANMAYDI."""

    def setUp(self):
        # Qatorlar migratsiyada allaqachon yaratilgan (har ilova × platforma
        # uchun bittadan) — admin ham aynan shularni TAHRIRLAYDI, yangi
        # yaratmaydi. Tekshiruv ham shu yo'l bilan boradi.
        self.row = AppRelease.objects.get(app="master", platform="ios")

    def test_yoqilgan_qator_HAVOLASIZ_saqlanmaydi(self):
        self.row.latest_version = "1.0.0"
        self.row.store_url = ""
        self.row.is_active = True

        with self.assertRaises(ValidationError) as ctx:
            self.row.full_clean()
        self.assertIn("store_url", ctx.exception.error_dict)

    def test_min_versiya_oxirgidan_YUQORI_bolmaydi(self):
        # Bunda HAMMA foydalanuvchi qulflanib qolardi.
        self.row.latest_version = "1.0.0"
        self.row.min_version = "2.0.0"
        self.row.store_url = "https://ustachi.uz"
        self.row.is_active = True

        with self.assertRaises(ValidationError) as ctx:
            self.row.full_clean()
        self.assertIn("min_version", ctx.exception.error_dict)

    def test_notogri_shakldagi_versiya_saqlanmaydi(self):
        self.row.latest_version = "v1.0-beta"

        with self.assertRaises(ValidationError) as ctx:
            self.row.full_clean()
        self.assertIn("latest_version", ctx.exception.error_dict)

    def test_OCHIQ_qator_havolasiz_ham_saqlanadi(self):
        # Admin qatorni bugun ko'radi, havolani ertaga qo'yadi — o'chiq
        # turgan qator hech kimga ta'sir qilmaydi.
        self.row.latest_version = "1.0.0"
        self.row.store_url = ""
        self.row.is_active = False

        self.row.full_clean()  # xato bo'lmasligi kerak

    def test_migratsiya_qatorlari_OCHIQ_kelgan(self):
        # Yangi backend chiqqan zahoti hech kimga oyna chiqmasin.
        self.assertEqual(AppRelease.objects.count(), 4)
        self.assertFalse(AppRelease.objects.filter(is_active=True).exists())


class ApiTests(TestCase):
    def setUp(self):
        self.api = APIClient()

    def get(self, url=CLIENT_URL, **params):
        params.setdefault("platform", "android")
        params.setdefault("version", "1.1.0")
        return self.api.get(url, params)

    def test_AUTHSIZ_ochiladi(self):
        # Majburiy yangilanish login ekranidan OLDIN ham kerak.
        release()
        self.assertEqual(self.get().status_code, 200)

    def test_ixtiyoriy_yangilanish__havola_va_izohlar_bilan(self):
        release(notes="Kafel narxlari\nTezlik oshirildi")

        data = self.get(version="1.1.0").data

        self.assertEqual(data["status"], "optional")
        self.assertEqual(data["latest_version"], "1.2.0")
        self.assertEqual(data["current_version"], "1.1.0")
        self.assertTrue(data["store_url"])
        self.assertEqual(data["notes"], ["Kafel narxlari", "Tezlik oshirildi"])

    def test_majburiy_yangilanish(self):
        release(min_version="1.1.0")
        self.assertEqual(self.get(version="1.0.0").data["status"], "required")

    def test_yangilanish_YOQ__havola_ham_yuborilmaydi(self):
        # Ishlatilmaydigan ma'lumot ilovaga bormaydi.
        release()
        data = self.get(version="1.2.0").data

        self.assertEqual(data["status"], "up_to_date")
        self.assertEqual(data["store_url"], "")
        self.assertEqual(data["notes"], [])

    def test_IZOHSIZ_yangilanish_ham_toliq_javob(self):
        release(notes="")
        data = self.get(version="1.0.0").data

        self.assertEqual(data["status"], "optional")
        self.assertEqual(data["notes"], [])
        self.assertTrue(data["store_url"], "havola baribir kerak")

    def test_qator_YOQ__hech_narsa(self):
        AppRelease.objects.all().delete()
        data = self.get(version="0.0.1").data
        self.assertEqual(data["status"], "up_to_date")

    def test_MIJOZ_va_USTA_qatorlari_ARALASHMAYDI(self):
        release(app="client", latest_version="9.9.9")
        release(app="master", latest_version="1.0.0")

        self.assertEqual(self.get(CLIENT_URL, version="1.0.0").data["status"], "optional")
        self.assertEqual(self.get(MASTER_URL, version="1.0.0").data["status"], "up_to_date")

    def test_ANDROID_va_IOS_qatorlari_ARALASHMAYDI(self):
        release(platform="android", latest_version="9.9.9")
        release(platform="ios", latest_version="1.0.0")

        self.assertEqual(self.get(platform="android", version="1.0.0").data["status"], "optional")
        self.assertEqual(self.get(platform="ios", version="1.0.0").data["status"], "up_to_date")

    def test_notogri_platforma__400(self):
        self.assertEqual(self.get(platform="symbian").status_code, 400)

    def test_notogri_versiya__400(self):
        self.assertEqual(self.get(version="eng-yangisi").status_code, 400)

    def test_versiya_YUBORILMASA__400(self):
        self.assertEqual(self.api.get(CLIENT_URL, {"platform": "android"}).status_code, 400)
