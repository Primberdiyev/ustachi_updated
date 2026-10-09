part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthCodeRequested extends AuthEvent {
  const AuthCodeRequested({required this.phoneNumber});

  final String phoneNumber;
}

class AuthCodeResendRequested extends AuthEvent {
  const AuthCodeResendRequested({required this.phoneNumber});

  final String phoneNumber;
}

class AuthCodeSubmitted extends AuthEvent {
  const AuthCodeSubmitted({
    required this.phoneNumber,
    required this.code,
  });

  final String phoneNumber;
  final String code;
}

class AuthProfileSubmitted extends AuthEvent {
  const AuthProfileSubmitted({
    required this.fullName,
    this.photoPath,
    this.regionId,
    this.districtId,
    this.address,
  });

  final String fullName;
  final String? photoPath;

  final int? regionId;
  final int? districtId;
  final String? address;
}
