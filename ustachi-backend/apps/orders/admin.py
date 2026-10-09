from django.contrib import admin
from django.db.models import Count, QuerySet, Sum
from django.http import HttpRequest
from django.urls import reverse
from django.utils import timezone
from django.utils.html import format_html
from unfold.admin import ModelAdmin, TabularInline
from unfold.contrib.filters.admin import (
    AllValuesCheckboxFilter,
    BooleanRadioFilter,
    ChoicesDropdownFilter,
    RangeDateFilter,
    RangeDateTimeFilter,
    RangeNumericFilter,
    RelatedDropdownFilter,
)
from unfold.decorators import action, display

from apps.common import telegram
from apps.orders.models import (
    ChatThread,
    ExclusiveTerritory,
    MasterOrder,
    MasterOrderItem,
    Order,
    OrderInvite,
    OrderResponse,
    OrderStageEvent,
    Review,
)
from apps.orders.models.master_order import MasterOrderStatus
from apps.orders.models.order import OrderStatus

#: Holat → yorliq rangi. Bir marta e'lon qilinadi, `@display(label=...)` da
#: qayta ishlatiladi — ranglar ro'yxat va kartalarda bir xil bo'lsin.
ORDER_STATUS_LABELS = {
    OrderStatus.PUBLISHED: "info",
    OrderStatus.ASSIGNED: "warning",
    OrderStatus.COMPLETED: "success",
    OrderStatus.CANCELLED: "danger",
    OrderStatus.EXPIRED: "danger",
}

MASTER_ORDER_STATUS_LABELS = {
    MasterOrderStatus.DRAFT: "info",
    MasterOrderStatus.NEW: "info",
    MasterOrderStatus.IN_PROGRESS: "warning",
    MasterOrderStatus.DONE: "success",
    MasterOrderStatus.DEBT: "danger",
    MasterOrderStatus.CANCELLED: "danger",
}


def _money(value: int | None) -> str:
    """So'm — mingliklari ajratilgan holda ("1 250 000 so'm")."""
    if not value:
        return "0 so'm"
    return f"{value:,}".replace(",", " ") + " so'm"


# ─────────────────────────── Buyurtma (marketplace) ───────────────────────────


class OrderResponseInline(TabularInline):
    model = OrderResponse
    extra = 0
    fields = ("master", "status", "message", "created_at")
    readonly_fields = ("created_at",)
    autocomplete_fields = ("master",)
    tab = True


class OrderStageEventInline(TabularInline):
    model = OrderStageEvent
    extra = 0
    fields = ("stage", "note", "actor", "created_at")
    readonly_fields = ("created_at",)
    autocomplete_fields = ("actor",)
    ordering = ("created_at",)
    tab = True


class ChatThreadInline(TabularInline):
    model = ChatThread
    extra = 0
    fields = ("master", "message_count", "last_message_at", "created_at")
    readonly_fields = ("message_count", "last_message_at", "created_at")
    autocomplete_fields = ("master",)
    tab = True

    @display(description="Xabarlar")
    def message_count(self, obj: ChatThread) -> int:
        return obj.messages.count() if obj.pk else 0


class OrderInviteInline(TabularInline):
    """Mijoz O'ZI tanlab yuborgan ustalar (yopiq e'londa kim ko'ra oladi)."""

    model = OrderInvite
    extra = 0
    fields = ("master", "status", "decline_reason", "created_at")
    readonly_fields = ("created_at",)
    autocomplete_fields = ("master",)
    ordering = ("created_at",)
    tab = True


