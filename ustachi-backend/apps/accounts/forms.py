"""Akkauntni o'chirish sahifasi (HTML) uchun formalar."""

import re

from django import forms

# `+998901234567` yoki `998901234567` — API'dagi format bilan bir xil.
PHONE_RE = re.compile(r"^\+?998\d{9}$")


class DeleteAccountPhoneForm(forms.Form):
    """1-qadam: raqamni kiritish va tasdiqlash kodini so'rash."""

    phone_number = forms.CharField(
        label="Telefon raqam",
        max_length=20,
        widget=forms.TextInput(
            attrs={
                "placeholder": "+998901234567",
                "inputmode": "tel",
                "autocomplete": "tel",
                "autofocus": "autofocus",
            }
        ),
    )

    def clean_phone_number(self):
        value = self.cleaned_data["phone_number"].strip().replace(" ", "")
        if not PHONE_RE.match(value):
            raise forms.ValidationError(
                "Telefon raqamni +998901234567 ko'rinishida kiriting."
            )
        # Bazada raqamlar `+` bilan saqlanadi — bitta ko'rinishga keltiramiz.
        return value if value.startswith("+") else f"+{value}"


class DeleteAccountCodeForm(forms.Form):
    """2-qadam: SMS kodi va oxirgi ogohlantirishga rozilik."""

    code = forms.CharField(
        label="SMS kod",
        max_length=6,
        widget=forms.TextInput(
            attrs={
                "placeholder": "______",
                "inputmode": "numeric",
                "autocomplete": "one-time-code",
                "maxlength": "6",
                "autofocus": "autofocus",
            }
        ),
    )
    confirm = forms.BooleanField(
        label=(
            "Akkauntim va undagi barcha ma'lumotlar butunlay o'chirilishiga "
            "roziman. Bu amalni ortga qaytarib bo'lmaydi."
        ),
        required=True,
        error_messages={"required": "Davom etish uchun roziligingizni belgilang."},
    )

    def clean_code(self):
        value = self.cleaned_data["code"].strip()
        if not value.isdigit() or len(value) != 6:
            raise forms.ValidationError("Kod 6 ta raqamdan iborat bo'lishi kerak.")
        return value
