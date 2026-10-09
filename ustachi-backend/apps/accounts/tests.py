"""
ROL MODELI testlari (2026-07-22 dan):
  * client — HAMMA foydalanuvchi mijoz.
  * master — `is_master=True`, mijozlikni YO'QOTMAYDI.
  * admin  — `is_superuser=True`.

Client/master parolsiz — faqat telefon + OTP orqali kiradi (send-code →
verify-code). Admin esa parol bilan kiradi (`login/`).

Asosiy talab: client bo'lib ro'yxatdan o'tgan odam MASTER bo'lib ham
ro'yxatdan o'ta olishi kerak (bitta telefon, bitta akkaunt, ikkala rol).
"""

from unittest.mock import patch

from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import MasterProfile, PhoneOTP, User

CLIENT = "/api/v1/client/auth/"
MASTER = "/api/v1/master/auth/"
ADMIN = "/api/v1/admin/auth/"
ADMIN_PASSWORD = "parol123"


@patch("apps.accounts.api.v1.views.send_otp_sms")  # haqiqiy SMS yuborilmaydi
class RoleFlowTests(TestCase):
    def setUp(self):
        self.api = APIClient()

    # ───────── yordamchilar ─────────
    def _otp(self, phone):
        return (
            PhoneOTP.objects.filter(phone_number=phone, is_used=False)
            .latest("created_at")
            .code
        )

    def _send_code(self, base, phone):
        return self.api.post(base + "send-code/", {"phone_number": phone})

    def _verify(self, base, phone):
        return self.api.post(
            base + "verify-code/", {"phone_number": phone, "code": self._otp(phone)}
        )

    def _login(self, base, phone):
        """send-code + verify-code — client/master uchun yagona kirish oqimi."""
        self._send_code(base, phone)
        return self._verify(base, phone)

    def _make_client(self, phone):
        self._login(CLIENT, phone)

    def _make_master(self, phone):
        self._login(MASTER, phone)

    # ───────── ASOSIY TALAB ─────────
    def test_client_can_also_become_master(self, _sms):
        phone = "+998901234501"

        # 1) Client sifatida OTP orqali ro'yxatdan o'tadi.
        self._send_code(CLIENT, phone)
        resp = self._verify(CLIENT, phone)
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertTrue(resp.data["is_new_user"])
        user = User.objects.get(phone_number=phone)
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_master)
        self.assertEqual(user.roles, ["client"])

        # 2) AYNAN shu telefon bilan master oqimiga kiradi — bloklanmaydi.
        send_resp = self._send_code(MASTER, phone)
        self.assertEqual(send_resp.status_code, 200, send_resp.data)
        self.assertFalse(send_resp.data["is_new_user"])

        # 3) OTP tasdiqlangач USTA roli QO'SHILADI, mijozlik saqlanadi.
        verify_resp = self._verify(MASTER, phone)
        self.assertEqual(verify_resp.status_code, 200, verify_resp.data)
        self.assertFalse(verify_resp.data["is_new_user"])
        user.refresh_from_db()
        self.assertTrue(user.is_master)
        self.assertEqual(user.roles, ["client", "master"])

        # 4) Bitta akkaunt — dublikat foydalanuvchi yaratilmadi.
        self.assertEqual(User.objects.filter(phone_number=phone).count(), 1)

    def test_dual_role_can_login_to_both_namespaces(self, _sms):
        phone = "+998901234502"
        self._make_client(phone)
        self._make_master(phone)

        # send-code 10 daqiqada 3 tagacha ruxsat beradi — yuqoridagi ikkita
        # to'liq oqim (har biri 1 tadan send-code) dan keyin faqat bitta
        # marta yana so'rash mumkin, shuning uchun bitta namespace'da tekshiramiz.
        resp = self._login(CLIENT, phone)
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data["roles"], ["client", "master"])
        self.assertTrue(resp.data["is_master"])

    # ───────── rol chegaralari ─────────
    def test_client_otp_never_grants_master_role(self, _sms):
        phone = "+998901234503"
        for expected_status in (201, 200):
            with self.subTest(expected_status=expected_status):
                self._send_code(CLIENT, phone)
                resp = self.api.post(
                    CLIENT + "verify-code/",
                    {
                        "phone_number": phone,
                        "code": self._otp(phone),
                        "is_master": True,
                        "roles": ["master"],
                    },
                    format="json",
                )
                self.assertEqual(resp.status_code, expected_status, resp.data)
                self.assertFalse(resp.data["is_master"])
                self.assertEqual(resp.data["roles"], ["client"])
                self.assertFalse(User.objects.get(phone_number=phone).is_master)

    def test_master_is_also_a_client(self, _sms):
        """Usta ham mijoz — client namespace'iga kira oladi."""
        phone = "+998901234505"
        self._make_master(phone)
        resp = self._login(CLIENT, phone)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data["roles"], ["client", "master"])

    def test_admin_login_requires_superuser(self, _sms):
        """Admin login IDENTIFIKATORI — `username` (telefon EMAS).

        Telefon OTP oqimiga tegishli va `User` da null bo'lishi mumkin;
        admin esa `createsuperuser` bilan yaratiladi va u username beradi.
        """
        phone = "+998901234507"
        self._make_client(phone)
        user = User.objects.get(phone_number=phone)
        user.set_password(ADMIN_PASSWORD)
        user.save(update_fields=["password"])

        credentials = {"username": user.username, "password": ADMIN_PASSWORD}

        resp = self.api.post(ADMIN + "login/", credentials)
        self.assertEqual(resp.status_code, 403)

        user.is_superuser = True
        user.save(update_fields=["is_superuser"])
        resp = self.api.post(ADMIN + "login/", credentials)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data["roles"], ["client", "admin"])

    def test_me_returns_roles(self, _sms):
        phone = "+998901234508"
        self._make_client(phone)
        login = self._login(CLIENT, phone)
        self.api.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")
        resp = self.api.get(CLIENT + "me/")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data["roles"], ["client"])
        self.assertFalse(resp.data["is_master"])

    def test_send_code_rate_limited(self, _sms):
        phone = "+998901234509"
        for _ in range(3):
            self.assertEqual(self._send_code(CLIENT, phone).status_code, 200)
        resp = self._send_code(CLIENT, phone)
        self.assertEqual(resp.status_code, 429)

    def test_verify_code_wrong_code_fails(self, _sms):
        phone = "+998901234510"
        self._send_code(CLIENT, phone)
        resp = self.api.post(
            CLIENT + "verify-code/", {"phone_number": phone, "code": "000000"}
        )
        self.assertEqual(resp.status_code, 400)


