"""Only penthouse waterproofing includes labor at a fixed 424000 UZS/m²."""
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

CODE = "penthaus_gidro_tom"
VARIANT = "Gidroizolatsiya — penthaus tom yopish"
UNIT_PRICE = 424000


def applies(specialty, proposal=None):
    return specialty is not None and (
        specialty.code == CODE or (
            specialty.code == "tom" and isinstance(proposal, dict)
            and proposal.get("variant") == VARIANT
        )
    )


def quote(proposal):
    if not isinstance(proposal, dict):
        raise ValueError("Uy uzunligi va enini kiriting.")
    try:
        length = Decimal(str(proposal.get("length_m", proposal.get("roof_house_length_m"))))
        width = Decimal(str(proposal.get("width_m", proposal.get("roof_house_width_m"))))
        if not all(v.is_finite() and 0 < v <= 1000 for v in (length, width)):
            raise ValueError("Uy o‘lchami 0 dan katta va 1000 metrgacha bo‘lishi kerak.")
        area = length * width
        total = int((area * UNIT_PRICE).quantize(Decimal("1"), rounding=ROUND_HALF_UP))
        return area, total
    except (InvalidOperation, TypeError) as exc:
        raise ValueError("Uy uzunligi va enini to‘g‘ri kiriting.") from exc
