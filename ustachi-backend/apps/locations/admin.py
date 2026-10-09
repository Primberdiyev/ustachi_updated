from django.contrib import admin
from django.db.models import Count, QuerySet
from django.http import HttpRequest
from unfold.admin import ModelAdmin, TabularInline
from unfold.contrib.filters.admin import RelatedDropdownFilter
from unfold.decorators import display

from apps.locations import models


class CityInline(TabularInline):
    model = models.City
    extra = 0
    fields = ("name",)
    ordering = ("name",)


@admin.register(models.Region)
class RegionAdmin(ModelAdmin):
    list_display = ("name", "city_count", "user_count", "order_count")
    search_fields = ("name",)
    ordering = ("name",)
    inlines = (CityInline,)

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        return (
            super()
            .get_queryset(request)
            .annotate(
                _cities=Count("cities", distinct=True),
                _users=Count("users", distinct=True),
                _orders=Count("orders", distinct=True),
            )
        )

    @display(description="Tumanlar", ordering="_cities")
    def city_count(self, obj: models.Region) -> int:
        return obj._cities

    @display(description="Foydalanuvchilar", ordering="_users")
    def user_count(self, obj: models.Region) -> int:
        return obj._users

    @display(description="Buyurtmalar", ordering="_orders")
    def order_count(self, obj: models.Region) -> int:
        return obj._orders


@admin.register(models.City)
class CityAdmin(ModelAdmin):
    # Viloyat ustuni bo'lmasa bir xil nomli tumanlarni ajratib bo'lmaydi.
    list_display = ("name", "region")
    list_filter = (("region", RelatedDropdownFilter),)
    search_fields = ("name", "region__name")
    autocomplete_fields = ("region",)
    ordering = ("region__name", "name")
    list_per_page = 50
