import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';

class AppUpdateApi {
  const AppUpdateApi(this._dio);

  final Dio _dio;

  static String? get platform {
    if (kIsWeb) return null;
    if (Platform.isIOS || Platform.isMacOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }

  Future<AppUpdateInfo?> check({required String version}) async {
    final target = platform;
    if (target == null || version.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiUrls.appVersion,
        queryParameters: {'platform': target, 'version': version},
        options: Options(

          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data;
      if (data == null) return null;
      return AppUpdateInfo.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
