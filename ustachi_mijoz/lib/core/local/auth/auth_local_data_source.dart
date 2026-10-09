import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/local/auth/token_model.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';

class AuthLocalDataSource {
  TokenModel? _userToken;

  TokenModel? get userToken => _userToken;

  bool get hasTokens => _userToken?.hasValue ?? false;

  Future<TokenModel?> getUserToken() async {
    final rawJson = StorageRepository.getString(StoreKeys.authTokens);
    if (rawJson.isEmpty) {
      _userToken = null;
      return null;
    }

    _userToken = TokenModel.fromRawJson(rawJson);
    return _userToken;
  }

  Future<bool> cacheTokens(TokenModel tokens) async {
    _userToken = tokens;
    return StorageRepository.putString(
      StoreKeys.authTokens,
      tokens.toRawJson(),
    );
  }

  Future<TokenModel?> cachePartialTokens(TokenModel tokens) async {
    final current =
        _userToken ?? const TokenModel(accessToken: '', refreshToken: '');

    final hasRoleInfo = tokens.roles.isNotEmpty || tokens.isMaster;

    final merged = current.copyWith(
      accessToken: tokens.accessToken.isEmpty ? null : tokens.accessToken,
      refreshToken: tokens.refreshToken.isEmpty ? null : tokens.refreshToken,
      roles: tokens.roles.isEmpty ? null : tokens.roles,
      isMaster: hasRoleInfo ? tokens.isMaster : null,
    );

    final saved = await cacheTokens(merged);
    return saved ? merged : null;
  }

  Future<void> clearUserData() async {
    _userToken = null;
    await StorageRepository.deleteString(StoreKeys.authTokens);
  }
}
