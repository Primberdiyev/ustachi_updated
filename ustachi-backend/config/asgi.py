"""
ASGI — HTTP + WebSocket.

WebSocket real-time hodisalar uchun (buyurtma o'zgardi, usta javob berdi,
yangi xabar). Ishga tushirish:
    uvicorn config.asgi:application
yoki mavjud gunicorn xizmatida FAQAT worker klassini almashtirib:
    gunicorn config.asgi:application -k uvicorn.workers.UvicornWorker
"""

import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

from django.core.asgi import get_asgi_application  # noqa: E402

# Django ilovasi AVVAL yuklanishi shart — consumer/middleware modellarga tegadi.
django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter  # noqa: E402

from apps.orders.routing import websocket_urlpatterns  # noqa: E402
from apps.orders.ws_auth import JWTAuthMiddleware  # noqa: E402

application = ProtocolTypeRouter(
    {
        "http": django_asgi_app,
        "websocket": JWTAuthMiddleware(URLRouter(websocket_urlpatterns)),
    }
)
