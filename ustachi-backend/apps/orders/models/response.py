"""
Usta javobi (`OrderResponse`) va mijoz bahosi (`Review`).

Usta javobida NARX YO'Q (foydalanuvchi qarori 2026-07-26): usta faqat
"qabul qilaman" deydi, xohlasa qisqa izoh qoldiradi. Narx va shartlar
CHATDA kelishiladi — shuning uchun bu model ataylab sodda.
"""

from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.core.models.base import BaseModel
from apps.orders.models.order import Order


class ResponseStatus(models.TextChoices):
    INTERESTED = "interested", "Qabul qilaman"
    WITHDRAWN = "withdrawn", "Voz kechdi"
    CHOSEN = "chosen", "Tanlandi"
    REJECTED = "rejected", "Tanlanmadi"


class OrderResponse(BaseModel):
    UZ_TITLE = "Usta javobi"

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="responses",
        verbose_name="Buyurtma",
    )
    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="order_responses",
        verbose_name="Usta",
    )
    status = models.CharField(
        max_length=20,
        choices=ResponseStatus.choices,
        default=ResponseStatus.INTERESTED,
        verbose_name="Holat",
    )
    #: Ixtiyoriy qisqa izoh ("ertaga o'lchov olib kelaman" kabi).
    message = models.CharField(
        max_length=500, blank=True, default="", verbose_name="Izoh"
    )

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Usta javobi"
        verbose_name_plural = "Usta javoblari"
        constraints = [
            # Bitta usta bitta buyurtmaga faqat bir marta javob beradi
            # (voz kechib qayta javob bersa — o'sha yozuv yangilanadi).
            models.UniqueConstraint(
                fields=["order", "master"], name="orders_response_unique_master"
            ),
        ]

    def __str__(self):
        return f"#{self.order_id} ← {self.master}"


class Review(BaseModel):
    """
    Mijozning yakuniy bahosi. Har buyurtmaga BITTA baho; usta reytingi shu
    yozuvlardan hisoblanadi (`MasterProfile` agregati API'da beriladi).
    """

    UZ_TITLE = "Baho"

    order = models.OneToOneField(
        Order,
        on_delete=models.CASCADE,
        related_name="review",
        verbose_name="Buyurtma",
    )
    client = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="given_reviews",
        verbose_name="Mijoz",
    )
    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="received_reviews",
        verbose_name="Usta",
    )
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        verbose_name="Baho (1-5)",
    )
    comment = models.TextField(blank=True, default="", verbose_name="Izoh")

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Baho"
        verbose_name_plural = "Baholar"
        indexes = [models.Index(fields=["master", "-created_at"])]

    def __str__(self):
        return f"#{self.order_id} — {self.rating}★"
