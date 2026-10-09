"""
MAYDON BO'YICHA NARX — pog'onali stavka (asfalt va shunga o'xshash sohalar).

QOIDA (foydalanuvchi qarori 2026-08-29): pog'ona TANLANADI, ustiga
qo'shilmaydi. Maydon qaysi pog'onaga tushsa, BUTUN maydon o'sha stavkada:

    100 m² gacha — 100 000 so'm/m²
    undan yuqori —  75 000 so'm/m²

     80 m² →  80 × 100 000 =  8 000 000
    100 m² → 100 × 100 000 = 10 000 000
    150 m² → 150 ×  75 000 = 11 250 000

⚠️ Bu qoidaning tabiiy yon ta'siri bor: chegaradan sal oshganda JAMI narx
kamayib ketadi (100 m² = 10 mln, 101 m² = 7,575 mln). Bu ataylab tanlangan
("ko'proq qilsang arzonroq"), lekin adminkada pog'ona qo'shayotgan odam buni
bilib turishi uchun ogohlantirish chiqariladi ([tier_warnings]).

Hisob ILOVADA ham takrorlanadi (mijoz oflayn ham ko'radi) — shuning uchun
qoida shu yerda YAGONA va sodda: ikkala tomon bir xil natija berishi shart.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal


@dataclass(frozen=True)
class AreaTier:
    """Bitta pog'ona: shu maydongacha (shu son ham kiradi) — shu stavkada."""

    #: Yuqori chegara (m²), `None` — cheksiz.
    up_to_area: Decimal | None
    #: 1 m² narxi (so'm).
    price: Decimal


@dataclass(frozen=True)
class AreaPrice:
    """Hisob natijasi."""

    area: Decimal
    #: Qo'llangan stavka (1 m² uchun).
    unit_price: Decimal
    #: Yakuniy summa (butun so'mga yaxlitlangan).
    total: int


def tiers_for(specialty) -> list[AreaTier]:
    """Yo'nalishning pog'onalari — modeldan sof qiymatlarga."""
    return [
        AreaTier(up_to_area=row.up_to_area, price=row.price)
        for row in specialty.area_tiers.all()
    ]


def sorted_tiers(tiers: list[AreaTier]) -> list[AreaTier]:
    """Chegarasi bo'yicha o'sish tartibida; cheksiz pog'ona OXIRIDA."""
    return sorted(
        tiers,
        key=lambda t: (t.up_to_area is None, t.up_to_area or Decimal(0)),
    )


def pick_tier(tiers: list[AreaTier], area: Decimal) -> AreaTier | None:
    """
    Maydonga MOS keladigan pog'ona — chegarasi yetadigan eng KICHIGI.

    Mos pog'ona topilmasa `None`: bu sozlama xatosi (cheksiz pog'ona
    qo'yilmagan). Chaqiruvchi u holda narxni KO'RSATMAYDI — yolg'on raqam
    ko'rsatgandan ko'ra "narx chatda kelishiladi" deyish to'g'ri.
    """
    for tier in sorted_tiers(tiers):
        if tier.up_to_area is None or area <= tier.up_to_area:
            return tier
    return None


def calculate(tiers: list[AreaTier], area: Decimal) -> AreaPrice | None:
    """Maydon → narx. Maydon musbat bo'lmasa yoki pog'ona topilmasa `None`."""
    if area <= 0:
        return None
    tier = pick_tier(tiers, area)
    if tier is None:
        return None
    total = (area * tier.price).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    return AreaPrice(area=area, unit_price=tier.price, total=int(total))


def tier_warnings(tiers: list[AreaTier]) -> list[str]:
    """
    Sozlamadagi shubhali joylar — adminkada ko'rsatish uchun.

    Xato EMAS (qoida ataylab shunday), lekin narx jadvalini to'ldirayotgan
    odam natijani ko'z oldiga keltira olsin.
    """
    problems: list[str] = []
    rows = sorted_tiers(tiers)
    if not rows:
        return problems

    if all(t.up_to_area is not None for t in rows):
        problems.append(
            "Cheksiz pog'ona yo'q — eng katta chegaradan oshgan maydonga narx "
            "topilmaydi va mijozga narx ko'rsatilmaydi. Bitta pog'onaning "
            "chegarasini BO'SH qoldiring."
        )

    # Chegaradan oshganda jami narx kamayib ketadimi.
    for lower, upper in zip(rows, rows[1:]):
        if lower.up_to_area is None:
            continue
        at_limit = lower.up_to_area * lower.price
        just_over = lower.up_to_area * upper.price
        if just_over < at_limit:
            problems.append(
                f"{lower.up_to_area:g} m² dan sal oshganda jami narx "
                f"{at_limit:,.0f} so'mdan {just_over:,.0f} so'mga TUSHIB "
                "ketadi (pog'ona tanlanadi, ustiga qo'shilmaydi).".replace(
                    ",", " "
                )
            )
    return problems
