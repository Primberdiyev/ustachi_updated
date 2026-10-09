from django.urls import path

from apps.accounts.web.views import (
    delete_account_confirm,
    delete_account_done,
    delete_account_request,
)

app_name = "accounts_web"

urlpatterns = [
    path("delete/", delete_account_request, name="delete-account"),
    path("delete/confirm/", delete_account_confirm, name="delete-account-confirm"),
    path("delete/done/", delete_account_done, name="delete-account-done"),
]
