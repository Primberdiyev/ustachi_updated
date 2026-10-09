"""
YO'NALISHLAR KATALOGI — boshlang'ich ma'lumot.

Bo'sh bazada ilovalar darhol ishlashi uchun: yo'nalishlar, maydon narxi
pog'onalari, variantlar, g'isht turlari va ta'mir muammolari. Manba —
`apps/accounts/data/specialty_catalog.json` (Django serializatsiya formati).

Qatorlar ID'lari bilan yoziladi (ilovalar variant/yo'nalish ID'sini
saqlaydi), shuning uchun oxirida ketma-ketliklar (sequence) tiklanadi —
PostgreSQL'da keyingi `INSERT` band ID'ga urilmasin.
"""

import json
from pathlib import Path

from django.core.management.color import no_style
from django.db import migrations

DATA_FILE = Path(__file__).resolve().parent.parent / "data" / "specialty_catalog.json"

#: Yozish tartibi — tashqi kalitlar bo'yicha (g'isht turi variantga bog'lanadi).
MODELS = [
    "MasterSpecialty",
    "SpecialtyAreaTier",
    "SpecialtyVariant",
    "SpecialtyBrick",
    "SpecialtyRepairProblem",
]


def seed(apps, schema_editor):
    rows = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    by_model: dict[str, list[dict]] = {}
    for row in rows:
        by_model.setdefault(row["model"], []).append(row)

    models = [apps.get_model("accounts", name) for name in MODELS]
    for model in models:
        fields = {f.name: f for f in model._meta.concrete_fields}
        objects = []
        for row in by_model.get(f"accounts.{model._meta.model_name}", []):
            values = {
                fields[name].attname: fields[name].to_python(value)
                for name, value in row["fields"].items()
            }
            objects.append(model(pk=row["pk"], **values))
        model.objects.using(schema_editor.connection.alias).bulk_create(objects)

    connection = schema_editor.connection
    statements = connection.ops.sequence_reset_sql(no_style(), models)
    with connection.cursor() as cursor:
        for sql in statements:
            cursor.execute(sql)


def unseed(apps, schema_editor):
    for name in reversed(MODELS):
        apps.get_model("accounts", name).objects.using(
            schema_editor.connection.alias
        ).all().delete()


class Migration(migrations.Migration):
    dependencies = [("accounts", "0001_initial")]
    operations = [migrations.RunPython(seed, unseed)]
