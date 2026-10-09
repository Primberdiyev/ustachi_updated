import 'package:equatable/equatable.dart';

class MasterCardEntity extends Equatable {
  const MasterCardEntity({
    required this.id,
    required this.fullName,
    this.photo,
    this.specialty,
    this.experienceYears,
    this.regionName,
    this.districtName,
    this.rating,
    this.reviewsCount = 0,
    this.completedOrders = 0,
    this.isVerified = false,
    this.acceptsOrders = true,
    this.workSamplesCount = 0,
    this.coverImage,
  });

  final int id;
  final String fullName;
  final String? photo;

  final String? specialty;
  final int? experienceYears;

  final String? regionName;
  final String? districtName;

  final double? rating;
  final int reviewsCount;
  final int completedOrders;

  final bool isVerified;
  final bool acceptsOrders;

  final int workSamplesCount;
  final String? coverImage;

  bool get hasProfile => specialty != null && experienceYears != null;

  String get location => [regionName, districtName]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  @override
  List<Object?> get props => [id, rating, reviewsCount, completedOrders];
}
