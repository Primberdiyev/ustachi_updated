"""
Buyurtma domen xizmatlari — HOLAT MASHINASI bir joyda.

Client va master API'lari shu funksiyalarni chaqiradi; qoidalar view'larga
tarqalib ketmasin (aks holda bir tomondan ruxsat etilgan o'tish ikkinchisidan
taqiqlangan bo'lib qolardi).

Har o'tish yonida BILDIRISHNOMA yoziladi: in-app yozuv + WebSocket hodisasi
(ilova ochiq bo'lsa) + FCM push (ilova yopiq bo'lsa ham) — hammasi yagona
`notify()` ichida.
"""

import logging

from django.db import transaction
from django.db.models import Count, Q
from django.utils import timezone
from rest_framework.exceptions import PermissionDenied, ValidationError

from apps.accounts.models import AppKind
from apps.accounts.models.device import app_filter
from apps.accounts.services import push
from apps.common import telegram
from apps.orders import realtime
from apps.orders import visibility
from apps.orders.models import (
    ChatThread,
    InviteStatus,
    Notification,
    NotificationType,
    Order,
    OrderInvite,
    OrderResponse,
    OrderStage,
    OrderStageEvent,
    OrderStatus,
    ResponseStatus,
    Review,
)


# ───────────────────────── Bildirishnoma ─────────────────────────


logger = logging.getLogger(__name__)


def _safe_push(send) -> None:
    """
    Push yuborishni XATOSIZ bajaradi.

    Bildirishnoma — qulaylik; u yiqilsa ham chat xabari yuborilishi, e'lon
    joylanishi va bosqich o'zgarishi DAVOM ETISHI shart.
    """
    try:
        send()
    except Exception as exc:  # pragma: no cover — kutilmagan nosozlik
        logger.warning("Push yuborilmadi (asosiy amal davom etdi): %s", exc)


def audience_app(user, order) -> str:
    """Buyurtma mijozi uchun client, qolgan qatnashchilar uchun master."""
    if order is None:
        return ""
    user_id = user.pk if hasattr(user, "pk") else user
    return AppKind.CLIENT if order.client_id == user_id else AppKind.MASTER


def unread_count(user, app: str = "") -> int:
    return Notification.objects.filter(
        app_filter(app), user=user, is_read=False
    ).count()


def notify(
    user,
    ntype: str,
    title: str,
    body: str = "",
    order=None,
    *,
    app: str | None = None,
    **extra,
) -> Notification:
    """
    Bitta bildirishnoma yozadi, foydalanuvchiga REAL-TIME turtadi VA telefoniga
    FCM push yuboradi.

    Bu yagona chiqish nuqtasi: har holat o'tishi shu funksiyadan o'tgani uchun
    ilova WebSocket orqali darhol xabardor bo'ladi (davriy so'rov shart emas),
    ilova yopiq bo'lsa esa push telefon ekranida ko'rinadi.
    [app] belgilanmasa, oluvchining buyurtmadagi rolidan aniqlanadi.
    [extra] — hodisaga qo'shimcha maydonlar (mas. `thread_id`).
    """
    if app is None:
        app = audience_app(user, order)

    notification = Notification.objects.create(
        user=user, type=ntype, title=title, body=body, order=order, app=app
    )

    unread = unread_count(user, app)
    event = {
        "topic": ntype,
        "order_id": order.pk if order is not None else None,
        "notification_id": notification.pk,
        "unread_count": unread,
        **extra,
    }
    realtime.push(user.pk, event, app=app)
    # Push ham AYNAN shu hodisani olib boradi — ilova bosilganda qaysi ekranga
    # o'tishni `topic` va `order_id` dan biladi.
    #
    # ⚠️ IKKINCHI QO'RIQCHI: push moduli xatolarni o'zi yutadi, lekin
    # bildirishnoma ASOSIY AMALNI (chat xabari, e'lon, bosqich) hech qachon
    # yiqitmasligi kerak — 2026-08-05 da aynan shu bo'lgan edi.
    _safe_push(lambda: push.send_to_user(user, title, body, event, app=app))
    return notification


