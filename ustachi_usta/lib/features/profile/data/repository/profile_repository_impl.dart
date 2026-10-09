import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:ustachi/features/profile/data/mappers/user_model_wrapper.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl with SafeCaller implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  static bool _isAuthFailure(Failure failure) =>
      failure is ServerFailure &&
      <int>[401, 403].contains(failure.statusCode);

  @override
  Future<Either<Failure, UserModel>> getUserData() async {
    final result = await safeCall(() async {
      final response = await remoteDataSource.getUserData();
      final user = response.toEntity();
      await localDataSource.cache(user);
      return user;
    });

    if (result.isRight || _isAuthFailure(result.left)) return result;

    final cached = localDataSource.getCached();
    return cached == null ? result : Right(cached);
  }
}