@patch("apps.accounts.api.v1.views.send_otp_sms")
class AddressTests(TestCase):
    """Manzil: viloyat + tuman (kaskad) va matnli manzil — /me/ orqali to'ldiriladi."""

    def setUp(self):
        from apps.locations.models import City, Region

        self.api = APIClient()
        self.region = Region.objects.create(name="Toshkent shahri")
        self.other_region = Region.objects.create(name="Andijon viloyati")
        self.district = City.objects.create(name="Chilonzor tumani", region=self.region)
        self.foreign_district = City.objects.create(
            name="Asaka tumani", region=self.other_region
        )

    def _otp(self, phone):
        return (
            PhoneOTP.objects.filter(phone_number=phone, is_used=False)
            .latest("created_at")
            .code
        )

    def _login(self, phone):
        self.api.post(CLIENT + "send-code/", {"phone_number": phone})
        resp = self.api.post(
            CLIENT + "verify-code/", {"phone_number": phone, "code": self._otp(phone)}
        )
        self.api.credentials(HTTP_AUTHORIZATION=f"Bearer {resp.data['access']}")
        return resp

    def test_me_patch_updates_address(self, _sms):
        phone = "+998901234603"
        self._login(phone)

        resp = self.api.patch(
            CLIENT + "me/",
            {
                "region": self.region.id,
                "district": self.district.id,
                "address": "Yangi manzil 5",
            },
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data["region_name"], "Toshkent shahri")
        self.assertEqual(resp.data["district_name"], "Chilonzor tumani")
        self.assertEqual(resp.data["address"], "Yangi manzil 5")

    def test_me_patch_district_must_belong_to_region(self, _sms):
        phone = "+998901234604"
        self._login(phone)

        resp = self.api.patch(
            CLIENT + "me/",
            {
                "region": self.region.id,
                "district": self.foreign_district.id,  # boshqa viloyatniki
            },
        )
        self.assertEqual(resp.status_code, 400)
        self.assertIn("district", resp.data)


