from rest_framework import serializers
from rest_framework.fields import empty
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from rest_framework_simplejwt.serializers import TokenRefreshSerializer

from apps.common.media import absolute_media_url
from apps.accounts.models import (
    DeviceToken,
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyNote,
    MasterSpecialtyRate,
    SpecialtyAreaTier,
    SpecialtyBrick,
    SpecialtyRepairProblem,
    SpecialtyVariant,
    MasterWorkSample,
    User,
)
from apps.accounts.models.master import MASTER_UNITS, MAX_SPECIALTY_NOTE


def _validate_region_district(attrs):
    """Tanlangan tuman AYNAN tanlangan viloyatga tegishli bo'lishi shart."""
    region = attrs.get("region")
    district = attrs.get("district")
    if district and region and district.region_id != region.id:
        raise serializers.ValidationError(
            {"district": "Tanlangan tuman bu viloyatga tegishli emas."}
        )
    if district and not region:
        raise serializers.ValidationError(
            {"region": "Tuman tanlansa, viloyat ham tanlanishi shart."}
        )
    return attrs


class SendCodeSerializer(serializers.Serializer):
    """Register va login uchun yagona kirish nuqtasi — faqat telefon raqam."""

    phone_number = serializers.CharField(max_length=20)


class VerifyCodeSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6)


class LoginSerializer(serializers.Serializer):
    """Faqat admin namespace'i uchun — client/master parolsiz kiradi.

    Identifikator — `username`, telefon raqam EMAS: admin `createsuperuser`
    bilan yaratiladi va o'sha buyruq aynan username so'raydi. Telefon esa
    `User` da null bo'lishi mumkin — u OTP oqimi uchun.
    """

    username = serializers.CharField(max_length=50)
    password = serializers.CharField(write_only=True)


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class CustomTokenRefreshSerializer(TokenRefreshSerializer):
    """
    Kengaytirilgan TokenRefreshSerializer:
      1. Foydalanuvchi O'CHIRILGAN bo'lsa (User.DoesNotExist), 500 error emas,
         xavfsiz 401 (InvalidToken) qaytaradi.
      2. Foydalanuvchi hisobi FAOL BO'LMASA (is_active=False), 401 qaytaradi.
      3. Blacklist yoki DB xatolari bo'lganda 500 o'rniga 401 (InvalidToken) qaytaradi.
    """

    def validate(self, attrs):
        try:
            refresh = self.token_class(attrs["refresh"])
        except TokenError:
            raise InvalidToken("Token noto'g'ri yoki muddati tugagan.")

        user_id = refresh.payload.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except (User.DoesNotExist, Exception):
            raise InvalidToken("Foydalanuvchi topilmadi yoki hisob o'chirilgan.")

        if not user.is_active:
            raise InvalidToken("Foydalanuvchi hisobi faollashtirilmagan.")

        try:
            return super().validate(attrs)
        except (User.DoesNotExist, TokenError):
            raise InvalidToken("Token noto'g'ri yoki muddati tugagan.")
        except Exception:
            raise InvalidToken("Tokenni yangilashda xatolik yuz berdi.")


