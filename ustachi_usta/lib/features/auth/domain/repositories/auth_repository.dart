import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, SendCodeResultEntity>> sendCode(SendCodeParams params);

  Future<Either<Failure, AuthTokensEntity>> verifyCode(VerifyCodeParams params);

  Future<Either<Failure, AuthTokensEntity>> exchangeTelegramCode(String code);

  Future<Either<Failure, AuthUserEntity>> me();

  Future<Either<Failure, AuthUserEntity>> updateMe(UpdateMeParams params);

  Future<Either<Failure, void>> logout();
}
