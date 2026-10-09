"""
DO'KON MODERATORI uchun DEMO hisoblar — Google Play va App Store.

Ikkita hisob, boshqa emas:
    * USTA  — `settings.OTP_DEMO_PHONE`        (kod: `OTP_DEMO_CODE`)
    * MIJOZ — `settings.OTP_DEMO_PHONE_CLIENT` (kod: `OTP_DEMO_CODE_CLIENT`)

Ishlatish:
    python manage.py seed_demo_accounts
    python manage.py seed_demo_accounts --remove
    python manage.py seed_demo_accounts --noinput      # CI/deploy

NEGA KERAK: raqamlar `PhoneOTP.demo_code_for()` da allaqachon ishlaydi, ammo
BAZADA hisob bo'lmasa `verify-code` ularni YANGI foydalanuvchi sifatida
yaratadi (`is_new_user=True`) — moderator ilovaga kirishi bilan bo'sh
ro'yxatdan o'tish oqimiga tushadi va ilovani baholay olmaydi. Bu esa
"couldn't fully evaluate your app" degan rad javobining eng keng tarqalgan
sababi. Hisob oldindan to'ldirilgan bo'lsa `is_new_user=False` qaytadi va
moderator to'g'ridan-to'g'ri ilovaga kiradi.

⚠️ `mock_` EMAS, `demo_` prefiksi ATAYLAB ishlatilgan: `seed_mock_users
--remove` namoyish ustalarini o'chirganda moderatorning kirish hisobi
O'CHIB KETMASLIGI kerak — aks holda ilova do'konda qayta ko'rikdan
o'tolmay qoladi. Ikkala buyruq bir-biriga tegmaydi.
"""

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
from apps.locations.models import City

#: Purge kaliti. `seed_mock_users` dagi `mock_` bilan KESISHMAYDI.
DEMO_PREFIX = "demo_"

DEMO_MASTER_USERNAME = f"{DEMO_PREFIX}master"
DEMO_CLIENT_USERNAME = f"{DEMO_PREFIX}client"

#: Ismlar ataylab "Demo" deb yozilgan: bu hisob mijoz ilovasidagi ommaviy
#: ustalar ro'yxatida ham KO'RINADI, shuning uchun haqiqiy mijoz unga yozib
#: javob kutib qolmasin.
DEMO_MASTER_NAME = "Demo Usta"
DEMO_CLIENT_NAME = "Demo Mijoz"
DEMO_COMPANY = "Ustachi Demo"

#: Moderator ilovaning KENG imkoniyatini ko'rsin:
#:   rom      — chizma ekrani (narx chatda kelishiladi),
#:   kafel    — variantli narx (pol/devor/sokl uchta stavka),
#:   elektrik — oddiy birlik narxi (nuqta).
DEMO_PRIMARY_CODE = "rom"
DEMO_EXTRA_CODES = ("kafel", "elektrik")

#: Variantli yo'nalishda har variantga, qolganida yo'nalishning o'ziga.
DEMO_PRICES = {"kafel": 70_000, "elektrik": 90_000}

#: Moderator O'zbekistonning istalgan nuqtasidan tekshiradi — poytaxt
#: eng neytral tanlov.
PREFERRED_DISTRICTS = ["Yunusobod tumani", "Chilonzor tumani", "Mirobod tumani"]