@admin.register(Order)
class OrderAdmin(ModelAdmin):
    """Mijoz e'loni: e'lon → usta javoblari → tanlov → 5 bosqich → baho."""

    list_display = (
        "display_order",
        "display_client",
        "display_status",
        "display_stage",
        "display_master",
        "display_price",
        "display_responses",
        "display_expires",
    )
    list_display_links = ("display_order",)
    list_filter = (
        ("status", ChoicesDropdownFilter),
        # Yopiq e'lon = mijoz aynan tanlagan ustalarga yuborgan.
        ("is_public", BooleanRadioFilter),
        # Ta'mir e'lonlari (2026-09-21) — alohida ko'rish uchun.
        ("is_repair", BooleanRadioFilter),
        ("stage", ChoicesDropdownFilter),
        ("region", RelatedDropdownFilter),
        ("calculated_price", RangeNumericFilter),
        ("created_at", RangeDateTimeFilter),
    )
    list_filter_submit = True
    list_fullwidth = True
    search_fields = (
        "title",
        "address",
        "client__phone_number",
        "client__full_name",
        "assigned_master__full_name",
    )
    autocomplete_fields = ("client", "assigned_master", "region", "district")
    readonly_fields = ("created_at", "modified_at", "display_proposal", "display_client_card")
    date_hierarchy = "created_at"
    ordering = ("-created_at",)
    list_per_page = 25
    compressed_fields = True
    warn_unsaved_form = True
    inlines = (
        OrderInviteInline,
        OrderResponseInline,
        OrderStageEventInline,
        ChatThreadInline,
    )
    actions = ("mark_cancelled", "mark_expired")

    fieldsets = (
        (None, {"fields": ("client", "display_client_card", "title", "description")}),
        (
            "Holat",
            {
                "fields": (
                    ("status", "is_public", "is_repair"),
                    "stage",
                    "assigned_master",
                    ("expires_at", "completed_at"),
                    "cancelled_reason",
                ),
            },
        ),
        ("Manzil", {"fields": (("region", "district"), "address")}),
        (
            "Hisob va taklif",
            {
                "description": (
                    "Taklif ilovada tasdiqlangan hujjat — buyurtma "
                    "yaratilgandan keyin o'zgartirilmaydi."
                ),
                "fields": ("calculated_price", "display_proposal", "proposal"),
            },
        ),
        ("Sanalar", {"fields": (("created_at", "modified_at"),)}),
    )

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return (
            super()
            .get_queryset(request)
            .select_related(
                "client", "client__region", "client__district", "assigned_master", "region", "district"
            )
            .annotate(_responses=Count("responses", distinct=True))
        )

    def get_search_results(self, request, queryset, search_term):
        """Raqam kiritilsa — buyurtma NOMERI bo'yicha ham topiladi."""
        queryset, may_have_duplicates = super().get_search_results(
            request, queryset, search_term
        )
        term = search_term.strip().lstrip("#")
        if term.isdigit():
            queryset |= self.model.objects.filter(pk=int(term))
        return queryset, may_have_duplicates

    @display(description="Buyurtma", ordering="title", header=True)
    def display_order(self, obj: Order) -> list:
        location = " / ".join(str(p) for p in (obj.region, obj.district) if p)
        return [
            f"#{obj.pk} {obj.title}",
            f"{obj.client} · {location}" if location else str(obj.client),
            f"#{obj.pk}",
        ]

    @display(description="Buyurtmachi", ordering="client__full_name", header=True)
    def display_client(self, obj: Order) -> list:
        """Ism va telefon — ro'yxatning o'zida (kartochkani ochmasdan)."""
        client = obj.client
        return [client.full_name or "Ismsiz", client.phone_number or "telefon yo'q"]

    @display(description="Usta", ordering="assigned_master__full_name", header=True)
    def display_master(self, obj: Order) -> list | str:
        master = obj.assigned_master
        if master is None:
            return "—"
        return [master.full_name or "Ismsiz", master.phone_number or ""]

    @display(description="Buyurtmachi ma'lumoti")
    def display_client_card(self, obj: Order) -> str:
        """Kartochkada: ism, telefon (bosilsa qo'ng'iroq), hudud va profilga havola."""
        client = getattr(obj, "client", None)
        if client is None:
            return "—"
        location = " / ".join(str(p) for p in (client.region, client.district) if p) or "—"
        phone = client.phone_number or ""
        return format_html(
            "<div>{}</div><div><a href='tel:{}'>{}</a></div><div style='color:#6b7280'>{}</div>"
            "<div><a href='{}'>Foydalanuvchi sahifasi →</a></div>",
            client.full_name or "Ismsiz",
            phone,
            phone or "telefon yo'q",
            location,
            reverse("admin:accounts_user_change", args=[client.pk]),
        )

    @display(description="Holat", ordering="status", label=ORDER_STATUS_LABELS)
    def display_status(self, obj: Order) -> tuple[str, str]:
        # (kalit, matn) — kalit rangni, matn ko'rinishni beradi.
        return obj.status, obj.get_status_display()

    @display(description="Bosqich", ordering="stage")
    def display_stage(self, obj: Order) -> str:
        if not obj.stage:
            return "—"
        return f"{obj.stage_step}/{obj.stage_total} · {obj.get_stage_display()}"

    @display(description="Hisob", ordering="calculated_price")
    def display_price(self, obj: Order) -> str:
        return _money(obj.calculated_price)

    @display(description="Javoblar", ordering="_responses")
    def display_responses(self, obj: Order) -> int:
        return obj._responses

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        if change:
            telegram.refresh_order_post(obj.pk)

    @display(description="Muddat", ordering="expires_at")
    def display_expires(self, obj: Order) -> str:
        if obj.is_expired:
            return format_html('<span style="color:#dc2626">muddati o\'tgan</span>')
        return obj.expires_at.strftime("%d.%m.%Y %H:%M")

    @display(description="Taklif tarkibi")
    def display_proposal(self, obj: Order) -> str:
        """JSON'ning o'qiladigan qisqacha ko'rinishi (xom JSON pastda turadi)."""
        if not obj.proposal:
            return "—"
        rows = "".join(
            format_html(
                "<tr><td style='padding:2px 12px 2px 0;color:#6b7280'>{}</td>"
                "<td style='padding:2px 0'>{}</td></tr>",
                key,
                value if not isinstance(value, dict | list) else "…",
            )
            for key, value in obj.proposal.items()
        )
        return format_html("<table>{}</table>", rows)

    @action(description="Bekor qilingan deb belgilash", icon="cancel")
    def mark_cancelled(self, request: HttpRequest, queryset: QuerySet) -> None:
        order_ids = list(queryset.filter(is_public=True, telegram_message_id__isnull=False).values_list("pk", flat=True))
        updated = queryset.update(status=OrderStatus.CANCELLED)
        for order_id in order_ids:
            telegram.refresh_order_post(order_id)
        self.message_user(request, f"{updated} ta buyurtma bekor qilindi.")

    @action(description="Muddati o'tgan deb belgilash", icon="timer_off")
    def mark_expired(self, request: HttpRequest, queryset: QuerySet) -> None:
        stale = queryset.filter(status=OrderStatus.PUBLISHED)
        order_ids = list(stale.filter(is_public=True, telegram_message_id__isnull=False).values_list("pk", flat=True))
        updated = stale.update(
            status=OrderStatus.EXPIRED, expires_at=timezone.now()
        )
        for order_id in order_ids:
            telegram.refresh_order_post(order_id)
        self.message_user(request, f"{updated} ta e'lon muddati yopildi.")


