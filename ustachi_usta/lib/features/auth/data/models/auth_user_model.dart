import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/core/api/media_url.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.phoneNumber,
    required super.isActive,
    super.roles,
    super.isMaster,
    super.isSuperuser,
    super.fullName,
    super.photo,
    super.regionId,
    super.districtId,
    super.regionName,
    super.districtName,
    super.address,
    super.dateJoined,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    var roles = rawRoles is List
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];
    final legacyType = json['user_type']?.toString();
    if (roles.isEmpty && legacyType != null && legacyType.isNotEmpty) {
      roles = legacyType == 'client' ? ['client'] : ['client', legacyType];
    }

    return AuthUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      roles: roles,
      isMaster: json['is_master'] as bool? ?? roles.contains('master'),
      isSuperuser: json['is_superuser'] as bool? ?? roles.contains('admin'),
      fullName: json['full_name']?.toString(),
      photo: mediaUrl(json['photo']?.toString()),
      regionId: (json['region'] as num?)?.toInt(),
      districtId: (json['district'] as num?)?.toInt(),
      regionName: json['region_name']?.toString(),
      districtName: json['district_name']?.toString(),
      address: json['address']?.toString(),
      dateJoined: DateTime.tryParse(json['date_joined']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        'is_active': isActive,
        'roles': roles,
        'is_master': isMaster,
        'is_superuser': isSuperuser,
        'full_name': fullName,
        'photo': photo,
        'region': regionId,
        'district': districtId,
        'region_name': regionName,
        'district_name': districtName,
        'address': address,
        'date_joined': dateJoined?.toIso8601String(),
      };
}
