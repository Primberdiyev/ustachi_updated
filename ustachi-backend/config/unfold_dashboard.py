"""
Admin bosh sahifasidagi ko'rsatkichlar (Unfold `DASHBOARD_CALLBACK`).

Chaqiriladigan joy: `UnfoldAdminSite.index` — natija `templates/admin/index.html`
ga kontekst sifatida uzatiladi. Barcha so'rovlar YENGIL (`count()` va oxirgi
10 ta yozuv), shuning uchun bosh sahifa sekinlashmaydi.
"""

from datetime import timedelta

from django.db.models import Count, Q
from django.http import HttpRequest
from django.urls import reverse
from django.utils import timezone


def _card(title: str, value, icon: str, link: str = "", footer: str = "") -> dict:
    return {
        "title": title,
        "value": value,
        "icon": icon,
        "link": link,
        "footer": footer,
    }


def dashboard_callback(request: HttpRequest, context: dict) -> dict:
    from apps.accounts.models import MasterProfile, User
    from apps.orders.models import MasterOrder, Order, OrderResponse, Review
    from apps.orders.models.master_order import MasterOrderStatus
    from apps.orders.models.order import OrderStatus

    now = timezone.now()
    week_ago = now - timedelta(days=7)

    users = User.objects.aggregate(
        total=Count("id"),
        masters=Count("id", filter=Q(is_master=True)),
        new_week=Count("id", filter=Q(date_joined__gte=week_ago)),
    )
    orders = Order.objects.aggregate(
        total=Count("id"),
        published=Count("id", filter=Q(status=OrderStatus.PUBLISHED)),
        assigned=Count("id", filter=Q(status=OrderStatus.ASSIGNED)),
        completed=Count("id", filter=Q(status=OrderStatus.COMPLETED)),
        new_week=Count("id", filter=Q(created_at__gte=week_ago)),
    )
    master_orders = MasterOrder.objects.aggregate(
        total=Count("id"),
        active=Count(
            "id",
            filter=~Q(status__in=MasterOrderStatus.closed()),
        ),
    )

    context.update(
        {
            "cards": [
                _card(
                    "Foydalanuvchilar",
                    users["total"],
                    "group",
                    reverse("admin:accounts_user_changelist"),
                    f"Haftada +{users['new_week']}",
                ),
                _card(
                    "Ustalar",
                    users["masters"],
                    "engineering",
                    reverse("admin:accounts_masterprofile_changelist"),
                    f"{MasterProfile.objects.filter(is_verified=True).count()} tasdiqlangan",
                ),
                _card(
                    "Ochiq e'lonlar",
                    orders["published"],
                    "campaign",
                    f"{reverse('admin:orders_order_changelist')}?status__exact={OrderStatus.PUBLISHED}",
                    f"Jami {orders['total']} buyurtma",
                ),
                _card(
                    "Jarayondagi ishlar",
                    orders["assigned"],
                    "pending_actions",
                    f"{reverse('admin:orders_order_changelist')}?status__exact={OrderStatus.ASSIGNED}",
                    f"{orders['completed']} yakunlangan",
                ),
                _card(
                    "Usta buyurtmalari",
                    master_orders["total"],
                    "construction",
                    reverse("admin:orders_masterorder_changelist"),
                    f"{master_orders['active']} faol",
                ),
                _card(
                    "Haftalik e'lonlar",
                    orders["new_week"],
                    "trending_up",
                    reverse("admin:orders_order_changelist"),
                    "Oxirgi 7 kun",
                ),
            ],
            "recent_orders": (
                Order.objects.select_related("client", "assigned_master", "region")
                .order_by("-created_at")[:8]
            ),
            "recent_responses": (
                OrderResponse.objects.select_related("order", "master")
                .order_by("-created_at")[:8]
            ),
            "recent_reviews": (
                Review.objects.select_related("order", "master", "client")
                .order_by("-created_at")[:5]
            ),
        }
    )
    return context
