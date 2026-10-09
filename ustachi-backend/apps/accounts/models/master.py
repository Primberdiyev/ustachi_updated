"""
Usta (master) profili — `is_master=True` foydalanuvchining kasbiy ma'lumoti.

MAJBURIY: yo'nalish (specialty) + tajriba yili.
IXTIYORIY: qisqacha izoh (bio) va ish namunalari — keyin ham qo'shsa bo'ladi.
"""

from decimal import Decimal

from django.db import models

from apps.accounts.models.user import User


#: Platformaning YO'NALISH katalogi (foydalanuvchi talabi 2026-08-13):
#: (tartib, kod, nom, o'lchov birligi, ustaga beriladigan savol).
#:
#: `code` — ILOVALAR uchun BARQAROR kalit: ikonka tanlash va "bu rom
#: yo'nalishimi?" tekshiruvi nom bo'yicha emas, shu kod bo'yicha qilinadi
#: (nom tahrirlansa ham ilova buzilmaydi).
#:
#: `unit` — usta narxini QAYSI o'lchovda aytishi (2026-08-13 kengaytmasi):
#: g'ishtda DONA, zinada METR, elektrikda NUQTA, polda KVADRAT METR...
#: Shu birlik bilan mijoz ustalarni taqqoslay oladi. Birlik bo'sh bo'lsa
#: (rom, mebel) narx so'ralmaydi — har safar loyihaga qarab kelishiladi.
SPECIALTY_CATALOG = [
    (2, "penthaus_gidro_tom", "Penthaus gidro tom", "", ""),
    (1, "rom", "Alyumin va PVX eshik va rom ustasi", "", ""),
    (2, "tom", "Tom yopish ustasi", "m²",
     "Tom yopishning bir kvadrat metrini qanchadan olasiz?"),
    (3, "gisht", "G'isht teruvchi", "dona",
     "Bitta g'ishtni qanchadan terasiz?"),
    (4, "suvoq", "Suvoqchi (shtukatur-sement)", "m²",
     "Suvoqning bir kvadrat metri qancha turadi?"),
    (5, "beton", "Beton ishlari ustasi", "m³",
     "Betonning bir kub metri qancha turadi?"),
    (6, "elektrik", "Elektrik", "nuqta",
     "Bitta nuqta (rozetka/vklyuchatel) qancha turadi?"),
    (7, "santexnik", "Santexnik", "nuqta",
     "Bitta nuqta (ulanish) qancha turadi?"),
    (8, "kafel", "Kafel-plitka ustasi", "m²",
     "Kafel yotqizishning bir kvadrat metri qancha?"),
    (9, "boyoq", "Bo'yoqchi (malyar)", "m²",
     "Bo'yashning bir kvadrat metri qancha?"),
    (10, "gipskarton", "Gipskarton ustasi", "m²",
     "Gipskartonning bir kvadrat metri qancha?"),
    (11, "mebel", "Mebel ustasi", "", ""),
    (12, "darvoza", "Darvoza-panjara ustasi (temirchi)", "m²",
     "Darvoza-panjaraning bir kvadrat metri qancha?"),
    (13, "payvand", "Payvandchi", "metr",
     "Payvandning bir metri qancha turadi?"),
    # POL va POTOLOK — BITTA soha (foydalanuvchi qarori 2026-08-14).
    (14, "pol", "Pol-potolok ustasi", "m²",
     "Pol yoki potolok ishining bir kvadrat metri qancha?"),
    (15, "quduq", "Quduq qazish ustasi", "metr",
     "Quduqning bir metrini qanchadan qazasiz?"),
    (16, "konditsioner", "Konditsioner o'rnatish", "dona",
     "Bitta konditsioner o'rnatish qancha turadi?"),
    (17, "mardikor", "Kunlik ishchilar (mardikor)", "kun",
     "Bir kunlik ish haqingiz qancha?"),
    (18, "zina", "Zina ustasi", "metr",
     "Zinaning bir metri qancha turadi?"),
    # 2026-08-14 kengaytmasi (foydalanuvchi ro'yxati).
    (19, "parda", "Jalyuzi-parda xizmati", "m²",
     "Jalyuzi-parda o'rnatishning bir kvadrat metri qancha?"),
    (20, "fasad", "Fasad ustasi", "m²",
     "Fasad ishining bir kvadrat metri qancha?"),
    (21, "bruschatka", "Bruschatka ustasi", "m²",
     "Bruschatka yotqizishning bir kvadrat metri qancha?"),
    (22, "travertin", "Travertin ustasi", "m²",
     "Travertin ishining bir kvadrat metri qancha?"),
    # Landshaft — loyihaga qarab (gul, archa, maysazor): birlik YO'Q,
    # narx chatda kelishiladi (mebel kabi).
    (23, "landshaft", "Landshaft xizmati (gul, archa)", "", ""),
    (24, "asfalt", "Asfalt ustasi", "m²",
     "Asfalt yotqizishning bir kvadrat metri qancha?"),
    (25, "hammom", "Hammom (dush kabinasi)", "dona",
     "Bitta dush kabinasi o'rnatish qancha turadi?"),
    # Kuzatuv kamerasi (foydalanuvchi talabi 2026-10-02): birlik YO'Q —
    # mijoz buyurtma beradi, narx chatda kelishiladi (mebel kabi).
    (26, "kamera", "Kuzatuv kamerasi o'rnatish va ta'mirlash", "", ""),
]

