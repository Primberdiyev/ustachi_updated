import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';

abstract class LocationsRepository {
  Future<Either<Failure, List<LocationEntity>>> regions();

  Future<Either<Failure, List<LocationEntity>>> districts({int? regionId});
}
