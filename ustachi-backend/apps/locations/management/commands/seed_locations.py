"""
O'zbekiston viloyat → tuman/shahar katalogini seed qiladi.

Ishlatish:  python manage.py seed_locations
Idempotent: qayta ishga tushirsa dublikat yaratmaydi (nom bo'yicha get_or_create).

Bu katalog usta/mijoz ro'yxatdan o'tishда manzil (viloyat + tuman) tanlash uchun.
"""

from django.core.management.base import BaseCommand
from django.db import transaction

from apps.locations import models

CATALOG: dict[str, list[str]] = {
    "Qoraqalpog'iston Respublikasi": [
        "Nukus shahri", "Amudaryo tumani", "Beruniy tumani", "Bo'zatov tumani",
        "Chimboy tumani", "Ellikqal'a tumani", "Kegeyli tumani", "Mo'ynoq tumani",
        "Nukus tumani", "Qanliko'l tumani", "Qo'ng'irot tumani", "Qorao'zak tumani",
        "Shumanay tumani", "Taxtako'pir tumani", "To'rtko'l tumani", "Xo'jayli tumani",
    ],
    "Andijon viloyati": [
        "Andijon shahri", "Xonobod shahri", "Qorasuv shahri", "Andijon tumani",
        "Asaka tumani", "Baliqchi tumani", "Bo'ston tumani", "Buloqboshi tumani",
        "Izboskan tumani", "Jalaquduq tumani", "Marhamat tumani", "Oltinko'l tumani",
        "Paxtaobod tumani", "Qo'rg'ontepa tumani", "Shahrixon tumani",
        "Ulug'nor tumani", "Xo'jaobod tumani",
    ],
    "Buxoro viloyati": [
        "Buxoro shahri", "Kogon shahri", "Buxoro tumani", "G'ijduvon tumani",
        "Jondor tumani", "Kogon tumani", "Olot tumani", "Peshku tumani",
        "Qorako'l tumani", "Qorovulbozor tumani", "Romitan tumani",
        "Shofirkon tumani", "Vobkent tumani",
    ],
    "Farg'ona viloyati": [
        "Farg'ona shahri", "Marg'ilon shahri", "Qo'qon shahri", "Quvasoy shahri",
        "Beshariq tumani", "Bog'dod tumani", "Buvayda tumani", "Dang'ara tumani",
        "Farg'ona tumani", "Furqat tumani", "O'zbekiston tumani", "Oltiariq tumani",
        "Qo'shtepa tumani", "Quva tumani", "Rishton tumani", "So'x tumani",
        "Toshloq tumani", "Uchko'prik tumani", "Yozyovon tumani",
    ],
    "Jizzax viloyati": [
        "Jizzax shahri", "Arnasoy tumani", "Baxmal tumani", "Do'stlik tumani",
        "Forish tumani", "G'allaorol tumani", "Mirzacho'l tumani", "Paxtakor tumani",
        "Sharof Rashidov tumani", "Yangiobod tumani", "Zafarobod tumani",
        "Zarbdor tumani", "Zomin tumani",
    ],
    "Xorazm viloyati": [
        "Urganch shahri", "Xiva shahri", "Bog'ot tumani", "Gurlan tumani",
        "Hazorasp tumani", "Qo'shko'pir tumani", "Shovot tumani", "Tuproqqal'a tumani",
        "Urganch tumani", "Xiva tumani", "Xonqa tumani", "Yangiariq tumani",
        "Yangibozor tumani",
    ],
    "Namangan viloyati": [
        "Namangan shahri", "Chortoq tumani", "Chust tumani", "Kosonsoy tumani",
        "Mingbuloq tumani", "Namangan tumani", "Norin tumani", "Pop tumani",
        "To'raqo'rg'on tumani", "Uchqo'rg'on tumani", "Uychi tumani",
        "Yangiqo'rg'on tumani",
    ],
    "Navoiy viloyati": [
        "Navoiy shahri", "Zarafshon shahri", "G'ozg'on shahri", "Karmana tumani",
        "Konimex tumani", "Navbahor tumani", "Nurota tumani", "Qiziltepa tumani",
        "Tomdi tumani", "Uchquduq tumani", "Xatirchi tumani",
    ],
    "Qashqadaryo viloyati": [
        "Qarshi shahri", "Shahrisabz shahri", "Chiroqchi tumani", "Dehqonobod tumani",
        "G'uzor tumani", "Kasbi tumani", "Kitob tumani", "Ko'kdala tumani",
        "Koson tumani", "Mirishkor tumani", "Muborak tumani", "Nishon tumani",
        "Qamashi tumani", "Qarshi tumani", "Shahrisabz tumani", "Yakkabog' tumani",
    ],
    "Samarqand viloyati": [
        "Samarqand shahri", "Kattaqo'rg'on shahri", "Bulung'ur tumani",
        "Ishtixon tumani", "Jomboy tumani", "Kattaqo'rg'on tumani", "Narpay tumani",
        "Nurobod tumani", "Oqdaryo tumani", "Pastdarg'om tumani", "Paxtachi tumani",
        "Payariq tumani", "Qo'shrabot tumani", "Samarqand tumani", "Toyloq tumani",
        "Urgut tumani",
    ],
    "Sirdaryo viloyati": [
        "Guliston shahri", "Shirin shahri", "Yangiyer shahri", "Boyovut tumani",
        "Guliston tumani", "Mirzaobod tumani", "Oqoltin tumani", "Sardoba tumani",
        "Sayxunobod tumani", "Sirdaryo tumani", "Xovos tumani",
    ],
    "Surxondaryo viloyati": [
        "Termiz shahri", "Angor tumani", "Bandixon tumani", "Boysun tumani",
        "Denov tumani", "Jarqo'rg'on tumani", "Muzrabot tumani", "Oltinsoy tumani",
        "Qiziriq tumani", "Qumqo'rg'on tumani", "Sariosiyo tumani", "Sherobod tumani",
        "Sho'rchi tumani", "Termiz tumani", "Uzun tumani",
    ],
    "Toshkent viloyati": [
        "Nurafshon shahri", "Angren shahri", "Bekobod shahri", "Chirchiq shahri",
        "Ohangaron shahri", "Olmaliq shahri", "Yangiyo'l shahri", "Bekobod tumani",
        "Bo'ka tumani", "Bo'stonliq tumani", "Chinoz tumani", "O'rtachirchiq tumani",
        "Ohangaron tumani", "Oqqo'rg'on tumani", "Parkent tumani", "Piskent tumani",
        "Qibray tumani", "Quyichirchiq tumani", "Yangiyo'l tumani",
        "Yuqorichirchiq tumani", "Zangiota tumani",
    ],
    "Toshkent shahri": [
        "Bektemir tumani", "Chilonzor tumani", "Mirobod tumani",
        "Mirzo Ulug'bek tumani", "Olmazor tumani", "Sergeli tumani",
        "Shayxontohur tumani", "Uchtepa tumani", "Yakkasaroy tumani",
        "Yashnobod tumani", "Yunusobod tumani",
    ],
}


class Command(BaseCommand):
    help = "O'zbekiston viloyat/tuman katalogini seed qiladi (idempotent)."

    @transaction.atomic
    def handle(self, *args, **options):
        regions_created = districts_created = 0

        for region_name, districts in CATALOG.items():
            region, r_new = models.Region.objects.get_or_create(name=region_name)
            regions_created += int(r_new)

            for district_name in districts:
                _, d_new = models.City.objects.get_or_create(
                    name=district_name, region=region
                )
                districts_created += int(d_new)

        self.stdout.write(
            self.style.SUCCESS(
                f"Tayyor. Viloyat: +{regions_created} (jami "
                f"{models.Region.objects.count()}), "
                f"tuman/shahar: +{districts_created} (jami "
                f"{models.City.objects.filter(region__isnull=False).count()})."
            )
        )
