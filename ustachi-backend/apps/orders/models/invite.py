"""
MIJOZ TAKLIFI (`OrderInvite`) — buyurtmani TANLANGAN ustaga yuborish.

NIMA UCHUN (foydalanuvchi talabi 2026-08-07): hisob tugagach mijozning ikki
yo'li bo'ladi —

  1. **E'lon qilish** — buyurtma hududdagi HAMMA ustaga ko'rinadi
     (`Order.is_public=True`, eski xulq, o'zgarmagan);
  2. **Usta tanlash** — mijoz ustalar ro'yxatidan o'zi yoqtirganini tanlab,
     buyurtmani AYNAN unga yuboradi (`is_public=False` + shu ustaga taklif).

Ikkinchi holatda e'lon boshqa ustalarga KO'RINMAYDI: mijoz ataylab bitta
odamni tanlagan, uni o'ntacha begona usta bosib ketmasligi kerak. Taklif
qilingan usta rad etsa yoki mijoz kutib charchasa — buyurtmani bir bosishda
hammaga ochish mumkin (`open_order_to_everyone`).

Taklif — javob (`OrderResponse`) EMAS: taklifni MIJOZ yuboradi, javobni USTA
beradi. Usta taklifni qabul qilsa, oddiy `OrderResponse` yoziladi va oqim
o'zgarishsiz davom etadi (chatda kelishuv → mijoz tanlaydi → bosqichlar).
"""

from django.db import models

from apps.core.models.base import BaseModel
from apps.orders.models.order import Order


class InviteStatus(models.TextChoices):
    PENDING = "pending", "Javob kutilmoqda"
    ACCEPTED = "accepted", "Usta qabul qildi"
    DECLINED = "declined", "Usta rad etdi"


class OrderInvite(BaseModel):
    UZ_TITLE = "Ustaga taklif"

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="invites",
        verbose_name="Buyurtma",
    )
    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="order_invites",
        verbose_name="Usta",
    )
    status = models.CharField(
        max_length=20,
        choices=InviteStatus.choices,
        default=InviteStatus.PENDING,
        verbose_name="Holat",
    )
    #: Usta rad etganda qoldirgan sababi (ixtiyoriy) — mijoz ko'radi.
    decline_reason = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Rad etish sababi"
    )

    class Meta:
        ordering = ["created_at"]
        verbose_name = "Ustaga taklif"
        verbose_name_plural = "Ustaga takliflar"
        constraints = [
            # Bitta ustaga bitta buyurtma bo'yicha BITTA taklif (qayta
            # yuborilsa o'sha yozuv yangilanadi).
            models.UniqueConstraint(
                fields=["order", "master"], name="orders_invite_unique_master"
            ),
        ]
        indexes = [models.Index(fields=["master", "status"])]

    def __str__(self):
        return f"#{self.order_id} → {self.master}"
