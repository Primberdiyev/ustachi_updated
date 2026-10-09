"""
USTANING O'Z buyurtmasi — marketplace'dan MUSTAQIL model.

Nima uchun `Order` ga qo'shilmadi:
  * `Order.client` MAJBURIY FK (ro'yxatdan o'tgan mijoz), bu yerda esa mijoz
    ilovaga umuman kirmagan — usta uning ismini/telefonini o'zi yozadi;
  * `Order` statuslari e'lon semantikasi (`published/assigned/expired`),
    bu yerda esa do'kon semantikasi (`new/in_progress/done/debt`);
  * `Order` da faqat BITTA rom bo'ladi.

Buyurtma faqat CHIZMANI saqlaydi: kim uchun, qachongacha va nima
(`MasterOrderItem.drawing`). Pul maydonlari yo'q.
"""

from django.core.validators import MinValueValidator
from django.db import models

from apps.core.models.base import BaseModel


class MasterOrderStatus(models.TextChoices):
    DRAFT = "draft", "Qoralama"
    NEW = "new", "Yangi"
    IN_PROGRESS = "in_progress", "Jarayonda"
    DONE = "done", "Yakunlangan"
    DEBT = "debt", "Qarzdor"
    CANCELLED = "cancelled", "Bekor qilingan"

    @classmethod
    def closed(cls) -> list[str]:
        """Yopilgan holatlar — ro'yxatda "arxiv" segmentiga tushadi."""
        return [cls.DONE, cls.CANCELLED]


class MasterOrder(BaseModel):
    UZ_TITLE = "Usta buyurtmasi"

    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="own_orders",
        verbose_name="Usta",
    )

    #: Qurilmadagi qoralama ID'si. Tarmoq uzilib so'rov qayta yuborilsa
    #: dublikat buyurtma yaratilmasligi uchun (idempotentlik kaliti).
    sync_client_id = models.CharField(
        max_length=64, blank=True, default="", verbose_name="Qurilma ID"
    )

    # ── Buyurtmachi (ilovaga kirmagan odam) ─────────────────────────────
    customer_name = models.CharField(max_length=120, verbose_name="Buyurtmachi")
    customer_phone = models.CharField(
        max_length=32, blank=True, default="", verbose_name="Telefon"
    )
    customer_address = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Manzil"
    )

    # ── Shartlar ────────────────────────────────────────────────────────
    deadline = models.DateField(null=True, blank=True, verbose_name="Muddat")
    note = models.TextField(blank=True, default="", verbose_name="Izoh")

    status = models.CharField(
        max_length=20,
        choices=MasterOrderStatus.choices,
        default=MasterOrderStatus.NEW,
        verbose_name="Holat",
    )
    completed_at = models.DateTimeField(
        null=True, blank=True, verbose_name="Yakunlandi"
    )

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Usta buyurtmasi"
        verbose_name_plural = "Usta buyurtmalari"
        indexes = [models.Index(fields=["master", "-created_at"])]
        constraints = [
            # Bo'sh `sync_client_id` cheklovga tushmaydi (admin/qo'lda yaratish).
            models.UniqueConstraint(
                fields=["master", "sync_client_id"],
                condition=~models.Q(sync_client_id=""),
                name="uniq_master_order_sync_client_id",
            )
        ]

    def __str__(self):
        return f"#{self.pk} {self.customer_name}"

    @property
    def product_count(self) -> int:
        return sum(item.qty for item in self.items.all())


class MasterOrderItem(models.Model):
    """
    Buyurtmadagi bitta mahsulot (rom).

    `drawing` — buyurtma HUJJATI: usta mijozga aynan shuni chizib ko'rsatgan.
    """

    UZ_TITLE = "Buyurtma mahsuloti"

    order = models.ForeignKey(
        MasterOrder,
        on_delete=models.CASCADE,
        related_name="items",
        verbose_name="Buyurtma",
    )
    position = models.PositiveIntegerField(default=0, verbose_name="Tartib")

    title = models.CharField(max_length=120, blank=True, default="", verbose_name="Nomi")
    material_label = models.CharField(
        max_length=60, blank=True, default="", verbose_name="Material"
    )
    width_mm = models.PositiveIntegerField(default=0, verbose_name="Eni (mm)")
    height_mm = models.PositiveIntegerField(default=0, verbose_name="Balandligi (mm)")

    qty = models.PositiveIntegerField(
        default=1, validators=[MinValueValidator(1)], verbose_name="Sanoq"
    )

    #: Chizma spetsifikatsiyasi (`ProposalSpecCodec` formati).
    drawing = models.JSONField(default=dict, blank=True, verbose_name="Chizma")

    class Meta:
        ordering = ["position", "id"]
        verbose_name = "Buyurtma mahsuloti"
        verbose_name_plural = "Buyurtma mahsulotlari"

    def __str__(self):
        return f"{self.title or 'Rom'} × {self.qty}"
