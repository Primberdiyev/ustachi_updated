"""
NAMOYISH (mock) foydalanuvchilari — usta va mijoz akkauntlari.

Ishlatish:
    python manage.py seed_mock_users                 # 24 usta + 12 mijoz
    python manage.py seed_mock_users --masters 40 --clients 20
    python manage.py seed_mock_users --remove        # HAMMASINI o'chirish
    python manage.py seed_mock_users --noinput       # tasdiqsiz (CI/deploy)

Idempotent: qayta ishga tushirilsa dublikat yaratmaydi (username bo'yicha
`get_or_create`) va mavjud yozuvlarni joriy ma'lumot bilan yangilaydi.

⚠️ BU MA'LUMOT SOXTA. Ishlab chiqarish (production) serverida faqat ilova
ochilganda bo'sh ko'rinmasligi uchun vaqtincha turadi. Haqiqiy ustalar
ro'yxatdan o'ta boshlagach `--remove` bilan TO'LIQ o'chirilishi kerak:
Google Play "misleading content" siyosati soxta profillarni taqiqlaydi.

O'CHIRISH KAFOLATI: har bir yozuv `username` da `mock_` prefiksi bilan
belgilanadi. Purge AYNAN shu prefiks bo'yicha ishlaydi, shuning uchun
haqiqiy foydalanuvchiga hech qachon tegmaydi (telefon raqami qo'lda
o'zgartirilgan bo'lsa ham).
"""

import random
import sys

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from apps.accounts.models import (
    MasterProfile,
    MasterSpecialty,
    MasterSpecialtyRate,
    User,
)
from apps.locations.models import City, Region

#: Purge kaliti — BU PREFIKSNI O'ZGARTIRMANG, aks holda eski mock yozuvlar
#: `--remove` bilan o'chmay qoladi.
MOCK_PREFIX = "mock_"

#: Soxta raqamlar: `+998 90 000 XX XX`. Bu blok hech bir operatorga
#: tegishli emas, shuning uchun haqiqiy foydalanuvchi bilan to'qnashmaydi.
MASTER_PHONE_TPL = "+99890000{:04d}"
CLIENT_PHONE_TPL = "+99890001{:04d}"

#: Qayta ishga tushirilganda narxlar sakramasin.
RANDOM_SEED = 20260907

#: Yo'nalish kodi → (eng past, eng yuqori) narx, O'LCHOV BIRLIGIDA (so'm).
#: Bozorga yaqin oraliqlar — mijoz ro'yxatni ko'rganda raqamlar ishonarli
#: chiqsin. Birligi yo'q yo'nalishlar (rom, mebel, landshaft) bu yerda YO'Q:
#: ularda narx so'ralmaydi.
PRICE_RANGES: dict[str, tuple[int, int]] = {
    "tom": (80_000, 200_000),
    "gisht": (800, 2_000),
    "suvoq": (35_000, 80_000),
    "beton": (300_000, 700_000),
    "elektrik": (50_000, 150_000),
    "santexnik": (60_000, 160_000),
    "kafel": (45_000, 90_000),
    "boyoq": (25_000, 60_000),
    "gipskarton": (50_000, 120_000),
    "darvoza": (400_000, 900_000),
    "payvand": (30_000, 90_000),
    "pol": (40_000, 100_000),
    "quduq": (300_000, 800_000),
    "konditsioner": (300_000, 800_000),
    "mardikor": (150_000, 350_000),
    "zina": (200_000, 600_000),
    "parda": (80_000, 200_000),
    "fasad": (90_000, 250_000),
    "bruschatka": (40_000, 90_000),
    "travertin": (120_000, 300_000),
    "asfalt": (70_000, 150_000),
    "hammom": (500_000, 1_500_000),
    "eshik": (150_000, 400_000),
}

