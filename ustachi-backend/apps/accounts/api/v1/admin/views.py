"""Admin panel — foydalanuvchilar, ustalar va yo'nalishlar."""

from django.db.models import Avg, Count, Q
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.accounts.api.v1.admin.filters import (
    AdminMasterProfileFilter,
    AdminUserFilter,
)
from apps.accounts.api.v1.admin.serializers import (
    AdminMasterProfileDetailSerializer,
    AdminMasterProfileListSerializer,
    AdminMasterSpecialtySerializer,
    AdminUserDetailSerializer,
    AdminUserListSerializer,
    AdminUserUpdateSerializer,
)
from apps.accounts.models import MasterProfile, MasterSpecialty, User
from apps.common.viewsets import AdminModelViewSet, AdminReadOnlyViewSet
from apps.orders.models import OrderStatus


@extend_schema_view(
    list=extend_schema(summary="Foydalanuvchilar ro'yxati", tags=["admin:users"]),
    retrieve=extend_schema(summary="Foydalanuvchi kartochkasi", tags=["admin:users"]),
    partial_update=extend_schema(summary="Foydalanuvchini tahrirlash", tags=["admin:users"]),
)
class AdminUserViewSet(AdminModelViewSet):
    """
    Foydalanuvchilar. YARATISH va O'CHIRISH yopiq:
      * yaratish — ro'yxatdan o'tish OTP orqali bo'ladi (admin qo'lda
        yaratsa telefon tasdiqlanmagan akkaunt paydo bo'ladi);
      * o'chirish — buyurtma/baho tarixi CASCADE bilan yo'qoladi. Buning
        o'rniga `block/` ishlatiladi (`is_active=False`).
    """

    http_method_names = ["get", "patch", "post", "head", "options"]
    filterset_class = AdminUserFilter
    search_fields = ["full_name", "phone_number", "username"]
    ordering_fields = ["date_joined", "full_name", "id"]
    ordering = ["-date_joined"]

    def get_queryset(self):
        qs = User.objects.select_related("region", "district")
        if self.action == "retrieve":
            qs = qs.annotate(
                orders_count=Count("orders", distinct=True),
                reviews_count=Count("received_reviews", distinct=True),
            )
        return qs

    def get_serializer_class(self):
        if self.action == "partial_update":
            return AdminUserUpdateSerializer
        if self.action == "retrieve":
            return AdminUserDetailSerializer
        return AdminUserListSerializer

    # ── Moderatsiya amallari ────────────────────────────────────────────
    @extend_schema(summary="Bloklash", tags=["admin:users"], request=None)
    @action(detail=True, methods=["post"])
    def block(self, request, pk=None):
        user = self.get_object()
        if user.is_superuser:
            return Response(
                {"detail": "Administratorni bloklab bo'lmaydi."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.is_active = False
        user.save(update_fields=["is_active"])
        return Response(AdminUserListSerializer(user, context=self.get_serializer_context()).data)

    @extend_schema(summary="Blokdan chiqarish", tags=["admin:users"], request=None)
    @action(detail=True, methods=["post"])
    def activate(self, request, pk=None):
        user = self.get_object()
        user.is_active = True
        user.save(update_fields=["is_active"])
        return Response(AdminUserListSerializer(user, context=self.get_serializer_context()).data)


@extend_schema_view(
    list=extend_schema(summary="Ustalar ro'yxati", tags=["admin:masters"]),
    retrieve=extend_schema(summary="Usta profili", tags=["admin:masters"]),
)
class AdminMasterProfileViewSet(AdminReadOnlyViewSet):
    """
    Usta profillari va ularni tasdiqlash (`verify`).

    Profil MAZMUNI (tajriba, bio, narxlar) faqat o'qiladi — uni usta o'z
    ilovasidan boshqaradi. Admin faqat moderatsiya bayrog'iga tegadi.
    """

    filterset_class = AdminMasterProfileFilter
    search_fields = [
        "user__full_name",
        "user__phone_number",
        "company_name",
    ]
    ordering_fields = ["created_at", "experience_years", "rating_avg"]
    ordering = ["-created_at"]

    def get_queryset(self):
        qs = (
            MasterProfile.objects.select_related("user", "specialty")
            .prefetch_related("specialties")
            .annotate(
                rating_avg=Avg("user__received_reviews__rating"),
                reviews_count=Count("user__received_reviews", distinct=True),
            )
        )
        if self.action == "retrieve":
            qs = qs.annotate(
                completed_orders=Count(
                    "user__assigned_orders",
                    filter=Q(user__assigned_orders__status=OrderStatus.COMPLETED),
                    distinct=True,
                )
            )
        return qs

    def get_serializer_class(self):
        if self.action == "retrieve":
            return AdminMasterProfileDetailSerializer
        return AdminMasterProfileListSerializer

    @extend_schema(summary="Tasdiqlash", tags=["admin:masters"], request=None)
    @action(detail=True, methods=["post"])
    def verify(self, request, pk=None):
        return self._set_verified(True)

    @extend_schema(summary="Tasdiqni olib tashlash", tags=["admin:masters"], request=None)
    @action(detail=True, methods=["post"])
    def unverify(self, request, pk=None):
        return self._set_verified(False)

    def _set_verified(self, value: bool):
        profile = self.get_object()
        if profile.is_verified != value:
            profile.is_verified = value
            profile.save(update_fields=["is_verified"])
        serializer = AdminMasterProfileListSerializer(
            profile, context=self.get_serializer_context()
        )
        return Response(serializer.data)


@extend_schema_view(
    list=extend_schema(summary="Yo'nalishlar", tags=["admin:catalog"]),
    create=extend_schema(summary="Yo'nalish qo'shish", tags=["admin:catalog"]),
    partial_update=extend_schema(summary="Yo'nalishni tahrirlash", tags=["admin:catalog"]),
)
class AdminMasterSpecialtyViewSet(AdminModelViewSet):
    """
    Usta yo'nalishlari (rom, tom yopish, g'isht terish...).

    O'CHIRISH yo'q: yo'nalish `Order.specialty` da PROTECT bilan bog'langan.
    Ishlatilmaydigan yo'nalish `is_active=False` qilinadi.
    """

    http_method_names = ["get", "post", "patch", "head", "options"]
    serializer_class = AdminMasterSpecialtySerializer
    filterset_fields = ["is_active", "calculator"]
    search_fields = ["name", "code"]
    ordering_fields = ["order", "name", "id"]
    ordering = ["order", "name"]

    def get_queryset(self):
        return MasterSpecialty.objects.annotate(
            masters_count=Count("masters", distinct=True)
        )
