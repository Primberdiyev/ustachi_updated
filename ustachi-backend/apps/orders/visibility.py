"""
E'LON KIMGA KO'RINADI — YAGONA QOIDA.

⚠️ BU FAYLNI O'ZGARTIRSANGIZ — UCHCHALA FUNKSIYANI BIRGA O'ZGARTIRING.

Qoida ikki YO'NALISHDA kerak va ular bir-birining ko'zgusi:
  * usta → e'lonlar (feed: `MasterOrderFeedView`)  → [public_orders_q]
  * e'lon → ustalar (xabar: `notify_masters_of_new_order`) → [masters_for_order_q]
  * bitta juftlik (obyekt darajasi: `Order.is_visible_to`, javob berish
    ruxsati) → [order_visible_to]

Ilgari uchalasi UCH JOYDA alohida yozilgan edi va ajralib ketdi: usta
e'lonni ro'yxatda ko'rib turardi, lekin bildirishnoma umuman kelmasdi
(2026-08-08 shikoyati — hududsiz usta feed'da hammasini ko'rar, xabar esa
faqat hududi teng bo'lganlarga ketardi). Shundan keyin qoida SHU YERGA
yig'ildi: uchalasi bitta matndan o'qiydi.

QOIDA
─────
1. TAKLIF QILINGAN usta — DOIM ko'radi. Hudud ham, yo'nalish ham
   tekshirilmaydi: mijoz uni ATAYIN tanlagan (chegara qo'ysak, mijozning
   tanlovi jimgina bekor bo'lardi).
2. Ochiq e'lon (`is_public`) — usta uchta shartdan o'tsa ko'radi:
     a) HUDUD: VILOYAT (region) teng bo'lsin — 7-qoida;
     b) YO'NALISH: e'lon yo'nalishi ustaning yo'nalishlari ichida bo'lsin
        (foydalanuvchi talabi 2026-08-13). E'londa yo'nalish yo'q bo'lsa
        (juda eski yozuv) — bu shart o'tkazib yuboriladi;
     c) e'lon mijozning O'ZIniki bo'lmasin.
3. Profilini to'ldirmagan (yo'nalishi yo'q) usta ochiq e'lon KO'RMAYDI.
   Ilova baribir profilni to'ldirishga majburlaydi; aks holda u har soha
   e'lonini olib, keraksiz xabarga ko'milardi.
4. TA'MIR e'loni (`Order.is_repair`, 2026-09-21) — faqat "Ta'mirga
   chiqaman" degan ustaga (`MasterProfile.does_repairs`). Ta'mir alohida
   ish: kichik, tez va yo'l vaqti ketadi — hamma usta chiqavermaydi.
   TAKLIF QILINGAN usta bunda ham ko'radi (1-qoida ustun): mijoz uni
   atayin tanlagan.
5. MATERIAL (2026-09-21) — usta o'zi ko'tarmaydigan materialni o'chirib
   qo'yadi ("men termo eshik yasay olmayman"). E'lon suratidagi
   `proposal["material"]` (0 plastik, 1 alyuminiy, 2 termo) o'chirilgan
   bo'lsa e'lon ko'rinmaydi. Materialsiz e'lon (tom, g'isht, ta'mir...)
   bu shartdan O'TADI.
6. TA'MIR (2026-09-21, usta tuzatishi) — faqat AYNAN o'sha tumandagi
   ustaga. Istisno: ESHIK-ROM ta'miri butun viloyatga boradi (2026-09-26).
   Sababi usta so'zi: "ta'mir puli oz bo'ladi, narigi chetdan kelish
   yo'l haqi ta'mir narxidan qimmat tushishi mumkin".

   Farqi nimada: oddiy e'londa tumani KO'RSATILMAGAN usta ham ko'radi
   (hududi noma'lum — chetga surib qo'ymaymiz), ta'mirda esa tuman
   MAJBURIY: mijozning tumani ustaning tumani bilan teng bo'lishi kerak.
   Tumandan ham kichik doira (mahalla, ko'chagacha masofa) hozircha
   yo'q — bazada bunday ma'lumot saqlanmaydi.
7. FAQAT O'Z VILOYATI (2026-09-26, foydalanuvchi talabi — 6-qoidaning
   oddiy e'lon qismini almashtiradi): oddiy e'lon TUMANGA qaramay, shu
   VILOYATDAGI hamma ustaga boradi. Va QAT'IY: viloyati ko'rsatilmagan
   usta hech bir ochiq e'lonni olmaydi, viloyati yo'q e'lon hech bir
   ustaga bormaydi (ilgari ikkalasi ham "hammaga" edi va e'lonlar boshqa
   viloyatga oqib ketardi). Ta'mir 6-qoidadagidek faqat o'z tumanida
   (eshik-romdan tashqari), lekin u ham viloyatdan chiqmaydi.
8. BIRIKTIRILGAN HUDUD (2026-10-05, foydalanuvchi talabi): tuman +
   yo'nalish bitta ustaga biriktirilgan bo'lsa (`ExclusiveTerritory`),
   o'sha tumandagi shu yo'nalish OCHIQ e'lonlari FAQAT shu ustaga
   ko'rinadi va xabar ham faqat unga boradi. 2–7-qoidalar bunda
   qo'llanmaydi: boshqa ustalar ko'rmaydi, biriktirilgan usta esa
   viloyati, materiali va ta'mir belgisidan qat'i nazar ko'radi.
   Taklif qilingan usta baribir ko'radi (1-qoida ustun).
   Bunday e'lon boshqa ustaga HECH QAYERDA ko'rinmaydi: sahifasi
   to'g'ridan-to'g'ri havola bilan ham ochilmaydi ([territory_closed_to])
   va Telegram kanaliga ham chiqmaydi.
"""

