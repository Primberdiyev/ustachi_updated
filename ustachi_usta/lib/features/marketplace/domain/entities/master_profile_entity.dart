import 'package:equatable/equatable.dart';

class WorkSampleEntity extends Equatable {
  const WorkSampleEntity(
      {required this.id, required this.image, this.caption = ''});

  final int id;
  final String image;
  final String caption;

  @override
  List<Object?> get props => [id, image];
}

class PublicReviewEntity extends Equatable {
  const PublicReviewEntity({
    required this.id,
    required this.rating,
    this.comment = '',
    this.clientName = '',
    this.orderTitle = '',
    this.createdAt,
  });

  final int id;
  final int rating;
  final String comment;
  final String clientName;
  final String orderTitle;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, rating];
}

class MasterProfileEntity extends Equatable {
  const MasterProfileEntity({
    required this.id,
    this.fullName = '',
    this.photo,
    this.phoneNumber,
    this.regionName,
    this.districtName,
    this.specialty,
    this.specialties = const [],
    this.experienceYears,
    this.bio = '',
    this.isVerified = false,
    this.memberSince,
    this.rating,
    this.reviewsCount = 0,
    this.completedOrders = 0,
    this.inProgressOrders = 0,
    this.workSamples = const [],
    this.reviews = const [],
  });

  final int id;
  final String fullName;
  final String? photo;

  final String? phoneNumber;

  final String? regionName;
  final String? districtName;

  final String? specialty;
  final List<String> specialties;
  final int? experienceYears;
  final String bio;
  final bool isVerified;
  final DateTime? memberSince;

  final double? rating;
  final int reviewsCount;
  final int completedOrders;
  final int inProgressOrders;

  final List<WorkSampleEntity> workSamples;
  final List<PublicReviewEntity> reviews;

  String get displayName => fullName;

  @override
  List<Object?> get props => [id, rating, reviewsCount, completedOrders];
}
