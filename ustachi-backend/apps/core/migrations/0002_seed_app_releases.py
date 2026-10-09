"""
Har (ilova, platforma) uchun BO'SH qator — admin nolдан yaratmasin.

Qatorlar `is_active=False` bilan keladi: hech kimga oyna chiqmaydi.
Admin havolani yozib, versiyani ko'tarib, o'zi yoqadi. Shu tartib
tasodifan «hamma yangilansin» degan holatga tushib qolishning oldini
oladi.

`latest_version` — bugungi ilovalardagi versiya (mijoz 0.1.4, usta
1.0.0): kimdir qatorni ataylab yoqib qo'ysa ham, hech kim «eskisan»
degan xabar olmaydi.
"""

from django.db import migrations

SEED = [
    ("client", "android", "0.1.4"),
    ("client", "ios", "0.1.4"),
    ("master", "android", "1.0.0"),
    ("master", "ios", "1.0.0"),
]


def seed(apps, schema_editor):
    AppRelease = apps.get_model("core", "AppRelease")
    for app, platform, version in SEED:
        AppRelease.objects.get_or_create(
            app=app,
            platform=platform,
            defaults={
                "latest_version": version,
                "min_version": "",
                "store_url": "",
                "notes": "",
                "is_active": False,
            },
        )


def unseed(apps, schema_editor):
    AppRelease = apps.get_model("core", "AppRelease")
    AppRelease.objects.filter(
        app__in=["client", "master"], platform__in=["android", "ios"]
    ).delete()


class Migration(migrations.Migration):
    dependencies = [("core", "0001_initial")]
    operations = [migrations.RunPython(seed, unseed)]
