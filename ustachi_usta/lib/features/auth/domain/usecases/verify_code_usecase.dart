import 'package:equatable/equatable.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';

class VerifyCodeUseCase extends UseCase<AuthTokensEntity, VerifyCodeParams> {
  VerifyCodeUseCase(AuthRepository repository) : _repository = repository;

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthTokensEntity>> call(VerifyCodeParams params) {
    return _repository.verifyCode(params);
  }
}

class VerifyCodeParams extends Equatable {
  const VerifyCodeParams({
    required this.phoneNumber,
    required this.code,
  });

  final String phoneNumber;

  final String code;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'code': code,
      };

  @override
  List<Object?> get props => [phoneNumber, code];
}
