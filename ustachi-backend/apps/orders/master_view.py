"""
USTA KO'RADIGAN SURAT — ba'zi buyurtmada MATERIAL TANNARXI berilmaydi.

Usta talabi (2026-09-19): "g'ishtning tan narxi usta ilovasida ko'rinmasin,
soni va ish to'g'risida ozgina tushuncha bo'lsa yetarlik".

G'isht terishda ish haqi ustaning O'Z stavkasidan chiqadi (1 dona terish
narxi), material esa mijozning xarajati — shuning uchun usta feed'ida va
buyurtma sahifasida tannarx ko'rsatilmaydi. Usta ilovasi narxsiz e'lonni
allaqachon biladi (`calculated_price = 0` → "narx chatda kelishiladi"),
shuning uchun USTA ILOVASIGA TEGILMAYDI — surat shu yerda tozalanadi.

Mijozda hammasi joyida qoladi: u material tannarxini ham, usta javob
berganda jami summani ham ko'radi.
"""

from __future__ import annotations

#: Suratdagi PUL kalitlari — usta ko'rmaydi.
_MONEY_KEYS = (
    "cost_price",
    "total_price",
    "unit_price",
    "masonry_brick_cost",
    "masonry_mortar_cost",
)

#: G'isht turi ichidagi narxlar.
_BRICK_MONEY_KEYS = ("price", "mortar_per_brick")


def hides_cost_from_master(proposal) -> bool:
    """Shu buyurtmada tannarx ustadan yashiriladimi."""
    return isinstance(proposal, dict) and proposal.get("engine") == "masonry"


def for_master(data: dict) -> dict:
    """Serializer chiqargan suratdan tannarxni olib tashlaydi."""
    proposal = data.get("proposal")
    if not hides_cost_from_master(proposal):
        return data

    clean = {key: value for key, value in proposal.items() if key not in _MONEY_KEYS}
    brick = clean.get("masonry_brick")
    if isinstance(brick, dict):
        clean["masonry_brick"] = {
            key: value for key, value in brick.items() if key not in _BRICK_MONEY_KEYS
        }
    data["proposal"] = clean
    # `calculated_price = 0` — usta ilovasida "narx chatda kelishiladi".
    data["calculated_price"] = 0
    return data