#: Eshik-rom yo'nalishining kodi (sohasiz eski e'lonlar shunga tushadi).
ROM_SPECIALTY_CODE = "rom"

#: "POLVON TEXNIKA" guruhi (usta qarori 2026-09-26) — qurilish texnikasi:
#: ekskavator, kran, samosval... Mijoz ilovasida bitta plita ostida
#: jamlanadi.
TEXNIKA_GROUP = "texnika"

#: Texnika egasi narxni QAYSI birlikda aytishi mumkin — o'zi tanlaydi
#: (usta qarori 2026-09-26: "biz hech qanday narx qo'ymaymiz, texnika
#: egalari soatga ishlaydimi, metrgami, masofagami — o'zlari belgilasin").
MASTER_UNITS = ("soat", "kun", "reys", "metr", "km", "m³", "tonna")

#: Bitta texnikaga ko'pi bilan shuncha birlik: masalan "soatiga + km ga"
#: (ish vaqtga ham, masofaga ham bog'liq bo'lsa).
MAX_MASTER_UNITS = 2


class CalculatorKind(models.TextChoices):
    """
    MIJOZ ILOVASIDAGI KALKULYATOR — yo'nalishda qaysi ekran ochiladi.

    Mijoz "Narx hisoblash" tugmasini bosganda AYNAN shu maydoni to'ldirilgan
    yo'nalishlar ro'yxati chiqadi. Bo'sh bo'lsa yo'nalish u yerda
    ko'rinmaydi — buyurtma narxsiz beriladi va narx chatda kelishiladi.

    Yangi kalkulyator qo'shilganda bu ro'yxatga bitta qator qo'shiladi va
    ilovada o'sha kod uchun ekran yoziladi. Ilova NOTANISH kodni jimgina
    o'tkazib yuboradi (eski ilova yangi serverdan buzilmaydi).
    """

    NONE = "", "Yo'q — narx chatda kelishiladi"
    ROM = "rom", "Rom (chizma ekrani: shakl va o'lcham)"
    AREA = "area", "Maydon (m² bo'yicha pog'onali narx)"
    VARIANT = "variant", "Variant (Odatiy/Standart/Premium — har biri o'z m² narxida)"
    MASONRY = "masonry", "G'isht terish (devor o'lchami → g'isht soni va narxi)"
    ROOF = "roof", "Tom yopish (uy o'lchami → tom maydoni va material narxi)"
    BETON = "beton", "Poydevor (uy o'lchami → beton kubi va armatura)"
    ELECTRICAL = "electrical", "Elektr montaj (materiallar hisobi)"
    HEATING = "heating", "Uyni isitish (xonalar → radiator, truba, kotyol)"


