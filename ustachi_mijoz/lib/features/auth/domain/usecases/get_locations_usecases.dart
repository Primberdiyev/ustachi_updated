import 'package:equatable/equatable.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/locations_repository.dart';

class GetRegionsUseCase extends UseCase<List<LocationEntity>, NoParams> {
  GetRegionsUseCase(LocationsRepository repository) : _repository = repository;

  final LocationsRepository _repository;

  @override
  Future<Either<Failure, List<LocationEntity>>> call(NoParams params) {
    return _repository.regions();
  }
}

class GetDistrictsUseCase
    extends UseCase<List<LocationEntity>, GetDistrictsParams> {
  GetDistrictsUseCase(LocationsRepository repository)
      : _repository = repository;

  final LocationsRepository _repository;

  @override
  Future<Either<Failure, List<LocationEntity>>> call(
    GetDistrictsParams params,
  ) {
    return _repository.districts(regionId: params.regionId);
  }
}

class GetDistrictsParams extends Equatable {
  const GetDistrictsParams({this.regionId});

  final int? regionId;

  @override
  List<Object?> get props => [regionId];
}
