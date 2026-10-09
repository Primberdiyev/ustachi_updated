import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.id,
    required this.phoneNumber,
    required this.isActive,
    this.roles = const [],
    this.isMaster = false,
    this.isSuperuser = false,
    this.fullName,
    this.photo,
    this.regionId,
    this.districtId,
    this.regionName,
    this.districtName,
    this.address,
    this.dateJoined,
  });

  final int id;
  final String phoneNumber;
  final bool isActive;

  final List<String> roles;
  final bool isMaster;
  final bool isSuperuser;

  final String? fullName;
  final String? photo;

  final int? regionId;
  final int? districtId;
  final String? regionName;
  final String? districtName;
  final String? address;

  final DateTime? dateJoined;

  bool get isProfileIncomplete => (fullName ?? '').trim().isEmpty;

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        isActive,
        roles,
        isMaster,
        isSuperuser,
        fullName,
        photo,
        regionId,
        districtId,
        regionName,
        districtName,
        address,
        dateJoined,
      ];
}