def notify_masters_of_new_order(order: Order) -> int:
    """
    Yangi e'lon haqida HUDUDDAGI ustalarga xabar.

    QOIDA (foydalanuvchi 2026-07-27):
      * Bildirishnoma yozuvi + in-app hodisa — HAMMA hududdagi ustaga
        (qo'ng'iroqchada va ochiq e'lonlar ro'yxatida ko'rinaveradi);
      * PUSH (telefon ekranidagi xabar) — FAQAT "buyurtma qabul qilaman"
        yoqilgan ustaga (`MasterProfile.accepts_orders`).

    KIMGA: e'lon YO'NALISHIDAGI (foydalanuvchi talabi 2026-08-13) va
    FAQAT shu viloyatdagi ustalarga — qoida `visibility.py` da (7-qoida),
    feed bilan bir xil. Viloyati yo'q e'lon hech kimga ketmaydi. Mijozning
    o'ziga xabar ketmaydi.

    YOPIQ e'lon (mijoz aynan o'zi tanlagan ustalarga yuborgan) bu yerdan
    O'TMAYDI — aks holda "faqat shu ustaga" degan tanlov ma'nosini yo'qotardi.
    """
    from apps.accounts.models import User

    if not order.is_public:
        return 0

    # ⚠️ FILTR FEED BILAN AYNI MANBADAN (`visibility.py`): hudud ham,
    # yo'nalish ham. Ikki qoida ajralsa, usta e'lonni ro'yxatda ko'rib
    # turib bildirishnoma olmaydi (2026-08-08 shikoyati shundan chiqqan).
    masters = list(
        User.objects.filter(is_master=True, is_active=True)
        .exclude(pk=order.client_id)
        .filter(visibility.masters_for_order_q(order))
        .select_related("master_profile")
        .distinct()  # M2M join dublikat bermasin
    )

    app = AppKind.MASTER
    Notification.objects.bulk_create(
        [
            Notification(
                user=m,
                type=NotificationType.ORDER_PUBLISHED,
                title="Yangi buyurtma",
                body=order.title,
                order=order,
                app=app,
            )
            for m in masters
        ]
    )

    # O'qilmaganlar soni — HAMMA usta uchun BITTA so'rovda. Aylanish ichida
    # `.count()` qilish N+1 berardi: 100 usta = 100 so'rov, va yangi e'lon
    # e'lon qilish shuncha vaqt ushlanib turardi.
    unread_by_user = dict(
        Notification.objects.filter(
            app_filter(app), user__in=masters, is_read=False
        )
        .values_list("user")
        .annotate(n=Count("pk"))
    )

    # Bulk yozuv `notify()` dan o'tmaydi — hodisani shu yerda turtamiz.
    push_targets = []
    for m in masters:
        unread = unread_by_user.get(m.pk, 0)
        profile = getattr(m, "master_profile", None)
        accepts = profile.accepts_orders if profile else True
        if accepts:
            push_targets.append(m)
        realtime.push(
            m.pk,
            {
                "topic": NotificationType.ORDER_PUBLISHED,
                "order_id": order.pk,
                "unread_count": unread,
                # Ro'yxatda hammaga ko'rinadi; telefon push'i esa faqat
                # "buyurtma qabul qilaman" yoqilganlarga (pastda).
                "push": accepts,
            },
            app=app,
        )

    # Push BITTA chaqiruvda — tokenlar bitta so'rovda olinadi va yuborish fon
    # oqimida bo'ladi, shuning uchun e'lon qilish so'rovi kutib turmaydi.
    _safe_push(
        lambda: push.send_to_users(
            push_targets,
            "Yangi buyurtma",
            order.title,
            {"topic": NotificationType.ORDER_PUBLISHED, "order_id": order.pk},
            app=app,
        )
    )
    return len(masters)


# ───────────────────────── Mijoz taklifi (usta tanlash) ─────────────────


