import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';

class SendCodeResultModel extends SendCodeResultEntity {
  const SendCodeResultModel({
    required super.isNewUser,
    super.message,
  });

  factory SendCodeResultModel.fromJson(Map<String, dynamic> json) {
    return SendCodeResultModel(
      isNewUser: json['is_new_user'] as bool? ?? false,
      message: json['message']?.toString(),
    );
  }
}
