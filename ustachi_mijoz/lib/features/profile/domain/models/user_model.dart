class UserModel {
  final int id;
  final String phoneNumber;
  final String fullName;

  final List<String> roles;
  final bool isMaster;

  final bool isActive;
  final String dataJoined;
  final String photo;

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
    this.regionName = '',
    this.districtName = '',
    this.address = '',
  });

  String get locationLabel =>
      [regionName, districtName].where((e) => e.isNotEmpty).join(', ');

  factory UserModel.empty() => UserModel(
        id: 0,
        phoneNumber: '',
        fullName: 'Foydalanuvchi',
        isActive: true,
        dataJoined: '',
        photo: '',
      );
}
