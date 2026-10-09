from django.contrib import admin, messages
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.db.models import Avg, Count, QuerySet
from django.http import HttpRequest
from django.utils.html import format_html
from unfold.admin import ModelAdmin, StackedInline, TabularInline
from unfold.contrib.filters.admin import (
    BooleanRadioFilter,
    RangeDateTimeFilter,
    RelatedDropdownFilter,
)
from unfold.decorators import action, display
from unfold.forms import AdminPasswordChangeForm, UserChangeForm, UserCreationForm

from apps.accounts.models import (
    CalculatorKind,
    DeviceToken,
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyNote,
    MasterSpecialtyRate,
    MasterWorkSample,
    SpecialtyAreaTier,
    SpecialtyBrick,
    SpecialtyRepairProblem,
    SpecialtyVariant,
    User,
)
from apps.accounts.services import area_pricing

# Django `Group` ni ham Unfold uslubida ko'rsatish uchun qayta ro'yxatdan
# o'tkazamiz — aks holda u yolg'iz "eski" jadval bo'lib qoladi.
from django.contrib.auth.models import Group

admin.site.unregister(Group)


@admin.register(Group)
class GroupAdmin(ModelAdmin):
    list_display = ("name", "permission_count")
    search_fields = ("name",)
    filter_horizontal = ("permissions",)

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return super().get_queryset(request).annotate(_perms=Count("permissions"))

    @display(description="Huquqlar", ordering="_perms")
    def permission_count(self, obj: Group) -> int:
        return obj._perms


class MasterProfileInline(StackedInline):
    """Usta profili — foydalanuvchi sahifasidan turib tahrirlanadi."""

    model = MasterProfile
    extra = 0
    can_delete = False
    autocomplete_fields = ("specialty",)
    fields = (
        ("specialty", "experience_years"),
        ("is_verified", "accepts_orders"),
        "bio",
        ("company_name", "company_logo"),
    )
    tab = True


class DeviceTokenInline(TabularInline):
    model = DeviceToken
    extra = 0
    fields = ("platform", "app", "device_name", "is_active", "last_seen_at")
    readonly_fields = ("app", "last_seen_at")
    tab = True


