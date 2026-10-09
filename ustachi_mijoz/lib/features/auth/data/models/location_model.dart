import 'package:ustachi/features/auth/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  static List<LocationModel> listFrom(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
