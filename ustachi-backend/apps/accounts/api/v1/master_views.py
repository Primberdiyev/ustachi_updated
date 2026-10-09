"""
Usta (master) profili API — faqat `ustachi_usta` ilovasi uchun.

Oqim: ro'yxatdan o'tish → usta profili (yo'nalish + tajriba MAJBURIY,
izoh/ish namunalari IXTIYORIY) → tekshiruv savollari → HomePage.
"""

from django.db import transaction
from rest_framework import status
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import (
    MasterSpecialty,
    MasterSpecialtyNote,
    MasterSpecialtyRate,
    MasterWorkSample,
)
from apps.accounts.models.master import MAX_MASTER_UNITS

from .serializers import (
    MasterProfileSerializer,
    MasterSpecialtyNoteSerializer,
    MasterSpecialtyRateSerializer,
    MasterSpecialtySerializer,
    MasterWorkSampleSerializer,
)


class MasterSpecialtyListView(APIView):
    """
    Yo'nalishlar katalogi — ikkala ilova ham shundan o'qiydi.

    Mijoz ilovasi bu ro'yxatdan "Narx hisoblash" bo'limini ham yig'adi
    (`calculator` to'ldirilgan yo'nalishlar), shuning uchun maydon
    narxlari BIRGA yuboriladi — `prefetch_related` bo'lmasa har yo'nalish
    uchun alohida so'rov ketardi (N+1).
    """

    permission_classes = [AllowAny]

    def get(self, request):
        specialties = MasterSpecialty.objects.filter(is_active=True).prefetch_related(
            "area_tiers", "variants", "bricks", "repair_problems"
        )
        return Response(MasterSpecialtySerializer(specialties, many=True).data)


