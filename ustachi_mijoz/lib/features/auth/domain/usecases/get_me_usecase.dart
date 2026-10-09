import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';

class GetMeUseCase extends UseCase<AuthUserEntity, NoParams> {
  GetMeUseCase(AuthRepository repository) : _repository = repository;

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUserEntity>> call(NoParams params) {
    return _repository.me();
  }
}
