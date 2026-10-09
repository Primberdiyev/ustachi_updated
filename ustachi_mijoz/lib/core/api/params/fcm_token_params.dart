import 'package:equatable/equatable.dart';

class FcmTokenParams extends Equatable {
  final String fcmToken;

  const FcmTokenParams({
    required this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'fcm_token': fcmToken};
  }

  @override
  List<Object?> get props => [fcmToken];
}
