import random
import string

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.db.models import Q
from django.utils import timezone


class UserManager(BaseUserManager):
    def _generate_username(self):
        while True:
            username = "user_" + "".join(random.choices(string.ascii_lowercase + string.digits, k=8))
            if not self.model.objects.filter(username=username).exists():
                return username

    def create_user(self, phone_number=None, password=None, **extra_fields):
        username = extra_fields.pop("username", None) or self._generate_username()
        user = self.model(phone_number=phone_number, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser uchun is_staff=True bo'lishi shart.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser uchun is_superuser=True bo'lishi shart.")

        phone_number = extra_fields.pop("phone_number", None)
        return self.create_user(phone_number=phone_number, password=password, username=username, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """
    ROL MODELI (2026-07-20 dan):
      * client — HAMMA foydalanuvchi mijoz bo'la oladi (alohida bayroq shart emas).
      * master — `is_master=True`. Mijozlikni YO'QOTMAYDI (bir odam ham mijoz,
        ham usta bo'lishi mumkin — bitta telefon, bitta akkaunt).
      * admin  — `is_superuser=True` (Django'niki), createsuperuser orqali.
    """

    UZ_TITLE = "Foydalanuvchi"

    phone_number = models.CharField(max_length=20, null=True, blank=True)
    telegram_auth_user_id = models.BigIntegerField(
        null=True, blank=True, unique=True,
        help_text="Mijoz Telegram autentifikatsiyasi uchun biriktirilgan Telegram user ID.",
    )
    username = models.CharField(max_length=50, unique=True)
    full_name = models.CharField(max_length=100, blank=True, default="")
    photo = models.ImageField(upload_to="users/photos/", null=True, blank=True)
    # ── Manzil (ro'yxatdan o'tishда tanlanadi) ────────────────────────────
    # Katalog `locations` app'ida (Region / City=tuman-shahar); string-havola
    # import sikliga yo'l qo'ymaydi.
    region = models.ForeignKey(
        "locations.Region",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="users",
        verbose_name="Viloyat",
    )
    district = models.ForeignKey(
        "locations.City",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="users",
        verbose_name="Tuman/shahar",
    )
    address = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Manzil"
    )
    is_master = models.BooleanField(
        default=False,
        verbose_name="Usta",
        help_text="Usta (master) roli. Mijozlik roli hammada bor.",
    )
    is_active = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = []

    class Meta:
        verbose_name = "Foydalanuvchi"
        verbose_name_plural = "Foydalanuvchilar"
        constraints = [
            models.UniqueConstraint(
                fields=["phone_number"],
                condition=Q(phone_number__isnull=False),
                name="accounts_user_phone_number_not_null_unique",
            ),
        ]

    def __str__(self):
        return self.full_name or self.phone_number or self.username

    @property
    def is_client(self) -> bool:
        """Hamma foydalanuvchi mijoz bo'la oladi — alohida bayroq yo'q."""
        return True

    @property
    def roles(self) -> list[str]:
        """Foydalanuvchining barcha rollari (API javoblari uchun)."""
        result = ["client"]
        if self.is_master:
            result.append("master")
        if self.is_superuser:
            result.append("admin")
        return result
