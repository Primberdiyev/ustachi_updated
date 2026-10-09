import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  final int? id;
  final String middleName;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;

  const RegisterParams({
    this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.middleName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      "middle_name": middleName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        firstName,
        lastName,
        password,
      ];

  factory RegisterParams.fromMap(Map<String, dynamic> map) {
    return RegisterParams(
        id: map['id'] != null ? map['id'] as int : null,
        phoneNumber: map['phone_number'] as String,
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String,
        password: '',
        middleName: map['middle_name']);
  }
}
