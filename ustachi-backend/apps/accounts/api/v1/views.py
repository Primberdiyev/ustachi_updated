from datetime import timedelta

from django.utils import timezone
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.generics import RetrieveUpdateAPIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView

from apps.accounts.models import DevicePlatform, DeviceToken, OTPPurpose, PhoneOTP, User
from apps.accounts.services.sms import send_otp_sms
from apps.common import telegram

from .serializers import (
    CustomTokenRefreshSerializer,
    DeviceTokenDeleteSerializer,
    DeviceTokenSerializer,
    LoginSerializer,
    LogoutSerializer,
    SendCodeSerializer,
    UserSerializer,
    VerifyCodeSerializer,
)


OTP_RATE_LIMIT_COUNT = 3
OTP_RATE_LIMIT_WINDOW_MINUTES = 10


class SendCodeView(APIView):
    """
    Telefon raqamga OTP yuboradi — register va login uchun yagona kirish
    nuqtasi (parol yo'q). Qayta yuborish uchun ham shu endpoint ishlatiladi.
    """

    permission_classes = [AllowAny]
    serializer_class = SendCodeSerializer

    def post(self, request):
        serializer = SendCodeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data["phone_number"]

        # DEMO hisob (do'kon moderatori): tezlik cheklovi qo'llanmaydi —
        # tekshiruvchi qayta-qayta urinishi mumkin va 429 uni ilovadan
        # butunlay chiqarib yuborardi.
        is_demo = PhoneOTP.is_demo_phone(phone_number)

        if not is_demo:
            recent_count = PhoneOTP.objects.filter(
                phone_number=phone_number,
                purpose=OTPPurpose.AUTH,
                created_at__gte=timezone.now()
                - timedelta(minutes=OTP_RATE_LIMIT_WINDOW_MINUTES),
            ).count()

            if recent_count >= OTP_RATE_LIMIT_COUNT:
                return Response(
                    {"error": "Juda ko'p urinish. Iltimos, keyinroq qayta urinib ko'ring."},
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                )

        otp = PhoneOTP.generate_otp(phone_number, purpose=OTPPurpose.AUTH)

        # Demo raqam bizniki emas — SMS yuborish pul sarflaydi va baribir
        # yetib bormaydi. Kod moderatorga do'kon formasida beriladi.
        if not is_demo:
            send_otp_sms(phone_number, otp.code)

        is_new_user = not User.objects.filter(phone_number=phone_number).exists()
        return Response(
            {
                "message": "Tasdiqlash kodi yuborildi.",
                "is_new_user": is_new_user,
            }
        )


class VerifyOTPView(APIView):
    """
    OTP kodni tekshiradi. Foydalanuvchi bo'lmasa yaratadi (register), bo'lsa
    tizimga kiritadi (login) va JWT tokenlarni qaytaradi.

    `grants_master` — master namespace'ida True: yangi foydalanuvchi USTA
    bo'lib yaratiladi, mavjud foydalanuvchiga esa usta roli qo'shiladi
    (mijozligi saqlanadi).
    """

    permission_classes = [AllowAny]
    serializer_class = VerifyCodeSerializer
    grants_master = False  # namespace subclass tomonidan o'zgartiriladi

    def post(self, request):
        serializer = VerifyCodeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data["phone_number"]
        code = serializer.validated_data["code"]

        # `purpose` SHART: akkauntni o'chirish uchun kelgan kod bilan tizimga
        # kirib bo'lmasligi kerak.
        otp = PhoneOTP.objects.filter(
            phone_number=phone_number,
            code=code,
            purpose=OTPPurpose.AUTH,
            is_used=False,
        ).first()
        if not otp or not otp.is_valid():
            return Response(
                {"error": "OTP noto'g'ri yoki muddati tugagan."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp.is_used = True
        otp.save(update_fields=["is_used"])

        user = User.objects.filter(phone_number=phone_number).first()
        is_new_user = user is None

        if is_new_user:
            user = User.objects.create_user(
                phone_number=phone_number,
                password=None,
                is_active=True,
                is_master=self.grants_master,
            )
            telegram.notify_new_user(user)
        else:
            updated = []
            if not user.is_active:
                user.is_active = True
                updated.append("is_active")
            if self.grants_master and not user.is_master:
                user.is_master = True  # usta roli QO'SHILADI (mijozlik saqlanadi)
                updated.append("is_master")
            if updated:
                user.save(update_fields=updated)

        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "message": "Telefon raqami tasdiqlandi.",
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "roles": user.roles,
                "is_master": user.is_master,
                "is_admin": user.is_superuser,
                "is_new_user": is_new_user,
            },
            status=status.HTTP_201_CREATED if is_new_user else status.HTTP_200_OK,
        )


