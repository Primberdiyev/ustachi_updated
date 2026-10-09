import 'package:equatable/equatable.dart';

class SendCodeResultEntity extends Equatable {
  const SendCodeResultEntity({
    required this.isNewUser,
    this.message,
  });

  final bool isNewUser;
  final String? message;

  @override
  List<Object?> get props => [isNewUser, message];
}