#: (ism, asosiy yo'nalish, qo'shimcha yo'nalishlar, tajriba, korxona, izoh)
MASTERS: list[tuple[str, str, tuple[str, ...], int, str, str]] = [
    ("Akmal To'xtayev", "gisht", ("beton",), 12, "Akmal Qurilish",
     "G'isht terish va poydevor ishlari. Toza, o'lchovga rioya qilingan ish."),
    ("Bekzod Rasulov", "elektrik", ("konditsioner",), 8, "Bekzod Elektro",
     "Uy va ofis elektr montaji, shchit yig'ish, konditsioner o'rnatish."),
    ("Sardor Yo'ldoshev", "santexnik", ("hammom",), 10, "",
     "Suv va kanalizatsiya liniyalari, dush kabina o'rnatish."),
    ("Jasur Ergashev", "kafel", ("suvoq",), 15, "Jasur Dekor",
     "Pol, devor va sokl kafeli. Katta formatli plitka bilan ishlayman."),
    ("Nodir Qodirov", "suvoq", ("boyoq", "gipskarton"), 9, "",
     "Mayoq bo'yicha sement suvoq, shpaklyovka va bo'yash."),
    ("Otabek Nazarov", "tom", ("fasad",), 11, "Otabek Tom",
     "Profnastil va cherepitsa bilan tom yopish, fasad qoplash."),
    ("Shuhrat Alimov", "beton", ("bruschatka",), 14, "Shuhrat Beton",
     "Monolit beton, tayanch devor, hovli maydonchalari."),
    ("Farrux Sobirov", "boyoq", ("gipskarton",), 7, "",
     "Dekorativ shtukaturka, vodoemulsiya, potolok bo'yash."),
    ("Ulug'bek Karimov", "gipskarton", ("boyoq",), 6, "",
     "Ko'p pog'onali potolok, ark va nishalar."),
    ("Doniyor Hasanov", "darvoza", ("payvand",), 13, "Doniyor Temir",
     "Darvoza, panjara, naves. Kovka elementlari bilan."),
    ("Rustam Yusupov", "payvand", ("darvoza",), 10, "",
     "Argon va elektr payvand, metall konstruksiya."),
    ("Sanjar Mirzayev", "pol", ("kafel",), 8, "Sanjar Pol",
     "Laminat, parket, natyajnoy potolok."),
    ("Aziz Qurbonov", "quduq", (), 16, "",
     "Ichimlik suvi va drenaj qudug'i qazish, halqa o'rnatish."),
    ("Xurshid Umarov", "konditsioner", ("elektrik",), 5, "Xurshid Klimat",
     "Split tizim o'rnatish, to'ldirish va profilaktika."),
    ("Islom Sattorov", "mardikor", (), 4, "",
     "Yuk tashish, buzish ishlari, hovli tozalash. Jamoa bilan chiqamiz."),
    ("Bahodir Tursunov", "zina", ("payvand",), 12, "Bahodir Zina",
     "Beton va metall zina, panjara bilan."),
    ("Kamol Ismoilov", "parda", (), 6, "Kamol Interyer",
     "Jalyuzi, rulon parda, karniz o'rnatish."),
    ("Alisher Rahimov", "fasad", ("suvoq",), 9, "",
     "Korauf, penoplast va dekorativ fasad."),
    ("Javohir Nurmatov", "bruschatka", ("asfalt",), 7, "",
     "Bruschatka, bordyur, hovli yo'lkalari."),
    ("Ozod Ashurov", "travertin", ("fasad",), 11, "Ozod Tosh",
     "Travertin va marmar bilan qoplash ishlari."),
    ("Sherzod Xolmatov", "asfalt", ("bruschatka",), 15, "Sherzod Yo'l",
     "Hovli va yo'l asfaltlash, tekislash."),
    ("Dilshod Abdullayev", "hammom", ("santexnik",), 8, "",
     "Dush kabina, jakuzi o'rnatish va ulash."),
    ("Anvar Sodiqov", "eshik", ("mebel",), 10, "Anvar Eshik",
     "Yog'och va MDF eshik, o'rnatish bilan."),
    ("Murod Ochilov", "rom", (), 13, "Murod Rom",
     "Plastik va alumin rom, vitraj. O'lchovga chiqaman."),
]

#: Mijoz akkauntlari — ilovada e'lon beruvchi tomon.
CLIENTS: list[str] = [
    "Dilnoza Yusupova", "Feruza Karimova", "Nigora Tosheva",
    "Malika Rahmonova", "Zilola Ergasheva", "Gulnora Sattorova",
    "Umida Qodirova", "Shahnoza Aliyeva", "Ma'mura Xolmatova",
    "Sevara Nazarova", "Nodira Ismoilova", "Kamola Tursunova",
]


