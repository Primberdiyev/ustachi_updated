
import 'package:equatable/equatable.dart';

class RegisterVerifyOtpParams extends Equatable {
  final String? uniqueString;
  final String otpCode;

  const RegisterVerifyOtpParams({this.uniqueString, required this.otpCode});

  @override
  List<Object?> get props => [uniqueString, otpCode];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'unique_string': uniqueString,
      'otp_code': otpCode
    };
  }

  RegisterVerifyOtpParams copyWith({String? uniqueString, String? otpCode}) {
    return RegisterVerifyOtpParams(
      uniqueString: uniqueString ?? this.uniqueString,
      otpCode: otpCode ?? this.otpCode,
    );
  }
}
