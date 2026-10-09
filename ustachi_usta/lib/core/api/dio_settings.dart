import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/api/data/interseptors/pretty_dio_interceptor.dart';
import 'package:ustachi/core/api/interceptor/custom_interceptor.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:flutter/foundation.dart';

typedef ConverterFunctionType<T> = T Function(dynamic response);

class DioSettings {
  final BaseOptions _dioBaseOptions = BaseOptions(
    baseUrl: ApiUrls.baseUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(minutes: 1),
    receiveTimeout: const Duration(minutes: 1),
    followRedirects: false,
    validateStatus: (status) => status != null && status >= 200 && status < 300,
  );

  BaseOptions get dioBaseOptions => _dioBaseOptions;

  void setBaseOptions({bool forceClearAuth = false}) {
    if (forceClearAuth ||
        (_dioBaseOptions.headers.containsKey('Authorization') &&
            !sl<AuthLocalDataSource>().hasTokens)) {
      _dioBaseOptions.headers.remove('Authorization');
    }
  }

  Dio get dio {
    final dio = Dio(_dioBaseOptions);
    dio.interceptors.add(CustomInterceptor(dio));
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  }

  Dio get publicDio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.transformer = BackgroundTransformer();
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  }
}
