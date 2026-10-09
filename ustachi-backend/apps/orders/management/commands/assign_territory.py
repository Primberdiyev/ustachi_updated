"""Tuman(lar)dagi bir yo'nalish e'lonlarini bitta ustaga biriktiradi.

    python manage.py assign_territory                      # Farg'ona eshik-rom (4 tuman)
    python manage.py assign_territory --phone +9989... --specialty rom \\
        --region "Farg'ona" --district "Quva tumani" --district "Rishton tumani"
    python manage.py assign_territory --list
"""
from django.core.management.base import BaseCommand, CommandError

from apps.accounts.models import MasterSpecialty, User
from apps.orders.models import ExclusiveTerritory
from apps.orders.territories import FERGANA_ROM_DISTRICTS, FERGANA_ROM_PHONE, find_district, norm
from apps.locations.models import City


class Command(BaseCommand):
    help = "Tuman + yo'nalish e'lonlarini bitta ustaga biriktiradi."

    def add_arguments(self, parser):
        parser.add_argument("--phone", default=FERGANA_ROM_PHONE)
        parser.add_argument("--specialty", default="rom")
        parser.add_argument("--region", default="Farg'ona")
        parser.add_argument("--district", action="append", help="Bir necha marta berish mumkin.")
        parser.add_argument("--list", action="store_true", help="Faqat mavjud biriktirishlarni ko'rsatadi.")

    def handle(self, *args, **options):
        if options["list"]:
            for row in ExclusiveTerritory.objects.select_related("district", "specialty", "master"):
                self.stdout.write(f"{row.district.name} · {row.specialty.code} → {row.master.phone_number}")
            return

        master = User.objects.filter(phone_number__in=[options["phone"], options["phone"].lstrip("+")]).first()
        if master is None:
            raise CommandError(f"Foydalanuvchi topilmadi: {options['phone']}")
        specialty = MasterSpecialty.objects.filter(code=options["specialty"]).first()
        if specialty is None:
            raise CommandError(f"Yo'nalish topilmadi: {options['specialty']}")

        region = norm(options["region"])
        cities = [
            c for c in City.objects.select_related("region")
            if c.region_id and norm(c.region.name).startswith(region)
        ]
        for name in options["district"] or FERGANA_ROM_DISTRICTS:
            city = find_district(cities, name)
            if city is None:
                raise CommandError(f"Tuman/shahar topilmadi: {name}")
            ExclusiveTerritory.objects.update_or_create(
                specialty=specialty, district=city, defaults={"master": master}
            )
            self.stdout.write(self.style.SUCCESS(f"{city.name} · {specialty.code} → {master.phone_number}"))
