import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:ustachi/features/profile/data/mappers/user_model_wrapper.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl with SafeCaller implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> getUserData() {
    return safeCall(() async {
      final result = await remoteDataSource.getUserData();
      return result.toEntity();
    });
  }
}
