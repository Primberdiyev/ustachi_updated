import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/api/interceptor/custom_interceptor.dart';
import 'package:ustachi/features/auth/data/models/auth_tokens_model.dart';
import 'package:ustachi/features/auth/data/models/auth_user_model.dart';
import 'package:ustachi/features/auth/data/models/send_code_result_model.dart';
import 'package:ustachi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';

abstract class AuthRemoteDataSource {
  Future<SendCodeResultModel> sendCode(SendCodeParams params);

  Future<AuthTokensModel> verifyCode(VerifyCodeParams params);

  Future<AuthTokensModel> exchangeTelegramCode(String code);

  Future<AuthUserModel> me();

  Future<AuthUserModel> updateMe(UpdateMeParams params);

  Future<void> logout(LogoutRequestParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Options get _formOptions =>
      Options(contentType: Headers.formUrlEncodedContentType);

  @override
  Future<SendCodeResultModel> sendCode(SendCodeParams params) async {
    final response = await _dio.post(
      ApiUrls.clientSendCode,
      data: params.toJson(),
      options: _formOptions,
    );

    return SendCodeResultModel.fromJson(_asMap(response.data));
  }

  @override
  Future<AuthTokensModel> verifyCode(VerifyCodeParams params) async {
    final response = await _dio.post(
      ApiUrls.clientVerifyCode,
      data: params.toJson(),
      options: _formOptions,
    );

    return AuthTokensModel.fromJson(
      _asMap(response.data),
      isNewUser: response.statusCode == 201,
    );
  }

  @override
  Future<AuthTokensModel> exchangeTelegramCode(String code) async {
    final response = await _dio.post(
      ApiUrls.clientTelegramExchange,
      data: {'code': code},
      options: _formOptions,
    );
    return AuthTokensModel.fromJson(_asMap(response.data));
  }

  @override
  Future<AuthUserModel> me() async {
    final response = await _dio.get(ApiUrls.clientMe);
    return AuthUserModel.fromJson(_asMap(response.data));
  }

  @override
  Future<AuthUserModel> updateMe(UpdateMeParams params) async {

    final formData = FormData.fromMap({
      if (params.fullName != null) 'full_name': params.fullName,
      if (params.photoPath != null)
        'photo': await MultipartFile.fromFile(params.photoPath!),

      if (params.regionId != null) 'region': params.regionId,
      if (params.districtId != null) 'district': params.districtId,
      if (params.address != null) 'address': params.address,
    });

    final response = await _dio.patch(ApiUrls.clientMe, data: formData);
    return AuthUserModel.fromJson(_asMap(response.data));
  }

  @override
  Future<void> logout(LogoutRequestParams params) async {
    await _dio.post(
      ApiUrls.clientLogout,
      data: params.toJson(),

      options: _formOptions.copyWith(
        extra: {CustomInterceptor.refreshInBodyFlag: true},
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }
}
