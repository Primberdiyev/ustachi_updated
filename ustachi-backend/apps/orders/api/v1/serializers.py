"""Buyurtma / javob / chat / bildirishnoma serializerlari (client + master)."""

from rest_framework import serializers

from apps.common.media import absolute_media_url
from apps.orders.models import (
    ChatMessage,
    ChatThread,
    InviteStatus,
    Notification,
    Order,
    OrderInvite,
    OrderResponse,
    OrderStage,
    OrderStageEvent,
    Review,
)


class UserBriefSerializer(serializers.Serializer):
    """Ro'yxatlarda ko'rinadigan qisqa foydalanuvchi kartasi."""

    id = serializers.IntegerField()
    full_name = serializers.CharField()
    phone_number = serializers.CharField()
    photo = serializers.SerializerMethodField()

    def get_photo(self, obj):
        # TO'LIQ URL: ilova nisbiy yo'lni ko'rsata olmaydi (host'ni bilmaydi).
        return absolute_media_url(
            getattr(obj, "photo", None), self.context.get("request")
        )


class MasterBriefSerializer(UserBriefSerializer):
    """Usta kartasi — reyting va tajriba bilan (mijoz tanlov qilishi uchun).

    N+1 FIX (2026-08-18): Rating va reviews_count cached in serializer context,
    not queried per master.
    """

    specialty = serializers.SerializerMethodField()
    experience_years = serializers.SerializerMethodField()
    rating = serializers.SerializerMethodField()
    reviews_count = serializers.SerializerMethodField()

    def _profile(self, obj):
        return getattr(obj, "master_profile", None)

    def get_specialty(self, obj):
        profile = self._profile(obj)
        return profile.specialty.name if profile else None

    def get_experience_years(self, obj):
        profile = self._profile(obj)
        return profile.experience_years if profile else None

    def get_rating(self, obj):
        # Check if cached in context (prefetched reviews)
        cached_ratings = self.context.get("_cached_ratings", {})
        if obj.pk in cached_ratings:
            return cached_ratings[obj.pk].get("rating")

        # Fallback to query (should not happen if prefetched correctly)
        from django.db.models import Avg
        agg = obj.received_reviews.aggregate(v=Avg("rating"))["v"]
        return round(agg, 1) if agg else None

    def get_reviews_count(self, obj):
        # Check if cached in context (prefetched reviews)
        cached_ratings = self.context.get("_cached_ratings", {})
        if obj.pk in cached_ratings:
            return cached_ratings[obj.pk].get("count", 0)

        # Fallback to query (should not happen if prefetched correctly)
        return obj.received_reviews.count()


class OrderStageEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderStageEvent
        fields = ["id", "stage", "note", "created_at"]


class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ["id", "rating", "comment", "created_at"]
        read_only_fields = ["id", "created_at"]


class OrderResponseSerializer(serializers.ModelSerializer):
    """
    Usta javobi — mijoz ro'yxatida ko'rinadi.

    Usta ERKIN narx yozmaydi (kelishuv chatda). Ba'zi yo'nalishlarda mijoz
    har usta uchun "xizmati bilan qancha bo'ladi"ni ko'radi
    (`service_total`); hisoblab bo'lmasa u `null`.

    N+1 FIX (2026-08-18): thread_id cached in context to avoid per-response query.
    """

    master = MasterBriefSerializer(read_only=True)
    thread_id = serializers.SerializerMethodField()
    service_total = serializers.SerializerMethodField()

    class Meta:
        model = OrderResponse
        fields = [
            "id",
            "master",
            "status",
            "message",
            "thread_id",
            "service_total",
            "created_at",
        ]
        read_only_fields = fields

    def get_thread_id(self, obj):
        # Check if cached in context (prefetched threads)
        cached_threads = self.context.get("_cached_threads", {})
        key = (obj.order_id, obj.master_id)
        if key in cached_threads:
            return cached_threads[key]

        # Fallback to query (should not happen if prefetched correctly)
        thread = obj.order.threads.filter(master_id=obj.master_id).first()
        return thread.pk if thread else None

    def get_service_total(self, obj):
        """
        "Shu ustani chaqirsam qancha bo'ladi" — mijoz shu raqam bo'yicha
        ustalarni taqqoslaydi (`apps/orders/response_total.py` da to'liq
        izohlangan). Hisoblab bo'lmasa `None` — narx chatda kelishiladi.
        """
        from apps.orders import penthouse_pricing, response_total

        if penthouse_pricing.applies(obj.order.specialty, obj.order.proposal):
            return obj.order.calculated_price

        # Material narxi ko'rsatiladigan sohalar (kafel, g'isht, zina): ish
        # haqi ustaning O'Z stavkasidan chiqadi. Stavka qo'yilmagan bo'lsa
        # `None` qaytadi va mijozga narx ko'rsatilmaydi.
        if response_total.uses_master_rate(obj.order):
            return response_total.total_by_rate(obj.order, obj.master)

        return None


