"""
WebSocket consumer — foydalanuvchining shaxsiy hodisa kanali.

Ulanish: `ws(s)://<host>/ws/events/?token=<access_jwt>`
Ilova bitta ulanish ochadi va HAMMA hodisani shu yerdan oladi (buyurtma
o'zgardi, usta javob berdi, yangi xabar, bildirishnoma).

Hodisa YENGIL — faqat "nima o'zgardi":
    {"topic": "order_response", "order_id": 12, "unread_count": 3}
Ilova shu signalga qarab kerakli REST resursni qayta o'qiydi.

Kanal BIR TOMONLAMA: server → ilova. Ilovadan kelgan xabarlar e'tiborsiz
qoldiriladi (yozish uchun REST bor).
"""

import json
from urllib.parse import parse_qs

from channels.generic.websocket import AsyncWebsocketConsumer

from apps.orders.realtime import APPS, user_group


class EventsConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user = self.scope.get("user")
        if user is None or not getattr(user, "is_authenticated", False):
            # Token yo'q/yaroqsiz — ulanishga ruxsat berilmaydi.
            await self.close(code=4401)
            return

        app = parse_qs((self.scope.get("query_string") or b"").decode()).get(
            "app", [""]
        )[0]
        self.group = user_group(user.pk, app if app in APPS else "")
        await self.channel_layer.group_add(self.group, self.channel_name)
        await self.accept()
        # Ilova ulanganini bilsin (fallback so'rovni o'chirish uchun).
        await self.send(text_data=json.dumps({"topic": "connected"}))

    async def disconnect(self, code):
        group = getattr(self, "group", None)
        if group:
            await self.channel_layer.group_discard(group, self.channel_name)

    async def app_event(self, event):
        """`realtime.push()` yuborgan hodisani ilovaga uzatadi."""
        await self.send(text_data=json.dumps(event["payload"]))
