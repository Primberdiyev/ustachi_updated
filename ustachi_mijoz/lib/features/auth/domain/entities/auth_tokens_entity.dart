import 'package:equatable/equatable.dart';

class AuthTokensEntity extends Equatable {
  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    this.roles = const [],
    this.isMaster = false,
    this.isAdmin = false,
    this.isNewUser = false,
  });

  final String? accessToken;
  final String? refreshToken;

  final List<String> roles;
  final bool isMaster;
  final bool isAdmin;

  final bool isNewUser;

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        roles,
        isMaster,
        isAdmin,
        isNewUser,
      ];
}
