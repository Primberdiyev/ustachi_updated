import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/splash/domain/entities/splash_destination.dart';

abstract class SplashRepository {
  Future<Either<Failure, SplashDestination>> resolveStartup();
  Future<Either<Failure, void>> clearSession();
}
