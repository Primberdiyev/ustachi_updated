"""
Admin API view'lari uchun asos sinflar.

Har bir admin viewset shu yerdan meros oladi — ruxsat, sahifalash va
filtr backend'lari bir joyda turadi. Ruxsatni bitta viewset uchun
o'zgartirish kerak bo'lsa, o'sha viewset'da `permission_classes` ni
qayta e'lon qiling.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, viewsets

from apps.common.pagination import AdminPagination
from apps.common.permissions import IsAdmin


class AdminViewSetMixin:
    permission_classes = [IsAdmin]
    pagination_class = AdminPagination
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]


class AdminModelViewSet(AdminViewSetMixin, viewsets.ModelViewSet):
    """To'liq CRUD — katalog/sozlama modellari uchun."""


class AdminReadOnlyViewSet(AdminViewSetMixin, viewsets.ReadOnlyModelViewSet):
    """Faqat o'qish — tranzaksion ma'lumot (buyurtma, javob, chat) uchun.

    Bunday yozuvlarni admin panelidan erkin tahrirlash mumkin emas:
    o'zgarish faqat aniq amallar (`@action`) orqali bo'ladi, shunda
    biznes qoidalari va hodisa tarixi buzilmaydi.
    """
