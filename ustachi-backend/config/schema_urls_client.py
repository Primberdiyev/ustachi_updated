from django.urls import include, path


urlpatterns = [
    path("api/v1/client/auth/", include("apps.accounts.api.v1.urls.client")),
    path("api/v1/client/", include("apps.orders.api.v1.urls.client")),
]
