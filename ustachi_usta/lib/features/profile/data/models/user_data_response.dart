import 'package:ustachi/core/api/media_url.dart';

class UserDataResponse {
  final int id;
  final String? phoneNumber;
  final String? fullName;
  final List<String> roles;
  final bool isMaster;
  final bool? isActive;
  final String? dataJoined;
  final String? photo;
  final int? regionId;
  final int? districtId;
  final String? regionName;
  final String? districtName;
  final String? address;

  UserDataResponse({
    required this.id,
    this.phoneNumber,
    this.fullName,
    this.roles = const [],
    this.isMaster = false,
    this.isActive,
    this.dataJoined,
    this.photo,
    this.regionId,
    this.districtId,
    this.regionName,
    this.districtName,
    this.address,
  });

  factory UserDataResponse.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    var roles = rawRoles is List
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];
    final legacyType = json['user_type']?.toString();
    if (roles.isEmpty && legacyType != null && legacyType.isNotEmpty) {
      roles = legacyType == 'client' ? ['client'] : ['client', legacyType];
    }

    return UserDataResponse(
      id: json['id'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      roles: roles,
      isMaster: json['is_master'] as bool? ?? roles.contains('master'),
      isActive: json['is_active'],
      dataJoined: json['date_joined'] ?? json['data_joined'],
      photo: mediaUrl(json['photo']?.toString()) ?? '',
      regionId: (json['region'] as num?)?.toInt(),
      districtId: (json['district'] as num?)?.toInt(),
      regionName: json['region_name']?.toString(),
      districtName: json['district_name']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