class MasterSpecialty(models.Model):
    """Usta yo'nalishi (soha) — rom, tom yopish, g'isht terish, ..."""

    UZ_TITLE = "Usta yo'nalishi"

    name = models.CharField(max_length=100, unique=True, verbose_name="Nomi")
    #: Ilovalar shu kod bilan ishlaydi (ikonka, rom tekshiruvi). `null` —
    #: faqat adminkada kodsiz yaratilgan qator; katalog seed'i hammasini to'ldiradi.
    code = models.SlugField(
        max_length=40, unique=True, null=True, blank=True, verbose_name="Kod"
    )
    #: Narx O'LCHOVI: "dona", "m²", "metr", "nuqta", "kun"... Bo'sh bo'lsa
    #: bu yo'nalishda narx so'ralmaydi (rom, mebel — har loyihaga qarab
    #: kelishiladi).
    unit = models.CharField(
        max_length=20, blank=True, default="", verbose_name="O'lchov birligi"
    )
    #: Ustaga beriladigan SAVOL ("Bitta g'ishtni qanchadan terasiz?").
    #: Ilovada aynan shu matn ko'rinadi — soha tilida so'ralsa usta
    #: o'ylab o'tirmaydi.
    unit_question = models.CharField(
        max_length=140, blank=True, default="", verbose_name="Narx savoli"
    )
    is_active = models.BooleanField(default=True, verbose_name="Faol")
    order = models.PositiveSmallIntegerField(default=0, verbose_name="Tartib")
    #: Mijoz ilovasidagi narx kalkulyatori ([CalculatorKind]). Bo'sh bo'lsa
    #: yo'nalish "Narx hisoblash" ro'yxatida KO'RINMAYDI.
    calculator = models.CharField(
        max_length=16,
        blank=True,
        default="",
        choices=CalculatorKind.choices,
        verbose_name="Narx kalkulyatori",
    )
    #: VARIANT narxi nimani anglatadi.
    #:
    #: `False` (odatiy) — narx YAKUNIY: mijoz ko'rgan raqam to'lanadigan
    #: summa (yog'och eshik shunday).
    #:
    #: `True` — narx faqat MATERIAL tannarxi, ish haqi ustiga qo'shiladi:
    #: usta har variantga O'Z m² stavkasini kiritadi
    #: (`MasterSpecialtyRate.variant`) va mijoz javob kelganda
    #: "material + usta stavkasi" bo'lib jamini ko'radi. Kafel shunday
    #: (foydalanuvchi qarori 2026-08-31).
    variant_price_is_material = models.BooleanField(
        default=False,
        verbose_name="Variant narxi — material tannarxi",
        help_text="Belgilansa: ko'rsatilgan narx faqat material. Usta har "
        "variantga o'z m² stavkasini kiritadi va mijoz javob kelganda "
        "jamini ko'radi.",
    )

    #: Guruh: bo'sh — oddiy yo'nalish; [TEXNIKA_GROUP] — "Polvon texnika".
    group = models.CharField(
        max_length=30, blank=True, default="", verbose_name="Guruh"
    )
    #: Narx BIRLIGINI har usta O'ZI tanlaydi ([MASTER_UNITS], ko'pi bilan
    #: [MAX_MASTER_UNITS] ta). Texnika shunday: biri soatiga, biri reysiga
    #: ishlaydi. Bunda [unit] bo'sh qoladi.
    unit_by_master = models.BooleanField(
        default=False,
        verbose_name="Birlikni usta tanlaydi",
        help_text="Belgilansa: har usta o'zi birlik tanlaydi (soat, reys, km...) "
        "va narxini yozadi.",
    )

    #: Narx katakchalari O'RNIGA usta O'Z IZOHINI yozadi (savol —
    #: [unit_question]). Tom va santexnikada turlari ko'p, har biriga
    #: alohida narx so'rash ustani charchatardi (usta qarori 2026-09-28):
    #: "Qanday tomni necha pulga yopasiz?" — erkin matn, mijozga ko'rinadi.
    note_by_master = models.BooleanField(
        default=False,
        verbose_name="Narx o'rniga usta izohi",
        help_text="Belgilansa: ustadan narx so'ralmaydi, u o'z xizmati va "
        "narxlarini erkin matnda yozadi.",
    )

    #: TA'MIR (2026-10-09): mijoz bu sohada "Yangi ish" bilan birga
    #: "Ta'mir"ni ham tanlay oladi — kalkulyatorsiz, o'lchovsiz qisqa
    #: e'lon. Muammolar ro'yxati — [SpecialtyRepairProblem].
    has_repair = models.BooleanField(
        default=False,
        verbose_name="Ta'mir bor",
        help_text="Belgilansa: mijoz soha ichida «Yangi ish / Ta'mir» tanlovini "
        "ko'radi. Ta'mirda narx hisoblanmaydi — usta ko'rib aytadi.",
    )

    @property
    def asks_rate(self) -> bool:
        """Bu yo'nalishda ustadan narx so'raladimi."""
        if self.note_by_master:
            return False
        if self.unit_by_master:
            return True
        return self.code != "penthaus_gidro_tom" and bool(self.unit)

    @property
    def has_calculator(self) -> bool:
        """Mijoz bu yo'nalishda narxni ilovada hisoblay oladimi."""
        return bool(self.calculator)

    class Meta:
        ordering = ["order", "name"]
        verbose_name = "Usta yo'nalishi"
        verbose_name_plural = "Usta yo'nalishlari"

    def __str__(self):
        return self.name


