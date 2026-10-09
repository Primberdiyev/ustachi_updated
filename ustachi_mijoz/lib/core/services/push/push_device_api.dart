import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ustachi/core/api/api_urls.dart';

class PushDeviceApi {
  const PushDeviceApi(this._dio);

  final Dio _dio;

  static const String appName = 'client';

  static String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<bool> register(String token) async {
    try {
      await _dio.post(
        ApiUrls.clientDeviceRegister,

        data: {
          'token': token,
          'platform': _platform,
          'device_name': appName,
        },
      );
      return true;
    } on DioException catch (e) {
      debugPrint('[push] token ro\'yxatdan o\'tmadi: ${e.type}');
      return false;
    }
  }

  Future<void> unregister(String token) async {
    try {
      await _dio.post(ApiUrls.clientDeviceUnregister, data: {'token': token});
    } on DioException catch (e) {

      debugPrint('[push] token o\'chirilmadi: ${e.type}');
    }
  }
}
