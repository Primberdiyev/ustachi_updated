"""Admin panel — manzil serializerlari."""
from rest_framework import serializers

from apps.locations.models import City, Region


class AdminRegionSerializer(serializers.ModelSerializer):
    cities_count = serializers.IntegerField(read_only=True, default=0)
    users_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = Region
        fields = ["id", "name", "cities_count", "users_count"]


class AdminCitySerializer(serializers.ModelSerializer):
    region_name = serializers.CharField(source="region.name", read_only=True, default=None)

    class Meta:
        model = City
        fields = ["id", "name", "region", "region_name"]