@admin.register(User)
class UserAdmin(BaseUserAdmin, ModelAdmin):
    """
    Mijoz/usta/admin — bitta model. Rol bayroqlari: `is_master`, `is_superuser`
    (mijozlik hammada bor, alohida bayroq yo'q — qarang `User.roles`).
    """

    form = UserChangeForm
    add_form = UserCreationForm
    change_password_form = AdminPasswordChangeForm

    list_display = (
        "display_user",
        "display_roles",
        "display_location",
        "is_active",
        "display_joined",
    )
    list_filter = (
        ("is_master", BooleanRadioFilter),
        ("is_active", BooleanRadioFilter),
        ("is_superuser", BooleanRadioFilter),
        ("region", RelatedDropdownFilter),
        ("date_joined", RangeDateTimeFilter),
    )
    list_filter_submit = True
    list_display_links = ("display_user",)
    search_fields = ("phone_number", "full_name", "username")
    ordering = ("-date_joined",)
    autocomplete_fields = ("region", "district")
    filter_horizontal = ("groups", "user_permissions")
    readonly_fields = ("date_joined", "last_login")
    date_hierarchy = "date_joined"
    list_per_page = 50
    compressed_fields = True
    warn_unsaved_form = True
    inlines = (MasterProfileInline, DeviceTokenInline)
    actions = ("activate_users", "deactivate_users")

    fieldsets = (
        (None, {"fields": ("username", "phone_number", "password")}),
        ("Shaxsiy ma'lumot", {"fields": ("full_name", "photo")}),
        ("Manzil", {"fields": (("region", "district"), "address")}),
        # Rollar: hamma mijoz; usta = is_master; admin = is_superuser.
        (
            "Rol va holat",
            {
                "fields": (
                    ("is_master", "is_active"),
                    ("is_staff", "is_superuser"),
                ),
            },
        ),
        (
            "Huquqlar",
            {"classes": ("collapse",), "fields": ("groups", "user_permissions")},
        ),
        ("Sanalar", {"fields": (("date_joined", "last_login"),)}),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("username", "phone_number", "usable_password", "password1", "password2"),
            },
        ),
    )

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return (
            super()
            .get_queryset(request)
            .select_related("region", "district", "master_profile")
        )

    @display(description="Foydalanuvchi", ordering="full_name", header=True)
    def display_user(self, obj: User) -> list:
        initials = (obj.full_name or obj.username or "?")[:2].upper()
        return [
            obj.full_name or "(ism kiritilmagan)",
            obj.phone_number or obj.username,
            initials,
            {"path": obj.photo.url} if obj.photo else None,
        ]

    # Bir nechta yorliq bir vaqtda ko'rsatilganda Unfold rangni ajrata olmaydi
    # (`display_for_label` lug'atni faqat BITTA qiymat uchun qo'llaydi), shuning
    # uchun bu ustun neytral uslubda.
    @display(description="Rollar", label=True)
    def display_roles(self, obj: User) -> list[str]:
        labels = {"client": "Mijoz", "master": "Usta", "admin": "Admin"}
        return [labels[role] for role in obj.roles]

    @display(description="Hudud", ordering="region__name")
    def display_location(self, obj: User) -> str:
        parts = [str(p) for p in (obj.region, obj.district) if p]
        return " / ".join(parts) or "—"

    @display(description="Ro'yxatdan o'tgan", ordering="date_joined")
    def display_joined(self, obj: User) -> str:
        return obj.date_joined.strftime("%d.%m.%Y %H:%M")

    @action(description="Faollashtirish", icon="check_circle")
    def activate_users(self, request: HttpRequest, queryset: QuerySet) -> None:
        updated = queryset.update(is_active=True)
        self.message_user(request, f"{updated} ta foydalanuvchi faollashtirildi.")

    @action(description="Faolsizlantirish", icon="block")
    def deactivate_users(self, request: HttpRequest, queryset: QuerySet) -> None:
        updated = queryset.update(is_active=False)
        self.message_user(request, f"{updated} ta foydalanuvchi faolsizlantirildi.")


class SpecialtyAreaTierInline(TabularInline):
    """
    MAYDON NARXLARI — mijoz ilovasidagi kalkulyator aynan shulardan hisoblaydi.

    Pog'ona TANLANADI, ustiga qo'shilmaydi: maydon qaysi pog'onaga tushsa,
    butun maydon o'sha stavkada. "Shu maydongacha" ni BO'SH qoldirish —
    cheksiz pog'ona (eng kattalari uchun), u har yo'nalishda bo'lishi shart.
    """

    model = SpecialtyAreaTier
    extra = 0
    fields = ("up_to_area", "price")
    ordering = ("up_to_area",)
    tab = True


class SpecialtyVariantInline(TabularInline):
    """
    VARIANTLAR — mijoz tanlaydigan sifat darajalari (Odatiy/Standart/
    Premium). Har birining O'Z m² narxi bor.

    Maydon narxidan farqi: u yerda stavkani maydon belgilaydi, bu yerda
    mijozning O'ZI tanlaydi. "Izoh" — kartadagi bir qatorlik farq
    («1 qanotli laminatsiya»), mijoz shusiz uchta narx orasidan taxminan
    tanlardi.
    """

    model = SpecialtyVariant
    extra = 0
    fields = ("order", "name", "size", "note", "price")
    ordering = ("order", "price")
    tab = True


