"""Usta buyurtma/chat/bildirishnoma yo'llari — `/api/v1/master/`."""

from django.urls import path

from apps.accounts.models import AppKind
from apps.orders.api.v1.master_views import (
    MasterOrderAdvanceView,
    MasterOrderDeclineView,
    MasterOrderDetailView,
    MasterOrderFeedView,
    MasterOrderListView,
    MasterOrderRespondView,
    MasterOrderWithdrawView,
)
from apps.orders.api.v1.own_order_views import (
    MasterOwnOrderDetailView,
    MasterOwnOrderListCreateView,
    MasterOwnOrderStatusView,
)
from apps.orders.api.v1.shared_views import (
    ChatMessageListView,
    ChatThreadListView,
    NotificationListView,
    NotificationReadAllView,
    NotificationReadView,
)

app_name = "master_orders"

urlpatterns = [
    # ── Buyurtmalar ──────────────────────────────────────────────
    path("orders/feed/", MasterOrderFeedView.as_view(), name="feed"),
    path("orders/", MasterOrderListView.as_view(), name="orders"),
    path("orders/<int:pk>/", MasterOrderDetailView.as_view(), name="order-detail"),
    path("orders/<int:pk>/respond/", MasterOrderRespondView.as_view(), name="respond"),
    path("orders/<int:pk>/withdraw/", MasterOrderWithdrawView.as_view(), name="withdraw"),
    # Shaxsiy taklifni rad etish (mijozga darhol xabar ketadi).
    path("orders/<int:pk>/decline/", MasterOrderDeclineView.as_view(), name="decline"),
    path("orders/<int:pk>/advance/", MasterOrderAdvanceView.as_view(), name="advance"),
    # ── Ustaning O'Z buyurtmalari (marketplace'dan mustaqil) ─────
    path("my-orders/", MasterOwnOrderListCreateView.as_view(), name="my-orders"),
    path("my-orders/<int:pk>/", MasterOwnOrderDetailView.as_view(),
         name="my-order-detail"),
    path("my-orders/<int:pk>/status/", MasterOwnOrderStatusView.as_view(),
         name="my-order-status"),
    # ── Chat ─────────────────────────────────────────────────────
    path("chat/threads/", ChatThreadListView.as_view(), name="chat-threads"),
    path("chat/threads/<int:pk>/messages/", ChatMessageListView.as_view(),
         name="chat-messages"),
    # ── Bildirishnomalar ─────────────────────────────────────────
    path("notifications/", NotificationListView.as_view(app=AppKind.MASTER),
         name="notifications"),
    path("notifications/read-all/",
         NotificationReadAllView.as_view(app=AppKind.MASTER),
         name="notifications-read-all"),
    path("notifications/<int:pk>/read/", NotificationReadView.as_view(),
         name="notification-read"),
]
