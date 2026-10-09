import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';
import 'package:ustachi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';

class AuthRepositoryImpl with SafeCaller implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  PushNotificationService? get _push => sl.isRegistered<PushNotificationService>()
      ? sl<PushNotificationService>()
      : null;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<Either<Failure, SendCodeResultEntity>> sendCode(
    SendCodeParams params,
  ) {
    return safeCall(() => _remoteDataSource.sendCode(params));
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> verifyCode(
    VerifyCodeParams params,
  ) {
    return safeCall(() async {
      final tokens = await _remoteDataSource.verifyCode(params);
      if (tokens.hasTokens) {
        await _authLocalDataSource.clearProfileCache();
        await _authLocalDataSource.cacheTokens(tokens.toLocalTokenModel());
        unawaited(_push?.syncToken() ?? Future<void>.value());
      }
      return tokens;
    });
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> exchangeTelegramCode(String code) {
    return safeCall(() async {
      final tokens = await _remoteDataSource.exchangeTelegramCode(code);
      if ((tokens.accessToken ?? '').isEmpty || (tokens.refreshToken ?? '').isEmpty) {
        throw const FormatException('Telegram auth tokenlari to\'liqicha kelmadi');
      }
      await _authLocalDataSource.clearProfileCache();
      await _authLocalDataSource.cacheTokens(tokens.toLocalTokenModel());
      unawaited(_push?.syncToken() ?? Future<void>.value());
      return tokens;
    });
  }

  @override
  Future<Either<Failure, AuthUserEntity>> me() {
    return safeCall(_remoteDataSource.me);
  }

  @override
  Future<Either<Failure, AuthUserEntity>> updateMe(UpdateMeParams params) {
    return safeCall(() => _remoteDataSource.updateMe(params));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _push?.forgetToken();

    final refreshToken = _authLocalDataSource.userToken?.refreshToken ?? '';
    try {
      if (refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(
          LogoutRequestParams(refresh: refreshToken),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[auth] logout server xatosi (e\'tiborsiz): $e');
    } finally {
      await _authLocalDataSource.clearUserData();
    }
    return Right(null);
  }
}
