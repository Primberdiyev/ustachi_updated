import 'package:ustachi/core/api/api_list.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/core/api/media_url.dart';

class MasterCardModel {
  static MasterCardEntity fromJson(Map<String, dynamic> json) => MasterCardEntity(
        id: json['id'] as int,
        fullName: json['full_name']?.toString() ?? '',
        photo: mediaUrl(json['photo']?.toString()),
        specialty: json['specialty']?.toString(),
        experienceYears: _int(json['experience_years']),
        regionName: json['region_name']?.toString(),
        districtName: json['district_name']?.toString(),
        rating: _double(json['rating']),
        reviewsCount: _int(json['reviews_count']) ?? 0,
        completedOrders: _int(json['completed_orders']) ?? 0,
        isVerified: json['is_verified'] == true,
        acceptsOrders: json['accepts_orders'] != false,
        workSamplesCount: _int(json['work_samples_count']) ?? 0,
        coverImage: json['cover_image']?.toString(),
      );

  static List<MasterCardEntity> listFrom(dynamic data) =>
      apiList(data)
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();

  static int? _int(Object? value) => switch (value) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v),
        _ => null,
      };

  static double? _double(Object? value) => switch (value) {
        final num v => v.toDouble(),
        final String v => double.tryParse(v),
        _ => null,
      };
}
