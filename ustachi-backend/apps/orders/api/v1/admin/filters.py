"""Admin panel — buyurtma va baho filtrlari."""

import django_filters

from apps.orders.models import Order, Review


class AdminOrderFilter(django_filters.FilterSet):
    """`?status=published&region=1&created_from=2026-09-01&price_min=1000000`"""

    created_from = django_filters.DateFilter(
        field_name="created_at", lookup_expr="date__gte"
    )
    created_to = django_filters.DateFilter(
        field_name="created_at", lookup_expr="date__lte"
    )
    price_min = django_filters.NumberFilter(
        field_name="calculated_price", lookup_expr="gte"
    )
    price_max = django_filters.NumberFilter(
        field_name="calculated_price", lookup_expr="lte"
    )
    client = django_filters.NumberFilter(field_name="client_id")
    master = django_filters.NumberFilter(field_name="assigned_master_id")

    class Meta:
        model = Order
        fields = ["status", "stage", "specialty", "region", "district", "is_public"]


class AdminReviewFilter(django_filters.FilterSet):
    """`?rating_max=2` — past baholarni moderatsiya qilish uchun."""

    rating_min = django_filters.NumberFilter(field_name="rating", lookup_expr="gte")
    rating_max = django_filters.NumberFilter(field_name="rating", lookup_expr="lte")
    created_from = django_filters.DateFilter(
        field_name="created_at", lookup_expr="date__gte"
    )
    created_to = django_filters.DateFilter(
        field_name="created_at", lookup_expr="date__lte"
    )
    has_comment = django_filters.BooleanFilter(method="filter_has_comment")

    class Meta:
        model = Review
        fields = ["rating", "master", "client"]

    def filter_has_comment(self, queryset, name, value):
        if value:
            return queryset.exclude(comment="")
        return queryset.filter(comment="")