@transaction.atomic
def invite_masters(order: Order, masters) -> list:
    """
    Mijoz TANLAGAN ustalarga buyurtmani yuboradi.

    Har ustaga bitta taklif yozuvi (qayta yuborilsa — o'shanisi tiklanadi,
    dublikat bo'lmaydi). Ochiq e'londan farqi: bildirishnoma ham, push ham
    FAQAT shu ustalarga ketadi va matni boshqacha — "sizni tanlashdi".

    Mijozning o'zi (usta bo'lsa ham) taklif ro'yxatidan chiqarib tashlanadi.

    TA'MIR e'lonida (foydalanuvchi talabi 2026-09-21) "Ta'mirga chiqaman"
    degan ustalargina taklif qilinadi: belgini o'chirgan ustani mijoz
    tanlay olmasligi kerak. Ilova bunday ustani ro'yxatda ko'rsatmaydi,
    bu yerda esa oxirgi to'siq turadi (eski ilova yoki usta belgini
    keyinroq o'chirgan bo'lsa).
    """
    invited = []
    for master in masters:
        if master.pk == order.client_id:
            continue
        if order.is_repair and not visibility.master_does_repairs(master):
            continue
        invite, _ = OrderInvite.objects.update_or_create(
            order=order,
            master=master,
            defaults={"status": InviteStatus.PENDING, "decline_reason": ""},
        )
        invited.append(invite)
        notify(
            master,
            NotificationType.ORDER_INVITE,
            "Sizga taklif",
            f"{order.client} sizni tanladi — {order.title}",
            order,
        )
    return invited


@transaction.atomic
def decline_invite(order: Order, master, reason: str = "") -> OrderInvite:
    """
    Usta taklifni rad etadi. Buyurtma YOPILMAYDI — mijoz boshqa ustani
    taklif qilishi yoki e'lonni hammaga ochishi mumkin, shuning uchun unga
    darhol xabar ketadi.
    """
    try:
        invite = OrderInvite.objects.get(order=order, master=master)
    except OrderInvite.DoesNotExist:
        raise ValidationError("Sizga bu buyurtma bo'yicha taklif yuborilmagan.")
    if invite.status == InviteStatus.DECLINED:
        return invite

    invite.status = InviteStatus.DECLINED
    invite.decline_reason = reason[:255]
    invite.save(update_fields=["status", "decline_reason", "modified_at"])

    # Javob bergan bo'lsa — u ham bekor bo'ladi (fikridan qaytgan usta).
    OrderResponse.objects.filter(order=order, master=master).exclude(
        status=ResponseStatus.CHOSEN
    ).update(status=ResponseStatus.WITHDRAWN)

    notify(
        order.client,
        NotificationType.ORDER_INVITE_DECLINED,
        "Usta rad etdi",
        f"{master} — {order.title}",
        order,
    )
    return invite


@transaction.atomic
def open_order_to_everyone(order: Order) -> Order:
    """
    Yopiq e'lonni HAMMAGA ochadi (mijoz kutib charchadi yoki usta rad etdi).

    Bir tomonlama o'tish: ochilgan e'lonni qayta yopib bo'lmaydi — uni ko'rgan
    ustalardan yashirishning ma'nosi yo'q. Takliflar o'z holicha qoladi
    (mijoz kimni tanlaganini keyin ham ko'radi).
    """
    if order.status != OrderStatus.PUBLISHED:
        raise ValidationError("Faqat ochiq turgan e'lonni hammaga ochish mumkin.")
    if order.is_public:
        return order

    order.is_public = True
    order.save(update_fields=["is_public", "modified_at"])
    notify_masters_of_new_order(order)
    telegram.notify_new_order(order)
    return order


# ───────────────────────── Buyurtma o'tishlari ─────────────────────────


