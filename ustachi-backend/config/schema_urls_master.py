from django.urls import include, path


urlpatterns = [
    path("api/v1/master/auth/", include("apps.accounts.api.v1.urls.master")),
    path("api/v1/master/", include("apps.orders.api.v1.urls.master")),
]
