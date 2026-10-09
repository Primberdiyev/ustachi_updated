import 'package:equatable/equatable.dart';

class RegisterPhoneParams extends Equatable {
  final int? user;
  final String phoneNumber;

  const RegisterPhoneParams({this.user, required this.phoneNumber});

  @override
  List<Object?> get props => [user, phoneNumber];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'user': user, 'phone_number': phoneNumber};
  }

  RegisterPhoneParams copyWith({int? user, String? phoneNumber}) {
    return RegisterPhoneParams(
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
