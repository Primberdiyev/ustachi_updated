"""Biriktirilgan hududlarni nom bo'yicha topish (`assign_territory` buyrug'i uchun)."""

#: Farg'ona viloyatidagi eshik-rom hududi (foydalanuvchi qarori 2026-10-05).
FERGANA_ROM_PHONE = "+998905601870"
FERGANA_ROM_DISTRICTS = ("Marg'ilon shahri", "Farg'ona shahri", "Qo'shtepa tumani", "Toshloq tumani")


def norm(name: str) -> str:
    """Nomni solishtirish uchun: apostrof turlari va bo'shliqlar farq qilmasin."""
    out = (name or "").lower()
    for mark in ("'", "ʻ", "ʼ", "‘", "’", "`"):
        out = out.replace(mark, "")
    return " ".join(out.split())


def find_district(cities, wanted: str):
    """
    Ro'yxatdan (`id`, `name` li yozuvlar) kerakli tuman/shahar.

    Avval nom aynan mos kelsa, bo'lmasa qo'shimchasiz ("Toshloq") ham olinadi.
    "Farg'ona shahri" hech qachon "Farg'ona tumani" ga tushmaydi.
    """
    target = norm(wanted)
    base, _, kind = target.rpartition(" ")
    exact = [c for c in cities if norm(c.name) == target]
    if exact:
        return exact[0]
    short = {"shahri": ("shahar", "sh", "sh."), "tumani": ("tuman", "t", "t.")}.get(kind, ())
    for c in cities:
        n = norm(c.name)
        if n == base or any(n == f"{base} {s}" for s in short):
            return c
    return None
