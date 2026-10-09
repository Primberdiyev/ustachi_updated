"""
Ilova ichidagi bildirishnomalar.

Hozircha FAQAT in-app ro'yxat (qo'ng'iroqcha + o'qilmaganlar soni). FCM push
keyingi bosqichda qo'shiladi — `notify()` xizmati o'sha yerda kengaytiriladi,
model va API o'zgarmaydi.
"""

from django.db import models

from apps.accounts.models.device import AppKind


class NotificationType(models.TextChoices):
    ORDER_PUBLISHED = "order_published", "Yangi buyurtma"
    #: Mijoz buyurtmani AYNAN shu ustaga yubordi (ochiq e'lon emas).
    ORDER_INVITE = "order_invite", "Sizga taklif"
    #: Taklif qilingan usta rad etdi — mijoz boshqa yo'l tanlashi kerak.
    ORDER_INVITE_DECLINED = "order_invite_declined", "Usta taklifni rad etdi"
    ORDER_RESPONSE = "order_response", "Usta javob berdi"
    ORDER_CHOSEN = "order_chosen", "Usta tanlandi"
    ORDER_NOT_CHOSEN = "order_not_chosen", "Boshqa usta tanlandi"
    ORDER_STAGE = "order_stage", "Bosqich o'zgardi"
    ORDER_COMPLETED = "order_completed", "Buyurtma yakunlandi"
    ORDER_CANCELLED = "order_cancelled", "Buyurtma bekor qilindi"
    REVIEW_RECEIVED = "review_received", "Yangi baho"
    CHAT_MESSAGE = "chat_message", "Yangi xabar"


class Notification(models.Model):
    UZ_TITLE = "Bildirishnoma"

    user = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="notifications",
        verbose_name="Foydalanuvchi",
    )
    type = models.CharField(
        max_length=32, choices=NotificationType.choices, verbose_name="Turi"
    )
    title = models.CharField(max_length=200, verbose_name="Sarlavha")
    body = models.CharField(max_length=500, blank=True, default="", verbose_name="Matn")
    order = models.ForeignKey(
        "orders.Order",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="notifications",
        verbose_name="Buyurtma",
    )
    is_read = models.BooleanField(default=False, verbose_name="O'qilgan")
    app = models.CharField(
        max_length=8,
        choices=AppKind.choices,
        blank=True,
        default="",
        verbose_name="Ilova",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Bildirishnoma"
        verbose_name_plural = "Bildirishnomalar"
        indexes = [models.Index(fields=["user", "is_read", "-created_at"])]

    def __str__(self):
        return f"{self.user} — {self.title}"