from django.db.models import Q


def master_specialty_ids(master) -> list[int]:
    """Ustaning barcha yo'nalishlari (profili yo'q bo'lsa — bo'sh)."""
    profile = getattr(master, "master_profile", None)
    if profile is None:
        return []
    return list(profile.specialties.values_list("id", flat=True))


def master_does_repairs(master) -> bool:
    """Usta ta'mirga chiqadimi (profili yo'q bo'lsa — yo'q)."""
    profile = getattr(master, "master_profile", None)
    return bool(profile and profile.does_repairs)


#: Rom materiali (e'lon suratidagi kod) → profildagi maydon nomi.
MATERIAL_FIELDS = {0: "does_plastic", 1: "does_aluminium", 2: "does_termo"}


def order_material(order):
    """E'lon qaysi materialda (0/1/2). Materialsiz e'londa — `None`."""
    raw = (order.proposal or {}).get("material")
    if isinstance(raw, bool):  # True/False — material emas
        return None
    try:
        code = int(raw)
    except (TypeError, ValueError):
        return None
    return code if code in MATERIAL_FIELDS else None


def _is_rom_order(order) -> bool:
    """Buyurtma eshik-rom yo'nalishidami."""
    specialty = getattr(order, "specialty", None)
    return bool(specialty and specialty.code == "rom")


def _district_only(order) -> bool:
    """Faqat o'z TUMANIGA boradimi (6-qoida): eshik-romdan boshqa ta'mir."""
    return order.is_repair and not _is_rom_order(order)


def master_materials_off(master) -> list[int]:
    """Usta O'CHIRIB qo'ygan materiallar (profili yo'q bo'lsa — bo'sh)."""
    profile = getattr(master, "master_profile", None)
    if profile is None:
        return []
    return [
        code
        for code, field in MATERIAL_FIELDS.items()
        if not getattr(profile, field, True)
    ]


#: Hech qachon rost bo'lmaydigan shart — "hech kimga / hech narsa".
_NOTHING = Q(pk__in=[])


def _master_region_q(master) -> Q:
    """USTA → E'LONLAR: faqat o'z viloyatidagi e'lon (7-qoida)."""
    if not master.region_id:
        return _NOTHING
    return Q(region_id=master.region_id)


def _master_repair_q(master) -> Q:
    """
    USTA → TA'MIR e'lonlari: faqat AYNAN o'z tumanidan (6-qoida).

    Tumani ko'rsatilmagan usta faqat o'z viloyatidagi tumansiz ta'mir
    e'lonini ko'radi — aks holda "tumandan tashqari" e'lonlar unga oqib
    kelaverardi va [masters_for_order_q] bilan ajralib ketardi.
    Viloyati yo'q usta hech narsa ko'rmaydi (7-qoida).
    """
    if not master.region_id:
        return _NOTHING
    region = Q(region_id=master.region_id)
    if master.district_id:
        return region & Q(district_id=master.district_id)
    return region & Q(district__isnull=True)


