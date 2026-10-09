import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/api/dio_settings.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/local/auth/token_model.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/session_cleanup_service.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';

class CustomInterceptor implements Interceptor {
  CustomInterceptor(this.dio);

  static const String _retriedFlag = 'auth_retried';

  static const String refreshInBodyFlag = 'auth_refresh_in_body';

  static const String refreshBodyKey = 'refresh';

  final Dio dio;

  Future<TokenModel?>? _refreshOperation;

  String? _deadRefreshToken;

  final List<String> _publicUrls = [
    ApiUrls.clientSendCode,
    ApiUrls.clientVerifyCode,
    ApiUrls.clientTelegramExchange,
    ApiUrls.clientRefreshToken,
  ];

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final bool canRefresh = err.response?.statusCode == 401 &&
        !_isPublicRequest(requestOptions) &&
        requestOptions.extra[_retriedFlag] != true;

    if (!canRefresh) return handler.next(err);

    final tokens = await _ensureRefreshed(requestOptions.baseUrl);
    if (tokens == null) return handler.next(err);

    requestOptions.extra[_retriedFlag] = true;
    requestOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    _refreshBodyToken(requestOptions, tokens.refreshToken);

    try {
      return handler.resolve(await dio.fetch(requestOptions));
    } on DioException catch (e) {
      return handler.reject(e);
    } catch (_) {
      return handler.reject(err);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool isPublic = _isPublicRequest(options);

    if (isPublic) {
      if (options.headers.containsKey('Authorization')) {
        options.headers.remove('Authorization');
      }
    } else {
      final accessToken = sl<AuthLocalDataSource>().userToken?.accessToken;

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    options.headers['Accept-Language'] =
        StorageRepository.getString(StoreKeys.language, defValue: 'uz');

    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);
  }

  Future<TokenModel?> _ensureRefreshed(String baseUrl) {
    return _refreshOperation ??= _refreshToken(baseUrl).whenComplete(() {
      _refreshOperation = null;
    });
  }

  Future<TokenModel?> _refreshToken(String baseUrl) async {
    final refreshToken = _getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession(reason: 'refresh token saqlanmagan');
      return null;
    }

    if (refreshToken == _deadRefreshToken) return null;

    final Response<dynamic> response;
    try {
      response = await dio.post(
        "$baseUrl${ApiUrls.clientRefreshToken}",
        data: {'refresh': refreshToken},
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        await _expireSession(
          deadToken: refreshToken,
          reason: 'server refresh tokenni rad etdi ($status)',
        );
      } else {

        _log('refresh tarmoq xatosi: ${e.type}');
      }
      return null;
    } catch (e) {
      _log('refresh kutilmagan xato: $e');
      return null;
    }

    TokenModel? parsed;
    try {
      final data = response.data;
      if (data is Map) {
        parsed = TokenModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      _log('refresh javobini o\'qib bo\'lmadi: $e');
    }

    if (parsed == null || parsed.accessToken.isEmpty) {
      await _expireSession(
        deadToken: refreshToken,
        reason: 'refresh javobida access token yo\'q',
      );
      return null;
    }

    final saved = await sl<AuthLocalDataSource>().cachePartialTokens(parsed);
    if (saved == null) {
      await _expireSession(
        deadToken: refreshToken,
        reason: 'yangi tokenlar xotiraga yozilmadi',
      );
      return null;
    }

    _deadRefreshToken = null;
    return saved;
  }

  String? _getRefreshToken() {
    return sl<AuthLocalDataSource>().userToken?.refreshToken;
  }

  Future<void> _expireSession({String? deadToken, required String reason}) async {
    _log('sessiya tugatildi — $reason');

    if (deadToken != null) _deadRefreshToken = deadToken;

    final hadSession = sl<AuthLocalDataSource>().hasTokens;

    await sl<AuthLocalDataSource>().clearUserData();
    await StorageRepository.deleteString(StoreKeys.pinCode);

    await sl<SessionCleanupService>().clearSessionData();
    sl<DioSettings>().setBaseOptions(forceClearAuth: true);

    if (hadSession) {
      sl<AppRouter>().replaceAll([const PhoneAuthPageRoute()]);
    }
  }

  void _refreshBodyToken(RequestOptions options, String refreshToken) {
    if (options.extra[refreshInBodyFlag] != true) return;
    if (refreshToken.isEmpty) return;

    final data = options.data;
    if (data is Map) {
      data[refreshBodyKey] = refreshToken;
      _log('qayta yuborishда tanadagi refresh token yangilandi');
    }
  }

  bool _isPublicRequest(RequestOptions options) {
    final path = options.path;
    return _publicUrls.any((url) => path.contains(url));
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[auth] $message');
  }
}
