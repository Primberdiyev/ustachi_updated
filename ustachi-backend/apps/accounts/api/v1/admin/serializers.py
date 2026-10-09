"""Admin panel — foydalanuvchi va usta serializerlari.

Mijoz/usta ilovasidagi serializerlardan ATAYLAB ajratilgan: admin panel
boshqa maydonlarni ko'radi (`is_staff`, `date_joined`, moderatsiya
holati) va ilova javoblarini o'zgartirmasdan rivojlanishi kerak.
"""

from rest_framework import serializers

from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.common.media import absolute_media_url


class AdminUserListSerializer(serializers.ModelSerializer):
    """Jadval qatori — yengil, JOIN'siz maydonlar."""

    roles = serializers.ListField(child=serializers.CharField(), read_only=True)
    photo_url = serializers.SerializerMethodField()
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)
    district_name = serializers.CharField(source="district.name", read_only=True, default=None)

    class Meta:
        model = User
        fields = [
            "id",
            "full_name",
            "phone_number",
            "username",
            "photo_url",
            "roles",
            "is_master",
            "is_active",
            "is_staff",
            "region",
            "region_name",
            "district",
            "district_name",
            "date_joined",
        ]

    def get_photo_url(self, obj) -> str | None:
        return absolute_media_url(obj.photo, self.context.get("request"))


class AdminUserDetailSerializer(AdminUserListSerializer):
    """Kartochka — statistika bilan (queryset annotate qiladi)."""

    orders_count = serializers.IntegerField(read_only=True, default=0)
    reviews_count = serializers.IntegerField(read_only=True, default=0)
    has_master_profile = serializers.SerializerMethodField()

    class Meta(AdminUserListSerializer.Meta):
        fields = AdminUserListSerializer.Meta.fields + [
            "address",
            "is_superuser",
            "last_login",
            "orders_count",
            "reviews_count",
            "has_master_profile",
        ]

    def get_has_master_profile(self, obj) -> bool:
        return hasattr(obj, "master_profile")


class AdminUserUpdateSerializer(serializers.ModelSerializer):
    """Admin qo'lda tahrirlay oladigan maydonlar — ATAYLAB tor ro'yxat.

    Parol, `is_superuser` va `username` bu yerda YO'Q: ular Django admin
    yoki `manage.py` orqali boshqariladi (huquq oshirish yo'lini API'dan
    ochib qo'ymaslik uchun).
    """

    class Meta:
        model = User
        fields = ["full_name", "phone_number", "region", "district", "address"]


class AdminMasterSpecialtySerializer(serializers.ModelSerializer):
    masters_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = MasterSpecialty
        fields = [
            "id",
            "name",
            "code",
            "unit",
            "unit_question",
            "calculator",
            "variant_price_is_material",
            "is_active",
            "order",
            "masters_count",
        ]


class AdminMasterProfileListSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source="user.id", read_only=True)
    full_name = serializers.CharField(source="user.full_name", read_only=True)
    phone_number = serializers.CharField(source="user.phone_number", read_only=True)
    is_active = serializers.BooleanField(source="user.is_active", read_only=True)
    specialty_name = serializers.CharField(source="specialty.name", read_only=True)
    rating_avg = serializers.FloatField(read_only=True, default=None)
    reviews_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = MasterProfile
        fields = [
            "id",
            "user_id",
            "full_name",
            "phone_number",
            "is_active",
            "specialty",
            "specialty_name",
            "experience_years",
            "company_name",
            "is_verified",
            "accepts_orders",
            "rating_avg",
            "reviews_count",
            "created_at",
        ]


class AdminMasterProfileDetailSerializer(AdminMasterProfileListSerializer):
    specialties = AdminMasterSpecialtySerializer(many=True, read_only=True)
    company_logo_url = serializers.SerializerMethodField()
    completed_orders = serializers.IntegerField(read_only=True, default=0)

    class Meta(AdminMasterProfileListSerializer.Meta):
        fields = AdminMasterProfileListSerializer.Meta.fields + [
            "specialties",
            "bio",
            "company_logo_url",
            "completed_orders",
            "updated_at",
        ]

    def get_company_logo_url(self, obj) -> str | None:
        return absolute_media_url(obj.company_logo, self.context.get("request"))
