"""
MIJOZ uchun USTA profili — tanlashdan OLDIN usta haqida to'liq ma'lumot.

Mijoz javob bergan ustalardan birini tanlashdan avval ko'rishi kerak:
kasbiy ma'lumot (yo'nalish, tajriba, bio), ISH NAMUNALARI (rasmlar),
REYTING va boshqa mijozlarning SHARHLARI, hamda bajarilgan ishlar soni.
"""

from django.db.models import Avg, Count, Q
from django.shortcuts import get_object_or_404
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.media import absolute_media_url
from apps.accounts.api.v1.serializers import MasterWorkSampleSerializer
from apps.accounts.models import User
from apps.orders.models import Order, OrderStatus, Review


class PublicReviewSerializer(serializers.ModelSerializer):
    """Sharh — mijoz ismi bilan (telefon BERILMAYDI)."""

    client_name = serializers.CharField(source="client.full_name", read_only=True)
    order_title = serializers.CharField(source="order.title", read_only=True)

    class Meta:
        model = Review
        fields = ["id", "rating", "comment", "client_name", "order_title", "created_at"]
        read_only_fields = fields


def _rates(profile, specialty_id=None):
    """Ustaning yo'nalish narxlari — mijozga ochiq ma'lumot."""
    if profile is None:
        return []
    rates = list(profile.rates.all())
    # Eski ilova birinchi tarifni ko'rsatadi. Filtrdagi soha oldinda tursin.
    preferred = int(specialty_id) if specialty_id else profile.specialty_id
    rates.sort(key=lambda rate: (rate.specialty_id != preferred, rate.pk))
    return [
        {
            "specialty": rate.specialty_id,
            "code": rate.specialty.code,
            "name": (
                f"{rate.specialty.name} — {rate.variant.name}"
                if rate.variant_id else rate.specialty.name
            ),
            "specialty_name": rate.specialty.name,
            "variant": rate.variant_id,
            "variant_name": rate.variant.name if rate.variant_id else None,
            "unit": rate.display_unit,
            "price": rate.price,
        }
        for rate in rates
        # Tom, santexnik: narx o'rniga izoh (2026-09-28) — eski stavka
        # bazada qolgan bo'lsa ham mijozga chiqmaydi.
        if not rate.specialty.note_by_master
    ]


def _notes(profile):
    """Ustaning yo'nalish IZOHLARI (tom, santexnik) — mijozga ochiq."""
    if profile is None:
        return []
    return [
        {
            "code": note.specialty.code,
            "name": note.specialty.name,
            "text": note.text,
        }
        for note in profile.specialty_notes.all()
        if note.text.strip() and note.specialty.note_by_master
    ]


