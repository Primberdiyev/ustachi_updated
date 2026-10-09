import 'package:equatable/equatable.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';

class SendCodeUseCase extends UseCase<SendCodeResultEntity, SendCodeParams> {
  SendCodeUseCase(AuthRepository repository) : _repository = repository;

  final AuthRepository _repository;

  @override
  Future<Either<Failure, SendCodeResultEntity>> call(SendCodeParams params) {
    return _repository.sendCode(params);
  }
}

class SendCodeParams extends Equatable {
  const SendCodeParams({required this.phoneNumber});

  final String phoneNumber;

  Map<String, dynamic> toJson() => {'phone_number': phoneNumber};

  @override
  List<Object?> get props => [phoneNumber];
}
