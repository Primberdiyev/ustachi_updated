"""
NEGA XABAR KELMADI? — bitta buyurtma bo'yicha to'liq tekshiruv.

Foydalanuvchida serverga SSH yo'q, shuning uchun "usta bilan mijoz bir
viloyatda, lekin bildirishnoma kelmadi" degan savolga javob berish uchun
DB ni ochib ko'rish kerak bo'ladi. Bu buyruq o'sha ishni bajaradi va
HAR USTA uchun sababni ochiq yozadi.

Hech narsani O'ZGARTIRMAYDI — faqat o'qiydi.

Ishlatish:
    python manage.py why_no_notification            # oxirgi buyurtma
    python manage.py why_no_notification --order 42
"""

from django.core.management.base import BaseCommand

from apps.accounts.models import AppKind, DeviceToken, User
from apps.accounts.models.device import app_filter
from apps.orders.models import Notification, NotificationType, Order

#: Bo'sh qiymat yorlig'i — f-string ichida apostrof bo'lmasin.
NONE_LABEL = "— yoq —"
NO_LABEL = "yoq"


class Command(BaseCommand):
    help = "Buyurtma bo'yicha bildirishnoma kimga bordi va kimga bormadi."

    def add_arguments(self, parser):
        parser.add_argument("--order", type=int, default=None)

    def handle(self, *args, **options):
        order = self._order(options.get("order"))
        if order is None:
            self.stdout.write("Buyurtma topilmadi.")
            return

        self._order_block(order)
        masters = self._masters()
        if not masters:
            self.stdout.write("\n⚠️  Bazada umuman usta yo'q.")
            return

        notified = set(
            Notification.objects.filter(
                order=order,
                type__in=[
                    NotificationType.ORDER_PUBLISHED,
                    NotificationType.ORDER_INVITE,
                ],
            ).values_list("user_id", flat=True)
        )
        tokens = self._tokens([m.pk for m in masters])
        invited = set(order.invites.values_list("master_id", flat=True))

        self.stdout.write("\n===== USTALAR =====")
        for master in masters:
            self._master_block(master, order, notified, tokens, invited)

        self._summary(order, masters, notified, tokens)

    # ───────────────────────── bo'laklar ─────────────────────────

    def _order(self, pk):
        qs = Order.objects.select_related("client", "region", "district")
        return qs.filter(pk=pk).first() if pk else qs.order_by("-pk").first()

    def _masters(self):
        return list(
            User.objects.filter(is_master=True)
            .select_related("master_profile", "region")
            .order_by("pk")
        )

    def _tokens(self, user_ids):
        out = {}
        for user_id, active in DeviceToken.objects.filter(
            app_filter(AppKind.MASTER), user_id__in=user_ids
        ).values_list("user_id", "is_active"):
            total, live = out.get(user_id, (0, 0))
            out[user_id] = (total + 1, live + (1 if active else 0))
        return out

    def _order_block(self, order):
        self.stdout.write("===== BUYURTMA =====")
        self.stdout.write(f"#{order.pk} — {order.title}")
        self.stdout.write(f"holat      : {order.status}")
        self.stdout.write(
            f"hammaga ochiq: {getattr(order, 'is_public', True)}"
            + ("  (yopiq — faqat taklif qilinganlarga)"
               if not getattr(order, "is_public", True) else "")
        )
        region_name = order.region.name if order.region_id else NONE_LABEL
        self.stdout.write(f"viloyat    : {region_name} (id={order.region_id})")
        district_name = order.district.name if order.district_id else "—"
        self.stdout.write(
            f"tuman      : {district_name}   [i] tuman FILTRDA ishlatilmaydi"
        )
        self.stdout.write(
            f"mijoz      : {order.client} (viloyat id={order.client.region_id})"
        )
        if not order.region_id:
            self.stdout.write(
                "⚠️  Buyurtmada viloyat YO'Q — xabar HECH KIMGA ketmaydi."
            )
        # Yo'nalish (soha) — 2026-08-13 dan xabar FAQAT shu soha ustalariga.
        if order.specialty_id:
            self.stdout.write(
                f"yo'nalish  : {order.specialty.name} "
                f"(kod={order.specialty.code})"
            )
        else:
            self.stdout.write(
                "yo'nalish  : —   ⚠️  yo'nalishsiz e'lon: soha filtri "
                "QO'LLANMAYDI (eski yozuv)"
            )

    def _master_block(self, master, order, notified, tokens, invited):
        profile = getattr(master, "master_profile", None)
        accepts = profile.accepts_orders if profile else True
        total, live = tokens.get(master.pk, (0, 0))

        # Hudud mos keladimi — `visibility.py` 7-qoida: viloyat TENG va
        # ko'rsatilgan bo'lsin (viloyatsiz usta ham, e'lon ham — o'tmaydi).
        in_region = bool(order.region_id) and master.region_id == order.region_id

        # Yo'nalish mos keladimi — `visibility.py` bilan AYNI qoida.
        master_specialties = (
            list(profile.specialties.values_list("code", flat=True))
            if profile
            else []
        )
        trade_ok = (
            True
            if not order.specialty_id
            else order.specialty_id
            in (profile.specialties.values_list("id", flat=True) if profile else [])
        )

        reasons = []
        if not master.is_active:
            reasons.append("hisob FAOL EMAS")
        if profile is None:
            reasons.append("PROFIL TO'LDIRILMAGAN — yo'nalish yo'q")
        elif not trade_ok:
            reasons.append(
                f"yo'nalish mos emas (usta={master_specialties or '—'}, "
                f"buyurtma={order.specialty.code if order.specialty_id else '—'})"
            )
        if not in_region:
            reasons.append(
                f"viloyat mos emas (usta={master.region_id}, "
                f"buyurtma={order.region_id})"
            )
        if not getattr(order, "is_public", True) and master.pk not in invited:
            reasons.append("e'lon yopiq, bu ustaga taklif yuborilmagan")
        if master.pk == order.client_id:
            reasons.append("buyurtmaning EGASI")

        got = master.pk in notified
        mark = "✅" if got else "❌"
        self.stdout.write(
            f"\n{mark} #{master.pk} {master.full_name or master.phone_number}"
        )
        region_name = master.region.name if master.region_id else NONE_LABEL
        self.stdout.write(
            f"    viloyat: {region_name} (id={master.region_id})"
        )
        inapp = "BOR" if got else NO_LABEL
        self.stdout.write(
            f"    ilova ichida xabar: {inapp}"
            f" · usta ilovasi tokeni: {live} faol / {total} ta"
            f" · buyurtma qabul qiladi: {accepts}"
        )
        if reasons:
            self.stdout.write("    sabab: " + "; ".join(reasons))
        elif got and not accepts:
            self.stdout.write(
                "    [i] ro'yxatda ko'rinadi, lekin TELEFON PUSH'i yo'q — "
                "usta \"Buyurtma qabul qilaman\" ni o'chirgan"
            )
        elif got and live == 0:
            self.stdout.write(
                "    ⚠️  push yuboriladigan QURILMA YO'Q — ilova tokenni "
                "ro'yxatdan o'tkazmagan (login qilinganmi? Firebase ulanganmi?)"
            )
        elif got:
            self.stdout.write(
                "    [i] hammasi joyida — push yuborilgan bo'lishi kerak"
            )

    def _summary(self, order, masters, notified, tokens):
        from django.conf import settings
        import os

        self.stdout.write("\n===== XULOSA =====")
        self.stdout.write(
            f"xabar yozilgan: {len(notified)} / {len(masters)} usta"
        )
        pushable = sum(
            1
            for m in masters
            if m.pk in notified
            and tokens.get(m.pk, (0, 0))[1] > 0
            and (
                getattr(m, "master_profile", None) is None
                or m.master_profile.accepts_orders
            )
        )
        self.stdout.write(f"push yuborish mumkin bo'lganlar: {pushable}")

        path = str(getattr(settings, "FIREBASE_CREDENTIALS", "") or "")
        key = "BOR" if path and os.path.exists(path) else NO_LABEL
        self.stdout.write(
            f"FCM yoqilgan: {getattr(settings, 'FCM_ENABLED', True)}"
            f" · kalit fayli: {key}"
        )
        if not (path and os.path.exists(path)):
            self.stdout.write(
                "⚠️  Firebase kaliti yo'q — TELEFON push'i umuman "
                "yuborilmaydi (ilova ichidagi ro'yxat ishlaydi)."
            )
