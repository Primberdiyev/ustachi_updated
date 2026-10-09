"""
FCM sozlamasini TEKSHIRISH buyrug'i.

    python manage.py send_test_push --user 5
    python manage.py send_test_push --user 5 --app master
    python manage.py send_test_push --token <FCM_TOKEN>

Firebase kaliti yoki tokenlar noto'g'ri bo'lsa — shu yerda darhol ko'rinadi
(ilova oqimida push jimgina o'tkazib yuboriladi, chunki u majburiyat emas).
"""

from django.core.management.base import BaseCommand, CommandError

from apps.accounts.models import DeviceToken
from apps.accounts.models.device import app_filter
from apps.accounts.services import push


class Command(BaseCommand):
    help = "Sinov FCM push yuboradi (foydalanuvchi yoki token bo'yicha)."

    def add_arguments(self, parser):
        parser.add_argument("--user", type=int, help="Foydalanuvchi ID")
        parser.add_argument("--token", type=str, help="Bitta FCM token")
        parser.add_argument(
            "--app",
            choices=["client", "master"],
            default="",
            help="Faqat shu ilovaning tokenlari; berilmasa — hamma qurilma",
        )
        parser.add_argument("--title", default="Usta Top", help="Sarlavha")
        parser.add_argument("--body", default="Sinov bildirishnomasi", help="Matn")

    def handle(self, *args, **options):
        user_id, token = options.get("user"), options.get("token")
        if not user_id and not token:
            raise CommandError("--user yoki --token bering.")

        if token:
            tokens = [token]
        else:
            tokens = list(
                DeviceToken.objects.filter(
                    app_filter(options.get("app") or ""),
                    user_id=user_id,
                    is_active=True,
                ).values_list("token", flat=True)
            )
            if not tokens:
                raise CommandError(f"user={user_id} da faol qurilma tokeni yo'q.")

        if push._get_app() is None:
            raise CommandError(
                "Firebase ishga tushmadi — FIREBASE_CREDENTIALS yo'lini va "
                "FCM_ENABLED sozlamasini tekshiring."
            )

        sent = push.send_now(
            tokens, options["title"], options["body"], {"topic": "test"}
        )
        self.stdout.write(
            self.style.SUCCESS(f"{sent}/{len(tokens)} ta qurilmaga yuborildi.")
        )