class OrderInviteSerializer(serializers.ModelSerializer):
    """
    Mijoz TANLAB yuborgan usta va uning javobi.

    Mijoz o'z buyurtmasida "kimga yubordim va nima bo'ldi"ni ko'radi:
    kutilmoqda / qabul qildi / rad etdi (sababi bilan).
    """

    master = MasterBriefSerializer(read_only=True)

    class Meta:
        model = OrderInvite
        fields = ["id", "master", "status", "decline_reason", "created_at"]
        read_only_fields = fields


class MasterAudienceMixin:
    """
    USTA so'ragan bo'lsa suratdan material tannarxi olib tashlanadi
    (`apps/orders/master_view.py` da izohlangan). Mijoz suratida hammasi
    joyida qoladi — shuning uchun `audience` kontekstda beriladi.
    """

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if self.context.get("audience") == "master":
            from apps.orders import master_view

            return master_view.for_master(data)
        return data


class OrderSerializer(MasterAudienceMixin, serializers.ModelSerializer):
    """Buyurtma to'liq ko'rinishi."""

    client = UserBriefSerializer(read_only=True)
    assigned_master = MasterBriefSerializer(read_only=True)
    invites = OrderInviteSerializer(many=True, read_only=True)
    stage_step = serializers.IntegerField(read_only=True)
    stage_total = serializers.SerializerMethodField()
    responses_count = serializers.SerializerMethodField()
    stage_events = OrderStageEventSerializer(many=True, read_only=True)
    review = ReviewSerializer(read_only=True)
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)
    district_name = serializers.CharField(
        source="district.name", read_only=True, default=None
    )
    #: Yo'nalish (soha): `code` — ilova uchun barqaror kalit (ikonka, rom
    #: tekshiruvi), `name` — ekranda ko'rsatiladigan nom.
    specialty_code = serializers.CharField(
        source="specialty.code", read_only=True, default=None
    )
    specialty_name = serializers.CharField(
        source="specialty.name", read_only=True, default=None
    )

    class Meta:
        model = Order
        fields = [
            "id",
            "title",
            "description",
            "proposal",
            "calculated_price",
            "specialty",
            "specialty_code",
            "specialty_name",
            "client",
            "assigned_master",
            "region",
            "region_name",
            "district",
            "district_name",
            "address",
            "status",
            "is_public",
            "is_repair",
            "invites",
            "stage",
            "stage_step",
            "stage_total",
            "responses_count",
            "stage_events",
            "review",
            "expires_at",
            "completed_at",
            "cancelled_reason",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "specialty",
            "specialty_code",
            "specialty_name",
            "client",
            "assigned_master",
            "status",
            "is_public",
            "is_repair",
            "invites",
            "stage",
            "completed_at",
            "cancelled_reason",
            "created_at",
        ]

    def get_stage_total(self, obj):
        return obj.stage_total

    def get_responses_count(self, obj):
        return obj.responses.exclude(status="withdrawn").count()


