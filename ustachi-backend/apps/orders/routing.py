from django.urls import path

from apps.orders.consumers import EventsConsumer

# Ilova BITTA ulanish ochadi va hamma hodisani shu yerdan oladi.
websocket_urlpatterns = [
    path("ws/events/", EventsConsumer.as_asgi()),
]
