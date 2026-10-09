import 'package:ustachi/core/local/auth/token_model.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';

class AuthTokensModel extends AuthTokensEntity {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    super.roles,
    super.isMaster,
    super.isAdmin,
    super.isNewUser,
  });

  factory AuthTokensModel.fromJson(
    Map<String, dynamic> json, {
    bool isNewUser = false,
  }) {
    final rawRoles = json['roles'];
    var roles = rawRoles is List
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];
    final legacyType = _pick(json, const ['user_type', 'userType']);
    if (roles.isEmpty && legacyType != null) {
      roles = legacyType == 'client' ? ['client'] : ['client', legacyType];
    }

    return AuthTokensModel(
      accessToken: _pick(json, const ['access', 'access_token', 'accessToken']),
      refreshToken:
          _pick(json, const ['refresh', 'refresh_token', 'refreshToken']),
      roles: roles,
      isMaster: json['is_master'] as bool? ?? roles.contains('master'),
      isAdmin: json['is_admin'] as bool? ?? roles.contains('admin'),
      isNewUser: json['is_new_user'] as bool? ?? isNewUser,
    );
  }

  bool get hasTokens =>
      (accessToken ?? '').isNotEmpty || (refreshToken ?? '').isNotEmpty;

  Map<String, dynamic> toJson() => {
        'access': accessToken,
        'refresh': refreshToken,
        'roles': roles,
        'is_master': isMaster,
        'is_admin': isAdmin,
        'is_new_user': isNewUser,
      };

  TokenModel toLocalTokenModel() {
    return TokenModel(
      accessToken: accessToken ?? '',
      refreshToken: refreshToken ?? '',
      roles: roles,
      isMaster: isMaster,
    );
  }

  static String? _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
