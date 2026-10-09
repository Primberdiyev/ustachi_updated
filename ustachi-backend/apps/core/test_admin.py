"""
Admin panel "tutun testi" (smoke test).

Unfold moslamalari (list_display, filtrlar, inline'lar, `@display` metodlari)
`manage.py check` da UMUMAN ushlanmaydi — xato faqat sahifa ochilganda
chiqadi. Bo'sh jadvalda esa `@display` metodlari umuman chaqirilmaydi,
shuning uchun avval har bir asosiy modeldan bittadan yozuv yaratiladi.
"""

from datetime import timedelta

from django.contrib import admin
from django.test import RequestFactory, TestCase
from django.urls import reverse
from django.utils import timezone

from apps.accounts.models import DeviceToken, MasterProfile, MasterSpecialty, PhoneOTP, User
from apps.locations.models import City, Region
from apps.orders.models import (
    ChatMessage,
    ChatThread,
    MasterOrder,
    MasterOrderItem,
    Notification,
    Order,
    OrderResponse,
    OrderStageEvent,
    Review,
)
from apps.orders.models.notification import NotificationType
from apps.orders.models.order import OrderStage, OrderStatus


class AdminSmokeTests(TestCase):
    @classmethod
    def setUpTestData(cls) -> None:
        cls.superuser = User.objects.create_superuser(
            username="admin_smoke",
            password="test-pass-12345",
            phone_number="+998900000000",
        )

        region = Region.objects.create(name="Toshkent viloyati")
        city = City.objects.create(name="Chirchiq", region=region)

        client_user = User.objects.create_user(
            phone_number="+998901111111", full_name="Mijoz Mijozov", region=region
        )
        master_user = User.objects.create_user(
            phone_number="+998902222222",
            full_name="Usta Ustayev",
            is_master=True,
            region=region,
        )
        # Rom yo'nalishi migratsiyada ekilgan. NOM bo'yicha izlanmaydi:
        # u mahsulot qarori va o'zgaradi (2026-09-05 da "Eshik va Rom
        # ustasi" bo'ldi) — barqaror kalit `code`.
        specialty, _ = MasterSpecialty.objects.get_or_create(
            code="rom", defaults={"name": "Eshik va Rom ustasi"}
        )
        MasterProfile.objects.create(
            user=master_user, specialty=specialty, experience_years=5
        )
        DeviceToken.objects.create(user=master_user, token="fcm-token-smoke")
        PhoneOTP.generate_otp("+998901111111")

        order = Order.objects.create(
            client=client_user,
            title="Oshxona romi",
            region=region,
            district=city,
            calculated_price=1_250_000,
            status=OrderStatus.ASSIGNED,
            stage=OrderStage.MEASURED,
            assigned_master=master_user,
            expires_at=timezone.now() + timedelta(days=2),
            proposal={"shape": "kvadrat", "width": 1200},
        )
        OrderResponse.objects.create(order=order, master=master_user, message="Bor")
        OrderStageEvent.objects.create(
            order=order, stage=OrderStage.MEASURED, actor=master_user
        )
        Review.objects.create(
            order=order, client=client_user, master=master_user, rating=5, comment="Zo'r"
        )
        Notification.objects.create(
            user=client_user,
            type=NotificationType.ORDER_RESPONSE,
            title="Usta javob berdi",
            order=order,
        )
        thread = ChatThread.objects.create(order=order, master=master_user)
        ChatMessage.objects.create(thread=thread, sender=master_user, text="Assalomu alaykum")

        master_order = MasterOrder.objects.create(
            master=master_user, customer_name="Anvar", customer_phone="+998903333333"
        )
        MasterOrderItem.objects.create(
            order=master_order, title="Rom", qty=2, width_mm=1500, height_mm=1600
        )

        cls.order = order

    def setUp(self) -> None:
        self.client.force_login(self.superuser)

    def _request(self):
        request = RequestFactory().get("/admin/")
        request.user = self.superuser
        return request

    def test_buyurtmalar_royxatida_buyurtmachi_ismi_va_telefoni(self) -> None:
        response = self.client.get(reverse("admin:orders_order_changelist"))
        self.assertContains(response, "Mijoz Mijozov")
        self.assertContains(response, "+998901111111")
        # Tayinlangan usta ham telefoni bilan.
        self.assertContains(response, "+998902222222")

        card = self.client.get(reverse("admin:orders_order_change", args=[self.order.pk]))
        self.assertContains(card, "tel:+998901111111")

    def test_index_renders(self) -> None:
        response = self.client.get(reverse("admin:index"))
        self.assertEqual(response.status_code, 200)
        # Dashboard kartalari kontekstga tushganini tekshiramiz.
        self.assertIn("cards", response.context)
        self.assertEqual(len(response.context["cards"]), 6)

    def test_all_changelists_render(self) -> None:
        for model in admin.site._registry:
            opts = model._meta
            url = reverse(f"admin:{opts.app_label}_{opts.model_name}_changelist")
            with self.subTest(model=f"{opts.app_label}.{opts.model_name}"):
                self.assertEqual(self.client.get(url).status_code, 200, msg=url)

    def test_all_add_forms_render(self) -> None:
        request = self._request()
        for model, model_admin in admin.site._registry.items():
            opts = model._meta
            if not model_admin.has_add_permission(request):
                continue
            url = reverse(f"admin:{opts.app_label}_{opts.model_name}_add")
            with self.subTest(model=f"{opts.app_label}.{opts.model_name}"):
                self.assertEqual(self.client.get(url).status_code, 200, msg=url)

    def test_change_forms_render(self) -> None:
        """Mavjud yozuvlar uchun tahrirlash sahifasi (inline'lar bilan)."""
        for model in admin.site._registry:
            instance = model.objects.first()
            if instance is None:
                continue
            opts = model._meta
            url = reverse(
                f"admin:{opts.app_label}_{opts.model_name}_change", args=[instance.pk]
            )
            with self.subTest(model=f"{opts.app_label}.{opts.model_name}"):
                self.assertEqual(self.client.get(url).status_code, 200, msg=url)

    def test_order_search_by_number(self) -> None:
        url = reverse("admin:orders_order_changelist")
        response = self.client.get(url, {"q": f"#{self.order.pk}"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(list(response.context["cl"].queryset), [self.order])
