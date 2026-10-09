import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/splash/domain/entities/splash_destination.dart';
import 'package:ustachi/features/splash/domain/repositories/splash_repository.dart';

class ResolveStartupUseCase extends UseCase<SplashDestination, NoParams> {
  ResolveStartupUseCase(this._repository);

  final SplashRepository _repository;

  @override
  Future<Either<Failure, SplashDestination>> call(NoParams params) {
    return _repository.resolveStartup();
  }
}
