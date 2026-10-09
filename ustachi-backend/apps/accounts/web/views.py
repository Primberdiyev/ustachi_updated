"""
Akkauntni o'chirish sahifasi — ilovaga kirmasdan, brauzer orqali.

Oqim: telefon raqam → SMS kod → tasdiqlash → o'chirish.
O'chirish FAQAT kod tekshirilgandan keyin bajariladi; kodsiz hech qanday
ma'lumot o'chmaydi.

Raqam bazada bor-yo'qligi 1-qadamda OSHKOR QILINMAYDI: begona odam bu
sahifa orqali kimning akkaunti borligini bilib ololmaydi. Farq faqat SMS
haqiqatan yuborilishida.
"""

from datetime import timedelta

from django.shortcuts import redirect, render
from django.utils import timezone
from django.views.decorators.http import require_http_methods

from apps.accounts.forms import DeleteAccountCodeForm, DeleteAccountPhoneForm
from apps.accounts.models import OTPPurpose, PhoneOTP, User
from apps.accounts.services.account_deletion import delete_user_account
from apps.accounts.services.sms import send_otp_sms

#: Kod so'rash chegarasi — API'dagi bilan bir xil (10 daqiqada 3 marta).
OTP_RATE_LIMIT_COUNT = 3
OTP_RATE_LIMIT_WINDOW_MINUTES = 10

#: Bitta kod uchun necha marta xato kiritish mumkin (brute-force'ga qarshi).
MAX_CODE_ATTEMPTS = 5

SESSION_PHONE_KEY = "delete_account_phone"
SESSION_ATTEMPTS_KEY = "delete_account_attempts"

GENERIC_CODE_ERROR = "Kod noto'g'ri yoki muddati tugagan."


@require_http_methods(["GET", "POST"])
def delete_account_request(request):
    """1-qadam: telefon raqam → SMS kod."""
    if request.method == "GET":
        return render(
            request,
            "accounts/delete_account_request.html",
            {"form": DeleteAccountPhoneForm()},
        )

    form = DeleteAccountPhoneForm(request.POST)
    if not form.is_valid():
        return render(
            request, "accounts/delete_account_request.html", {"form": form}
        )

    phone_number = form.cleaned_data["phone_number"]

    recent_count = PhoneOTP.objects.filter(
        phone_number=phone_number,
        purpose=OTPPurpose.DELETE_ACCOUNT,
        created_at__gte=timezone.now()
        - timedelta(minutes=OTP_RATE_LIMIT_WINDOW_MINUTES),
    ).count()
    if recent_count >= OTP_RATE_LIMIT_COUNT:
        form.add_error(
            None, "Juda ko'p urinish. Iltimos, 10 daqiqadan keyin qayta urinib ko'ring."
        )
        return render(
            request, "accounts/delete_account_request.html", {"form": form}
        )

    # SMS faqat akkaunt mavjud bo'lsa ketadi, lekin javob har doim bir xil.
    if User.objects.filter(phone_number=phone_number).exists():
        otp = PhoneOTP.generate_otp(phone_number, purpose=OTPPurpose.DELETE_ACCOUNT)
        send_otp_sms(phone_number, otp.code)

    request.session[SESSION_PHONE_KEY] = phone_number
    request.session[SESSION_ATTEMPTS_KEY] = 0
    return redirect("accounts_web:delete-account-confirm")


@require_http_methods(["GET", "POST"])
def delete_account_confirm(request):
    """2-qadam: kodni tekshirish va akkauntni o'chirish."""
    phone_number = request.session.get(SESSION_PHONE_KEY)
    if not phone_number:
        # Sessiya tugagan yoki sahifa to'g'ridan-to'g'ri ochilgan.
        return redirect("accounts_web:delete-account")

    context = {"phone_number": phone_number}

    if request.method == "GET":
        context["form"] = DeleteAccountCodeForm()
        return render(request, "accounts/delete_account_confirm.html", context)

    form = DeleteAccountCodeForm(request.POST)
    if not form.is_valid():
        context["form"] = form
        return render(request, "accounts/delete_account_confirm.html", context)

    attempts = request.session.get(SESSION_ATTEMPTS_KEY, 0)
    if attempts >= MAX_CODE_ATTEMPTS:
        _clear_session(request)
        return render(
            request,
            "accounts/delete_account_request.html",
            {
                "form": DeleteAccountPhoneForm(),
                "blocked_error": (
                    "Kod bir necha marta noto'g'ri kiritildi. "
                    "Boshidan boshlang."
                ),
            },
        )

    otp = PhoneOTP.objects.filter(
        phone_number=phone_number,
        code=form.cleaned_data["code"],
        purpose=OTPPurpose.DELETE_ACCOUNT,
        is_used=False,
    ).first()

    if not otp or not otp.is_valid():
        request.session[SESSION_ATTEMPTS_KEY] = attempts + 1
        form.add_error("code", GENERIC_CODE_ERROR)
        context["form"] = form
        return render(request, "accounts/delete_account_confirm.html", context)

    otp.is_used = True
    otp.save(update_fields=["is_used"])

    user = User.objects.filter(phone_number=phone_number).first()
    if user is None:
        # Kod tekshirilgandan keyin ham akkaunt topilmasa — o'chiradigan narsa
        # yo'q. Xabar bir xil qoladi (raqam oshkor bo'lmaydi).
        _clear_session(request)
        return redirect("accounts_web:delete-account-done")

    # ── SHU YERDAN KEYIN o'chirish bajariladi: kod tasdiqlangan ──
    delete_user_account(user)

    _clear_session(request)
    return redirect("accounts_web:delete-account-done")


@require_http_methods(["GET"])
def delete_account_done(request):
    return render(request, "accounts/delete_account_done.html")


def _clear_session(request):
    request.session.pop(SESSION_PHONE_KEY, None)
    request.session.pop(SESSION_ATTEMPTS_KEY, None)