@admin.register(Review)
class ReviewAdmin(ModelAdmin):
    list_display = ("display_review", "display_rating", "comment", "created_at")
    list_display_links = ("display_review",)
    # `rating` — choices'siz butun son, shuning uchun mavjud qiymatlar bo'yicha.
    list_filter = (
        ("rating", AllValuesCheckboxFilter),
        ("created_at", RangeDateTimeFilter),
    )
    search_fields = ("order__title", "master__full_name", "client__full_name", "comment")
    autocomplete_fields = ("order", "master", "client")
    readonly_fields = ("created_at", "modified_at")
    date_hierarchy = "created_at"
    ordering = ("-created_at",)

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return super().get_queryset(request).select_related("order", "master", "client")

    @display(description="Baho", ordering="order__title", header=True)
    def display_review(self, obj: Review) -> list:
        return [
            f"{obj.master} ← {obj.client}",
            f"#{obj.order_id} {obj.order.title}",
            f"{obj.rating}★",
        ]

    @display(
        description="Yulduz",
        ordering="rating",
        label={5: "success", 4: "success", 3: "warning", 2: "danger", 1: "danger"},
    )
    def display_rating(self, obj: Review) -> tuple[int, str]:
        return obj.rating, "★" * obj.rating


# ───────────────────────── Ustaning o'z buyurtmasi ─────────────────────────────


