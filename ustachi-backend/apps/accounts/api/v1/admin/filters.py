"""Admin panel jadvallari uchun filtrlar."""

import django_filters
from django.db.models import Q

from apps.accounts.models import MasterProfile, User


class AdminUserFilter(django_filters.FilterSet):
    """`?role=master&is_active=true&joined_from=2026-01-01`"""

    role = django_filters.ChoiceFilter(
        choices=[
            ("client", "Mijoz"),
            ("master", "Usta"),
            ("staff", "Xodim"),
            ("admin", "Admin"),
        ],
        method="filter_role",
        label="Rol",
    )
    joined_from = django_filters.DateFilter(
        field_name="date_joined", lookup_expr="date__gte"
    )
    joined_to = django_filters.DateFilter(
        field_name="date_joined", lookup_expr="date__lte"
    )
    has_phone = django_filters.BooleanFilter(
        field_name="phone_number", lookup_expr="isnull", exclude=True
    )

    class Meta:
        model = User
        fields = ["is_active", "is_master", "is_staff", "region", "district"]

    def filter_role(self, queryset, name, value):
        if value == "master":
            return queryset.filter(is_master=True)
        if value == "staff":
            return queryset.filter(is_staff=True)
        if value == "admin":
            return queryset.filter(is_superuser=True)
        # "client" — hamma foydalanuvchi mijoz (rol modeliga qarang),
        # shuning uchun faqat usta/xodim BO'LMAGANLAR ajratiladi.
        return queryset.filter(is_master=False, is_staff=False)


class AdminMasterProfileFilter(django_filters.FilterSet):
    """`?is_verified=false&specialty=3&region=1`"""

    region = django_filters.NumberFilter(field_name="user__region_id")
    district = django_filters.NumberFilter(field_name="user__district_id")
    is_active = django_filters.BooleanFilter(field_name="user__is_active")
    specialty = django_filters.NumberFilter(method="filter_specialty")
    experience_min = django_filters.NumberFilter(
        field_name="experience_years", lookup_expr="gte"
    )

    class Meta:
        model = MasterProfile
        fields = ["is_verified", "accepts_orders"]

    def filter_specialty(self, queryset, name, value):
        """Asosiy yo'nalish YOKI qo'shimcha yo'nalishlar ichida."""
        return queryset.filter(
            Q(specialty_id=value) | Q(specialties__id=value)
        ).distinct()