def _order_repair_q(order) -> Q:
    """TA'MIR e'loni → ustalar: faqat shu tumandagilar (6, 7-qoida)."""
    if not order.region_id:
        return _NOTHING
    region = Q(region_id=order.region_id)
    if order.district_id:
        return region & Q(district_id=order.district_id)
    return region & Q(district_id__isnull=True)


def _order_region_q(order) -> Q:
    """E'LON → USTALAR: faqat shu viloyatdagilar (7-qoida)."""
    if not order.region_id:
        return _NOTHING
    return Q(region_id=order.region_id)


def territory_owner_id(order):
    """E'lon biriktirilgan hududdami — egasi (usta id) yoki `None` (8-qoida)."""
    specialty_id = getattr(order, "specialty_id", None)
    district_id = getattr(order, "district_id", None)
    if not specialty_id or not district_id:
        return None
    from apps.orders.models import ExclusiveTerritory

    return (
        ExclusiveTerritory.objects.filter(
            specialty_id=specialty_id, district_id=district_id
        )
        .values_list("master_id", flat=True)
        .first()
    )


def territory_closed_to(order, master) -> bool:
    """E'lon birovga biriktirilgan hududdami (bu ustaga yopiq) — 8-qoida."""
    owner_id = territory_owner_id(order)
    return owner_id is not None and owner_id != master.pk


def _territories_q(master) -> tuple[Q, Q]:
    """
    USTA → biriktirilgan hududlar (8-qoida): (o'ziniki, boshqalarniki).

    Ikkalasi ham `Order` filtri; hudud yo'q bo'lsa — "hech narsa".
    """
    from apps.orders.models import ExclusiveTerritory

    mine, others = _NOTHING, _NOTHING
    for specialty_id, district_id, owner_id in ExclusiveTerritory.objects.values_list(
        "specialty_id", "district_id", "master_id"
    ):
        pair = Q(specialty_id=specialty_id, district_id=district_id)
        if owner_id == master.pk:
            mine = mine | pair
        else:
            others = others | pair
    return mine, others


def public_orders_q(master) -> Q:
    """
    USTA → E'LONLAR. Ochiq e'lonlar uchun `Order` queryset filtri.

    Taklif qilingan e'lonlar bu yerga KIRMAYDI — chaqiruvchi ularni alohida
    `Q(invites__master=...)` bilan qo'shadi (1-qoida).
    """
    # 8-qoida: o'ziga biriktirilgan hudud e'lonlari — boshqa shartsiz;
    # birovga biriktirilgani — umuman ko'rinmaydi.
    mine, others = _territories_q(master)
    return (Q(is_public=True) & mine) | (_open_orders_q(master) & ~others)


def _open_orders_q(master) -> Q:
    """Biriktirilmagan hududlar uchun umumiy qoida (2–7)."""
    specialty_ids = master_specialty_ids(master)
    if not specialty_ids:
        # Yo'nalishsiz usta ochiq e'lon ko'rmaydi (3-qoida). Hech qachon
        # rost bo'lmaydigan shart — faqat taklif qilinganlari qoladi.
        return Q(pk__in=[])

    # (b) yo'nalish: e'lonniki ustanikilar ichida (yoki e'lon yo'nalishsiz).
    matches_trade = Q(specialty_id__in=specialty_ids) | Q(specialty__isnull=True)

    # (d) ta'mir: chiqmaydigan ustaga ta'mir e'loni KO'RINMAYDI (4-qoida).
    repairs = Q() if master_does_repairs(master) else Q(is_repair=False)

    # (e) material: o'chirilgan materialdagi e'lon ko'rinmaydi (5-qoida).
    #     ⚠️ `~Q(proposal__material__in=...)` YOLG'IZ ishlamaydi: JSON'da
    #     kalit BO'LMASA taqqoslash NULL beradi va materialsiz e'lonlar
    #     (tom, g'isht, ta'mir) ham tushib qolardi — shuning uchun
    #     "kaliti yo'q" holati alohida qo'shilgan.
    off = master_materials_off(master)
    materials = (
        Q()
        if not off
        else (~Q(proposal__material__in=off) | Q(proposal__material__isnull=True))
    )

    # (a) hudud: VILOYAT bo'yicha (7-qoida); eshik-romdan boshqa ta'mir
    #     esa faqat AYNAN o'sha tumandan (6-qoida).
    district_only = Q(is_repair=True) & (
        Q(specialty__isnull=True) | ~Q(specialty__code="rom")
    )
    in_location = (~district_only & _master_region_q(master)) | (
        district_only & _master_repair_q(master)
    )

    return Q(is_public=True) & matches_trade & in_location & repairs & materials


