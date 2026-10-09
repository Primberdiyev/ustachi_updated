"""Biriktirilgan hudud — tumandagi bir soha e'lonlari BITTA ustaga boradi."""
from django.db import models


class ExclusiveTerritory(models.Model):
    """
    Tuman + yo'nalish → usta (foydalanuvchi talabi 2026-10-05).

    Shu tumandagi shu yo'nalish OCHIQ e'lonlari faqat biriktirilgan ustaga
    ko'rinadi va bildirishnoma ham faqat unga boradi; boshqa ustalar ularni
    ko'rmaydi. Ustaning o'z viloyati, materiali yoki "ta'mirga chiqaman"
    belgisi bunda tekshirilmaydi — hudud unga atayin berilgan.
    Qoida `apps/orders/visibility.py` da (8-qoida).
    """

    specialty = models.ForeignKey(
        "accounts.MasterSpecialty",
        on_delete=models.CASCADE,
        related_name="exclusive_territories",
        verbose_name="Yo'nalish",
    )
    district = models.ForeignKey(
        "locations.City",
        on_delete=models.CASCADE,
        related_name="exclusive_territories",
        verbose_name="Tuman/shahar",
    )
    master = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="exclusive_territories",
        verbose_name="Usta",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Biriktirilgan hudud"
        verbose_name_plural = "Biriktirilgan hududlar"
        constraints = [
            models.UniqueConstraint(
                fields=["specialty", "district"], name="unique_territory_specialty_district"
            ),
        ]

    def __str__(self):
        return f"{self.district} · {self.specialty} → {self.master}"
