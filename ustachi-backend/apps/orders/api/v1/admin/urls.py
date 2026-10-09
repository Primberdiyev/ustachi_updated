"""`/api/v1/admin/` — buyurtma domeni."""

from django.urls import include, path
from rest_framework.routers import DefaultRouter

from apps.orders.api.v1.admin.views import (
    AdminChatThreadViewSet,
    AdminOrderViewSet,
    AdminReviewViewSet,
)

app_name = "admin_orders"

router = DefaultRouter()
router.register("orders", AdminOrderViewSet, basename="order")
router.register("reviews", AdminReviewViewSet, basename="review")
router.register("chats", AdminChatThreadViewSet, basename="chat")

urlpatterns = [
    path("", include(router.urls)),
]
