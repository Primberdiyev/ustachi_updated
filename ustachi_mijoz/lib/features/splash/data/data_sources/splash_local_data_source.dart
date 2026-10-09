import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/local/auth/token_model.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';

class SplashLocalDataSource {
  SplashLocalDataSource(this._authLocalDataSource);

  final AuthLocalDataSource _authLocalDataSource;

  Future<TokenModel?> getCachedTokens() {
    return _authLocalDataSource.getUserToken();
  }

  bool isFirstLaunch() {
    return StorageRepository.getBool(
      StoreKeys.isFirstTime,
      defValue: true,
    );
  }

  Future<void> clearSession() {
    return _authLocalDataSource.clearUserData();
  }
}
