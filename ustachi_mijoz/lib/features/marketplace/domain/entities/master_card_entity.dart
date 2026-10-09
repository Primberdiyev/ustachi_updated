import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:equatable/equatable.dart';

class MasterCardEntity extends Equatable {
  const MasterCardEntity({
    required this.id,
    required this.fullName,
    this.phoneNumber = '',
    this.photo,
    this.specialty,
    this.specialties = const [],
    this.rates = const [],
    this.notes = const [],
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

  final String phoneNumber;

  final String? photo;

  final String? specialty;
  final List<SpecialtyEntity> specialties;

  final List<MasterRateEntity> rates;

  final List<MasterNoteEntity> notes;
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

  bool matchesSearch(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    if (fullName.toLowerCase().contains(text) ||
        (specialty?.toLowerCase().contains(text) ?? false) ||
        specialties.any((s) => s.name.toLowerCase().contains(text))) {
      return true;
    }
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 4 &&
        phoneNumber.replaceAll(RegExp(r'[^0-9]'), '').contains(digits);
  }

  MasterRateEntity? rateFor(int? specialtyId) {
    if (specialtyId == null) return rates.firstOrNull;
    final codes =
        specialties.where((s) => s.id == specialtyId).map((s) => s.code);
    return rates
        .where((r) =>
            r.specialtyId == specialtyId ||
            (r.specialtyId == null && codes.contains(r.code)))
        .firstOrNull;
  }

  bool get hasProfile => specialty != null && experienceYears != null;

  String get location => [regionName, districtName]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  bool get hasPhone => phoneNumber.trim().isNotEmpty;

  @override
  List<Object?> get props =>
      [id, phoneNumber, rating, reviewsCount, completedOrders];
}