class SpecialtyBrickInline(TabularInline):
    """
    G'ISHT TURLARI — «G'isht terish» kalkulyatori shulardan hisoblaydi.

    O'lchamlar mm da. 1 m² devordagi g'isht soni — "1 m² ga" ustunidan
    (amaliyot), u bo'sh bo'lsa o'lchamlar va chokdan. Mijoz faqat material
    narxini ko'radi; terish haqini har usta o'zi qo'yadi — shu jadvaldagi
    har tur uchun «Variantlar»da avtomatik qator paydo bo'ladi.
    """

    model = SpecialtyBrick
    extra = 0
    fields = (
        "order", "kind", "name", "length_mm", "width_mm", "height_mm", "joint_mm",
        "bricks_per_m2_half", "price", "mortar_per_brick", "waste_pct",
    )
    ordering = ("order", "price")
    tab = True


class SpecialtyRepairProblemInline(TabularInline):
    """
    TA'MIR MUAMMOLARI — mijoz "Ta'mir"ni tanlaganda ko'radigan tayyor
    variantlar ("Kran oqyapti"). «Ta'mir bor» belgilanganda ishlaydi.
    "Boshqa muammo" bandini ilova o'zi qo'shadi.
    """

    model = SpecialtyRepairProblem
    extra = 0
    fields = ("title", "hint", "code", "order", "is_active")
    ordering = ("order", "id")
    tab = True


