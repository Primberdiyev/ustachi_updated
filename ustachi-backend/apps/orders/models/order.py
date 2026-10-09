"""
Buyurtma (order) — mijoz e'loni va uning hayot sikli.

OQIM (foydalanuvchi qarori 2026-07-26 — "e'lon + takliflar", narxsiz kelishuv):
  1. Mijoz ilovada taklifni (proposal) tanlaydi va BUYURTMA E'LON qiladi.
     E'lon hududdagi ustalarga ko'rinadi (`published`).
  2. Ustalar "Qabul qilaman" deydi — `OrderResponse` yoziladi. Usta NARX
     TAKLIF QILMAYDI; narx/shart CHATDA kelishiladi.
  3. Mijoz javob berganlardan BITTASINI tanlaydi → `assigned`, ish 5 bosqichda
     boradi (`OrderStage`), oxirida `completed` va mijoz baho beradi.

Mijozning hisobi (`calculated_price`) — O'ZGARMAS HUJJAT: ilova yuborgan
raqam aynan saqlanadi. Usta uni tahrirlay olmaydi, faqat ko'radi.
"""

from django.db import models
from django.utils import timezone

from apps.core.models.base import BaseModel


class OrderStatus(models.TextChoices):
    PUBLISHED = "published", "E'lon qilingan"
    ASSIGNED = "assigned", "Usta tanlangan"
    COMPLETED = "completed", "Yakunlangan"
    CANCELLED = "cancelled", "Bekor qilingan"
    EXPIRED = "expired", "Muddati o'tgan"


class OrderStage(models.TextChoices):
    """
    Ish bosqichlari. Tartib va nomlar IKKALA ilovada bir xil
    (`ustachi_usta` OrderStage enum bilan mos) — har bosqich yakunlanganda
    mijozga xabar ketadi.

    QISQARTIRILDI (foydalanuvchi qarori 2026-09-23): romda ikki bosqich
    qoldi — "Qabul qilindi" va "O'lchov olindi", undan keyin usta ishni
    DARHOL yakunlaydi va mijoz baho beradi. Boshqa yo'nalishlarda o'lchov
    ham yo'q: qabul qilindi → yakunlash. Uzun zanjir (ishlab chiqarish,
    o'rnatish, topshirish) ustalarni chalg'itardi.

    PRODUCTION/INSTALLATION/HANDOVER qiymatlari ESKI buyurtmalar uchun
    qoldirildi: bazadagi qatorlar o'zgarmaydi, lekin yangi buyurtma ularga
    o'tmaydi. Shunday qatordagi usta "Yakunlash" tugmasini ko'radi
    (`next_stage` → None).
    """

    ACCEPTED = "accepted", "Qabul qilindi"
    MEASURED = "measured", "O'lchov olindi"
    PRODUCTION = "production", "Ishlab chiqarish"
    INSTALLATION = "installation", "O'rnatish"
    HANDOVER = "handover", "Topshirildi"

    @classmethod
    def order(cls) -> list[str]:
        return [cls.ACCEPTED, cls.MEASURED]


#: Yangi buyurtmalarda ISHLATILMAYDI — faqat eski qatorlarda uchraydi.
LEGACY_STAGES = (
    OrderStage.PRODUCTION,
    OrderStage.INSTALLATION,
    OrderStage.HANDOVER,
)


