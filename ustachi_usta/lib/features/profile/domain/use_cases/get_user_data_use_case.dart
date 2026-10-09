import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';

class GetUserDataUseCase extends UseCase<UserModel, NoParams> {
  final ProfileRepository repository;

  GetUserDataUseCase({required this.repository});
  @override
  Future<Either<Failure, UserModel>> call(NoParams params) {
    return repository.getUserData();
  }
}