class MasterProfileView(APIView):
    """
    Ustaning O'Z profili.
      GET   — profilni olish (yo'q bo'lsa 404)
      POST  — yaratish yoki to'liq yangilash (upsert)
      PATCH — qisman yangilash (izoh/tajribani keyin to'ldirish uchun)
    Profil yaratilganда foydalanuvchiga USTA roli beriladi.
    """

    permission_classes = [IsAuthenticated]
    # JSONParser SHART: ilova sozlamalarni JSON body bilan PATCH qiladi
    # (multipart faqat rasm yuklashda). Bo'lmasa 415 qaytardi.
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    serializer_class = MasterProfileSerializer

    def get(self, request):
        profile = getattr(request.user, "master_profile", None)
        if profile is None:
            return Response(
                {"detail": "Usta profili hali to'ldirilmagan."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(MasterProfileSerializer(profile).data)

    def _upsert(self, request, partial):
        profile = getattr(request.user, "master_profile", None)
        # Profil BOR bo'lsa PATCH qisman ishlaydi (mas. faqat bandlikni
        # yuborish mumkin). Profil YO'Q bo'lsa qisman
        # bo'lmaydi: `specialty`/`experience_years` majburiy, ularsiz yozuv
        # yaratib bo'lmaydi — DRF toza 400 qaytaradi (aks holda IntegrityError
        # bilan 500 bo'lardi).
        serializer = MasterProfileSerializer(
            profile, data=request.data, partial=partial and profile is not None
        )
        serializer.is_valid(raise_exception=True)
        created = profile is None
        profile = serializer.save(user=request.user)

        # Usta profili bor — demak foydalanuvchi usta. Mijozligi saqlanadi.
        if not request.user.is_master:
            request.user.is_master = True
            request.user.save(update_fields=["is_master"])

        return Response(
            MasterProfileSerializer(profile).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    def post(self, request):
        return self._upsert(request, partial=False)

    def patch(self, request):
        return self._upsert(request, partial=True)


class MasterRatesView(APIView):
    """
    USTANING NARXLARI — yo'nalish bo'yicha, o'lchov birligida
    (foydalanuvchi talabi 2026-08-13).

    GET — joriy narxlar.
    PUT — narxlarni to'liq almashtirish:
          `{"rates": [{"specialty": 3, "price": 1500}, ...]}`
          Texnikada (birlikni usta tanlaydi) har qatorda `unit` ham:
          `{"specialty": 40, "unit": "soat", "price": 350000}`.

    NEGA ALOHIDA ENDPOINT: narxlar RO'YXAT, profil so'rovi esa multipart
    (rasm yuklash uchun) — multipart ichida ichma-ich ro'yxat yuborish
    ilovada ham, serverda ham chalkash bo'lardi.

    Ro'yxatda kelmagan yo'nalish narxi O'CHIRILADI: usta sohani tashlab
    ketsa, eski narxi ommaviy profilida osilib qolmasin.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = MasterSpecialtyRateSerializer

    def _profile(self, request):
        return getattr(request.user, "master_profile", None)

    def get(self, request):
        profile = self._profile(request)
        if profile is None:
            return Response(
                {"detail": "Usta profili hali to'ldirilmagan."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(
            MasterSpecialtyRateSerializer(
                profile.rates.select_related("specialty", "variant"),
                many=True,
            ).data
        )

    def put(self, request):
        profile = self._profile(request)
        if profile is None:
            return Response(
                {"detail": "Avval usta profilini to'ldiring."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = MasterSpecialtyRateSerializer(
            data=request.data.get("rates", []), many=True
        )
        serializer.is_valid(raise_exception=True)
        rows = serializer.validated_data

        # Narx FAQAT ustaning O'Z yo'nalishlariga qo'yiladi — aks holda u
        # ishlamaydigan sohada narx e'lon qilib, mijozni chalg'itardi.
        own = set(profile.specialties.values_list("id", flat=True))
        unknown = [r["specialty"].pk for r in rows if r["specialty"].pk not in own]
        if unknown:
            return Response(
                {"rates": "Bu yo'nalish sizning ro'yxatingizda yo'q."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # TEXNIKA: bitta texnikaga ko'pi bilan [MAX_MASTER_UNITS] ta birlik
        # ("soatiga + km ga"), bir xil birlik ikki marta emas.
        units_by_specialty: dict[int, list[str]] = {}
        for row in rows:
            if row["specialty"].unit_by_master:
                units_by_specialty.setdefault(row["specialty"].pk, []).append(row["unit"])
        for units in units_by_specialty.values():
            if len(units) > MAX_MASTER_UNITS or len(set(units)) != len(units):
                return Response(
                    {"rates": f"Bitta texnikaga ko'pi bilan {MAX_MASTER_UNITS} ta "
                     "har xil birlik tanlanadi."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        with transaction.atomic():
            # SAQLANGAN qatorlarning o'zini eslab qolamiz: kafelda bitta
            # yo'nalishga bir nechta narx bo'ladi (pol/devor/sokl), shuning
            # uchun "yo'nalish bo'yicha o'chirish" endi yaramaydi — aks
            # holda oxirgi variantdan boshqasi o'chib ketardi.
            keep_ids = []
            for row in rows:
                specialty = row["specialty"]
                # Birligi yo'q yo'nalishda (rom, mebel) narx SAQLANMAYDI.
                # Texnikada birlikni usta o'zi tanlaydi — u saqlanadi.
                if not specialty.unit and not specialty.unit_by_master:
                    continue
                # Tom, santexnik, darvoza, payvand, dush kabinasi: narx
                # o'rniga IZOH (2026-09-28). Eski ilova stavka yuborsa ham
                # saqlanmaydi (va eskisi pastda o'chadi) — so'rov yiqilmaydi.
                if specialty.note_by_master:
                    continue
                rate, _ = MasterSpecialtyRate.objects.update_or_create(
                    profile=profile,
                    specialty=specialty,
                    variant=row.get("variant"),
                    unit=row.get("unit", ""),
                    defaults={"price": row["price"]},
                )
                keep_ids.append(rate.pk)
            profile.rates.exclude(pk__in=keep_ids).delete()

        return Response(
            MasterSpecialtyRateSerializer(
                profile.rates.select_related("specialty", "variant"),
                many=True,
            ).data
        )


class MasterNotesView(APIView):
    """
    USTANING IZOHLARI — narx katakchalari o'rniga erkin matn
    (usta qarori 2026-09-28): tom, santexnik, darvoza, payvand, dush kabinasi.

    GET — joriy izohlar.
    PUT — to'liq almashtirish: `{"notes": [{"specialty": 2, "text": "..."}]}`.
          Bo'sh matn yoki ro'yxatda kelmagan yo'nalish izohi O'CHIRILADI.
    """

    permission_classes = [IsAuthenticated]
    serializer_class = MasterSpecialtyNoteSerializer

    def _data(self, profile):
        return MasterSpecialtyNoteSerializer(
            profile.specialty_notes.select_related("specialty"), many=True
        ).data

    def get(self, request):
        profile = getattr(request.user, "master_profile", None)
        if profile is None:
            return Response(
                {"detail": "Usta profili hali to'ldirilmagan."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(self._data(profile))

    def put(self, request):
        profile = getattr(request.user, "master_profile", None)
        if profile is None:
            return Response(
                {"detail": "Avval usta profilini to'ldiring."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = MasterSpecialtyNoteSerializer(
            data=request.data.get("notes", []), many=True
        )
        serializer.is_valid(raise_exception=True)
        rows = serializer.validated_data

        own = set(profile.specialties.values_list("id", flat=True))
        for row in rows:
            specialty = row["specialty"]
            if specialty.pk not in own:
                return Response(
                    {"notes": "Bu yo'nalish sizning ro'yxatingizda yo'q."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if not specialty.note_by_master:
                return Response(
                    {"notes": "Bu yo'nalishda izoh emas, narx so'raladi."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        with transaction.atomic():
            keep_ids = []
            for row in rows:
                text = row["text"].strip()
                if not text:
                    continue
                note, _ = MasterSpecialtyNote.objects.update_or_create(
                    profile=profile,
                    specialty=row["specialty"],
                    defaults={"text": text},
                )
                keep_ids.append(note.pk)
            profile.specialty_notes.exclude(pk__in=keep_ids).delete()

        return Response(self._data(profile))


class MasterWorkSampleListCreateView(APIView):
    """Ish namunalari — ixtiyoriy, keyin ham qo'shsa bo'ladi."""

    permission_classes = [IsAuthenticated]
    # JSONParser SHART: ilova sozlamalarni JSON body bilan PATCH qiladi
    # (multipart faqat rasm yuklashda). Bo'lmasa 415 qaytardi.
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    serializer_class = MasterWorkSampleSerializer

    def _profile_or_404(self, request):
        return getattr(request.user, "master_profile", None)

    def get(self, request):
        profile = self._profile_or_404(request)
        if profile is None:
            return Response([], status=status.HTTP_200_OK)
        return Response(
            MasterWorkSampleSerializer(profile.work_samples.all(), many=True).data
        )

    def post(self, request):
        profile = self._profile_or_404(request)
        if profile is None:
            return Response(
                {"detail": "Avval usta profilini to'ldiring."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        serializer = MasterWorkSampleSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(profile=profile)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class MasterWorkSampleDetailView(APIView):
    """Ish namunasini o'chirish (faqat o'zinikini)."""

    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        sample = MasterWorkSample.objects.filter(
            pk=pk, profile__user=request.user
        ).first()
        if sample is None:
            return Response(
                {"detail": "Namuna topilmadi."}, status=status.HTTP_404_NOT_FOUND
            )
        sample.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