@transaction.atomic
def respond_to_order(order: Order, master, message: str = "") -> OrderResponse:
    """Usta "qabul qilaman" deydi. Narx TAKLIF QILINMAYDI — chatda kelishiladi."""
    if order.client_id == master.pk:
        raise ValidationError("O'z buyurtmangizga javob bera olmaysiz.")
    if not order.is_open_for_responses:
        raise ValidationError("Bu buyurtma javoblar uchun yopiq.")
    # YOPIQ e'lon — faqat taklif qilingan usta javob bera oladi. Aks holda
    # mijozning "aynan shu ustani chaqiraman" degan tanlovi buzilardi.
    if not order.is_visible_to(master):
        raise ValidationError("Bu buyurtma faqat taklif qilingan ustalar uchun.")

    response, created = OrderResponse.objects.update_or_create(
        order=order,
        master=master,
        defaults={
            "status": ResponseStatus.INTERESTED,
            "message": message,
        },
    )
    # Savdolashuv uchun suhbat darhol ochiladi.
    ChatThread.objects.get_or_create(order=order, master=master)

    # Taklif bo'yicha kelgan javob — taklif holati ham yopiladi, mijoz
    # ro'yxatida "javob kutilmoqda" bo'lib osilib qolmasin.
    OrderInvite.objects.filter(order=order, master=master).update(
        status=InviteStatus.ACCEPTED, decline_reason=""
    )

    notify(
        order.client,
        NotificationType.ORDER_RESPONSE,
        "Usta javob berdi",
        f"{master} — {order.title}",
        order,
    )
    telegram.refresh_order_post(order.pk)
    return response


@transaction.atomic
def withdraw_response(order: Order, master) -> OrderResponse:
    """Usta javobidan voz kechadi (tanlangandan keyin mumkin emas)."""
    try:
        response = OrderResponse.objects.get(order=order, master=master)
    except OrderResponse.DoesNotExist:
        raise ValidationError("Javob topilmadi.")
    if response.status == ResponseStatus.CHOSEN:
        raise ValidationError("Tanlangandan keyin voz kechib bo'lmaydi.")

    response.status = ResponseStatus.WITHDRAWN
    response.save(update_fields=["status", "modified_at"])
    telegram.refresh_order_post(order.pk)
    return response


@transaction.atomic
def choose_master(order: Order, response: OrderResponse) -> Order:
    """
    Mijoz ustani tanlaydi: buyurtma `assigned` bo'ladi va birinchi bosqich
    (`accepted`) ochiladi. Qolgan javoblar `rejected` bo'ladi.

    RACE CONDITION FIX (2026-08-18): select_for_update() prevents two concurrent
    clients from both selecting different masters. Lock until commit.
    """
    # Lock order row to prevent concurrent selection race
    order = Order.objects.select_for_update().get(pk=order.pk)

    if order.status != OrderStatus.PUBLISHED:
        raise ValidationError("Bu buyurtmada usta allaqachon tanlangan yoki yopiq.")
    if response.order_id != order.pk:
        raise ValidationError("Javob bu buyurtmaga tegishli emas.")
    if response.status == ResponseStatus.WITHDRAWN:
        raise ValidationError("Bu usta javobidan voz kechgan.")

    order.assigned_master = response.master
    order.status = OrderStatus.ASSIGNED
    order.stage = OrderStage.ACCEPTED
    order.save(update_fields=["assigned_master", "status", "stage", "modified_at"])

    response.status = ResponseStatus.CHOSEN
    response.save(update_fields=["status", "modified_at"])

    others = order.responses.exclude(pk=response.pk).exclude(
        status=ResponseStatus.WITHDRAWN
    )
    for other in others:
        other.status = ResponseStatus.REJECTED
        other.save(update_fields=["status", "modified_at"])
        notify(
            other.master,
            NotificationType.ORDER_NOT_CHOSEN,
            "Boshqa usta tanlandi",
            order.title,
            order,
        )

    # SHAXSAN taklif qilingan, lekin javob bermagan ustalar ham kutib
    # o'tirmasin: mijoz ularni ataylab tanlagan edi, endi esa boshqa usta
    # bilan kelishdi. Javob berganlari yuqorida xabar oldi (ularning
    # taklifi `accepted` bo'lgani uchun bu yerga TUSHMAYDI — bitta usta
    # ikki marta xabar olmaydi).
    waiting = (
        order.invites.filter(status=InviteStatus.PENDING)
        .exclude(master_id=response.master_id)
        .select_related("master")
    )
    for invite in waiting:
        notify(
            invite.master,
            NotificationType.ORDER_NOT_CHOSEN,
            "Boshqa usta tanlandi",
            order.title,
            order,
        )
    waiting.update(
        status=InviteStatus.DECLINED, decline_reason="Boshqa usta tanlandi"
    )

    OrderStageEvent.objects.create(
        order=order, stage=OrderStage.ACCEPTED, actor=order.client
    )
    notify(
        response.master,
        NotificationType.ORDER_CHOSEN,
        "Sizni tanlashdi!",
        order.title,
        order,
    )
    telegram.refresh_order_post(order.pk)
    return order