class SpecialtyRepairProblem(models.Model):
    """
    Ta'mirda mijoz belgilaydigan tayyor muammo ("Kran oqyapti").

    Ro'yxat adminkadan boshqariladi — yangi variant uchun ilovani
    yangilash kerak emas. "Boshqa muammo" bandini ilova o'zi qo'shadi.
    Eshik-rom ro'yxati tarixan ilova ichida (ikonkalari bilan) turadi.
    """

    specialty = models.ForeignKey(
        "MasterSpecialty",
        on_delete=models.CASCADE,
        related_name="repair_problems",
        verbose_name="Yo'nalish",
    )
    #: E'lon suratiga yoziladi (`proposal["repair_problems"]`) — o'zgartirmang.
    code = models.SlugField(max_length=40, verbose_name="Kod")
    title = models.CharField(max_length=80, verbose_name="Nomi")
    hint = models.CharField(max_length=140, blank=True, default="", verbose_name="Izoh")
    order = models.PositiveSmallIntegerField(default=0, verbose_name="Tartib")
    is_active = models.BooleanField(default=True, verbose_name="Faol")

    class Meta:
        ordering = ["order", "id"]
        verbose_name = "Ta'mir muammosi"
        verbose_name_plural = "Ta'mir muammolari"
        constraints = [
            models.UniqueConstraint(
                fields=["specialty", "code"], name="unique_repair_problem_code"
            ),
        ]

    def __str__(self):
        return self.title


class SpecialtyAreaTier(models.Model):
    """
    MAYDON BO'YICHA NARX POG'ONASI — `calculator="area"` yo'nalishlari uchun
    (asfalt, kelajakda bruschatka, beton maydon...).

    Qoida (foydalanuvchi qarori 2026-08-29): pog'ona TANLANADI, ustiga
    qo'shilmaydi. Ya'ni maydon qaysi pog'onaga tushsa, BUTUN maydon o'sha
    stavkada hisoblanadi:

        100 m² gacha — 100 000 so'm/m²   →   80 m²  = 8 000 000
        undan yuqori —  75 000 so'm/m²   →  150 m²  = 11 250 000

    [up_to_area] — pog'onaning YUQORI chegarasi, SHU SON HAM KIRADI
    ("100 m² gacha" = 100 ham shu pog'onada). Bo'sh qoldirilsa — cheksiz,
    ya'ni oxirgi pog'ona. Har yo'nalishda cheksiz pog'ona BITTA bo'ladi,
    aks holda katta maydonga narx topilmay qolardi.
    """

    UZ_TITLE = "Maydon narxi"

    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.CASCADE,
        related_name="area_tiers",
        verbose_name="Yo'nalish",
    )
    up_to_area = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        verbose_name="Shu maydongacha (m²)",
        help_text="Shu son ham kiradi. Bo'sh qoldirilsa — cheksiz "
        "(eng katta maydonlar uchun oxirgi pog'ona).",
    )
    price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        verbose_name="1 m² narxi (so'm)",
    )

    class Meta:
        verbose_name = "Maydon narxi"
        verbose_name_plural = "Maydon narxlari"
        # Cheksiz pog'ona (`up_to_area=None`) OXIRIDA tursin: SQLite ham,
        # PostgreSQL ham `F(...).asc(nulls_last=True)` ni tushunadi.
        ordering = [models.F("up_to_area").asc(nulls_last=True)]
        constraints = [
            models.UniqueConstraint(
                fields=["specialty", "up_to_area"],
                name="uniq_specialty_area_tier",
            ),
            models.CheckConstraint(
                condition=models.Q(price__gte=0), name="area_tier_price_gte_0"
            ),
        ]

    def __str__(self):
        limit = f"{self.up_to_area:g} m² gacha" if self.up_to_area else "cheksiz"
        return f"{self.specialty} — {limit}: {self.price:g} so'm/m²"