class Command(BaseCommand):
    help = "Do'kon moderatori uchun 2 ta demo hisob yaratadi (usta + mijoz)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--remove", action="store_true",
            help="Demo hisoblarni o'chiradi.",
        )
        parser.add_argument(
            "--noinput", "--no-input", "--yes",
            action="store_false", dest="interactive",
            help="Tasdiq so'ramaydi (deploy skriptlari va CI uchun).",
        )

    # ── production himoyasi (seed_mock_users bilan bir xil qoida) ────
    def _confirm_on_production(self, action: str, *, interactive: bool) -> None:
        if settings.DEBUG or not interactive or not sys.stdin.isatty():
            return
        self.stdout.write(self.style.WARNING(
            f"\n⚠️  DEBUG=False — bu PRODUCTION baza ko'rinadi.\n"
            f"    Amal: {action}\n"
        ))
        if input("    Davom etilsinmi? [yes/N]: ").strip().lower() != "yes":
            raise CommandError("Bekor qilindi.")

    def _pick_district(self):
        """Poytaxt tumani, topilmasa istalgan bog'langan tuman."""
        for name in PREFERRED_DISTRICTS:
            district = City.objects.filter(
                name=name, region__isnull=False
            ).select_related("region").first()
            if district is not None:
                return district
        return (
            City.objects.filter(region__isnull=False)
            .select_related("region")
            .first()
        )

    def _upsert(self, *, username, phone, full_name, is_master, district):
        defaults = {
            "phone_number": phone,
            "full_name": full_name,
            "is_master": is_master,
            "is_active": True,
            "region": district.region if district else None,
            "district": district,
        }
        user, created = User.objects.get_or_create(
            username=username, defaults=defaults
        )
        if created:
            # Haqiqiy usta/mijoz kabi parolsiz: kirish faqat OTP orqali.
            user.set_unusable_password()
            user.save(update_fields=["password"])
        else:
            for field, value in defaults.items():
                setattr(user, field, value)
            user.save(update_fields=list(defaults))
        return user, created

    @transaction.atomic
    def _remove(self) -> None:
        qs = User.objects.filter(username__startswith=DEMO_PREFIX)
        total = qs.count()
        if not total:
            self.stdout.write("O'chiriladigan demo hisob topilmadi.")
            return
        qs.delete()
        self.stdout.write(self.style.SUCCESS(f"O'chirildi: {total} demo hisob."))
        self.stdout.write(self.style.WARNING(
            "⚠️  Ilova hali do'kon ko'rigida bo'lsa, moderator KIRA OLMAYDI."
        ))

    @transaction.atomic
    def _create(self) -> None:
        master_phone = getattr(settings, "OTP_DEMO_PHONE", "")
        client_phone = getattr(settings, "OTP_DEMO_PHONE_CLIENT", "")
        if not master_phone or not client_phone:
            raise CommandError(
                "OTP_DEMO_PHONE va OTP_DEMO_PHONE_CLIENT sozlanmagan (.env)."
            )
        if master_phone == client_phone:
            raise CommandError(
                "OTP_DEMO_PHONE va OTP_DEMO_PHONE_CLIENT bir xil bo'lmasin: "
                "do'kon ikkala ilovani alohida hisob bilan tekshiradi."
            )

        district = self._pick_district()
        if district is None:
            raise CommandError(
                "Manzil katalogi bo'sh. Avval `python manage.py seed_locations`."
            )

        by_code = {
            s.code: s
            for s in MasterSpecialty.objects.prefetch_related("variants")
        }
        primary = by_code.get(DEMO_PRIMARY_CODE)
        if primary is None:
            raise CommandError(
                f"'{DEMO_PRIMARY_CODE}' yo'nalishi katalogda yo'q. "
                "Avval migratsiyalarni qo'llang."
            )

        # ── USTA ────────────────────────────────────────────────────
        master, m_new = self._upsert(
            username=DEMO_MASTER_USERNAME,
            phone=master_phone,
            full_name=DEMO_MASTER_NAME,
            is_master=True,
            district=district,
        )
        profile, _ = MasterProfile.objects.update_or_create(
            user=master,
            defaults={
                "specialty": primary,
                "experience_years": 10,
                "bio": "Do'kon ko'rigi uchun namoyish hisobi. "
                       "Kafel va elektrik narxlari to'ldirilgan.",
                "company_name": DEMO_COMPANY,
                "is_verified": True,
                # Moderator yangi e'lon oqimini ham ko'ra olsin.
                "accepts_orders": True,
            },
        )
        chosen = [primary] + [by_code[c] for c in DEMO_EXTRA_CODES if c in by_code]
        profile.specialties.set(chosen)

        keep: list[int] = []
        for specialty in chosen:
            if not specialty.unit:
                continue  # rom — birligi yo'q, narx so'ralmaydi
            price = DEMO_PRICES.get(specialty.code, 100_000)
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
                    defaults={"price": price},
                )
                keep.append(rate.pk)
        profile.rates.exclude(pk__in=keep).delete()

        # ── MIJOZ ───────────────────────────────────────────────────
        _, c_new = self._upsert(
            username=DEMO_CLIENT_USERNAME,
            phone=client_phone,
            full_name=DEMO_CLIENT_NAME,
            is_master=False,
            district=district,
        )

        created = int(m_new) + int(c_new)
        self.stdout.write(self.style.SUCCESS(
            f"Tayyor. Demo hisob: +{created} yangi, jami 2 ta."
        ))
        self._print_credentials(master_phone, client_phone)

    def _print_credentials(self, master_phone: str, client_phone: str) -> None:
        """Play Console'ga ko'chirib qo'yish uchun tayyor blok."""
        master_code = getattr(settings, "OTP_DEMO_CODE", "777777")
        client_code = getattr(settings, "OTP_DEMO_CODE_CLIENT", "888888")
        line = "─" * 58
        self.stdout.write(
            f"\n{line}\n"
            f"  PLAY CONSOLE → App content → App access\n"
            f"{line}\n"
            f"  Ustachi Pro (usta ilovasi)\n"
            f"      Telefon : {master_phone}\n"
            f"      SMS kod : {master_code}\n\n"
            f"  Ustachi (mijoz ilovasi)\n"
            f"      Telefon : {client_phone}\n"
            f"      SMS kod : {client_code}\n"
            f"{line}\n"
            f"  Izoh (moderatorga): kodni SMS orqali kutmang — bu raqamlar\n"
            f"  uchun kod O'ZGARMAYDI va yuqorida berilgan.\n"
            f"{line}\n"
        )

    def handle(self, *args, **options):
        if options["remove"]:
            self._confirm_on_production(
                "demo hisoblarni o'chirish", interactive=options["interactive"]
            )
            self._remove()
            return

        self._confirm_on_production(
            "2 ta demo hisob yaratish", interactive=options["interactive"]
        )
        self._create()