class MasterOrderItemInline(TabularInline):
    model = MasterOrderItem
    extra = 0
    fields = (
        "position",
        "title",
        "material_label",
        "width_mm",
        "height_mm",
        "qty",
    )
    ordering = ("position", "id")
    tab = True


@admin.register(MasterOrder)
class MasterOrderAdmin(ModelAdmin):
    """Ustaning o'z buyurtmasi (marketplace `Order` dan alohida)."""

    list_display = (
        "display_order",
        "display_status",
        "item_count",
        "deadline",
        "created_at",
    )
    list_display_links = ("display_order",)
    list_filter = (
        ("status", ChoicesDropdownFilter),
        ("created_at", RangeDateTimeFilter),
        ("deadline", RangeDateFilter),  # DateField — vaqtsiz
    )
    list_filter_submit = True
    list_fullwidth = True
    search_fields = (
        "customer_name",
        "customer_phone",
        "master__full_name",
        "master__phone_number",
    )
    autocomplete_fields = ("master",)
    readonly_fields = (
        "created_at",
        "modified_at",
        "sync_client_id",
    )
    date_hierarchy = "created_at"
    ordering = ("-created_at",)
    compressed_fields = True
    warn_unsaved_form = True
    inlines = (MasterOrderItemInline,)

    fieldsets = (
        (None, {"fields": ("master", "status", "sync_client_id")}),
        (
            "Buyurtmachi",
            {"fields": ("customer_name", ("customer_phone", "customer_address"))},
        ),
        ("Shartlar", {"fields": (("deadline", "completed_at"), "note")}),
        ("Sanalar", {"fields": (("created_at", "modified_at"),)}),
    )

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return (
            super()
            .get_queryset(request)
            .select_related("master")
            .annotate(_items=Sum("items__qty"))
        )

    def get_search_results(self, request, queryset, search_term):
        """Raqam kiritilsa — buyurtma NOMERI bo'yicha ham topiladi."""
        queryset, may_have_duplicates = super().get_search_results(
            request, queryset, search_term
        )
        term = search_term.strip().lstrip("#")
        if term.isdigit():
            queryset |= self.model.objects.filter(pk=int(term))
        return queryset, may_have_duplicates

    @display(description="Buyurtma", ordering="customer_name", header=True)
    def display_order(self, obj: MasterOrder) -> list:
        return [
            f"#{obj.pk} {obj.customer_name}",
            f"{obj.master} · {obj.customer_phone or 'telefon yo‘q'}",
            (obj.customer_name or "?")[:2].upper(),
        ]

    @display(description="Holat", ordering="status", label=MASTER_ORDER_STATUS_LABELS)
    def display_status(self, obj: MasterOrder) -> tuple[str, str]:
        return obj.status, obj.get_status_display()

    @display(description="Romlar", ordering="_items")
    def item_count(self, obj: MasterOrder) -> int:
        return obj._items or 0


# ─────────────────────────── Biriktirilgan hududlar ───────────────────────────


@admin.register(ExclusiveTerritory)
class ExclusiveTerritoryAdmin(ModelAdmin):
    """Tuman + yo'nalish → usta: shu tumandagi e'lonlar faqat unga boradi."""

    list_display = ("district", "specialty", "master", "created_at")
    list_filter = (("specialty", RelatedDropdownFilter), ("district__region", RelatedDropdownFilter))
    list_filter_submit = True
    list_select_related = ("district", "district__region", "specialty", "master")
    search_fields = ("district__name", "master__phone_number", "master__full_name")
    raw_id_fields = ("master",)
