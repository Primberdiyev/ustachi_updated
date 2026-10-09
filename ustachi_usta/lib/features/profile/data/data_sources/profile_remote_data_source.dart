import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/features/profile/data/models/user_data_response.dart';

abstract class ProfileRemoteDataSource {
  Future<UserDataResponse> getUserData();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({
    required this.dio,
  });
  @override
  Future<UserDataResponse> getUserData() async {
    final response = await dio.get(ApiUrls.masterMe);
    final data = response.data;
    return UserDataResponse.fromJson(data);
  }
}
