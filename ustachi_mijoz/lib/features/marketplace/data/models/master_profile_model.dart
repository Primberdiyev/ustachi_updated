import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/core/api/media_url.dart';

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
int _int(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
String _str(dynamic v) => v?.toString() ?? '';
double? _double(dynamic v) => v == null
    ? null
    : (v is num ? v.toDouble() : double.tryParse(v.toString()));

class MasterProfileModel extends MasterProfileEntity {
  const MasterProfileModel({
    required super.id,
    super.fullName,
    super.photo,
    super.phoneNumber,
    super.regionName,
    super.districtName,
    super.specialty,
    super.specialties,
    super.rates,
    super.notes,
    super.experienceYears,
    super.bio,
    super.isVerified,
    super.memberSince,
    super.rating,
    super.reviewsCount,
    super.completedOrders,
    super.inProgressOrders,
    super.workSamples,
    super.reviews,
  });

  factory MasterProfileModel.fromJson(Map<String, dynamic> json) {
    final samples = json['work_samples'];
    final reviews = json['reviews'];
    return MasterProfileModel(
      id: _int(json['id']),
      fullName: _str(json['full_name']),
      photo: mediaUrl(json['photo']?.toString()),
      phoneNumber: json['phone_number']?.toString(),
      regionName: json['region_name']?.toString(),
      districtName: json['district_name']?.toString(),
      specialty: json['specialty']?.toString(),
      specialties: SpecialtyEntity.listFrom(json['specialties']),
      rates: MasterRateEntity.listFrom(json['rates']),
      notes: MasterNoteEntity.listFrom(json['notes']),
      experienceYears: json['experience_years'] == null
          ? null
          : _int(json['experience_years']),
      bio: _str(json['bio']),
      isVerified: json['is_verified'] == true,
      memberSince: _date(json['member_since']),
      rating: _double(json['rating']),
      reviewsCount: _int(json['reviews_count']),
      completedOrders: _int(json['completed_orders']),
      inProgressOrders: _int(json['in_progress_orders']),
      workSamples: samples is List
          ? samples.whereType<Map>().map((e) {
              final m = Map<String, dynamic>.from(e);
              return WorkSampleEntity(
                id: _int(m['id']),
                image: _str(m['image']),
                caption: _str(m['caption']),
              );
            }).toList()
          : const [],
      reviews: reviews is List
          ? reviews.whereType<Map>().map((e) {
              final m = Map<String, dynamic>.from(e);
              return PublicReviewEntity(
                id: _int(m['id']),
                rating: _int(m['rating']),
                comment: _str(m['comment']),
                clientName: _str(m['client_name']),
                orderTitle: _str(m['order_title']),
                createdAt: _date(m['created_at']),
              );
            }).toList()
          : const [],
    );
  }
}
