
import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String phoneNumber;
  final String password;

  const LoginParams({required this.phoneNumber, required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phone_number': phoneNumber, 'password': password};
  }

  @override
  List<Object?> get props => [phoneNumber, password];
}
