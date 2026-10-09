import 'dart:convert';

class TokenModel {
  final String accessToken;
  final String refreshToken;

  final List<String> roles;
  final bool isMaster;

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.roles = const [],
    this.isMaster = false,
  });

  bool get hasValue => accessToken.isNotEmpty || refreshToken.isNotEmpty;

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    var roles = rawRoles is List
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];
    final legacyType = json['user_type']?.toString();
    if (roles.isEmpty && legacyType != null && legacyType.isNotEmpty) {
      roles = legacyType == 'client' ? ['client'] : ['client', legacyType];
    }

    return TokenModel(
      accessToken:
          (json['access'] ?? json['access_token'] ?? json['accessToken'] ?? '')
              .toString(),
      refreshToken: (json['refresh'] ??
              json['refresh_token'] ??
              json['refreshToken'] ??
              '')
          .toString(),
      roles: roles,
      isMaster: json['is_master'] as bool? ?? roles.contains('master'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      if (roles.isNotEmpty) 'roles': roles,
      'is_master': isMaster,
    };
  }

  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    List<String>? roles,
    bool? isMaster,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      roles: roles ?? this.roles,
      isMaster: isMaster ?? this.isMaster,
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory TokenModel.fromRawJson(String source) =>
      TokenModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