@transaction.atomic
def advance_stage(order: Order, actor, note: str = "") -> Order:
    """
    Ustani keyingi bosqichga o'tkazadi. Oxirgi bosqich (`handover`) yakunlanса
    buyurtma `completed` bo'ladi va mijozdan baho so'raladi.
    """
    if order.status != OrderStatus.ASSIGNED:
        raise ValidationError("Faqat usta tanlangan buyurtmada bosqich suriladi.")
    if actor.pk != order.assigned_master_id:
        raise PermissionDenied("Faqat tanlangan usta bosqichni o'zgartira oladi.")

    nxt = order.next_stage
    if nxt is None:
        # Oxirgi bosqichdaman — ishni yakunlayman.
        order.status = OrderStatus.COMPLETED
        order.completed_at = timezone.now()
        order.save(update_fields=["status", "completed_at", "modified_at"])
        notify(
            order.client,
            NotificationType.ORDER_COMPLETED,
            "Buyurtma yakunlandi",
            "Ustaga baho bering.",
            order,
        )
        telegram.refresh_order_post(order.pk)
        return order

    order.stage = nxt
    order.save(update_fields=["stage", "modified_at"])
    OrderStageEvent.objects.create(order=order, stage=nxt, actor=actor, note=note)
    notify(
        order.client,
        NotificationType.ORDER_STAGE,
        "Bosqich yangilandi",
        f"{order.get_stage_display()} ({order.stage_step}/{order.stage_total})",
        order,
    )
    return order


@transaction.atomic
def cancel_order(order: Order, actor, reason: str = "", force: bool = False) -> Order:
    """
    Mijoz buyurtmani bekor qiladi (yakunlangandan keyin mumkin emas).

    `force=True` — ADMIN majburiy bekor qilishi (admin panel API'si):
    egalik tekshiruvi o'tkazib yuboriladi va mijozning O'ZIGA ham xabar
    ketadi (u bekor qilishni so'ramagan — sababini bilishi kerak).
    Holat tekshiruvi (`completed`/`cancelled`) admin uchun ham kuchda.
    """
    if not force and actor.pk != order.client_id:
        raise PermissionDenied("Faqat mijoz bekor qila oladi.")
    if order.status in (OrderStatus.COMPLETED, OrderStatus.CANCELLED):
        raise ValidationError("Bu buyurtmani bekor qilib bo'lmaydi.")

    was_assigned = order.assigned_master_id
    order.status = OrderStatus.CANCELLED
    order.cancelled_reason = reason
    order.save(update_fields=["status", "cancelled_reason", "modified_at"])

    # Feed faqat `published` e'lonlarni beradi — demak bekor qilingan
    # buyurtma ustalarning ro'yxatidan O'ZI chiqib ketadi. Lekin ISHTIROK
    # ETGAN usta buni bilmay qoladi: kartasi jimgina yo'qoladi va u mijoz
    # javobini kutib o'tiraveradi (foydalanuvchi talabi 2026-08-08).
    #
    # Shuning uchun xabar UCHALASIGA ham ketadi:
    #   * tanlangan usta (ish boshlangan bo'lsa);
    #   * taklif bergan ustalar (voz kechganlaridan tashqari);
    #   * mijoz shaxsan tanlab yuborgan, hali javob bermagan ustalar.
    #
    # Xabar bilan birga WebSocket hodisasi ham ketadi (`notify` ichida) —
    # ilova ochiq bo'lsa ro'yxat DARHOL yangilanadi.
    for master in _masters_to_inform(order):
        notify(
            master,
            NotificationType.ORDER_CANCELLED,
            "Buyurtma bekor qilindi",
            order.title,
            order,
        )

    # Javob kutayotgan takliflar yopiladi — mijoz keyin buyurtmani ochsa
    # ham eski taklif "javob kutilmoqda" bo'lib osilib qolmasin.
    order.invites.filter(status=InviteStatus.PENDING).update(
        status=InviteStatus.DECLINED, decline_reason="Buyurtma bekor qilindi"
    )

    # Admin bekor qilganda mijoz ham xabardor bo'ladi (o'zi bekor qilganda
    # emas — u allaqachon biladi).
    if force and order.client_id:
        notify(
            order.client,
            NotificationType.ORDER_CANCELLED,
            "Buyurtma bekor qilindi",
            reason or order.title,
            order,
        )
    telegram.refresh_order_post(order.pk)
    return order


