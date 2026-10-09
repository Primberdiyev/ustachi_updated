import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getUserData();
}
