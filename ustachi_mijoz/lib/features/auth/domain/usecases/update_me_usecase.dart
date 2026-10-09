import 'package:equatable/equatable.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';

class UpdateMeUseCase extends UseCase<AuthUserEntity, UpdateMeParams> {
  UpdateMeUseCase(AuthRepository repository) : _repository = repository;

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUserEntity>> call(UpdateMeParams params) {
    return _repository.updateMe(params);
  }
}

class UpdateMeParams extends Equatable {
  const UpdateMeParams({
    this.fullName,
    this.photoPath,
    this.regionId,
    this.districtId,
    this.address,
  });

  final String? fullName;

  final String? photoPath;

  final int? regionId;
  final int? districtId;
  final String? address;

  bool get isEmpty =>
      fullName == null &&
      photoPath == null &&
      regionId == null &&
      districtId == null &&
      address == null;

  @override
  List<Object?> get props => [
        fullName,
        photoPath,
        regionId,
        districtId,
        address,
      ];
}
