"""
Chat — mijoz ↔ usta yozishmasi.

Suhbat BUYURTMAGA bog'lanadi: har (buyurtma, usta) juftligi uchun bitta
`ChatThread`. Shu sabab mijoz javob bergan har bir usta bilan alohida
savdolashadi (narx/shart CHATDA kelishiladi), tanlangandan keyin esa o'sha
suhbat ish yakunigacha davom etadi.

Real-time (WebSocket/Channels) keyingi bosqichda ulanadi — model va REST
tarixi o'zgarmaydi, ustiga faqat kanal qo'shiladi.
"""

from django.db import models
from django.utils import timezone


class ChatThread(models.Model):
    UZ_TITLE = "Suhbat"

    order = models.ForeignKey(
        "orders.Order",
        on_delete=models.CASCADE,
        related_name="threads",
        verbose_name="Buyurtma",
    )
    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="chat_threads_as_master",
        verbose_name="Usta",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    last_message_at = models.DateTimeField(
        null=True, blank=True, verbose_name="Oxirgi xabar"
    )

    class Meta:
        ordering = ["-last_message_at", "-created_at"]
        verbose_name = "Suhbat"
        verbose_name_plural = "Suhbatlar"
        constraints = [
            models.UniqueConstraint(
                fields=["order", "master"], name="orders_chatthread_unique"
            ),
        ]

    def __str__(self):
        return f"#{self.order_id} ↔ {self.master}"

    @property
    def client_id(self) -> int:
        return self.order.client_id

    def participant_ids(self) -> set[int]:
        return {self.order.client_id, self.master_id}


class ChatMessage(models.Model):
    UZ_TITLE = "Xabar"

    thread = models.ForeignKey(
        ChatThread,
        on_delete=models.CASCADE,
        related_name="messages",
        verbose_name="Suhbat",
    )
    sender = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="chat_messages",
        verbose_name="Yuboruvchi",
    )
    text = models.TextField(verbose_name="Matn")
    is_read = models.BooleanField(default=False, verbose_name="O'qilgan")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]
        verbose_name = "Xabar"
        verbose_name_plural = "Xabarlar"
        indexes = [
            models.Index(fields=["thread", "-created_at"]),
            # INDEX FIX (2026-08-18): Mark as read query needs thread + is_read + time
            models.Index(fields=["thread", "is_read", "-created_at"]),
            # SAHIFALASH (2026-09-05): kursor `id` bo'yicha ketadi
            # (`created_at` bir soniyada takrorlanishi mumkin, `id` — yo'q).
            # Busiz "WHERE thread=X AND id<N ORDER BY id DESC LIMIT 50"
            # suhbatning HAMMA qatorini saralashga majbur bo'lardi.
            models.Index(fields=["thread", "-id"]),
        ]

    def __str__(self):
        return f"{self.sender}: {self.text[:30]}"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Suhbat ro'yxati oxirgi xabar bo'yicha tartiblanadi.
        ChatThread.objects.filter(pk=self.thread_id).update(
            last_message_at=self.created_at or timezone.now()
        )
