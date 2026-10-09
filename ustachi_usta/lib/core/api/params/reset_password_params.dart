import 'package:equatable/equatable.dart';

class ResetPasswordParams extends Equatable {
  final String? secretKey;
  final String newPassword;

  const ResetPasswordParams({this.secretKey, required this.newPassword});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'secret_key': secretKey, 'password': newPassword};
  }

  @override
  List<Object?> get props => [secretKey, newPassword];

  ResetPasswordParams copyWith({String? secretKey, String? newPassword}) {
    return ResetPasswordParams(
      secretKey: secretKey ?? this.secretKey,
      newPassword: newPassword ?? this.newPassword,
    );
  }
}
