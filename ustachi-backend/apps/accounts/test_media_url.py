"""
MEDIA MANZILI — API'dan chiqadigan rasm yo'llari TO'LIQ bo'lishi shart.

Foydalanuvchi shikoyati (2026-08-03): profil rasmi `"/media/users/photos/
image_picker_....jpg"` bo'lib kelgan va ilovada KO'RINMAGAN — mobil klient
"host" degan tushunchani bilmaydi, `Image.network` nisbiy yo'lni ocholmaydi.
"""

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient

from apps.accounts.api.v1.serializers import UserSerializer
from apps.accounts.models import User
from apps.common.media import absolute_media_url, absolute_url

# 1×1 shaffof GIF — haqiqiy rasm bayti (ImageField validatsiyadan o'tsin).
_GIF = (
    b"GIF89a\x01\x00\x01\x00\x80\x00\x00\x00\x00\x00\xff\xff\xff!"
    b"\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00"
    b"\x00\x02\x02D\x01\x00;"
)


class AbsoluteUrlHelperTests(TestCase):
    def test_nisbiy_yol_toliq_boladi(self):
        with self.settings(PUBLIC_BASE_URL="https://usta-top.simpl.uz"):
            self.assertEqual(
                absolute_url("/media/users/photos/a.jpg"),
                "https://usta-top.simpl.uz/media/users/photos/a.jpg",
            )

    def test_toliq_url_ozgarmaydi(self):
        url = "https://cdn.example.com/a.jpg"
        self.assertEqual(absolute_url(url), url)

    def test_bosh_qiymat_None(self):
        self.assertIsNone(absolute_url(None))
        self.assertIsNone(absolute_url(""))
        self.assertIsNone(absolute_media_url(None))

    def test_base_sozlanmagan_bolsa_nisbiy_qoladi(self):
        # Xato emas: eng yaxshi mumkin bo'lgan javob.
        with self.settings(PUBLIC_BASE_URL=""):
            self.assertEqual(absolute_url("/media/a.jpg"), "/media/a.jpg")


class UserPhotoApiTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone_number="+998900000100", full_name="Aziz", is_active=True
        )
        self.user.photo = SimpleUploadedFile("a.gif", _GIF, content_type="image/gif")
        self.user.save(update_fields=["photo"])

        self.api = APIClient()
        self.api.force_authenticate(self.user)

    def test_me_javobida_rasm_TOLIQ_url(self):
        response = self.api.get(reverse("client_auth:me"))
        self.assertEqual(response.status_code, 200)
        photo = response.data["photo"]
        self.assertTrue(
            photo.startswith("http://") or photo.startswith("https://"),
            msg=f"nisbiy yo'l qaytdi: {photo}",
        )

    def test_kontekstsiz_serializer_ham_TOLIQ_url_beradi(self):
        # `request` yo'q joylarda (WS hodisasi, ichki chaqiruv) ham rasm
        # ko'rinishi kerak — PUBLIC_BASE_URL shu uchun.
        with self.settings(PUBLIC_BASE_URL="https://usta-top.simpl.uz"):
            data = UserSerializer(self.user).data
        self.assertTrue(data["photo"].startswith("https://usta-top.simpl.uz/media/"))

    def test_rasmsiz_foydalanuvchida_None(self):
        other = User.objects.create_user(
            phone_number="+998900000101", is_active=True
        )
        self.assertIsNone(UserSerializer(other).data["photo"])
