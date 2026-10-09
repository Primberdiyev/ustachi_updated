import 'package:equatable/equatable.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase(AuthRepository repository) : _repository = repository;

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.logout();
  }
}

class LogoutRequestParams extends Equatable {
  const LogoutRequestParams({
    required this.refresh,
  });

  final String refresh;

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
    };
  }

  @override
  List<Object?> get props => [refresh];
}
