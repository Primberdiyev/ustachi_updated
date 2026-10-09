from django.apps import AppConfig


class AccountsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.accounts"
    verbose_name = "Accounts"

    def ready(self):
        # PUSH TAYYORLIGI tekshiruvi — kalit fayli bo'lmasa push jimgina
        # o'chib qoladi, shuning uchun server ishga tushganda ogohlantirish
        # chiqadi (`apps/accounts/checks.py` ga qarang).
        from apps.accounts import checks  # noqa: F401
