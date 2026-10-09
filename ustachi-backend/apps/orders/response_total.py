"""
USTA JAVOB BERGANDA JAMI NARX — ustaning O'Z STAVKASIDAN.

Mijoz ustalarni bitta raqam bo'yicha taqqoslaydi: "shu ustani chaqirsam
qancha bo'ladi?". Bu raqam faqat narxi MATERIAL deb belgilangan
yo'nalishlarda (`variant_price_is_material`) chiqadi:

1. m² STAVKA (kafel, 2026-08-31 dan)
       jami = material narxi + maydon × ustaning shu turdagi stavkasi
   Kafelchi pol/devor/sokl uchun uchta ALOHIDA stavka kiritadi — pol
   kafelini bosish bilan sokl kafelini bosish bir xil ish emas. Mijoz
   ilovada avval MATERIAL hisobini ko'radi, usta javob berganda esa shu
   yerdagi hisob bo'yicha jamini.

2. DONA STAVKA (g'isht terish, 2026-09-17 dan)
       jami = material narxi + teriladigan g'isht × ustaning shu turdagi
              1 dona narxi
   Mijoz ilovada g'isht sonini va material narxini ko'radi. Singanlar
   uchun zaxira SOTIB OLINADI, lekin TERILMAYDI — ish haqi zaxirasiz songa
   (`masonry_bricks_laid`).

3. METR STAVKA (beton zina, 2026-09-19 dan)
       jami = material narxi + metr × ustaning 1 metr narxi
   Mijoz zina uzunligini kiritadi va MATERIAL (armatura + beton) narxini
   ko'radi. Maydon kalkulyatori (`calculator="area"`) + material bayrog'i;
   stavka — ustaning yo'nalishdagi o'z narxi ("Zinaning bir metri qancha
   turadi?"), variantsiz.

Stavka nimaga ko'paytirilishini taklifdagi `engine` belgilaydi:
`masonry` — g'isht soniga, qolganida — maydonga.

Boshqa yo'nalishlarda, shuningdek stavka topilmasa (usta o'sha turga narx
qo'ymagan) `None` qaytadi — mijozga YOLG'ON raqam ko'rsatilmaydi, narx
chatda kelishiladi.
"""

from __future__ import annotations

from decimal import ROUND_HALF_UP, Decimal


def _number(value) -> Decimal | None:
    """JSON'dagi son — raqam ham, satr ham bo'lishi mumkin."""
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except Exception:
        return None


def rate_quantity(order) -> Decimal | None:
    """
    Usta stavkasi NIMAGA ko'paytiriladi: g'ishtda — teriladigan g'isht soni,
    kafelda — maydon. Ma'lum bo'lmasa yoki nol bo'lsa `None`.
    """
    proposal = order.proposal or {}
    key = "masonry_bricks_laid" if proposal.get("engine") == "masonry" else "area_m2"
    quantity = _number(proposal.get(key))
    return quantity if quantity is not None and quantity > 0 else None


def uses_master_rate(order) -> bool:
    """
    Bu buyurtmada jami USTANING STAVKASIDAN chiqadimi.

    Uch shart birga: taklifda variant hisobi bor, yo'nalish narxni material
    deb belgilagan va miqdor (maydon yoki g'isht soni) ma'lum. Bittasi
    yetishmasa — jami hisoblanmaydi.
    """
    from apps.orders.penthouse_pricing import applies
    if applies(order.specialty, order.proposal):
        return False
    proposal = order.proposal or {}
    # `area` — metr bo'yicha material (zina); `variant` — kafel, g'isht.
    if proposal.get("calculator") not in ("variant", "area"):
        return False
    if not order.specialty_id:
        return False
    if not order.specialty.variant_price_is_material:
        return False
    # Tom, santexnik: usta narx emas, izoh yozadi (2026-09-28) — eski
    # stavkalar bazada qolgan bo'lsa ham ishlatilmaydi.
    if order.specialty.note_by_master:
        return False
    return rate_quantity(order) is not None


def master_rate_for(order, master):
    """
    Ustaning SHU buyurtma turi uchun m² stavkasi (so'm) yoki `None`.

    Variant NOMI bo'yicha topiladi: taklif surati buyurtma berilganda
    olingan, keyin adminka variantni qayta nomlagan bo'lishi mumkin —
    unda stavka topilmaydi va narx ko'rsatilmaydi (noto'g'ri raqamdan
    ko'ra yo'q raqam yaxshi).
    """
    from apps.accounts.models import MasterSpecialtyRate

    profile = getattr(master, "master_profile", None)
    if profile is None:
        return None

    proposal = order.proposal or {}
    rates = MasterSpecialtyRate.objects.filter(
        profile=profile, specialty_id=order.specialty_id
    )
    # Maydon/metr kalkulyatorida variant yo'q — ustaning yo'nalishdagi
    # umumiy narxi ("Zinaning bir metri qancha turadi?").
    if proposal.get("calculator") == "area":
        return (
            rates.filter(variant__isnull=True).values_list("price", flat=True).first()
        )

    variant_name = proposal.get("variant")
    if not variant_name:
        return None
    return rates.filter(variant__name=variant_name).values_list("price", flat=True).first()


def total_by_rate(order, master) -> int | None:
    """
    Material narxi + miqdor (maydon yoki g'isht soni) × ustaning stavkasi.

    Yaxlitlash: ROUND_HALF_UP (yarim — yuqoriga).
    """
    rate = master_rate_for(order, master)
    if rate is None:
        return None

    quantity = rate_quantity(order)
    if quantity is None:
        return None

    labour = (quantity * Decimal(rate)).quantize(
        Decimal("1"), rounding=ROUND_HALF_UP
    )
    return int(order.cost_base) + int(labour)
