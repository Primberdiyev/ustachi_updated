import 'package:ustachi/features/profile/data/models/user_data_response.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';

extension UserModelWrapper on UserDataResponse {
  UserModel toEntity() {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber ?? '',
      fullName: fullName ?? '',
      roles: roles,
      isMaster: isMaster,
      isActive: isActive ?? false,
      dataJoined: dataJoined ?? '',
      photo: photo ?? '',
      regionId: regionId,
      districtId: districtId,
      regionName: regionName ?? '',
      districtName: districtName ?? '',
      address: address ?? '',
    );
  }
}