class MasterPublicProfileView(APIView):
    """
    Ustaning OMMAVIY profili (mijoz ko'radi).

    Telefon raqami OCHIQ (foydalanuvchi qarori 2026-08-08) — mijoz ustaga
    to'g'ridan-to'g'ri qo'ng'iroq qila oladi. Ilgari u faqat usta shu
    mijozning buyurtmasiga javob berganidan keyin ko'rinardi.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        master = get_object_or_404(
            User.objects.select_related(
                "master_profile", "master_profile__specialty", "region", "district"
            ).prefetch_related(
                "master_profile__specialties", "master_profile__rates__specialty",
                "master_profile__rates__variant",
                "master_profile__specialty_notes__specialty",
            ),
            pk=pk,
            is_master=True,
            is_active=True,
        )
        profile = getattr(master, "master_profile", None)

        reviews = (
            Review.objects.filter(master=master)
            .select_related("client", "order")
            .order_by("-created_at")[:20]
        )
        agg = Review.objects.filter(master=master).aggregate(
            avg=Avg("rating"), total=Count("id")
        )
        completed = Order.objects.filter(
            assigned_master=master, status=OrderStatus.COMPLETED
        ).count()
        in_progress = Order.objects.filter(
            assigned_master=master, status=OrderStatus.ASSIGNED
        ).count()

        return Response(
            {
                "id": master.pk,
                "full_name": master.full_name,
                "photo": absolute_media_url(master.photo, request),
                "phone_number": master.phone_number,
                "region_name": master.region.name if master.region_id else None,
                "district_name": master.district.name if master.district_id else None,
                # ── Kasbiy ma'lumot ──
                "specialty": profile.specialty.name if profile else None,
                "specialties": [
                    {"id": s.id, "code": s.code, "name": s.name}
                    for s in (profile.specialties.all() if profile else [])
                ],
                # NARXLAR — usta o'z sohasida qanchadan ishlashi
                # (2026-08-13): "g'isht 1 500 so'm/dona". Mijoz ustalarni
                # bir xil o'lchovda taqqoslaydi.
                "rates": _rates(profile),
                # Tom, santexnik: narx o'rniga ustaning izohi (2026-09-28).
                "notes": _notes(profile),
                "experience_years": profile.experience_years if profile else None,
                "bio": profile.bio if profile else "",
                "is_verified": profile.is_verified if profile else False,
                "member_since": master.date_joined,
                # ── Statistika ──
                "rating": round(agg["avg"], 1) if agg["avg"] else None,
                "reviews_count": agg["total"],
                "completed_orders": completed,
                "in_progress_orders": in_progress,
                # ── Ish namunalari + sharhlar ──
                "work_samples": MasterWorkSampleSerializer(
                    profile.work_samples.all() if profile else [], many=True
                ).data,
                "reviews": PublicReviewSerializer(reviews, many=True).data,
            }
        )


class MasterPublicListView(APIView):
    """
    Ustalar RO'YXATI (mijoz "Ustalar" bo'limida ko'radi).

    Faqat faol, kasbiy profili va asosiy yo'nalishi mavjud ustalar chiqadi.
    OTP orqali usta roli berilgani hali profil to'ldirilganini anglatmaydi.
    Javob formati avvalgi mobil ilovalar bilan mos holda saqlanadi.

    Filtrlar:  ?search=<ism|yo'nalish>  &region=<id>  &specialty=<id>
               &repairs=1  &district=<id>
    Tartib: avval TASDIQLANGANLAR, so'ng reyting, so'ng yangi qo'shilganlar.

    `repairs=1` — faqat "Ta'mirga chiqaman" degan ustalar (foydalanuvchi
    talabi 2026-09-21: belgini o'chirgan ustani ta'mirga tanlab bo'lmaydi).
    `district` — ta'mirda mijoz o'z TUMANIDAGI ustani chaqiradi: viloyat
    katta, yo'l haqi ta'mir narxidan qimmat tushishi mumkin. Tumani
    ko'rsatilmagan ustalar ro'yxatdan tushib qolmaydi.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Pagination is opt-in: released clients still receive a JSON list.
        page = None
        if "page" in request.query_params:
            class PageParams(serializers.Serializer):
                page = serializers.IntegerField(min_value=1, max_value=100000)
                page_size = serializers.IntegerField(min_value=1, max_value=100, default=20)

            params = PageParams(data=request.query_params)
            params.is_valid(raise_exception=True)
            page = params.validated_data["page"]
            page_size = params.validated_data["page_size"]

        masters = (
            User.objects.filter(
                is_master=True,
                is_active=True,
                master_profile__specialty__isnull=False,
            )
            .select_related("master_profile", "master_profile__specialty",
                            "region", "district")
            .prefetch_related(
                "master_profile__work_samples",
                "master_profile__specialties",
                "master_profile__rates__specialty",
                "master_profile__rates__variant",
                "master_profile__specialty_notes__specialty",
            )
        )

        search = request.query_params.get("search", "").strip()
        if search:
            # TELEFON RAQAM bo'yicha ham qidiriladi (foydalanuvchi talabi
            # 2026-08-08): mijoz ustaning raqamini bilsa, ismini eslamasa ham
            # topa olishi kerak.
            #
            # Raqam har xil yoziladi: "+998 90 123 45 67", "90 123 45 67".
            # Bazada u ajratkichsiz turadi ("+998901234567"), shuning uchun
            # qidiruv matnidan raqam bo'lmagan belgilar olib tashlanadi va
            # ustun ichidan qidiriladi — mamlakat kodini yozish shart emas.
            digits = "".join(ch for ch in search if ch.isdigit())
            query = (
                Q(full_name__icontains=search)
                | Q(master_profile__specialty__name__icontains=search)
                # Usta bir nechta yo'nalishda ishlaydi — qo'shimcha
                # sohasi bo'yicha ham topilsin (2026-08-13).
                | Q(master_profile__specialties__name__icontains=search)
            )
            # 4 tadan kam raqam bilan qidirish har kimni topib beradi —
            # foydasi yo'q, shuning uchun chegara qo'yilgan.
            if len(digits) >= 4:
                query |= Q(phone_number__contains=digits)
            masters = masters.filter(query).distinct()

        region = request.query_params.get("region")
        if region:
            masters = masters.filter(region_id=region)

        # TA'MIR (2026-09-21): faqat ta'mirga chiqadigan ustalar va faqat
        # shu tumandan — mijoz keyin tanlay olmaydigan ustani ko'rmasin.
        if request.query_params.get("repairs") in ("1", "true", "True"):
            masters = masters.filter(master_profile__does_repairs=True)

        district = request.query_params.get("district")
        if district:
            masters = masters.filter(
                Q(district_id=district) | Q(district__isnull=True)
            )

        specialty = request.query_params.get("specialty")
        if specialty:
            # M2M bo'yicha: usta uchun bu soha ASOSIY bo'lishi shart emas
            # (2026-08-13 — usta bir nechta yo'nalish tanlaydi).
            masters = masters.filter(
                master_profile__specialties=specialty
            ).distinct()

        # Reyting va bajarilgan ishlar — bitta so'rovda (N+1 bo'lmasin).
        masters = masters.annotate(
            rating=Avg("received_reviews__rating"),
            reviews_count=Count("received_reviews", distinct=True),
            completed_orders=Count(
                "assigned_orders",
                filter=Q(assigned_orders__status=OrderStatus.COMPLETED),
                distinct=True,
            ),
        ).order_by("-master_profile__is_verified", "-rating", "-date_joined", "-pk")

        if page is not None:
            offset = (page - 1) * page_size
            # One extra row determines whether more data exists, without COUNT.
            rows = list(masters[offset:offset + page_size + 1])
            return Response({
                "results": [self._card(m, request) for m in rows[:page_size]],
                "next_page": page + 1 if len(rows) > page_size else None,
            })

        return Response([self._card(m, request) for m in masters])

    @staticmethod
    def _card(master, request=None):
        profile = getattr(master, "master_profile", None)
        samples = list(profile.work_samples.all()) if profile else []
        return {
            "id": master.pk,
            "full_name": master.full_name,
            # TELEFON RAQAM ochiq (foydalanuvchi qarori 2026-08-08): mijoz
            # ustani ro'yxatdan ko'rib, to'g'ridan-to'g'ri qo'ng'iroq qila
            # olishi kerak. Ilgari raqam faqat chatdan keyin berilardi.
            "phone_number": master.phone_number,
            "photo": absolute_media_url(master.photo, request),
            "region_name": master.region.name if master.region_id else None,
            "district_name": master.district.name if master.district_id else None,
            # ── Kasbiy ma'lumot (profil to'ldirilmagan bo'lsa null) ──
            # `specialty` — ASOSIY yo'nalish (eski ilovalar shuni o'qiydi),
            # `specialties` — hammasi (yangi ilova chiplar bilan ko'rsatadi).
            "specialty": profile.specialty.name if profile else None,
            "specialties": [
                {"id": s.id, "code": s.code, "name": s.name}
                for s in (profile.specialties.all() if profile else [])
            ],
            "rates": _rates(profile, request.query_params.get("specialty") if request else None),
            "notes": _notes(profile),
            "experience_years": profile.experience_years if profile else None,
            "is_verified": profile.is_verified if profile else False,
            "accepts_orders": profile.accepts_orders if profile else True,
            # Mijoz ta'mir uchun usta tanlayotganda kerak (2026-09-21).
            "does_repairs": profile.does_repairs if profile else False,
            # ── Statistika ──
            "rating": round(master.rating, 1) if master.rating else None,
            "reviews_count": master.reviews_count,
            "completed_orders": master.completed_orders,
            # Kartada ko'rsatish uchun BIRINCHI namuna kifoya.
            "work_samples_count": len(samples),
            "cover_image": absolute_media_url(
                samples[0].image if samples else None, request
            ),
        }