@admin.register(MasterSpecialty)
class MasterSpecialtyAdmin(ModelAdmin):
    """YO'NALISHLAR KATALOGI — yangi soha SHU YERDAN qo'shiladi.

    Ilovalarga migratsiya kerak emas: katalog serverdan o'qiladi, notanish
    `code` uchun ilova umumiy ikonka ko'rsatadi. Qoidalar:
      * `code` — lotincha qisqa kalit (mas. `parda`); saqlangach
        O'ZGARTIRMANG — ilovalar ikonkani shu bo'yicha tanlaydi;
      * `unit` (dona/m²/metr/nuqta/kun) to'ldirilsa usta profilida
        "qanchadan ishlaysiz?" so'raladi; bo'sh qolsa narx so'ralmaydi
        (narx chatda kelishiladi);
      * `calculator` to'ldirilsa yo'nalish mijozdagi "Narx hisoblash"
        ro'yxatida chiqadi (pastdagi izohga qarang);
      * soha kerak bo'lmasa O'CHIRMANG — "Faol"ni oling (unga usta va
        buyurtmalar bog'langan bo'lishi mumkin).
    """

    inlines = (
        SpecialtyAreaTierInline,
        SpecialtyVariantInline,
        SpecialtyBrickInline,
        SpecialtyRepairProblemInline,
    )
    list_display = (
        "name",
        "code",
        "unit",
        "calculator_label",
        "master_count",
        "is_active",
        "order",
    )
    list_editable = ("is_active", "order")
    list_filter = (("is_active", BooleanRadioFilter), "calculator", "group")
    search_fields = ("name", "code")
    ordering = ("order", "name")
    fieldsets = (
        (None, {"fields": ("name", "code", "order", "is_active", "group")}),
        (
            "Ta'mir",
            {
                "fields": ("has_repair",),
                "description": "Belgilansa mijoz bu sohada «Yangi ish / Ta'mir» "
                "tanlovini ko'radi. Muammolar ro'yxati — pastdagi «Ta'mir "
                "muammolari» bo'limida.",
            },
        ),
        (
            "Narx so'rovi (ixtiyoriy)",
            {
                "fields": ("unit", "unit_question", "unit_by_master", "note_by_master"),
                "description": "Birlik to'ldirilsa usta profilida narx "
                "so'raladi va u mijozga ko'rinadi. Savolni soha tilida "
                "yozing: «Bitta g'ishtni qanchadan terasiz?»<br>"
                "<b>Birlikni usta tanlaydi</b> (texnika) belgilansa — birlik "
                "bo'sh qoladi, har usta o'zi tanlaydi (soat, reys, km...).<br>"
                "<b>Narx o'rniga usta izohi</b> belgilansa — narx so'ralmaydi, "
                "usta savolga erkin matnda javob yozadi (tom, santexnik...).",
            },
        ),
        (
            "Mijozdagi narx kalkulyatori",
            {
                "fields": ("calculator", "variant_price_is_material"),
                "description": (
                    "To'ldirilsa yo'nalish mijoz ilovasidagi «Narx hisoblash» "
                    "ro'yxatida chiqadi.<br>"
                    "<b>Maydon (m²)</b> tanlansa — «Maydon narxlari» "
                    "jadvalini to'ldiring. Pog'ona <b>tanlanadi</b>, ustiga "
                    "qo'shilmaydi: 100 m² gacha 100 000 so'm/m² va cheksiz "
                    "75 000 so'm/m² bo'lsa, 150 m² = 150 × 75 000.<br>"
                    "<b>Variant</b> tanlansa — «Variantlar» jadvalini "
                    "to'ldiring (Odatiy/Standart/Premium). Stavkani mijoz "
                    "TANLAYDI, keyin maydonni kiritadi.<br>"
                    "<b>«Variant narxi — material tannarxi»</b> belgilansa "
                    "(kafel): ko'rsatilgan narx faqat material bo'ladi, "
                    "ish haqini har usta O'ZI qo'yadi — kafelchi pol/devor/"
                    "sokl uchun uchta alohida m² stavka kiritadi.<br>"
                    "<b>G'isht terish</b> tanlansa — «G'isht turlari» "
                    "jadvalini to'ldiring: material, o'lchami (mm) va 1 dona "
                    "narxi. «Variant narxi — material tannarxi» belgilangan "
                    "bo'lsin — terish haqini har usta o'zi qo'yadi."
                ),
            },
        ),
    )

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        # Ustalar soni — M2M bo'yicha (usta bir nechta yo'nalishda bo'lishi
        # mumkin; asosiy yo'nalish ham shu ro'yxatda turadi).
        return super().get_queryset(request).annotate(_masters=Count("masters"))

    @display(description="Ustalar", ordering="_masters")
    def master_count(self, obj: MasterSpecialty) -> int:
        return obj._masters

    @display(description="Kalkulyator", ordering="calculator")
    def calculator_label(self, obj: MasterSpecialty) -> str:
        return obj.get_calculator_display() if obj.calculator else "—"

    def save_related(self, request, form, formsets, change):
        """
        Narxlar saqlangach SOZLAMANI TEKSHIRAMIZ.

        Jadval xato to'ldirilsa (cheksiz pog'ona yo'q) mijozga narx umuman
        ko'rsatilmaydi — buni admin SAQLAGAN ZAHOTI bilishi kerak, oradan
        bir hafta o'tib "nega asfalt narxi chiqmayapti?" degan savol
        kelgunicha emas.
        """
        super().save_related(request, form, formsets, change)
        obj = form.instance

        if obj.calculator == CalculatorKind.VARIANT:
            if not obj.variants.exists():
                self.message_user(
                    request,
                    "«Variantlar» jadvali bo'sh — mijozga narx "
                    "ko'rsatilmaydi. Kamida bitta variant qo'shing.",
                    level=messages.WARNING,
                )
            return

        if obj.calculator == CalculatorKind.MASONRY:
            if not obj.bricks.exists():
                self.message_user(
                    request,
                    "«G'isht turlari» jadvali bo'sh — mijozga narx "
                    "ko'rsatilmaydi. Kamida bitta g'isht turini qo'shing.",
                    level=messages.WARNING,
                )
            return

        if obj.calculator != CalculatorKind.AREA:
            return

        tiers = area_pricing.tiers_for(obj)
        if not tiers:
            self.message_user(
                request,
                "«Maydon narxlari» jadvali bo'sh — mijozga narx "
                "ko'rsatilmaydi. Kamida bitta pog'ona qo'shing.",
                level=messages.WARNING,
            )
            return
        for warning in area_pricing.tier_warnings(tiers):
            self.message_user(request, warning, level=messages.WARNING)