@patch("apps.accounts.api.v1.views.send_otp_sms")
class MasterProfileTests(TestCase):
    """Usta profili: yo'nalish + tajriba MAJBURIY, izoh/namuna IXTIYORIY."""

    def setUp(self):
        from apps.accounts.models import MasterSpecialty

        self.api = APIClient()
        self.specialty = MasterSpecialty.objects.get(code="rom")
        self.phone = "+998901234701"

    def _auth(self):
        self.api.post(CLIENT + "send-code/", {"phone_number": self.phone})
        code = (
            PhoneOTP.objects.filter(phone_number=self.phone, is_used=False)
            .latest("created_at")
            .code
        )
        login = self.api.post(
            CLIENT + "verify-code/", {"phone_number": self.phone, "code": code}
        )
        self.api.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")

    def test_specialties_list_has_rom_ustasi(self, _sms):
        resp = self.api.get(MASTER + "specialties/")
        self.assertEqual(resp.status_code, 200)
        self.assertIn(self.specialty.name, [s["name"] for s in resp.data])

    # ── KO'P YO'NALISH (foydalanuvchi qarori 2026-08-13) ──────────────
    #
    # Usta bir nechta soha tanlay oladi. Kontrakt IKKI KO'RINISHDA
    # ishlashi shart: chiqib bo'lgan ilova bitta `specialty` int yuboradi,
    # yangisi `specialties` ro'yxatini. Buyurtma ko'rinishi (feed, push)
    # M2M bo'yicha hisoblanadi — shuning uchun asosiy yo'nalish DOIM
    # ro'yxat ichida bo'lishi kerak.

    def test_katalog_kodlar_bilan_keladi(self, _sms):
        resp = self.api.get(MASTER + "specialties/")
        codes = {s["code"] for s in resp.data}
        self.assertIn("rom", codes)
        self.assertIn("tom", codes)

    def test_ESKI_ilova_bitta_yo_nalish_yuboradi(self, _sms):
        self._auth()
        resp = self.api.post(
            MASTER + "profile/",
            {"specialty": self.specialty.pk, "experience_years": 5},
        )
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(resp.data["specialty"], self.specialty.pk)
        # Asosiy yo'nalish ro'yxatga ham tushdi (aks holda usta o'z
        # sohasidagi e'lonni feed'da ko'rmay qolardi).
        self.assertEqual(
            [s["code"] for s in resp.data["specialty_list"]], ["rom"]
        )

    def test_YANGI_ilova_ro_yxat_yuboradi(self, _sms):
        from apps.accounts.models import MasterSpecialty

        tom = MasterSpecialty.objects.get(code="tom")
        gisht = MasterSpecialty.objects.get(code="gisht")
        self._auth()
        resp = self.api.post(
            MASTER + "profile/",
            {"specialties": [tom.pk, gisht.pk], "experience_years": 5},
            format="json",
        )
        self.assertEqual(resp.status_code, 201, resp.data)
        # Asosiy yo'nalish — birinchisi.
        self.assertEqual(resp.data["specialty"], tom.pk)
        self.assertEqual(
            sorted(s["code"] for s in resp.data["specialty_list"]),
            ["gisht", "tom"],
        )

    def test_ESKI_ilova_saqlashi_ko_p_yo_nalishni_O_CHIRMAYDI(self, _sms):
        """Eng xavfli holat: usta yangi ilovada 3 soha tanlab, keyin eski
        ilovadan profilini saqlasa — tanlovi yo'qolmasin."""
        from apps.accounts.models import MasterSpecialty

        tom = MasterSpecialty.objects.get(code="tom")
        gisht = MasterSpecialty.objects.get(code="gisht")
        self._auth()
        self.api.post(
            MASTER + "profile/",
            {"specialties": [tom.pk, gisht.pk], "experience_years": 5},
            format="json",
        )
        resp = self.api.patch(
            MASTER + "profile/", {"experience_years": 7}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(
            sorted(s["code"] for s in resp.data["specialty_list"]),
            ["gisht", "tom"],
        )

    def test_yo_nalishni_ALMASHTIRISH_eskisini_olib_tashlaydi(self, _sms):
        from apps.accounts.models import MasterSpecialty

        tom = MasterSpecialty.objects.get(code="tom")
        self._auth()
        self.api.post(
            MASTER + "profile/",
            {"specialty": self.specialty.pk, "experience_years": 5},
        )
        resp = self.api.patch(
            MASTER + "profile/", {"specialties": [tom.pk]}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        # Asosiy yo'nalish ham yangisiga o'tdi — aks holda model `save()`
        # eski sohani ro'yxatga qaytarib tiqib qo'yardi.
        self.assertEqual(resp.data["specialty"], tom.pk)
        self.assertEqual(
            [s["code"] for s in resp.data["specialty_list"]], ["tom"]
        )

    def test_yo_nalishsiz_profil_YARATIB_bo_lmaydi(self, _sms):
        self._auth()
        resp = self.api.post(MASTER + "profile/", {"experience_years": 5})
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_profile_creation_requires_specialty_for_post_and_patch(self, _sms):
        self._auth()
        for method in (self.api.post, self.api.patch):
            for selection in ({}, {"specialties": []}, {"specialty": None}):
                with self.subTest(method=method.__name__, selection=selection):
                    resp = method(
                        MASTER + "profile/",
                        {"experience_years": 0, **selection},
                        format="json",
                    )
                    self.assertEqual(resp.status_code, 400, resp.data)
                    user = User.objects.get(phone_number=self.phone)
                    self.assertFalse(MasterProfile.objects.filter(user=user).exists())
                    self.assertFalse(user.is_master)

    def test_last_specialty_cannot_be_removed(self, _sms):
        self._auth()
        user = User.objects.get(phone_number=self.phone)
        profile = MasterProfile.objects.create(
            user=user, specialty=self.specialty, experience_years=3,
        )
        for method in (self.api.post, self.api.patch):
            for selection in ({"specialties": []}, {"specialty": None}):
                with self.subTest(method=method.__name__, selection=selection):
                    resp = method(
                        MASTER + "profile/",
                        {"experience_years": 4, **selection},
                        format="json",
                    )
                    self.assertEqual(resp.status_code, 400, resp.data)
                    profile.refresh_from_db()
                    self.assertEqual(profile.specialty_id, self.specialty.pk)
                    self.assertEqual(profile.experience_years, 3)
                    self.assertEqual(
                        list(profile.specialties.values_list("pk", flat=True)),
                        [self.specialty.pk],
                    )

    def test_create_profile_grants_master_role(self, _sms):
        self._auth()
        self.assertFalse(User.objects.get(phone_number=self.phone).is_master)

        resp = self.api.post(
            MASTER + "profile/",
            {"specialty": self.specialty.id, "experience_years": 5},
        )
        self.assertEqual(resp.status_code, 201, resp.data)
        self.assertEqual(resp.data["specialty_name"], self.specialty.name)
        self.assertEqual(resp.data["experience_years"], 5)
        self.assertEqual(resp.data["bio"], "")  # ixtiyoriy — bo'sh
        self.assertFalse(resp.data["is_verified"])

        user = User.objects.get(phone_number=self.phone)
        self.assertTrue(user.is_master)  # usta roli AVTOMATIK berildi
        self.assertEqual(user.roles, ["client", "master"])

    def test_specialty_and_experience_are_required(self, _sms):
        self._auth()
        resp = self.api.post(MASTER + "profile/", {"bio": "faqat izoh"})
        self.assertEqual(resp.status_code, 400)
        self.assertIn("experience_years", resp.data)
        # Yo'nalish endi IKKI ko'rinishda kelishi mumkin (`specialty` yoki
        # `specialties`), shuning uchun uning tekshiruvi maydon darajasida
        # emas — tajriba yili to'ldirilgach chiqadi:
        resp = self.api.post(MASTER + "profile/", {"experience_years": 5})
        self.assertEqual(resp.status_code, 400)
        self.assertIn("specialty", resp.data)

    def test_bio_can_be_added_later_via_patch(self, _sms):
        self._auth()
        self.api.post(
            MASTER + "profile/",
            {"specialty": self.specialty.id, "experience_years": 3},
        )
        resp = self.api.patch(MASTER + "profile/", {"bio": "10 yildan beri rom ustasiman"})
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data["bio"], "10 yildan beri rom ustasiman")
        self.assertEqual(resp.data["experience_years"], 3)  # o'zgarmadi

    def test_profile_404_before_created(self, _sms):
        self._auth()
        self.assertEqual(self.api.get(MASTER + "profile/").status_code, 404)

    def test_work_sample_requires_profile(self, _sms):
        self._auth()
        resp = self.api.post(MASTER + "profile/work-samples/", {"caption": "ish"})
        self.assertEqual(resp.status_code, 400)

@patch("apps.accounts.api.v1.views.send_otp_sms")
class MasterProfileSettingsTests(TestCase):
    """Usta profilidagi sozlamalar: bandlik va korxona ma'lumoti."""

    def setUp(self):
        from apps.accounts.models import MasterSpecialty

        self.api = APIClient()
        self.specialty = MasterSpecialty.objects.get(code="rom")
        self.phone = "+998901234801"

    def _auth(self):
        self.api.post(CLIENT + "send-code/", {"phone_number": self.phone})
        code = (
            PhoneOTP.objects.filter(phone_number=self.phone, is_used=False)
            .latest("created_at")
            .code
        )
        login = self.api.post(
            CLIENT + "verify-code/", {"phone_number": self.phone, "code": code}
        )
        self.api.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")

    def _profile(self):
        """Auth + to'liq profil (PATCH'lar uchun shart)."""
        self._auth()
        return self.api.post(
            MASTER + "profile/",
            {"specialty": self.specialty.pk, "experience_years": 5},
        )

    def test_accepts_orders_is_writable(self, _sms):
        """
        REGRESSIYA: `accepts_orders` `read_only_fields` da turgani uchun
        ilovadagi "Buyurtma qabul qilaman" tugmachasi serverga HECH QACHON
        saqlanmagan — xato jimgina yutilardi.
        """
        self._profile()
        resp = self.api.patch(
            MASTER + "profile/", {"accepts_orders": False}, format="json"
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertFalse(resp.data["accepts_orders"])

        profile = MasterProfile.objects.get(user__phone_number=self.phone)
        self.assertFalse(profile.accepts_orders, "serverda ham saqlanishi kerak")

    def test_company_name_is_saved(self, _sms):
        """Korxona nomi — "Korxona" bo'limidagi asosiy maydon."""
        self._profile()
        resp = self.api.patch(
            MASTER + "profile/",
            {"company_name": "Ustachi Servis"},
            format="json",
        )
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(resp.data["company_name"], "Ustachi Servis")

        # Boshqa maydonlar tegilmaydi.
        self.assertEqual(resp.data["experience_years"], 5)

    def test_company_defaults_to_empty(self, _sms):
        resp = self._profile()
        self.assertEqual(resp.data["company_name"], "")
        self.assertIsNone(resp.data["company_logo"])


@patch("apps.accounts.api.v1.views.send_otp_sms")
class DemoAccountTests(TestCase):
    """
    DO'KON MODERATORI uchun demo hisob (Google Play / App Store).

    Moderator ilovani ochib ko'rishi kerak, lekin unga real SMS bora
    olmaydi. Shu sabab BITTA ajratilgan raqamga kod DOIM bir xil bo'ladi.

    ⚠️ Faqat shu raqam: boshqa raqam demo kod bilan KIRMASLIGI shart.
    """

    DEMO = "+998917777777"
    DEMO_CODE = "777777"

    def setUp(self):
        self.api = APIClient()

    def _send(self, phone):
        return self.api.post(CLIENT + "send-code/", {"phone_number": phone})

    def _verify(self, base, phone, code):
        return self.api.post(
            base + "verify-code/", {"phone_number": phone, "code": code}
        )

    def test_demo_code_is_fixed(self, _sms):
        self._send(self.DEMO)
        otp = PhoneOTP.objects.filter(phone_number=self.DEMO).latest("created_at")
        self.assertEqual(otp.code, self.DEMO_CODE)

    def test_no_sms_is_sent_to_demo(self, sms):
        """Raqam bizniki emas — SMS pul sarflaydi va baribir yetmaydi."""
        self._send(self.DEMO)
        sms.assert_not_called()

    def test_sms_is_still_sent_to_real_numbers(self, sms):
        self._send("+998901112255")
        sms.assert_called_once()

    def test_mijoz_ilovasida_kiradi(self, _sms):
        self._send(self.DEMO)
        resp = self._verify(CLIENT, self.DEMO, self.DEMO_CODE)

        self.assertIn(resp.status_code, (200, 201), resp.data)
        self.assertIn("access", resp.data)

    def test_usta_ilovasida_ham_kiradi(self, _sms):
        """Ikkala ilova bitta backendga uradi — demo ikkalasida ishlashi kerak."""
        self._send(self.DEMO)
        resp = self._verify(MASTER, self.DEMO, self.DEMO_CODE)

        self.assertIn(resp.status_code, (200, 201), resp.data)
        self.assertTrue(resp.data["is_master"])

    def test_kod_qayta_qayta_ishlaydi(self, _sms):
        """Moderator bir necha marta kirib-chiqishi mumkin."""
        for _ in range(3):
            self._send(self.DEMO)
            resp = self._verify(CLIENT, self.DEMO, self.DEMO_CODE)
            self.assertIn(resp.status_code, (200, 201), resp.data)

    def test_tezlik_cheklovi_demo_raqamga_qollanmaydi(self, _sms):
        """429 moderatorni ilovadan butunlay chiqarib yuborardi."""
        for _ in range(10):
            resp = self._send(self.DEMO)
            self.assertEqual(resp.status_code, 200, resp.data)

    def test_tezlik_cheklovi_ODDIY_raqamda_ishlayveradi(self, _sms):
        """Regressiya: demo istisnosi cheklovni butunlay o'chirib qo'ymasin."""
        statuses = {self._send("+998901112266").status_code for _ in range(12)}
        self.assertIn(429, statuses)

    def test_BOSHQA_raqam_demo_kod_bilan_KIRMAYDI(self, _sms):
        """Eng muhim qulf: demo kod umumiy parolga aylanib qolmasin."""
        other = "+998901112277"
        self._send(other)
        PhoneOTP.objects.filter(phone_number=other).update(code="123456")

        resp = self._verify(CLIENT, other, self.DEMO_CODE)
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_bosh_joyli_yozilishi_ham_tanilaydi(self, _sms):
        """`+998 91 777 77 77` va `+998917777777` — bitta raqam."""
        self.assertTrue(PhoneOTP.is_demo_phone("+998 91 777 77 77"))
        self.assertTrue(PhoneOTP.is_demo_phone("998917777777"))
        self.assertFalse(PhoneOTP.is_demo_phone("+998901112233"))

    # ── MIJOZ demo hisobi (alohida raqam, alohida kod) ──────────────────

    CLIENT_DEMO = "+998918888888"
    CLIENT_DEMO_CODE = "888888"

    def test_mijoz_demo_kodi_ham_qotirilgan_va_SMSsiz(self, sms):
        self._send(self.CLIENT_DEMO)
        otp = PhoneOTP.objects.filter(
            phone_number=self.CLIENT_DEMO
        ).latest("created_at")
        self.assertEqual(otp.code, self.CLIENT_DEMO_CODE)
        sms.assert_not_called()

    def test_mijoz_demo_MIJOZ_ilovasida_kiradi(self, _sms):
        self._send(self.CLIENT_DEMO)
        resp = self._verify(CLIENT, self.CLIENT_DEMO, self.CLIENT_DEMO_CODE)

        self.assertIn(resp.status_code, (200, 201), resp.data)
        self.assertIn("access", resp.data)

    def test_ikkala_demo_ALOHIDA_hisob(self, _sms):
        """Usta demosi va mijoz demosi bitta userga tushib qolmasin."""
        self._send(self.DEMO)
        self._verify(MASTER, self.DEMO, self.DEMO_CODE)
        self._send(self.CLIENT_DEMO)
        self._verify(CLIENT, self.CLIENT_DEMO, self.CLIENT_DEMO_CODE)

        self.assertEqual(
            User.objects.filter(
                phone_number__in=[self.DEMO, self.CLIENT_DEMO]
            ).count(),
            2,
        )

    def test_kodlar_ALMASHMAYDI(self, _sms):
        """Usta kodi mijoz raqamiga (va aksincha) ishlamasligi shart."""
        self._send(self.CLIENT_DEMO)
        resp = self._verify(CLIENT, self.CLIENT_DEMO, self.DEMO_CODE)
        self.assertEqual(resp.status_code, 400, resp.data)

        self._send(self.DEMO)
        resp = self._verify(CLIENT, self.DEMO, self.CLIENT_DEMO_CODE)
        self.assertEqual(resp.status_code, 400, resp.data)

    def test_mijoz_demo_tezlik_cheklovisiz(self, _sms):
        for _ in range(10):
            resp = self._send(self.CLIENT_DEMO)
            self.assertEqual(resp.status_code, 200, resp.data)


class TokenRefreshTests(TestCase):
    def setUp(self):
        self.api = APIClient()

    def test_active_user_token_refresh(self):
        from rest_framework_simplejwt.tokens import RefreshToken

        user = User.objects.create_user(
            phone_number="+998901119999", password="pass", is_active=True
        )
        refresh = str(RefreshToken.for_user(user))
        resp = self.api.post(MASTER + "token/refresh/", {"refresh": refresh})
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertIn("access", resp.data)
        self.assertIn("refresh", resp.data)

    def test_deleted_user_token_refresh_returns_401(self):
        from rest_framework_simplejwt.tokens import RefreshToken

        user = User.objects.create_user(
            phone_number="+998901118888", password="pass", is_active=True
        )
        refresh = str(RefreshToken.for_user(user))
        user.delete()
        resp = self.api.post(MASTER + "token/refresh/", {"refresh": refresh})
        self.assertEqual(resp.status_code, 401, resp.data)
        self.assertEqual(resp.data.get("code"), "token_not_valid")

    def test_inactive_user_token_refresh_returns_401(self):
        from rest_framework_simplejwt.tokens import RefreshToken

        user = User.objects.create_user(
            phone_number="+998901117777", password="pass", is_active=False
        )
        refresh = str(RefreshToken.for_user(user))
        resp = self.api.post(MASTER + "token/refresh/", {"refresh": refresh})
        self.assertEqual(resp.status_code, 401, resp.data)

    def test_invalid_token_refresh_returns_401(self):
        resp = self.api.post(
            MASTER + "token/refresh/", {"refresh": "invalid_token_string"}
        )
        self.assertEqual(resp.status_code, 401, resp.data)
