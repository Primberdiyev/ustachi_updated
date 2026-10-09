import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/splash/domain/repositories/splash_repository.dart';

class ClearSessionUseCase extends UseCase<void, NoParams> {
  ClearSessionUseCase(this._repository);

  final SplashRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearSession();
  }
}