class MasterSpecialtyNoteInline(TabularInline):
    """Ustaning yo'nalish izohlari (tom, santexnik...) — narx o'rniga."""

    model = MasterSpecialtyNote
    extra = 0
    fields = ("specialty", "text")
    autocomplete_fields = ("specialty",)
    tab = True


class MasterSpecialtyRateInline(TabularInline):
    """Ustaning yo'nalish narxlari (g'isht donasi, zina metri...)."""

    model = MasterSpecialtyRate
    extra = 0
    fields = ("specialty", "unit", "price")
    autocomplete_fields = ("specialty",)
    tab = True


class MasterWorkSampleInline(TabularInline):
    model = MasterWorkSample
    extra = 0
    fields = ("preview", "image", "caption", "created_at")
    readonly_fields = ("preview", "created_at")
    tab = True

    @display(description="Ko'rinishi")
    def preview(self, obj: MasterWorkSample) -> str:
        if not obj.pk or not obj.image:
            return "—"
        return format_html(
            '<img src="{}" style="height:48px;border-radius:4px;object-fit:cover" />',
            obj.image.url,
        )


@admin.register(MasterProfile)
class MasterProfileAdmin(ModelAdmin):
    list_display = (
        "display_master",
        "specialty",
        "experience_years",
        "display_rating",
        "display_verified",
        "accepts_orders",
        "created_at",
    )
    list_filter = (
        ("specialty", RelatedDropdownFilter),
        ("is_verified", BooleanRadioFilter),
        ("accepts_orders", BooleanRadioFilter),
        # Ta'mirga chiqadigan ustalarni ajratib ko'rish uchun (2026-09-21).
        ("does_repairs", BooleanRadioFilter),
        ("created_at", RangeDateTimeFilter),
    )
    list_filter_submit = True
    list_display_links = ("display_master",)
    search_fields = ("user__phone_number", "user__full_name", "company_name")
    autocomplete_fields = ("user", "specialty")
    filter_horizontal = ("specialties",)
    readonly_fields = ("created_at", "updated_at")
    date_hierarchy = "created_at"
    compressed_fields = True
    warn_unsaved_form = True
    inlines = (MasterSpecialtyRateInline, MasterSpecialtyNoteInline, MasterWorkSampleInline)
    actions = ("verify_profiles",)

    fieldsets = (
        (
            None,
            {
                "fields": (
                    "user",
                    "specialty",
                    "specialties",
                    "experience_years",
                    "bio",
                )
            },
        ),
        ("Holat", {"fields": (("is_verified", "accepts_orders", "does_repairs"),)}),
        ("Korxona", {"fields": (("company_name", "company_logo"),)}),
        ("Sanalar", {"fields": (("created_at", "updated_at"),)}),
    )

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return (
            super()
            .get_queryset(request)
            .select_related("user", "specialty")
            .annotate(
                _rating=Avg("user__received_reviews__rating"),
                _reviews=Count("user__received_reviews", distinct=True),
            )
        )

    @display(description="Usta", ordering="user__full_name", header=True)
    def display_master(self, obj: MasterProfile) -> list:
        return [
            obj.user.full_name or obj.user.username,
            obj.user.phone_number or "",
            (obj.user.full_name or "?")[:2].upper(),
            {"path": obj.user.photo.url} if obj.user.photo else None,
        ]

    @display(description="Reyting", ordering="_rating")
    def display_rating(self, obj: MasterProfile) -> str:
        if not obj._rating:
            return "—"
        return f"{obj._rating:.1f}★ ({obj._reviews})"

    @display(
        description="Tasdiq",
        label={"Tasdiqlangan": "success", "Kutilmoqda": "warning"},
    )
    def display_verified(self, obj: MasterProfile) -> str:
        return "Tasdiqlangan" if obj.is_verified else "Kutilmoqda"

    @action(description="Tasdiqlash", icon="verified")
    def verify_profiles(self, request: HttpRequest, queryset: QuerySet) -> None:
        updated = queryset.update(is_verified=True)
        self.message_user(request, f"{updated} ta usta profili tasdiqlandi.")
