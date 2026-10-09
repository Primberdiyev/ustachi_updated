"""
Admin API uchun umumiy ruxsat sinflari.

Rol modeli (`apps/accounts/models/user.py`):
  * mijoz  — har bir foydalanuvchi (alohida bayroq yo'q)
  * usta   — `is_master=True`
  * xodim  — `is_staff=True` (moderator/operator)
  * admin  — `is_superuser=True`

Admin panel API'si standart holda `IsAdmin` ustiga quriladi. Moderator roli
kerak bo'lganda view'da `permission_classes` ni `IsStaff` yoki
`IsAdminOrStaffReadOnly` ga almashtiring — boshqa hech narsa o'zgarmaydi.
"""

from rest_framework.permissions import SAFE_METHODS, BasePermission


class IsAdmin(BasePermission):
    """Faqat superuser. Admin panel API'sining standart ruxsati."""

    message = "Bu bo'lim faqat administratorlar uchun."

    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and user.is_superuser)


class IsStaff(BasePermission):
    """Xodim (moderator) yoki admin."""

    message = "Bu bo'lim faqat xodimlar uchun."

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user and user.is_authenticated and (user.is_staff or user.is_superuser)
        )


class IsAdminOrStaffReadOnly(BasePermission):
    """Xodim faqat ko'radi; yozish/o'chirish — faqat admin."""

    message = "O'zgartirish uchun administrator huquqi kerak."

    def has_permission(self, request, view):
        user = request.user
        if not (user and user.is_authenticated):
            return False
        if user.is_superuser:
            return True
        return bool(user.is_staff and request.method in SAFE_METHODS)
