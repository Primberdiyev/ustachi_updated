"""
WebSocket uchun JWT autentifikatsiyasi.

Brauzer/ilova WS ulanishida `Authorization` sarlavhasini qo'ya olmaydi,
shuning uchun token QUERY parametrida keladi: `?token=<access>`.
Sarlavha bilan kelsa (mobil klientlar qila oladi) u ham qabul qilinadi.
"""

from urllib.parse import parse_qs

from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from django.contrib.auth.models import AnonymousUser


@database_sync_to_async
def _user_from_token(raw_token: str):
    from rest_framework_simplejwt.exceptions import TokenError
    from rest_framework_simplejwt.tokens import AccessToken

    from apps.accounts.models import User

    try:
        token = AccessToken(raw_token)
        user_id = token.get("user_id")
    except (TokenError, KeyError, TypeError):
        return AnonymousUser()
    if user_id is None:
        return AnonymousUser()
    return User.objects.filter(pk=user_id).first() or AnonymousUser()


class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        raw = None

        query = parse_qs((scope.get("query_string") or b"").decode())
        if query.get("token"):
            raw = query["token"][0]

        if raw is None:
            for name, value in scope.get("headers", []):
                if name == b"authorization":
                    text = value.decode()
                    if text.lower().startswith("bearer "):
                        raw = text[7:]
                    break

        scope["user"] = await _user_from_token(raw) if raw else AnonymousUser()
        return await super().__call__(scope, receive, send)