class SpecialtyVariant(models.Model):
    """
    SIFAT DARAJASI — `calculator="variant"` yo'nalishlari uchun
    (yog'och eshik: Odatiy / Standart / Premium).

    Maydon narxidan (`SpecialtyAreaTier`) farqi: u yerda stavkani MAYDON
    belgilaydi, bu yerda esa MIJOZ TANLAYDI. Ikkalasi ham m² narxi, lekin
    savol boshqa — "qancha joyga?" emas, "qaysi darajada?".

    [note] — kartadagi bir qatorlik izoh ("1 qanotli laminatsiya"): mijoz
    darajalar farqini shu yerdan biladi, aks holda uchta narx orasidan
    tanlash taxminга aylanardi.
    """

    UZ_TITLE = "Variant"

    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.CASCADE,
        related_name="variants",
        verbose_name="Yo'nalish",
    )
    name = models.CharField(max_length=60, verbose_name="Nomi")
    #: Mahsulot o'lchami — "40×40 sm". Kafelda mijoz uchun muhim belgi,
    #: eshikda esa kerak emas: bo'sh qoldirilsa ko'rsatilmaydi.
    size = models.CharField(
        max_length=40, blank=True, default="", verbose_name="O'lchami",
        help_text="Masalan «40×40 sm». Bo'sh qoldirilsa ko'rsatilmaydi.",
    )
    note = models.CharField(
        max_length=140,
        blank=True,
        default="",
        verbose_name="Izoh",
        help_text="Mijozga ko'rinadigan bir qatorlik farq: "
        "«1 qanotli laminatsiya».",
    )
    price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        verbose_name="1 m² narxi (so'm)",
    )
    order = models.PositiveSmallIntegerField(default=0, verbose_name="Tartib")

    class Meta:
        verbose_name = "Variant"
        verbose_name_plural = "Variantlar"
        ordering = ["order", "price"]
        constraints = [
            models.UniqueConstraint(
                fields=["specialty", "name"], name="uniq_specialty_variant_name"
            ),
            models.CheckConstraint(
                condition=models.Q(price__gte=0), name="variant_price_gte_0"
            ),
        ]

    def __str__(self):
        return f"{self.specialty} — {self.name}: {self.price:g} so'm/m²"


class SpecialtyBrick(models.Model):
    """
    G'ISHT TURI — `calculator="masonry"` yo'nalishlari uchun (g'isht terish).

    Mijoz savollarda nima qurishini (bino / zabor), materialni va devor
    o'lchamini beradi. Ilova 1 m² devordagi g'isht sonini hisoblaydi
    (usta qarori 2026-09-17):

        [bricks_per_m2_half] to'ldirilgan bo'lsa — AMALIYOTDAGI son:
            pishgan g'isht 250×125×88 → yarim 40 · bir 80 · bir yarim 120
        bo'sh bo'lsa — o'lchamdan:
            yarim g'ishtlar soni / ((uzunlik+chok) × (balandlik+chok))

    Jami songa singan g'isht uchun [waste_pct] foiz qo'shiladi.

    MIJOZ faqat g'isht sonini va MATERIAL tannarxini ko'radi ([price] —
    1 dona). TERISH HAQINI har usta O'Z ilovasida qo'yadi: har g'isht turi
    uchun yo'nalishga bitta [variant] avtomatik yaratiladi va usta ilovasi
    kafeldagi kabi "qaysi turini qanchadan olasiz?" deb so'raydi. Usta javob
    berganda mijoz "material + teriladigan g'isht × ustaning 1 dona narxi"ni
    ko'radi (`apps/orders/response_total.py`).
    """

    UZ_TITLE = "G'isht turi"

    class Kind(models.TextChoices):
        """
        MATERIAL — mijoz savollarida shu bo'yicha tanlaydi (usta qarori
        2026-09-17). Qaysi material qayerga mos (bino / zabor) — ilovada:
        shlakoblok FAQAT zabor uchun taklif qilinadi.
        """

        PISHGAN = "pishgan", "Pishgan g'isht"
        XOM = "xom", "Xom g'isht"
        PENOBLOK = "penoblok", "Penoblok"
        SHLAKOBLOK = "shlakoblok", "Shlakoblok"

    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.CASCADE,
        related_name="bricks",
        verbose_name="Yo'nalish",
    )
    kind = models.CharField(
        max_length=20,
        choices=Kind.choices,
        default=Kind.PISHGAN,
        verbose_name="Material",
    )
    name = models.CharField(max_length=60, verbose_name="Nomi")
    length_mm = models.PositiveSmallIntegerField(default=250, verbose_name="Uzunligi (mm)")
    width_mm = models.PositiveSmallIntegerField(default=125, verbose_name="Eni (mm)")
    height_mm = models.PositiveSmallIntegerField(
        default=88, verbose_name="Bo'yi (mm)",
        help_text="Terimdagi bir qator balandligi.",
    )
    joint_mm = models.PositiveSmallIntegerField(
        default=10, verbose_name="Chok (mm)",
        help_text="G'ishtlar orasidagi qorishma qalinligi.",
    )
    bricks_per_m2_half = models.DecimalField(
        max_digits=7,
        decimal_places=2,
        null=True,
        blank=True,
        verbose_name="1 m² ga, yarim g'ishtda (dona)",
        help_text="Amaliyotdagi son, chok bilan. Bir g'isht — 2 barobar, "
        "bir yarim — 3 barobar. Bo'sh qolsa o'lchamlardan hisoblanadi.",
    )
    price = models.DecimalField(
        max_digits=12, decimal_places=2, verbose_name="1 dona narxi (so'm)"
    )
    #: Usta ma'lumoti (2026-09-17): 1 kamaz qum 1 500 000 + 1 t ohak
    #: 1 300 000 + 1 t sement 800 000 = 3 600 000 so'm → 30 000 pishgan
    #: g'isht, ya'ni 1 donaga 120 so'm.
    mortar_per_brick = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0,
        verbose_name="Qorishma, 1 dona terimga (so'm)",
        help_text="Qum, ohak, sement narxi ÷ shu qorishmaga teriladigan "
        "g'isht soni. Singan g'ishtga qo'shilmaydi.",
    )
    #: Usta qarori (2026-09-17): singan g'isht uchun 1,8%.
    waste_pct = models.DecimalField(
        max_digits=5, decimal_places=2, default=Decimal("1.8"),
        verbose_name="Singan g'isht zaxirasi (%)",
    )
    order = models.PositiveSmallIntegerField(default=0, verbose_name="Tartib")
    #: Usta shu tur uchun terish narxini qo'yadigan variant — avtomatik.
    variant = models.OneToOneField(
        SpecialtyVariant,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        editable=False,
        related_name="brick",
        verbose_name="Usta narxi uchun tur",
    )

    class Meta:
        verbose_name = "G'isht turi"
        verbose_name_plural = "G'isht turlari"
        ordering = ["order", "price"]
        constraints = [
            models.UniqueConstraint(
                fields=["specialty", "name"], name="uniq_specialty_brick_name"
            ),
            models.CheckConstraint(
                condition=models.Q(price__gte=0, waste_pct__gte=0),
                name="brick_prices_gte_0",
            ),
        ]

    @property
    def size_label(self) -> str:
        return f"{self.length_mm}×{self.width_mm}×{self.height_mm} mm"

    def save(self, *args, **kwargs):
        """
        Usta narxi uchun variantni shu g'isht turi bilan BIR XIL tutamiz:
        nomi (javobdagi jami narx shu nom bo'yicha topiladi), o'lchami va
        tartibi. Variant narxi — material narxi (usta ilovasida ko'rinmaydi).
        """
        super().save(*args, **kwargs)
        variant = self.variant
        if variant is None:
            variant = SpecialtyVariant.objects.filter(
                specialty=self.specialty, name=self.name
            ).first() or SpecialtyVariant(specialty=self.specialty)
        variant.name = self.name
        variant.size = self.size_label
        variant.price = self.price
        variant.order = self.order
        variant.save()
        if self.variant_id != variant.pk:
            self.variant = variant
            super().save(update_fields=["variant"])

    def delete(self, *args, **kwargs):
        variant = self.variant
        result = super().delete(*args, **kwargs)
        if variant is not None:
            variant.delete()
        return result

    def __str__(self):
        return f"{self.specialty} — {self.name} {self.size_label}: {self.price:g} so'm/dona"


