import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/data/datasources/locations_remote_data_source.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/locations_repository.dart';

class LocationsRepositoryImpl with SafeCaller implements LocationsRepository {
  LocationsRepositoryImpl(this._remoteDataSource);

  final LocationsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<LocationEntity>>> regions() {
    return safeCall(() => _remoteDataSource.regions());
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> districts({int? regionId}) {
    return safeCall(() => _remoteDataSource.districts(regionId: regionId));
  }
}
