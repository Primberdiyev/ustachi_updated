class UserModel {
  final int id;
  final String phoneNumber;
  final String fullName;

  final List<String> roles;
  final bool isMaster;

  final bool isActive;
  final String dataJoined;
  final String photo;

  final int? regionId;
  final int? districtId;
  final String regionName;
  final String districtName;
  final String address;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.isActive,
    required this.dataJoined,
    required this.photo,
    this.roles = const [],
    this.isMaster = false,
    this.regionId,
    this.districtId,
    this.regionName = '',
    this.districtName = '',
    this.address = '',
  });

  bool get hasRequiredProfile =>
      fullName.trim().isNotEmpty &&
      (regionId != null || regionName.trim().isNotEmpty) &&
      (districtId != null || districtName.trim().isNotEmpty);

  String get locationLabel =>
      [regionName, districtName].where((e) => e.isNotEmpty).join(', ');

  factory UserModel.empty() => UserModel(
        id: 0,
        phoneNumber: '',
        fullName: '',
        isActive: true,
        dataJoined: '',
        photo: '',
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        phoneNumber: json['phone_number']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        roles: [
          for (final role in (json['roles'] as List? ?? const []))
            role.toString(),
        ],
        isMaster: json['is_master'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? false,
        dataJoined: json['date_joined']?.toString() ?? '',
        photo: json['photo']?.toString() ?? '',
        regionId: (json['region'] as num?)?.toInt(),
        districtId: (json['district'] as num?)?.toInt(),
        regionName: json['region_name']?.toString() ?? '',
        districtName: json['district_name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        'full_name': fullName,
        'roles': roles,
        'is_master': isMaster,
        'is_active': isActive,
        'date_joined': dataJoined,
        'photo': photo,
        'region': regionId,
        'district': districtId,
        'region_name': regionName,
        'district_name': districtName,
        'address': address,
      };
}
