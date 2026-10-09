"""
Akkauntni o'chirish sahifasi (HTML forma) testlari.

Asosiy talab: o'chirish FAQAT OTP tasdiqlangandan keyin sodir bo'lishi kerak.
"""

from datetime import timedelta
from unittest.mock import patch

from django.test import TestCase
from django.utils import timezone
from django.utils.html import escape

from apps.accounts.models import OTPPurpose, PhoneOTP, User

REQUEST_URL = "/account/delete/"
CONFIRM_URL = "/account/delete/confirm/"
DONE_URL = "/account/delete/done/"
PHONE = "+998901234567"


@patch("apps.accounts.web.views.send_otp_sms")  # haqiqiy SMS yuborilmaydi
class DeleteAccountPageTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(phone_number=PHONE, is_active=True)

    def _request_code(self, phone=PHONE):
        return self.client.post(REQUEST_URL, {"phone_number": phone})

    def _latest_code(self, phone=PHONE):
        return (
            PhoneOTP.objects.filter(
                phone_number=phone, purpose=OTPPurpose.DELETE_ACCOUNT
            )
            .first()
            .code
        )

    # ── Muvaffaqiyatli oqim ──────────────────────────────────────────

    def test_full_flow_deletes_account(self, mock_sms):
        response = self._request_code()
        self.assertRedirects(response, CONFIRM_URL)
        mock_sms.assert_called_once()

        response = self.client.post(
            CONFIRM_URL, {"code": self._latest_code(), "confirm": "on"}
        )
        self.assertRedirects(response, DONE_URL)
        self.assertFalse(User.objects.filter(phone_number=PHONE).exists())

    def test_page_loads(self, mock_sms):
        self.assertEqual(self.client.get(REQUEST_URL).status_code, 200)

    # ── O'chirish OTP'siz sodir bo'lmasligi kerak ────────────────────

    def test_wrong_code_does_not_delete(self, mock_sms):
        self._request_code()

        response = self.client.post(CONFIRM_URL, {"code": "000000", "confirm": "on"})
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, escape("Kod noto'g'ri yoki muddati tugagan."))
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())

    def test_expired_code_does_not_delete(self, mock_sms):
        self._request_code()
        PhoneOTP.objects.filter(phone_number=PHONE).update(
            expires_at=timezone.now() - timedelta(minutes=1)
        )

        response = self.client.post(
            CONFIRM_URL, {"code": self._latest_code(), "confirm": "on"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())

    def test_login_code_cannot_delete_account(self, mock_sms):
        """Kirish uchun yuborilgan kod o'chirish sahifasida ISHLAMASLIGI kerak."""
        self._request_code()
        # Lokal dev'da kod doim `111111` — maqsadlar farqi ko'rinishi uchun
        # kirish kodini boshqa qiymatga o'rnatamiz.
        auth_otp = PhoneOTP.generate_otp(PHONE, purpose=OTPPurpose.AUTH)
        auth_otp.code = "222222"
        auth_otp.save(update_fields=["code"])

        response = self.client.post(
            CONFIRM_URL, {"code": auth_otp.code, "confirm": "on"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())
        # Kirish kodi ishlatilmagan holida qoladi.
        auth_otp.refresh_from_db()
        self.assertFalse(auth_otp.is_used)

    def test_confirm_page_requires_session(self, mock_sms):
        """Kod so'ralmasdan to'g'ridan-to'g'ri kirib bo'lmaydi."""
        self.assertRedirects(self.client.get(CONFIRM_URL), REQUEST_URL)

    def test_confirm_checkbox_required(self, mock_sms):
        self._request_code()

        response = self.client.post(CONFIRM_URL, {"code": self._latest_code()})
        self.assertEqual(response.status_code, 200)
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())

    def test_used_code_does_not_delete(self, mock_sms):
        """Bir marta ishlatilgan kod ikkinchi marta o'tmaydi."""
        self._request_code()
        otp = PhoneOTP.objects.filter(
            phone_number=PHONE, purpose=OTPPurpose.DELETE_ACCOUNT
        ).first()
        otp.is_used = True
        otp.save(update_fields=["is_used"])

        response = self.client.post(CONFIRM_URL, {"code": otp.code, "confirm": "on"})
        self.assertEqual(response.status_code, 200)
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())

    def test_code_marked_used_after_deletion(self, mock_sms):
        self._request_code()
        code = self._latest_code()

        self.client.post(CONFIRM_URL, {"code": code, "confirm": "on"})

        self.assertFalse(User.objects.filter(phone_number=PHONE).exists())
        # O'chirish bilan birga shu raqamning kodlari ham tozalanadi.
        self.assertFalse(PhoneOTP.objects.filter(phone_number=PHONE).exists())

    # ── Ma'lumot sizib chiqmasligi va cheklovlar ─────────────────────

    def test_unknown_phone_does_not_leak_and_sends_no_sms(self, mock_sms):
        response = self._request_code("+998900000000")
        self.assertRedirects(response, CONFIRM_URL)
        mock_sms.assert_not_called()
        self.assertFalse(
            PhoneOTP.objects.filter(phone_number="+998900000000").exists()
        )

    def test_invalid_phone_format_rejected(self, mock_sms):
        response = self.client.post(REQUEST_URL, {"phone_number": "12345"})
        self.assertEqual(response.status_code, 200)
        mock_sms.assert_not_called()

    def test_rate_limited_after_three_requests(self, mock_sms):
        for _ in range(3):
            self._request_code()

        response = self._request_code()
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, escape("Juda ko'p urinish"))
        self.assertEqual(mock_sms.call_count, 3)

    def test_too_many_wrong_codes_resets_flow(self, mock_sms):
        self._request_code()

        for _ in range(5):
            self.client.post(CONFIRM_URL, {"code": "000000", "confirm": "on"})

        response = self.client.post(CONFIRM_URL, {"code": "000000", "confirm": "on"})
        self.assertContains(response, "Boshidan boshlang")
        self.assertTrue(User.objects.filter(phone_number=PHONE).exists())
        # Sessiya tozalangan — endi qaytadan kod so'rash kerak.
        self.assertRedirects(self.client.get(CONFIRM_URL), REQUEST_URL)


@patch("apps.accounts.web.views.send_otp_sms")
class DeleteAccountCascadeTests(TestCase):
    """O'chirish bog'liq ma'lumotlarni ham olib ketishini tekshiradi."""

    def test_master_profile_and_device_tokens_removed(self, mock_sms):
        from apps.accounts.models import (
            DeviceToken,
            MasterProfile,
            MasterSpecialty,
        )

        user = User.objects.create_user(
            phone_number=PHONE, is_active=True, is_master=True
        )
        # Rom yo'nalishi migratsiyada yaratilgan; barqaror kalit — `code`.
        specialty, _ = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )
        MasterProfile.objects.create(
            user=user, specialty=specialty, experience_years=3
        )
        DeviceToken.objects.create(user=user, token="fcm-token-123")

        self.client.post(REQUEST_URL, {"phone_number": PHONE})
        code = PhoneOTP.objects.filter(
            phone_number=PHONE, purpose=OTPPurpose.DELETE_ACCOUNT
        ).first().code
        self.client.post(CONFIRM_URL, {"code": code, "confirm": "on"})

        self.assertFalse(User.objects.filter(pk=user.pk).exists())
        self.assertFalse(MasterProfile.objects.filter(user_id=user.pk).exists())
        self.assertFalse(DeviceToken.objects.filter(user_id=user.pk).exists())
        # Yo'nalish katalogi o'chmaydi (PROTECT).
        self.assertTrue(MasterSpecialty.objects.filter(pk=specialty.pk).exists())