class MasterProfile(models.Model):
    UZ_TITLE = "Usta profili"

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="master_profile",
        verbose_name="Foydalanuvchi",
    )
    #: ASOSIY yo'nalish. [specialties] paydo bo'lgandan keyin ham QOLDI:
    #: ommaviy kartalar va eski ilovalar shu bitta qiymat bilan ishlaydi
    #: (u DOIM [specialties] ning a'zosi bo'ladi — serializer shuni ta'minlaydi).
    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.PROTECT,
        related_name="profiles",
        verbose_name="Asosiy yo'nalish",
    )
    #: Ustaning BARCHA yo'nalishlari (foydalanuvchi qarori 2026-08-13: usta
    #: bir nechta soha tanlay oladi). Buyurtma FAQAT shu ro'yxatga tushgan
    #: ustalarga ko'rinadi va push shu bo'yicha yuboriladi.
    specialties = models.ManyToManyField(
        MasterSpecialty,
        related_name="masters",
        blank=True,
        verbose_name="Yo'nalishlar",
    )
    experience_years = models.PositiveSmallIntegerField(verbose_name="Tajriba (yil)")
    bio = models.TextField(blank=True, default="", verbose_name="Qisqacha izoh")
    # Tekshiruv savollaridan o'tgach True bo'ladi.
    is_verified = models.BooleanField(default=False, verbose_name="Tasdiqlangan")
    #: Usta yangi buyurtmalarni QABUL QILYAPTIMI (ilovadagi tugmacha).
    #: False bo'lsa yangi e'lon haqida PUSH bormaydi — lekin bildirishnomalar
    #: ro'yxatida va ochiq e'lonlar feed'ida KO'RINAVERADI (usta o'zi qarab
    #: chiqib, xohlasa javob beradi).
    accepts_orders = models.BooleanField(
        default=True,
        verbose_name="Buyurtma qabul qiladi",
        help_text="O'chirilsa yangi e'lon haqida push kelmaydi (ro'yxatda ko'rinadi).",
    )
    # ── QAYSI MATERIALDA ISHLAYDI (foydalanuvchi talabi 2026-09-21) ──
    # Har usta uchala materialni ham ko'tarmaydi: "men termo eshik yasay
    # olmayman" (usta so'zi). O'chirilgan materialdagi ROM e'loni shu
    # ustaga KO'RINMAYDI va push ham bormaydi
    # (`apps/orders/visibility.py`, `proposal["material"]` bo'yicha:
    # 0 plastik, 1 alyuminiy, 2 termo).
    #
    # Hammasi DEFAULT YOQIQ — eski ustalar xulqi o'zgarmaydi.
    does_plastic = models.BooleanField(
        default=True, verbose_name="Plastik ishlayman"
    )
    does_aluminium = models.BooleanField(
        default=True, verbose_name="Alyuminiy ishlayman"
    )
    does_termo = models.BooleanField(default=True, verbose_name="Termo ishlayman")

    #: TA'MIRGA CHIQAMAN (foydalanuvchi talabi 2026-09-21).
    #:
    #: Ta'mir — alohida ish: usta yangi rom yasashni oladi-yu, eski romni
    #: sozlashga chiqmasligi mumkin (kichik ish, yo'l vaqti). Shuning uchun
    #: TA'MIR e'lonlari (`Order.is_repair`) FAQAT shu belgini yoqqan ustaga
    #: ko'rinadi va push ham faqat ularga boradi (`apps/orders/visibility.py`).
    #: Oddiy e'lonlarga ta'siri YO'Q.
    does_repairs = models.BooleanField(
        default=False,
        verbose_name="Ta'mirga chiqaman",
        help_text="Yoqilsa ta'mir e'lonlari ham ko'rinadi (eski rom/eshikni "
        "sozlash, furnitura, oyna almashtirish).",
    )
    # ── KORXONA (ilovada "Korxona" bo'limi) ───────────────────────
    # Ustaning o'z brendi: buyurtma varag'ida ko'rinadi. Hozircha faqat
    # usta ilovasida.
    company_name = models.CharField(
        max_length=120,
        blank=True,
        default="",
        verbose_name="Korxona nomi",
    )
    company_logo = models.ImageField(
        upload_to="masters/company/",
        null=True,
        blank=True,
        verbose_name="Korxona logotipi",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Usta profili"
        verbose_name_plural = "Usta profillari"

    def save(self, *args, **kwargs):
        """Asosiy yo'nalish DOIM [specialties] ichida bo'lsin.

        Invariant SHU YERDA: e'lon ko'rinishi (`orders/visibility.py`) M2M
        bo'yicha ishlaydi va u SQL darajasida — profil qaysi yo'l bilan
        yaratilganidan (serializer, admin, test, eski ilova) qat'i nazar
        asosiy yo'nalish ro'yxatga tushmasa, usta o'z sohasidagi e'lonni
        ko'rmay qolardi.
        """
        super().save(*args, **kwargs)
        if self.specialty_id:
            self.specialties.add(self.specialty_id)

    def __str__(self):
        return f"{self.user} — {self.specialty}"


class MasterSpecialtyRate(models.Model):
    """
    USTANING NARXI — yo'nalish bo'yicha, O'LCHOV BIRLIGIDA
    (foydalanuvchi talabi 2026-08-13).

    "G'isht ustasi bo'lsa g'isht donasi qanchadan, zina ustasi bo'lsa
    metri, elektrik bo'lsa nuqtasi" — mijoz ustalarni bir xil o'lchovda
    taqqoslay olsin.

    Narx MIJOZGA OCHIQ: u ustani tanlashda asosiy ma'lumot. Yakuniy summa baribir chatda aniqlanadi — bu
    mo'ljal narx.
    """

    UZ_TITLE = "Usta narxi"

    profile = models.ForeignKey(
        "accounts.MasterProfile",
        on_delete=models.CASCADE,
        related_name="rates",
        verbose_name="Usta profili",
    )
    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.PROTECT,
        related_name="rates",
        verbose_name="Yo'nalish",
    )
    #: QAYSI VARIANTGA (kafelda: pol / devor / sokl). `null` — yo'nalishning
    #: o'ziga (variantsiz sohalar: g'isht, zina, elektrik...).
    #:
    #: Kafelchi uchta stavka kiritadi, chunki pol kafelini bosish bilan
    #: sokl kafelini bosish bir xil ish emas (foydalanuvchi 2026-08-31).
    variant = models.ForeignKey(
        "accounts.SpecialtyVariant",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="master_rates",
        verbose_name="Variant",
    )
    #: So'mda, BIR BIRLIK uchun (dona / m² / metr / nuqta / kun).
    price = models.BigIntegerField(verbose_name="Narx (so'm)")
    #: Usta O'ZI tanlagan birlik — faqat `specialty.unit_by_master` bo'lsa
    #: (texnika: soat, reys, km...). Oddiy yo'nalishda bo'sh: birlik
    #: yo'nalishniki (`specialty.unit`).
    unit = models.CharField(
        max_length=20, blank=True, default="", verbose_name="Birlik (usta tanlagan)"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def display_unit(self) -> str:
        """Mijozga ko'rinadigan birlik: ustaniki yoki yo'nalishniki."""
        return self.unit or self.specialty.unit

    class Meta:
        # Bitta yo'nalish+variantga bitta narx. Variantsiz yo'nalishda
        # `variant=NULL` — SQL'da NULL lar bir-biriga teng emas, shuning
        # uchun ular uchun ALOHIDA shart kerak (aks holda bitta usta bir
        # yo'nalishga bir nechta narx yozib yuborardi).
        #
        # Texnikada (usta birlik tanlaydi) bitta yo'nalishga HAR BIRLIKKA
        # bittadan narx: "soatiga" va "km ga" — ikkita qator.
        constraints = [
            models.UniqueConstraint(
                fields=["profile", "specialty", "variant"],
                name="uniq_master_rate_variant",
            ),
            models.UniqueConstraint(
                fields=["profile", "specialty"],
                condition=models.Q(variant__isnull=True, unit=""),
                name="uniq_master_rate",
            ),
            models.UniqueConstraint(
                fields=["profile", "specialty", "unit"],
                condition=models.Q(variant__isnull=True) & ~models.Q(unit=""),
                name="uniq_master_rate_unit",
            ),
        ]
        ordering = ["specialty__order"]
        verbose_name = "Usta narxi"
        verbose_name_plural = "Usta narxlari"

    def __str__(self):
        unit = f"/{self.unit}" if self.unit else ""
        return f"{self.profile} — {self.specialty}: {self.price}{unit}"


#: Usta izohining eng uzun hajmi (belgi).
MAX_SPECIALTY_NOTE = 1000


class MasterSpecialtyNote(models.Model):
    """
    USTANING IZOHI — yo'nalish bo'yicha, erkin matn (usta qarori 2026-09-28).

    Faqat `specialty.note_by_master` bo'lgan yo'nalishlarda (tom,
    santexnik): "Sasna + shifer — 1 m² 30 000, profnastil — 25 000".
    Mijozga ochiq — usta profilida va usta tanlashda ko'rinadi.
    """

    UZ_TITLE = "Usta izohi"

    profile = models.ForeignKey(
        "accounts.MasterProfile",
        on_delete=models.CASCADE,
        related_name="specialty_notes",
        verbose_name="Usta profili",
    )
    specialty = models.ForeignKey(
        MasterSpecialty,
        on_delete=models.CASCADE,
        related_name="master_notes",
        verbose_name="Yo'nalish",
    )
    text = models.TextField(max_length=MAX_SPECIALTY_NOTE, verbose_name="Izoh")
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["profile", "specialty"], name="uniq_master_specialty_note"
            ),
        ]
        ordering = ["specialty__order"]
        verbose_name = "Usta izohi"
        verbose_name_plural = "Usta izohlari"

    def __str__(self):
        return f"{self.profile} — {self.specialty}"


class MasterWorkSample(models.Model):
    """Usta qilgan ishlaridan namuna (rasm). Ixtiyoriy, keyin ham qo'shiladi."""

    UZ_TITLE = "Ish namunasi"

    profile = models.ForeignKey(
        MasterProfile,
        on_delete=models.CASCADE,
        related_name="work_samples",
        verbose_name="Usta profili",
    )
    image = models.ImageField(upload_to="masters/work_samples/", verbose_name="Rasm")
    caption = models.CharField(
        max_length=200, blank=True, default="", verbose_name="Izoh"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Ish namunasi"
        verbose_name_plural = "Ish namunalari"

    def __str__(self):
        return f"{self.profile.user} — namuna #{self.pk}"