def _round_price(value: int) -> int:
    """Narxni ko'zga yoqadigan qilib yaxlitlash (1000 dan katta bo'lsa)."""
    if value >= 100_000:
        return round(value / 10_000) * 10_000
    if value >= 10_000:
        return round(value / 5_000) * 5_000
    if value >= 1_000:
        return round(value / 500) * 500
    return round(value / 100) * 100


class Command(BaseCommand):
    help = "Namoyish uchun soxta usta/mijoz akkauntlarini yaratadi (idempotent)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--masters", type=int, default=len(MASTERS),
            help=f"Nechta usta yaratilsin (maks {len(MASTERS)}).",
        )
        parser.add_argument(
            "--clients", type=int, default=len(CLIENTS),
            help=f"Nechta mijoz yaratilsin (maks {len(CLIENTS)}).",
        )
        parser.add_argument(
            "--remove", action="store_true",
            help="Yaratish o'rniga BARCHA mock yozuvlarni o'chiradi.",
        )
        parser.add_argument(
            "--noinput", "--no-input", "--yes",
            action="store_false", dest="interactive",
            help="Tasdiq so'ramaydi (deploy skriptlari va CI uchun).",
        )

    # ── production himoyasi ──────────────────────────────────────────
    def _confirm_on_production(self, action: str, *, interactive: bool) -> None:
        """DEBUG=False bo'lsa qo'lda tasdiq so'raladi.

        Bu buyruq ATAYLAB production'da ishlaydi (ilova bo'sh ko'rinmasin),
        shuning uchun DEBUG'ni bloklamaymiz — faqat tasodifiy ishga
        tushirishdan himoya qilamiz.

        `sys.stdin.isatty()` SHART: Django test ishga tushiruvchisi DEBUG'ni
        MAJBURAN False qiladi, CI va deploy skriptlarida esa terminal yo'q —
        u yerda savol berilsa buyruq muzlab qolardi.
        """
        if settings.DEBUG or not interactive or not sys.stdin.isatty():
            return
        self.stdout.write(self.style.WARNING(
            f"\n⚠️  DEBUG=False — bu PRODUCTION baza ko'rinadi.\n"
            f"    Amal: {action}\n"
        ))
        if input("    Davom etilsinmi? [yes/N]: ").strip().lower() != "yes":
            raise CommandError("Bekor qilindi.")

    # ── o'chirish ────────────────────────────────────────────────────
    @transaction.atomic
    def _remove(self) -> None:
        qs = User.objects.filter(username__startswith=MOCK_PREFIX)
        total = qs.count()
        if not total:
            self.stdout.write("O'chiriladigan mock yozuv topilmadi.")
            return
        # MasterProfile / MasterSpecialtyRate — CASCADE bilan o'chadi.
        profiles = MasterProfile.objects.filter(user__in=qs).count()
        qs.delete()
        self.stdout.write(self.style.SUCCESS(
            f"O'chirildi: {total} foydalanuvchi, {profiles} usta profili."
        ))

    # ── yaratish ─────────────────────────────────────────────────────
    def _upsert_user(self, *, username, phone, full_name, is_master, rng, districts):
        district = rng.choice(districts) if districts else None
        defaults = {
            "phone_number": phone,
            "full_name": full_name,
            "is_master": is_master,
            "is_active": True,
            "region": district.region if district else None,
            "district": district,
            "address": "",
        }
        user, created = User.objects.get_or_create(
            username=username, defaults=defaults
        )
        if created:
            # Haqiqiy usta/mijoz kabi: parolsiz, faqat OTP bilan kiradi.
            user.set_unusable_password()
            user.save(update_fields=["password"])
        else:
            for field, value in defaults.items():
                setattr(user, field, value)
            user.save(update_fields=list(defaults))
        return user, created

    def _sync_rates(self, profile, specialties, rng) -> int:
        """Ustaning har bir yo'nalishiga narx qo'yadi.

        Qoidalar `MasterRatesView` dagi bilan bir xil:
          * `unit` bo'sh yo'nalishda (rom, mebel, landshaft) narx SAQLANMAYDI;
          * `variant_price_is_material=True` (kafel) — HAR VARIANTGA alohida
            stavka, chunki pol, devor va sokl kafeli bir xil ish emas;
          * qolganlarida bitta stavka (`variant=None`).
        """
        written = 0
        keep: list[int] = []
        for specialty in specialties:
            if not specialty.unit:
                continue
            low, high = PRICE_RANGES.get(specialty.code, (50_000, 150_000))
            targets = (
                list(specialty.variants.all())
                if specialty.variant_price_is_material
                else [None]
            )
            for variant in targets:
                rate, _ = MasterSpecialtyRate.objects.update_or_create(
                    profile=profile,
                    specialty=specialty,
                    variant=variant,
                    defaults={"price": _round_price(rng.randint(low, high))},
                )
                keep.append(rate.pk)
                written += 1
        # Ro'yxatdan chiqib ketgan eski narx osilib qolmasin.
        profile.rates.exclude(pk__in=keep).delete()
        return written

    @transaction.atomic
    def _create(self, n_masters: int, n_clients: int) -> None:
        rng = random.Random(RANDOM_SEED)

        by_code = {s.code: s for s in MasterSpecialty.objects.prefetch_related("variants")}
        if not by_code:
            raise CommandError(
                "Yo'nalish katalogi bo'sh. Avval migratsiyalarni qo'llang."
            )
        districts = list(City.objects.filter(region__isnull=False).select_related("region"))
        if not districts:
            raise CommandError(
                "Manzil katalogi bo'sh. Avval `python manage.py seed_locations`."
            )

        m_new = c_new = rates = 0

        for idx, (name, primary, extras, years, company, bio) in enumerate(
            MASTERS[:n_masters], start=1
        ):
            specialty = by_code.get(primary)
            if specialty is None:
                self.stderr.write(f"  ! yo'nalish topilmadi: {primary} ({name})")
                continue

            user, created = self._upsert_user(
                username=f"{MOCK_PREFIX}master_{idx:03d}",
                phone=MASTER_PHONE_TPL.format(idx),
                full_name=name,
                is_master=True,
                rng=rng,
                districts=districts,
            )
            m_new += int(created)

            profile, _ = MasterProfile.objects.update_or_create(
                user=user,
                defaults={
                    "specialty": specialty,
                    "experience_years": years,
                    "bio": bio,
                    "company_name": company,
                    "is_verified": True,
                    "accepts_orders": True,
                },
            )
            # Asosiy + qo'shimcha yo'nalishlar. `save()` asosiysini o'zi
            # qo'shadi, lekin M2M ni to'liq shu yerda belgilaymiz.
            chosen = [specialty] + [
                by_code[c] for c in extras if c in by_code
            ]
            profile.specialties.set(chosen)
            rates += self._sync_rates(profile, chosen, rng)

        for idx, name in enumerate(CLIENTS[:n_clients], start=1):
            _, created = self._upsert_user(
                username=f"{MOCK_PREFIX}client_{idx:03d}",
                phone=CLIENT_PHONE_TPL.format(idx),
                full_name=name,
                is_master=False,
                rng=rng,
                districts=districts,
            )
            c_new += int(created)

        total = User.objects.filter(username__startswith=MOCK_PREFIX).count()
        self.stdout.write(self.style.SUCCESS(
            f"Tayyor. Usta: +{m_new}, mijoz: +{c_new}, narx yozuvi: {rates}. "
            f"Jami mock foydalanuvchi: {total}."
        ))
        self.stdout.write(
            "O'chirish uchun: python manage.py seed_mock_users --remove"
        )

    def handle(self, *args, **options):
        if options["remove"]:
            self._confirm_on_production(
                "barcha mock foydalanuvchilarni o'chirish",
                interactive=options["interactive"],
            )
            self._remove()
            return

        n_masters = max(0, min(options["masters"], len(MASTERS)))
        n_clients = max(0, min(options["clients"], len(CLIENTS)))
        self._confirm_on_production(
            f"{n_masters} usta + {n_clients} mijoz yaratish",
            interactive=options["interactive"],
        )
        self._create(n_masters, n_clients)
