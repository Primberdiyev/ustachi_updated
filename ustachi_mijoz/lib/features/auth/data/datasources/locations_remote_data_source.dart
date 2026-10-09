import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/features/auth/data/models/location_model.dart';

abstract class LocationsRemoteDataSource {
  Future<List<LocationModel>> regions();

  Future<List<LocationModel>> districts({int? regionId});
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  LocationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<LocationModel>> regions() async {
    final response = await _dio.get(ApiUrls.locationsRegions);
    return LocationModel.listFrom(response.data);
  }

  @override
  Future<List<LocationModel>> districts({int? regionId}) async {
    final response = await _dio.get(
      ApiUrls.locationsDistricts,
      queryParameters: regionId == null ? null : {'region': regionId},
    );
    return LocationModel.listFrom(response.data);
  }
}