class LoginView(APIView):
    """
    Username va parol bilan kirish — faqat admin namespace'ida
    ishlatiladi (client/master parolsiz, faqat OTP orqali kiradi).

    Identifikator sifatida `username` olinadi: admin `createsuperuser`
    orqali yaratiladi va o'sha buyruq aynan username so'raydi. Telefon
    raqam esa `User` da null bo'lishi mumkin — u OTP oqimi uchun, admin
    kirishi unga bog'lanmagan.
    """

    permission_classes = [AllowAny]
    serializer_class = LoginSerializer
    require_admin = True

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data["username"]
        password = serializer.validated_data["password"]

        user = User.objects.filter(username=username).first()
        # Xato matni "qaysi biri noto'g'ri" ekanini AYTMAYDI — mavjud
        # username'larni tanlab olishga yo'l qo'ymaslik uchun.
        if not user or not user.check_password(password):
            return Response(
                {"error": "Username yoki parol noto'g'ri."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        if not user.is_active:
            return Response(
                {"error": "Hisob faollashtirilmagan."},
                status=status.HTTP_403_FORBIDDEN,
            )

        if self.require_admin and not user.is_superuser:
            return Response(
                {"error": "Bu endpoint orqali kirishga ruxsat yo'q."},
                status=status.HTTP_403_FORBIDDEN,
            )

        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "roles": user.roles,
                "is_master": user.is_master,
                "is_admin": user.is_superuser,
            }
        )


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = LogoutSerializer

    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            token = RefreshToken(serializer.validated_data["refresh"])
            token.blacklist()
        except TokenError:
            return Response(
                {"error": "Token noto'g'ri yoki muddati tugagan."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response({"message": "Tizimdan muvaffaqiyatli chiqildi."}, status=status.HTTP_205_RESET_CONTENT)


class CustomTokenRefreshView(TokenRefreshView):
    """
    Refresh token o'chirilgan foydalanuvchiga yoki eskirgan token'ga duch kelganda
    500 error o'rniga toza 401 qaytaradi.
    """

    serializer_class = CustomTokenRefreshSerializer


class DeviceRegisterView(APIView):
    """
    FCM tokenini ro'yxatdan o'tkazadi (login'dan keyin va token yangilanganda).

    IDEMPOTENT: ayni token qayta yuborilsa yangi yozuv ochilmaydi, mavjudi
    yangilanadi. Token boshqa akkauntda qolgan bo'lsa (bir telefondan ikki
    kishi kirgan) — EGASI ALMASHADI, aks holda push eski egasiga ketardi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = DeviceTokenSerializer
    # URL prefix determines which app owns this token; never trust request data.
    app = ""

    def post(self, request):
        serializer = DeviceTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        device, _ = DeviceToken.objects.update_or_create(
            token=data["token"],
            defaults={
                "user": request.user,
                "platform": data.get("platform") or DevicePlatform.ANDROID,
                "device_name": data.get("device_name", ""),
                "app": self.app,
                "is_active": True,
                "last_seen_at": timezone.now(),
            },
        )
        return Response(
            DeviceTokenSerializer(device).data, status=status.HTTP_201_CREATED
        )


class DeviceDeleteView(APIView):
    """
    Tokenni o'chiradi — ilova CHIQISHDA (logout) chaqiradi, aks holda telefon
    egasi almashgach ham eski akkauntning push'lari kelaverardi.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = DeviceTokenDeleteSerializer

    def post(self, request):
        serializer = DeviceTokenDeleteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        deleted, _ = DeviceToken.objects.filter(
            user=request.user, token=serializer.validated_data["token"]
        ).delete()
        return Response({"deleted": deleted})


class MeView(RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    http_method_names = ["get", "patch", "head", "options"]

    def get_object(self):
        return self.request.user