def master_ids_field(**kwargs):
    """
    Usta ID'lari maydoni — mavjudligi VA ustaligi shu yerda tekshiriladi.

    Funksiya sifatida (sinf emas): `many=True` ni `PrimaryKeyRelatedField`
    `__new__` bosqichida olishi kerak, `__init__` da kech bo'ladi.
    Bitta joyda turgani muhim — buyurtma yaratishda ham, keyin "yana usta
    taklif qilish"da ham AYNAN bir xil qoida ishlaydi.
    """
    from apps.accounts.models import User

    kwargs.setdefault("required", False)
    return serializers.PrimaryKeyRelatedField(
        many=True,
        write_only=True,
        queryset=User.objects.filter(is_master=True, is_active=True),
        **kwargs,
    )


class OrderInviteCreateSerializer(serializers.Serializer):
    """Mavjud buyurtmaga qo'shimcha usta taklif qilish."""

    master_ids = master_ids_field(required=True, allow_empty=False)


class OrderCreateSerializer(serializers.ModelSerializer):
    """
    Mijoz e'lon yaratadi. Holat/bosqich serverda belgilanadi.

    `master_ids` berilsa — e'lon YOPIQ bo'ladi (`is_public=False`) va faqat
    o'sha ustalarga ketadi. Berilmasa — eski xulq: hududdagi hammaga.
    """

    master_ids = master_ids_field()

    def validate(self, attrs):
        from apps.orders import penthouse_pricing
        proposal = attrs.get("proposal")
        specialty = attrs.get("specialty")
        if (specialty is not None and specialty.code == "tom"
                and isinstance(proposal, dict)
                and (proposal.get("variant") == penthouse_pricing.VARIANT
                     or proposal.get("roof_material") == "waterproofing")):
            raise serializers.ValidationError({"specialty": "Bu xizmat uchun Penthaus gidro tom yo‘nalishini tanlang."})
        if penthouse_pricing.applies(attrs.get("specialty"), proposal):
            try:
                area, total = penthouse_pricing.quote(proposal)
            except ValueError as exc:
                raise serializers.ValidationError({"proposal": str(exc)})
            attrs["calculated_price"] = total
            attrs["proposal"] = {**proposal, "area_m2": float(area),
                "unit": "m²", "unit_price": penthouse_pricing.UNIT_PRICE,
                "cost_price": total, "total_price": total,
                "fixed_price": True, "includes_labor": True}
        return attrs

    class Meta:
        model = Order
        fields = [
            "title",
            "description",
            "proposal",
            "calculated_price",
            "specialty",
            # TA'MIR e'loni (2026-09-21): mijoz "ta'mir" bo'limidan bersa
            # `true` keladi va e'lon faqat ta'mirga chiqadigan ustalarga
            # ko'rinadi.
            "is_repair",
            "region",
            "district",
            "address",
            "expires_at",
            "master_ids",
        ]
        extra_kwargs = {"expires_at": {"required": False}}

    def validate_calculated_price(self, value):
        if value < 0:
            raise serializers.ValidationError("Narx manfiy bo'lmaydi.")
        return value


class OrderFeedSerializer(MasterAudienceMixin, serializers.ModelSerializer):
    """
    Usta feed'idagi qisqa karta. Mijoz telefoni BERILMAYDI — aloqa faqat
    javob bergandan keyin (chat) ochiladi.
    """

    client_name = serializers.CharField(source="client.full_name", read_only=True)
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)
    district_name = serializers.CharField(
        source="district.name", read_only=True, default=None
    )
    my_response_status = serializers.SerializerMethodField()
    responses_count = serializers.SerializerMethodField()
    #: Mijoz AYNAN shu ustani tanlab yuborganmi (feed'da alohida ajratiladi).
    is_invited = serializers.SerializerMethodField()
    invite_status = serializers.SerializerMethodField()
    specialty_code = serializers.CharField(
        source="specialty.code", read_only=True, default=None
    )
    specialty_name = serializers.CharField(
        source="specialty.name", read_only=True, default=None
    )

    class Meta:
        model = Order
        fields = [
            "id",
            "title",
            "description",
            "proposal",
            "calculated_price",
            "specialty_code",
            "specialty_name",
            "client_name",
            "region_name",
            "district_name",
            "address",
            "status",
            "is_public",
            # Usta kartada DARHOL ko'rsin: bu yangi ish emas, ta'mir.
            "is_repair",
            "is_invited",
            "invite_status",
            "expires_at",
            "responses_count",
            "my_response_status",
            "created_at",
        ]

    def _invite(self, obj):
        user = self.context["request"].user
        # `prefetch_related("invites")` bilan kelganda qo'shimcha so'rov YO'Q.
        return next((i for i in obj.invites.all() if i.master_id == user.pk), None)

    def get_is_invited(self, obj):
        return self._invite(obj) is not None

    def get_invite_status(self, obj):
        invite = self._invite(obj)
        return invite.status if invite else None

    def get_my_response_status(self, obj):
        user = self.context["request"].user
        response = next(
            (r for r in obj.responses.all() if r.master_id == user.pk), None
        )
        return response.status if response else None

    def get_responses_count(self, obj):
        return sum(1 for r in obj.responses.all() if r.status != "withdrawn")


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "type", "title", "body", "order", "is_read", "created_at"]
        read_only_fields = fields