def masters_for_order_q(order) -> Q:
    """
    E'LON → USTALAR. `User` queryset filtri (xabar yuborish uchun).

    [public_orders_q] ning ko'zgusi: bir xil hudud va yo'nalish shartlari,
    faqat teskari tomondan yozilgan.

    QOIDA 3: Profilini to'ldirmagan (yo'nalishi yo'q) usta ochiq e'lon KO'RMAYDI.

    Hudud — 7-qoida (faqat shu viloyat ustalariga). E'LON YO'NALISHI
    bo'yicha FAQAT ustaning o'z sohasiga oid bo'lsa xabar ketadi — boshqa
    soha usta bu e'longa javob bera olmaydi.
    """
    # 8-qoida: biriktirilgan hudud — faqat egasiga.
    owner_id = territory_owner_id(order)
    if owner_id is not None:
        return Q(pk=owner_id)

    # (b) yo'nalish: usta yo'nalishlari orasida e'lonniki bo'lsin.
    #     E'lon yo'nalishsiz bo'lsa (eski yozuv) — filtr qo'llanmaydi.
    trade = Q()
    if order.specialty_id:
        # Usta FAQAT o'z yo'nalishlari orasida e'lon yo'nalishi bo'lsa xabar oladi.
        # Profili yo'q yoki specialty bo'sh usta — xabar olmaydi (QOIDA 3).
        trade = Q(master_profile__specialties__id=order.specialty_id)
    # Agar e'lon yo'nalishsiz bo'lsa, HAMMA usta oladi (eski e'lonlar)

    # (a) hudud: VILOYAT bo'yicha (7-qoida); eshik-romdan boshqa ta'mir
    #     undan ham tor — tuman (6-qoida).
    in_location = (
        _order_repair_q(order) if _district_only(order) else _order_region_q(order)
    )

    # (d) ta'mir e'loni bo'lsa — faqat "ta'mirga chiqaman" deganlarga
    #     (4-qoida). Oddiy e'londa bu shart qo'llanmaydi.
    repairs = Q(master_profile__does_repairs=True) if order.is_repair else Q()

    # (e) material: e'lon materialini o'chirib qo'ygan ustaga xabar
    #     ketmaydi (5-qoida). Materialsiz e'londa shart qo'llanmaydi.
    material = order_material(order)
    materials = (
        Q(**{f"master_profile__{MATERIAL_FIELDS[material]}": True})
        if material is not None
        else Q()
    )

    # Agar e'lon yo'nalishsiz bo'lsa, trade bo'sh Q() qoladi va u hech narsani
    # filter qilmaydi (Q() doim True) — faqat location shart qo'llanadi.
    return trade & in_location & repairs & materials


def order_visible_to(order, master) -> bool:
    """
    Bitta juftlik uchun javob (`Order.is_visible_to` va javob berish ruxsati).

    Yuqoridagi ikki queryset bilan AYNI qoida, faqat obyekt darajasida.
    """
    # 1) Taklif qilingan bo'lsa — boshqa shart yo'q.
    if order.invites.filter(master=master).exists():
        return True

    if not order.is_public:
        return False

    # 8-qoida: biriktirilgan hudud — faqat egasi, boshqa shartsiz.
    owner_id = territory_owner_id(order)
    if owner_id is not None:
        return owner_id == master.pk

    # (a) hudud: viloyat TENG va ko'rsatilgan bo'lsin (7-qoida); ta'mirda
    #     tumanlar ham TENG bo'lishi shart (6-qoida, eshik-romdan tashqari).
    if not master.region_id or master.region_id != order.region_id:
        return False
    if _district_only(order) and master.district_id != order.district_id:
        return False

    # (b) yo'nalish
    if order.specialty_id:
        if order.specialty_id not in master_specialty_ids(master):
            return False

    # (d) ta'mir (4-qoida)
    if order.is_repair and not master_does_repairs(master):
        return False

    # (e) material (5-qoida)
    material = order_material(order)
    if material is not None and material in master_materials_off(master):
        return False

    return True