def _masters_to_inform(order: Order) -> list:
    """
    Buyurtma bekor qilinganda XABAR BERISH kerak bo'lgan ustalar.

    Faqat ISHTIROK ETGANLAR: e'lonni shunchaki ro'yxatda ko'rgan ustaga
    "bekor qilindi" deyish shovqin bo'lardi (ular uchun karta indamay
    yo'qolgani yetarli).

    Takrorlanmaydi: bitta usta ham tanlangan, ham javob bergan bo'lishi
    mumkin — u BITTA xabar oladi.
    """
    seen: dict[int, object] = {}

    if order.assigned_master_id:
        seen[order.assigned_master_id] = order.assigned_master

    responses = order.responses.exclude(
        status=ResponseStatus.WITHDRAWN
    ).select_related("master")
    for response in responses:
        seen.setdefault(response.master_id, response.master)

    invites = order.invites.filter(status=InviteStatus.PENDING).select_related(
        "master"
    )
    for invite in invites:
        seen.setdefault(invite.master_id, invite.master)

    return list(seen.values())


@transaction.atomic
def leave_review(order: Order, client, rating: int, comment: str = "") -> Review:
    """Mijoz yakunlangan buyurtmaga baho beradi (bir marta)."""
    if client.pk != order.client_id:
        raise PermissionDenied("Faqat mijoz baho bera oladi.")
    if order.status != OrderStatus.COMPLETED:
        raise ValidationError("Baho faqat yakunlangan buyurtmaga beriladi.")
    if not order.assigned_master_id:
        raise ValidationError("Bu buyurtmada usta yo'q.")
    if hasattr(order, "review"):
        raise ValidationError("Bahoni bir marta berish mumkin.")

    review = Review.objects.create(
        order=order,
        client=client,
        master=order.assigned_master,
        rating=rating,
        comment=comment,
    )
    notify(
        order.assigned_master,
        NotificationType.REVIEW_RECEIVED,
        "Yangi baho",
        f"{rating}★ — {order.title}",
        order,
    )
    return review


# ───────────────────────── Chat ─────────────────────────


@transaction.atomic
def send_message(thread: ChatThread, sender, text: str):
    """Suhbatga xabar yozadi va qarshi tomonga bildirishnoma yuboradi."""
    from apps.orders.models import ChatMessage

    if sender.pk not in thread.participant_ids():
        raise PermissionDenied("Bu suhbat sizga tegishli emas.")
    text = (text or "").strip()
    if not text:
        raise ValidationError("Xabar bo'sh bo'lmasin.")

    message = ChatMessage.objects.create(thread=thread, sender=sender, text=text)

    recipient_id = next(i for i in thread.participant_ids() if i != sender.pk)
    from apps.accounts.models import User

    recipient = User.objects.filter(pk=recipient_id).first()
    if recipient:
        notify(
            recipient,
            NotificationType.CHAT_MESSAGE,
            "Yangi xabar",
            text[:120],
            thread.order,
            thread_id=thread.pk,
        )
    return message


def expire_stale_orders() -> int:
    """
    Muddati o'tgan e'lonlarni `expired` qiladi. Cron/management buyrug'idan
    ham, ro'yxat so'ralganda ham chaqirilishi mumkin (arzon so'rov).
    """
    stale = Order.objects.filter(
        status=OrderStatus.PUBLISHED, expires_at__lte=timezone.now()
    )
    order_ids = list(stale.filter(is_public=True, telegram_message_id__isnull=False).values_list("pk", flat=True))
    updated = stale.update(status=OrderStatus.EXPIRED)
    for order_id in order_ids:
        telegram.refresh_order_post(order_id)
    return updated
