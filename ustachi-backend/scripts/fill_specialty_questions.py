"""
Yo'nalishlarga o'lchov birligi va narx savolini TO'LDIRADI (adminkada bitta-bitta
kiritish o'rniga).

Ilova qoidasi: birlik bo'sh bo'lsa ustadan narx SO'RALMAYDI. Rom, mebel va
landshaftda birlik ataylab bo'sh — narx har loyihaga qarab kelishiladi.

ISHLATISH (serverda, loyiha papkasida):

    # avval ko'rib chiqish — hech narsa o'zgarmaydi
    venv/bin/python manage.py shell < scripts/fill_specialty_questions.py

    # keyin yozish
    APPLY=1 venv/bin/python manage.py shell < scripts/fill_specialty_questions.py

Skript xavfsiz: bir necha marta yurgizilsa ham natija bir xil. Nom tahrirlangan
bo'lsa TEGMAYDI (faqat birlik va savol yoziladi). Takroriy qatorlar o'chirilmaydi
— ro'yxatda ko'rsatiladi, qaysi birini o'chirishni o'zingiz hal qilasiz.
"""

import os

from apps.accounts.models import MasterSpecialty

APPLY = os.environ.get("APPLY") == "1"

#: (kod, nom, birlik, savol) — nom faqat YANGI qator yaratilganda ishlatiladi.
CATALOG = [
    ("rom", "Rom va eshik ustasi", "", ""),
    ("tom", "Tom yopish ustasi", "m²", "Tom yopishning bir kvadrat metrini qanchadan olasiz?"),
    ("gisht", "G'isht teruvchi", "dona", "Bitta g'ishtni qanchadan terasiz?"),
    ("suvoq", "Suvoqchi (shtukatur-sement)", "m²", "Suvoqning bir kvadrat metri qancha turadi?"),
    ("beton", "Beton ishlari ustasi", "m³", "Betonning bir kub metri qancha turadi?"),
    ("elektrik", "Elektrik", "nuqta", "Bitta nuqta (rozetka/vklyuchatel) qancha turadi?"),
    ("santexnik", "Santexnik", "nuqta", "Bitta nuqta (ulanish) qancha turadi?"),
    ("kafel", "Kafel-plitka ustasi", "m²", "Kafel yotqizishning bir kvadrat metri qancha?"),
    ("boyoq", "Bo'yoqchi (malyar)", "m²", "Bo'yashning bir kvadrat metri qancha?"),
    ("gipskarton", "Gipskarton ustasi", "m²", "Gipskartonning bir kvadrat metri qancha?"),
    ("mebel", "Mebel ustasi", "", ""),
    ("darvoza", "Darvoza-panjara ustasi (temirchi)", "m²", "Darvoza-panjaraning bir kvadrat metri qancha?"),
    ("payvand", "Payvandchi", "metr", "Payvandning bir metri qancha turadi?"),
    ("pol", "Pol-potolok ustasi", "m²", "Pol yoki potolok ishining bir kvadrat metri qancha?"),
    ("quduq", "Quduq qazish ustasi", "metr", "Quduqning bir metrini qanchadan qazasiz?"),
    ("konditsioner", "Konditsioner o'rnatish", "dona", "Bitta konditsioner o'rnatish qancha turadi?"),
    ("mardikor", "Kunlik ishchilar (mardikor)", "kun", "Bir kunlik ish haqingiz qancha?"),
    ("zina", "Zina ustasi", "metr", "Zinaning bir metri qancha turadi?"),
    ("parda", "Jalyuzi-parda xizmati", "m²", "Jalyuzi-parda o'rnatishning bir kvadrat metri qancha?"),
    ("fasad", "Fasad ustasi", "m²", "Fasad ishining bir kvadrat metri qancha?"),
    ("bruschatka", "Bruschatka ustasi", "m²", "Bruschatka yotqizishning bir kvadrat metri qancha?"),
    ("travertin", "Travertin ustasi", "m²", "Travertin ishining bir kvadrat metri qancha?"),
    ("landshaft", "Landshaft xizmati (gul, archa)", "", ""),
    ("asfalt", "Asfalt ustasi", "m²", "Asfalt yotqizishning bir kvadrat metri qancha?"),
    ("hammom", "Hammom (dush kabinasi)", "dona", "Bitta dush kabinasi o'rnatish qancha turadi?"),
    ("kamera", "Kuzatuv kamerasi o'rnatish va ta'mirlash", "", ""),
]


def normalize(text: str) -> str:
    """Nomlarni solishtirish uchun: kichik harf, tutuq belgilari bir xil."""
    return (
        text.lower()
        .replace("‘", "'")
        .replace("’", "'")
        .replace("`", "'")
        .replace("ʻ", "'")
        .strip()
    )


changed, created, untouched = [], [], []

for order, (code, name, unit, question) in enumerate(CATALOG, start=1):
    row = MasterSpecialty.objects.filter(code=code).first()
    if row is None:
        # Kodi yo'q, lekin nomi mos qator bo'lishi mumkin (qo'lda qo'shilgan).
        row = next(
            (r for r in MasterSpecialty.objects.filter(code__isnull=True) if normalize(r.name) == normalize(name)),
            None,
        )
        if row is not None and APPLY:
            row.code = code
            row.save(update_fields=["code"])

    if row is None:
        created.append(f"{name} ({code}) — birlik «{unit or '—'}»")
        if APPLY:
            MasterSpecialty.objects.create(
                name=name, code=code, unit=unit, unit_question=question, order=order, is_active=True
            )
        continue

    if row.unit == unit and row.unit_question == question:
        untouched.append(f"{row.name} ({code})")
        continue

    changed.append(f"{row.name} ({code}): «{row.unit or '—'}» → «{unit or '—'}»")
    if APPLY:
        row.unit = unit
        row.unit_question = question
        row.save(update_fields=["unit", "unit_question"])

# Kodsiz faol qatorlar: ilova ularni ikonkasiz ko'rsatadi va narx so'ramaydi.
# (Nom DB darajasida takrorlanmaydi, shuning uchun "duplikat" — nomi biroz
# boshqacha yozilgan qator bo'ladi.)
catalog_names = {normalize(n) for _, n, _, _ in CATALOG}
duplicates = []
for row in MasterSpecialty.objects.filter(is_active=True).order_by("name"):
    if not row.code and normalize(row.name) in catalog_names:
        duplicates.append(f"#{row.id} {row.name} — kodi yo'q, birlik «{row.unit or '—'}»")
    elif not row.code:
        duplicates.append(f"#{row.id} {row.name} — katalogda yo'q, kodi yo'q")

print()
print("=== TO'LDIRILDI ===" if APPLY else "=== KO'RIB CHIQISH (hech narsa yozilmadi) ===")
for title, rows in (("Yangilandi", changed), ("Yaratildi", created), ("Allaqachon to'g'ri", untouched)):
    print(f"\n{title}: {len(rows)}")
    for line in rows:
        print(f"  {line}")

if duplicates:
    print(f"\nDIQQAT — tekshirilsin: {len(duplicates)}")
    for line in duplicates:
        print(f"  {line}")
    print("  Bular takroriy bo'lsa, adminkada «Faol» belgisini oling.")

if not APPLY:
    print("\nYozish uchun: APPLY=1 venv/bin/python manage.py shell < scripts/fill_specialty_questions.py")
