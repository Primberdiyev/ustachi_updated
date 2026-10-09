"""Manzil katalogi: viloyat (`Region`) → tuman/shahar (`City`).

Ro'yxatdan o'tishda, buyurtmada va biriktirilgan hududlarda ishlatiladi.
"""
from django.db import models


class Region(models.Model):
    name = models.CharField("Nomi", max_length=100, unique=True)

    class Meta:
        verbose_name = "Viloyat"
        verbose_name_plural = "Viloyatlar"
        ordering = ["name"]

    def __str__(self):
        return self.name


class City(models.Model):
    name = models.CharField("Nomi", max_length=100)
    # Viloyatga bog'lanish — tuman/shahar tanlashda kaskad uchun (viloyat →
    # tumanlar).
    region = models.ForeignKey(
        Region,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="cities",
        verbose_name="Viloyat",
    )

    class Meta:
        verbose_name = "Shahar/Tuman"
        verbose_name_plural = "Shahar/Tumanlar"
        ordering = ["name"]

    def __str__(self):
        return self.name