#: Sahifa hajmi. Ilova ham shuni so'raydi; server chegarani O'ZI ushlaydi,
#: shunda mijoz "hammasini ber" deb server xotirasini yeya olmaydi.
DEFAULT_CHAT_PAGE = 50
MAX_CHAT_PAGE = 100


class ChatMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source="sender.full_name", read_only=True)
    is_mine = serializers.SerializerMethodField()

    class Meta:
        model = ChatMessage
        fields = ["id", "text", "sender", "sender_name", "is_mine", "is_read", "created_at"]
        read_only_fields = ["id", "sender", "sender_name", "is_mine", "is_read", "created_at"]

    def get_is_mine(self, obj):
        request = self.context.get("request")
        return bool(request and obj.sender_id == request.user.pk)


class ChatHistoryQuerySerializer(serializers.Serializer):
    """
    Suhbat tarixini SAHIFALAB o'qish parametrlari.

    Uchta rejim, hammasi bitta endpointda:
      * `limit` — eng SO'NGGI shuncha xabar (chat ochilganda);
      * `before=<id>` — o'sha xabardan OLDINGI sahifa (tepaga surilganda);
      * `after=<id>`  — o'sha xabardan KEYINGILARI (jonli yangilanish).

    Hech biri berilmasa — BUTUN tarix. Bu ataylab: do'kondagi eski
    ilovalar sahifalashni bilmaydi va ular uchun javob o'zgarmasligi kerak.
    """

    limit = serializers.IntegerField(
        required=False, min_value=1, max_value=MAX_CHAT_PAGE
    )
    before = serializers.IntegerField(required=False, min_value=1)
    after = serializers.IntegerField(required=False, min_value=1)

    def validate(self, attrs):
        if "before" in attrs and "after" in attrs:
            raise serializers.ValidationError(
                "`before` va `after` birga berilmaydi — yo'nalish noaniq bo'ladi."
            )
        return attrs


class ChatThreadSerializer(serializers.ModelSerializer):
    """Suhbat ro'yxati kartasi — qarshi tomon + oxirgi xabar + o'qilmaganlar."""

    order_title = serializers.CharField(source="order.title", read_only=True)
    peer = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatThread
        fields = [
            "id",
            "order",
            "order_title",
            "peer",
            "last_message",
            "unread_count",
            "last_message_at",
            "created_at",
        ]

    def _me(self):
        request = self.context.get("request")
        return request.user if request else None

    def get_peer(self, obj):
        me = self._me()
        peer = obj.order.client if me and me.pk == obj.master_id else obj.master
        return UserBriefSerializer(peer).data

    def get_last_message(self, obj):
        message = obj.messages.order_by("-created_at").first()
        return (
            {"text": message.text, "created_at": message.created_at}
            if message
            else None
        )

    def get_unread_count(self, obj):
        me = self._me()
        if not me:
            return 0
        return obj.messages.filter(is_read=False).exclude(sender=me).count()