class Order(BaseModel):
    UZ_TITLE = "Buyurtma"

    #: E'lon standart amal qilish muddati (soat).
    DEFAULT_TTL_HOURS = 48

    client = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="orders",
        verbose_name="Mijoz",
    )
    title = models.CharField(max_length=200, verbose_name="Sarlavha")
    #: Mijozning SHARTLARI/izohi — erkin matn ("2-qavat, lift yo'q" kabi).
    description = models.TextField(blank=True, default="", verbose_name="Shartlar")

    # ── Taklif (proposal) surati ────────────────────────────────────────
    #: Ilovadagi taklifning to'liq nusxasi: shakl, o'lcham, brend, rang,
    #: tokcha, gul... Buyurtma yaratilgandan keyin O'ZGARMAYDI — usta aynan
    #: nimaga rozilik berayotganini bilishi uchun.
    proposal = models.JSONField(default=dict, blank=True, verbose_name="Taklif")
    calculated_price = models.BigIntegerField(
        default=0, verbose_name="Mijoz hisobi (so'm)"
    )

    # ── Manzil ──────────────────────────────────────────────────────────
    region = models.ForeignKey(
        "locations.Region",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="orders",
        verbose_name="Viloyat",
    )
    district = models.ForeignKey(
        "locations.City",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="orders",
        verbose_name="Tuman/shahar",
    )
    address = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Manzil"
    )

    # ── Yo'nalish (soha) ────────────────────────────────────────────────
    #: Buyurtma QAYSI SOHA ustasiga (foydalanuvchi talabi 2026-08-13):
    #: rom, tom yopish, g'isht terish... E'lon FAQAT shu yo'nalishdagi
    #: ustalarga ko'rinadi va push ham faqat ularga boradi.
    #:
    #: `null` — zaxira yo'l: sohasiz e'lon soha filtridan o'tib ketadi.
    #: PROTECT: yo'nalish o'chirilmaydi, `is_active=False` qilinadi.
    specialty = models.ForeignKey(
        "accounts.MasterSpecialty",
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="orders",
        verbose_name="Yo'nalish",
    )

    # ── Ko'rinish doirasi ───────────────────────────────────────────────
    #: E'lon HAMMA ustaga ko'rinadimi (foydalanuvchi talabi 2026-08-07).
    #:
    #: `True`  — ochiq e'lon: hududdagi har bir usta ko'radi (eski xulq).
    #: `False` — mijoz AYNAN o'zi tanlagan ustalarga yubordi (`OrderInvite`);
    #:           boshqa ustalar feed'da ko'rmaydi va javob bera olmaydi.
    #:
    #: Yopiq e'lonni mijoz istagan payt hammaga ochishi mumkin
    #: (`services.open_order_to_everyone`) — teskarisi YO'Q: e'lonni ko'rgan
    #: ustalardan uni yashirib bo'lmaydi.
    is_public = models.BooleanField(default=True, verbose_name="Hammaga ochiq")

    # ── Ta'mir e'loni ───────────────────────────────────────────────────
    #: Bu YANGI ish emas, TA'MIR (foydalanuvchi talabi 2026-09-21): eski
    #: rom/eshikni sozlash, furnitura yoki oyna almashtirish.
    #:
    #: Ta'mir e'loni faqat "Ta'mirga chiqaman" degan ustalarga ko'rinadi
    #: (`MasterProfile.does_repairs`, qoida `visibility.py` da). Narx
    #: hisoblanmaydi (`calculated_price=0`) — har usta o'z narxini aytadi.
    #: Nima buzilgani suratda: `proposal["repair_problems"]`.
    is_repair = models.BooleanField(default=False, verbose_name="Ta'mir")

    # ── Holat ───────────────────────────────────────────────────────────
    status = models.CharField(
        max_length=20,
        choices=OrderStatus.choices,
        default=OrderStatus.PUBLISHED,
        verbose_name="Holat",
    )
    stage = models.CharField(
        max_length=20,
        choices=OrderStage.choices,
        null=True,
        blank=True,
        verbose_name="Bosqich",
    )
    assigned_master = models.ForeignKey(
        "accounts.User",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_orders",
        verbose_name="Tanlangan usta",
    )
    expires_at = models.DateTimeField(verbose_name="E'lon muddati")
    completed_at = models.DateTimeField(null=True, blank=True, verbose_name="Yakunlandi")
    telegram_message_id = models.BigIntegerField(null=True, blank=True, editable=False)
    telegram_post_is_photo = models.BooleanField(default=False, editable=False)
    cancelled_reason = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Bekor qilish sababi"
    )

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Buyurtma"
        verbose_name_plural = "Buyurtmalar"
        indexes = [
            models.Index(fields=["status", "region"]),
            models.Index(fields=["client", "-created_at"]),
            # Feed so'rovi: ochiq e'lonlar → yo'nalish → hudud.
            models.Index(fields=["status", "specialty", "region"]),
        ]

    def __str__(self):
        return f"#{self.pk} {self.title}"

    def save(self, *args, **kwargs):
        if not self.expires_at:
            self.expires_at = timezone.now() + timezone.timedelta(
                hours=self.DEFAULT_TTL_HOURS
            )

        # VALIDATION FIX (2026-08-18): Ensure calculated_price is non-negative
        # to prevent masters from working for free due to malformed data
        if self.calculated_price < 0:
            from django.core.exceptions import ValidationError
            raise ValidationError("calculated_price must be non-negative")

        super().save(*args, **kwargs)

    # ── Holat yordamchilari ─────────────────────────────────────────────
    @property
    def is_expired(self) -> bool:
        """Muddati o'tgan e'lon (hali usta tanlanmagan)."""
        return (
            self.status == OrderStatus.PUBLISHED and self.expires_at <= timezone.now()
        )

    @property
    def is_open_for_responses(self) -> bool:
        """Usta javob bera oladimi."""
        return self.status == OrderStatus.PUBLISHED and not self.is_expired

    @property
    def cost_base(self) -> int:
        """
        MATERIAL NARXI (so'm) — usta stavkasi shuning ustiga qo'shiladi
        (`apps/orders/response_total.py`).

        Taklif suratida `cost_price` bo'lsa o'sha, bo'lmasa
        `calculated_price` ning o'zi.
        """
        raw = (self.proposal or {}).get("cost_price")
        try:
            cost = int(raw)
        except (TypeError, ValueError):
            cost = 0
        return cost if cost > 0 else (self.calculated_price or 0)

    def is_visible_to(self, master) -> bool:
        """
        Shu usta e'lonni KO'RA oladimi.

        Qoida `apps/orders/visibility.py` da — feed va bildirishnoma bilan
        AYNI matn (ular ajralib ketgani uchun 2026-08-08 da xato chiqqan edi).
        Qisqacha: taklif qilingan usta doim ko'radi; ochiq e'lonni esa
        hududi va YO'NALISHI mos ustalar ko'radi.
        """
        from apps.orders import visibility

        return visibility.order_visible_to(self, master)

    @property
    def is_rom(self) -> bool:
        if not self.specialty_id:
            return True
        return self.specialty.code == "rom"

    @property
    def active_stages(self) -> list[str]:
        """Rom: qabul + o'lchov. Qolganida o'lchov yo'q — faqat qabul."""
        if self.is_rom:
            return OrderStage.order()
        return [OrderStage.ACCEPTED]

    @property
    def stage_total(self) -> int:
        return len(self.active_stages)

    @property
    def stage_step(self) -> int:
        """1 dan boshlanadigan bosqich raqami (UI: "5 dan 3-bosqich" yoki "3 dan 2-bosqich")."""
        if not self.stage:
            return 0
        try:
            return self.active_stages.index(self.stage) + 1
        except ValueError:
            # Eski zanjirda qolgan buyurtma — oxirgi bosqichda deb ko'rsatiladi.
            return len(self.active_stages)

    @property
    def next_stage(self) -> str | None:
        stages = self.active_stages
        if self.stage not in stages:
            # Eski zanjirdagi buyurtma: keyingi bosqich yo'q — usta uni
            # darhol yakunlay oladi.
            return None
        idx = stages.index(self.stage)
        if idx + 1 < len(stages):
            return stages[idx + 1]
        return None


class OrderStageEvent(models.Model):
    """Bosqich tarixi — kim, qachon, qaysi bosqichga o'tkazdi."""

    UZ_TITLE = "Bosqich hodisasi"

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="stage_events",
        verbose_name="Buyurtma",
    )
    stage = models.CharField(
        max_length=20, choices=OrderStage.choices, verbose_name="Bosqich"
    )
    note = models.CharField(
        max_length=255, blank=True, default="", verbose_name="Izoh"
    )
    actor = models.ForeignKey(
        "accounts.User",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="+",
        verbose_name="Kim",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]
        verbose_name = "Bosqich hodisasi"
        verbose_name_plural = "Bosqich hodisalari"

    def __str__(self):
        return f"#{self.order_id} → {self.stage}"
