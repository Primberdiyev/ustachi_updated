import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/splash/data/data_sources/splash_local_data_source.dart';
import 'package:ustachi/features/splash/domain/entities/splash_destination.dart';
import 'package:ustachi/features/splash/domain/repositories/splash_repository.dart';

class SplashRepositoryImpl with SafeCaller implements SplashRepository {
  SplashRepositoryImpl({
    required SplashLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final SplashLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, SplashDestination>> resolveStartup() async {
    final tokens = await _localDataSource.getCachedTokens();
    if (!(tokens?.hasValue ?? false)) {
      final shouldShowOnboarding = _localDataSource.isFirstLaunch();
      if (shouldShowOnboarding) {
        return Right(SplashDestination.onboarding);
      }

      return Right(SplashDestination.authSelection);
    }

    return Right(SplashDestination.main);

  }

  @override
  Future<Either<Failure, void>> clearSession() {
    return safeCall(_localDataSource.clearSession);
  }
}