class UserSerializer(serializers.ModelSerializer):
    # Parol faqat admin uchun ma'noga ega (client/master parolsiz kiradi).
    password = serializers.CharField(write_only=True, required=False, min_length=6)
    photo = serializers.ImageField(required=False, allow_null=True)
    # Rollar: hamma "client"; usta bo'lsa "master"; superuser bo'lsa "admin".
    roles = serializers.ReadOnlyField()
    # Ko'rsatish uchun nomlar (ID lar `region`/`district` da).
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)
    district_name = serializers.CharField(
        source="district.name", read_only=True, default=None
    )

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Rasm DOIM to'liq URL bo'lib chiqadi (yozishda ImageField'ligicha
        # qoladi — yuklash oqimi o'zgarmaydi).
        data["photo"] = absolute_media_url(
            instance.photo, self.context.get("request")
        )
        return data

    def validate(self, attrs):
        # PATCH (qisman) — yuborilmagan qiymatni mavjud obyektдан olamiz.
        merged = dict(attrs)
        if self.instance is not None:
            merged.setdefault("region", self.instance.region)
            merged.setdefault("district", self.instance.district)
        _validate_region_district(merged)
        return attrs

    class Meta:
        model = User
        fields = [
            "id",
            "phone_number",
            "full_name",
            "photo",
            "region",
            "district",
            "region_name",
            "district_name",
            "address",
            "roles",
            "is_master",
            "is_superuser",
            "is_active",
            "date_joined",
            "password",
        ]
        read_only_fields = [
            "id",
            "phone_number",
            "region_name",
            "district_name",
            "roles",
            "is_master",
            "is_superuser",
            "is_active",
            "date_joined",
        ]

    def update(self, instance, validated_data):
        password = validated_data.pop("password", None)
        instance = super().update(instance, validated_data)
        if password:
            instance.set_password(password)
            instance.save(update_fields=["password"])
        return instance


# ───────────────── Qurilma tokeni (FCM push) ─────────────────


class DeviceTokenSerializer(serializers.ModelSerializer):
    """Ilova kirgandan keyin FCM tokenini shu yerda ro'yxatdan o'tkazadi."""

    # UNIKALLIK tekshiruvi ATAY olib tashlangan: mavjud token qayta yuborilsa
    # xato emas, YANGILANISH bo'lishi kerak (view `update_or_create` qiladi).
    token = serializers.CharField(max_length=255)

    class Meta:
        model = DeviceToken
        fields = [
            "id", "token", "platform", "device_name", "app", "is_active", "created_at"
        ]
        read_only_fields = ["id", "app", "is_active", "created_at"]


class DeviceTokenDeleteSerializer(serializers.Serializer):
    """Chiqishda (logout) tokenni o'chirish uchun."""

    token = serializers.CharField(max_length=255)


# ───────────────── USTA (master) profili ─────────────────


class SpecialtyAreaTierSerializer(serializers.ModelSerializer):
    """
    Maydon narxining bitta pog'onasi.

    Sonlar SATR emas, RAQAM bo'lib ketadi (`coerce_to_string=False`): ilova
    ularni hisobga darhol qo'shadi, satrni qayta parse qilib o'tirmaydi.
    [up_to_area] `null` — cheksiz pog'ona.
    """

    up_to_area = serializers.DecimalField(
        max_digits=10, decimal_places=2, coerce_to_string=False, allow_null=True
    )
    price = serializers.DecimalField(
        max_digits=12, decimal_places=2, coerce_to_string=False
    )

    class Meta:
        model = SpecialtyAreaTier
        fields = ["up_to_area", "price"]


class SpecialtyVariantSerializer(serializers.ModelSerializer):
    """Mijoz tanlaydigan sifat darajasi (Odatiy/Standart/Premium)."""

    price = serializers.DecimalField(
        max_digits=12, decimal_places=2, coerce_to_string=False
    )

    class Meta:
        model = SpecialtyVariant
        # `id` USTA ilovasiga kerak: u har turga alohida narx saqlaydi
        # (`rates` endpointiga `variant` bo'lib ketadi).
        fields = ["id", "name", "size", "note", "price"]


class SpecialtyBrickSerializer(serializers.ModelSerializer):
    """G'isht turi — material, o'lchamlari (mm) va 1 dona narxi.

    Terish haqi YO'Q: uni har usta o'zi qo'yadi (g'isht turining varianti
    orqali, kafeldagi kabi).
    """

    price = serializers.DecimalField(
        max_digits=12, decimal_places=2, coerce_to_string=False
    )
    mortar_per_brick = serializers.DecimalField(
        max_digits=10, decimal_places=2, coerce_to_string=False
    )
    waste_pct = serializers.DecimalField(
        max_digits=5, decimal_places=2, coerce_to_string=False
    )
    bricks_per_m2_half = serializers.DecimalField(
        max_digits=7, decimal_places=2, coerce_to_string=False, allow_null=True
    )

    class Meta:
        model = SpecialtyBrick
        fields = [
            "id",
            "kind",
            "name",
            "length_mm",
            "width_mm",
            "height_mm",
            "joint_mm",
            "bricks_per_m2_half",
            "price",
            "mortar_per_brick",
            "waste_pct",
        ]


class SpecialtyRepairProblemSerializer(serializers.ModelSerializer):
    """Ta'mirda mijoz belgilaydigan tayyor muammo."""

    class Meta:
        model = SpecialtyRepairProblem
        fields = ["code", "title", "hint"]


class MasterSpecialtySerializer(serializers.ModelSerializer):
    """Yo'nalish katalogi. `code` — ILOVA uchun barqaror kalit (ikonka,
    "rom yo'nalishimi?" tekshiruvi); nom tahrirlansa ham buzilmaydi.

    `unit` + `unit_question` — ustadan narx so'rash uchun (2026-08-13):
    g'ishtda "dona", zinada "metr". Birlik bo'sh bo'lsa narx so'ralmaydi.

    `calculator` + `area_tiers` — MIJOZ ilovasidagi "Narx hisoblash"
    ro'yxati uchun (2026-08-29). Bo'sh `calculator` — yo'nalish u ro'yxatda
    ko'rinmaydi. Eski ilova bu maydonlarni bilmaydi va e'tiborsiz
    qoldiradi, ya'ni yangilanmagan telefonda hech narsa buzilmaydi.
    """

    area_tiers = SpecialtyAreaTierSerializer(many=True, read_only=True)
    variants = SpecialtyVariantSerializer(many=True, read_only=True)
    #: G'isht terish kalkulyatori (2026-09-17).
    bricks = SpecialtyBrickSerializer(many=True, read_only=True)
    #: Ta'mir (2026-10-09): faqat faol muammolar, tartibi bilan.
    repair_problems = serializers.SerializerMethodField()

    def get_repair_problems(self, obj) -> list:
        if not obj.has_repair:
            return []
        rows = [p for p in obj.repair_problems.all() if p.is_active]
        return SpecialtyRepairProblemSerializer(rows, many=True).data

    class Meta:
        model = MasterSpecialty
        fields = [
            "id",
            "code",
            "name",
            "unit",
            "unit_question",
            "calculator",
            "area_tiers",
            "variants",
            "variant_price_is_material",
            "bricks",
            # "Polvon texnika" (2026-09-26): guruh va "birlikni usta
            # tanlaydi". Eski ilovalar bu maydonlarni bilmaydi.
            "group",
            "unit_by_master",
            # Tom, santexnik (2026-09-28): narx o'rniga usta izohi;
            # savol — `unit_question`.
            "note_by_master",
            # Ta'mir (2026-10-09): soha ichida "Yangi ish / Ta'mir" tanlovi.
            "has_repair",
            "repair_problems",
        ]


class MasterSpecialtyRateSerializer(serializers.ModelSerializer):
    """
    Ustaning narxi — yo'nalish (va kerak bo'lsa VARIANT) bo'yicha.

    [variant] — kafeldagi kabi sohalar uchun: usta pol, devor va sokl
    kafeliga UCHTA alohida m² stavka kiritadi, chunki ular bir xil ish
    emas (foydalanuvchi 2026-08-31). Variantsiz sohalarda `null`.
    """

    code = serializers.CharField(source="specialty.code", read_only=True)
    name = serializers.CharField(source="specialty.name", read_only=True)
    #: O'qishda — ko'rinadigan birlik (ustaniki yoki yo'nalishniki).
    #: Yozishda — faqat "birlikni usta tanlaydi" yo'nalishida (texnika).
    unit = serializers.CharField(required=False, allow_blank=True, max_length=20)
    variant_name = serializers.CharField(
        source="variant.name", read_only=True, default=None
    )

    class Meta:
        model = MasterSpecialtyRate
        fields = [
            "specialty",
            "variant",
            "variant_name",
            "code",
            "name",
            "unit",
            "price",
        ]
        read_only_fields = ["code", "name", "variant_name"]
        extra_kwargs = {"variant": {"required": False, "allow_null": True}}

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["unit"] = instance.display_unit
        return data

    def validate(self, attrs):
        """Variant AYNAN shu yo'nalishniki bo'lishi shart."""
        variant = attrs.get("variant")
        specialty = attrs.get("specialty")
        # Birlik: texnikada usta TANLAYDI (ro'yxatdan), boshqa yo'nalishda
        # yo'nalishniki — ilova yuborgan qiymat e'tiborsiz qoladi.
        unit = (attrs.get("unit") or "").strip()
        if specialty is not None and getattr(specialty, "unit_by_master", False):
            if unit not in MASTER_UNITS:
                raise serializers.ValidationError(
                    {"unit": "Birlikni tanlang: " + ", ".join(MASTER_UNITS) + "."}
                )
            attrs["unit"] = unit
        else:
            attrs["unit"] = ""
        from apps.orders import penthouse_pricing
        if penthouse_pricing.applies(specialty, {"variant": getattr(variant, "name", None)}):
            raise serializers.ValidationError({"price": "Penthaus narxiga usta xizmati kiradi; alohida stavka belgilanmaydi."})
        if variant is not None and specialty is not None:
            if variant.specialty_id != specialty.pk:
                raise serializers.ValidationError(
                    {"variant": "Bu variant tanlangan yo'nalishga tegishli emas."}
                )
        return attrs

    def validate_price(self, value):
        if value < 0:
            raise serializers.ValidationError("Narx manfiy bo'lmaydi.")
        # Ma'nosiz kattalikdan himoya (bir birlik uchun 1 mlrd so'm).
        if value > 1_000_000_000:
            raise serializers.ValidationError("Narx juda katta.")
        return value


class MasterSpecialtyNoteSerializer(serializers.ModelSerializer):
    """Ustaning yo'nalish izohi (tom, santexnik) — erkin matn."""

    code = serializers.CharField(source="specialty.code", read_only=True)
    name = serializers.CharField(source="specialty.name", read_only=True)
    text = serializers.CharField(
        allow_blank=True, max_length=MAX_SPECIALTY_NOTE, trim_whitespace=True
    )

    class Meta:
        model = MasterSpecialtyNote
        fields = ["specialty", "code", "name", "text"]
        read_only_fields = ["code", "name"]
        # Yangilashda (profile, specialty) juftligi view'da tekshiriladi.
        validators = []


class MasterWorkSampleSerializer(serializers.ModelSerializer):
    class Meta:
        model = MasterWorkSample
        fields = ["id", "image", "caption", "created_at"]
        read_only_fields = ["id", "created_at"]

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Kontekstda `request` bo'lmasa DRF nisbiy yo'l beradi — ilova esa
        # host'ni bilmaydi va rasm ko'rinmaydi.
        data["image"] = absolute_media_url(
            instance.image, self.context.get("request")
        )
        return data


class _KeptFlag(serializers.BooleanField):
    """
    Profil belgisi — so'rovda KELMASA tegilmaydi.

    DRF multipart (forma) so'rovida yo'q belgini `False` deb o'qiydi
    (`default_empty_html`). "Kasbiy ma'lumot" sahifasi profilni multipart
    POST bilan saqlaydi va bu belgilarni yubormaydi — natijada har saqlashda
    "Buyurtma qabul qilaman", "Ta'mirga chiqaman" va materiallar O'CHIB
    qolardi, ustaga buyurtma kelmay qolardi (2026-09-28 xatosi).
    """

    default_empty_html = empty

    def __init__(self, **kwargs):
        kwargs.setdefault("required", False)
        super().__init__(**kwargs)


class MasterProfileSerializer(serializers.ModelSerializer):
    """MAJBURIY: yo'nalish + experience_years. IXTIYORIY: bio, ish namunalari.

    YO'NALISH IKKI KO'RINISHDA (foydalanuvchi qarori 2026-08-13 — usta bir
    nechta soha tanlay oladi):
      * `specialty`   — ASOSIY yo'nalish (bitta id). ESKI ilovalar faqat
        shuni yuboradi va faqat shuni o'qiydi;
      * `specialties` — BARCHA yo'nalishlar ro'yxati (yangi ilova).

    Yozishda uchala holat ham qabul qilinadi ([_resolve_specialties]).
    """

    specialty = serializers.PrimaryKeyRelatedField(
        queryset=MasterSpecialty.objects.filter(is_active=True),
        required=False,
    )
    specialties = serializers.PrimaryKeyRelatedField(
        queryset=MasterSpecialty.objects.filter(is_active=True),
        many=True,
        required=False,
    )
    specialty_name = serializers.CharField(source="specialty.name", read_only=True)
    specialty_list = MasterSpecialtySerializer(
        source="specialties", many=True, read_only=True
    )
    #: Yo'nalish bo'yicha NARXLAR — o'qish uchun. Yozish alohida
    #: endpointda (`/profile/rates/`): ular ro'yxat bo'lgani uchun
    #: multipart profil so'rovida noqulay bo'lardi.
    rates = MasterSpecialtyRateSerializer(many=True, read_only=True)
    #: Tom, santexnik izohlari — o'qish uchun; yozish `/profile/notes/`.
    notes = MasterSpecialtyNoteSerializer(
        source="specialty_notes", many=True, read_only=True
    )
    work_samples = MasterWorkSampleSerializer(many=True, read_only=True)

    # Kelmasa tegilmaydi (multipart saqlash ularni o'chirib yubormasin).
    accepts_orders = _KeptFlag()
    does_repairs = _KeptFlag()
    does_plastic = _KeptFlag()
    does_aluminium = _KeptFlag()
    does_termo = _KeptFlag()

    class Meta:
        model = MasterProfile
        fields = [
            "id",
            "specialty",
            "specialty_name",
            "specialties",
            "specialty_list",
            "rates",
            "notes",
            "experience_years",
            "bio",
            "company_name",
            "company_logo",
            "work_samples",
            "is_verified",
            "accepts_orders",
            # "Ta'mirga chiqaman" va material tugmachalari (2026-09-21) —
            # ilovadan PATCH qilinadi, shuning uchun read-only EMAS.
            "does_repairs",
            "does_plastic",
            "does_aluminium",
            "does_termo",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "specialty_name",
            "specialty_list",
            "rates",
            "notes",
            "work_samples",
            "is_verified",
            # DIQQAT: `accepts_orders` bu yerda TURMASLIGI kerak — u ilovadagi
            # "Buyurtma qabul qilaman" tugmachasi bilan PATCH qilinadi.
            # Read-only bo'lgani uchun tugmacha serverga hech qachon
            # saqlanmagan edi (xato jimgina yutilardi).
            "created_at",
            "updated_at",
        ]

    def validate_experience_years(self, value):
        if value < 0 or value > 80:
            raise serializers.ValidationError("Tajriba yili 0 dan 80 gacha bo'lishi kerak.")
        return value

    def validate(self, attrs):
        # ⚠️ MULTIPART TUZOG'I: DRF `many=True` maydonni HTML/multipart
        # so'rovda maydon UMUMAN yuborilmagan bo'lsa ham BO'SH RO'YXAT deb
        # o'qiydi (`QueryDict.getlist`). Natijada ESKI ilova (faqat bitta
        # `specialty` yuboradi va multipart bilan ishlaydi) ustaning barcha
        # yo'nalishlarini jimgina O'CHIRIB yuborardi. Shuning uchun: kalit
        # haqiqatan kelmagan bo'lsa — maydonni butunlay tashlaymiz.
        if not attrs.get("specialties") and "specialties" not in self.initial_data:
            attrs.pop("specialties", None)

        # Mavjud profilning ham oxirgi yo'nalishini olib tashlab bo'lmaydi.
        # Maydon yuborilmagan eski ilova/PATCH esa mavjud tanlovni saqlaydi.
        if "specialties" in attrs and not attrs["specialties"]:
            raise serializers.ValidationError(
                {"specialties": "Kamida bitta yo'nalish tanlanishi shart."}
            )

        # Profil YARATILAYOTGANDA kamida bitta yo'nalish bo'lishi shart.
        # (Ikkala maydon ham `required=False` — qaysi biri kelishi ilova
        # versiyasiga bog'liq, shuning uchun tekshiruv shu yerda.)
        if self.instance is None and not attrs.get("specialty") and not attrs.get(
            "specialties"
        ):
            raise serializers.ValidationError(
                {"specialty": "Yo'nalish tanlanmagan."}
            )
        return attrs

    def _resolve_specialties(self, attrs, instance=None):
        """ASOSIY yo'nalishni ro'yxatga moslaydi.

        Uch holat:
          * faqat `specialty` (ESKI ilova) — tegilmaydi; model `save()`
            uni ro'yxatga QO'SHADI (mavjud tanlovni o'chirmaydi);
          * faqat `specialties` (yangi ilova) — asosiy yo'nalish ro'yxat
            ichida bo'lishi kerak, aks holda model `save()` uni qaytarib
            ro'yxatga tiqib qo'yardi (usta o'chirgan soha tirilib qolardi);
          * ikkalasi — aniq berilgan `specialty` ustun.
        """
        specialties = attrs.get("specialties")
        if not specialties or attrs.get("specialty") is not None:
            return attrs
        current = instance.specialty_id if instance else None
        if current is None or current not in {s.pk for s in specialties}:
            attrs["specialty"] = specialties[0]
        return attrs

    def create(self, validated_data):
        return super().create(self._resolve_specialties(validated_data))

    def update(self, instance, validated_data):
        return super().update(
            instance, self._resolve_specialties(validated_data, instance)
        )
