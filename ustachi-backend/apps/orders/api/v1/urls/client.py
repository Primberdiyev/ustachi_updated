"""Mijoz buyurtma/chat/bildirishnoma yo'llari — `/api/v1/client/`."""

from django.urls import path

from apps.accounts.models import AppKind
from apps.orders.api.v1.client_views import (
    ClientChooseMasterView,
    ClientOrderCancelView,
    ClientOrderDetailView,
    ClientOrderInviteView,
    ClientOrderListCreateView,
    ClientOrderPublishView,
    ClientOrderResponseListView,
    ClientReviewView,
)
from apps.accounts.api.v1.master_views import MasterSpecialtyListView
from apps.orders.api.v1.master_profile_views import (
    MasterPublicListView,
    MasterPublicProfileView,
)
from apps.orders.api.v1.shared_views import (
    ChatMessageListView,
    ChatThreadListView,
    NotificationListView,
    NotificationReadAllView,
    NotificationReadView,
)

app_name = "client_orders"

urlpatterns = [
    # ── Buyurtmalar ──────────────────────────────────────────────
    path("orders/", ClientOrderListCreateView.as_view(), name="orders"),
    path("orders/<int:pk>/", ClientOrderDetailView.as_view(), name="order-detail"),
    path("orders/<int:pk>/cancel/", ClientOrderCancelView.as_view(), name="order-cancel"),
    # Usta tanlash: buyurtmani aynan shu ustaga yuborish / hammaga ochish.
    path("orders/<int:pk>/invite/", ClientOrderInviteView.as_view(), name="order-invite"),
    path("orders/<int:pk>/publish/", ClientOrderPublishView.as_view(),
         name="order-publish"),
    path("orders/<int:pk>/responses/", ClientOrderResponseListView.as_view(),
         name="order-responses"),
    path("orders/<int:pk>/responses/<int:response_id>/choose/",
         ClientChooseMasterView.as_view(), name="order-choose"),
    path("orders/<int:pk>/review/", ClientReviewView.as_view(), name="order-review"),
    # ── Yo'nalishlar katalogi (mijoz qaysi soha bo'yicha e'lon berishini
    #    tanlaydi; usta ilovasidagi bilan AYNI ro'yxat) ─────────────
    path("specialties/", MasterSpecialtyListView.as_view(), name="specialties"),
    # ── Ustalar (ro'yxat + tanlashdan oldin profilni ko'rish) ────
    path("masters/", MasterPublicListView.as_view(), name="masters"),
    path("masters/<int:pk>/", MasterPublicProfileView.as_view(), name="master-profile"),
    # ── Chat ─────────────────────────────────────────────────────
    path("chat/threads/", ChatThreadListView.as_view(), name="chat-threads"),
    path("chat/threads/<int:pk>/messages/", ChatMessageListView.as_view(),
         name="chat-messages"),
    # ── Bildirishnomalar ─────────────────────────────────────────
    path("notifications/", NotificationListView.as_view(app=AppKind.CLIENT),
         name="notifications"),
    path("notifications/read-all/",
         NotificationReadAllView.as_view(app=AppKind.CLIENT),
         name="notifications-read-all"),
    path("notifications/<int:pk>/read/", NotificationReadView.as_view(),
         name="notification-read"),
]
