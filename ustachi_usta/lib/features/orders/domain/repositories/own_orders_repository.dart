import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';

abstract class OwnOrdersRepository {
  Future<Either<Failure, List<OwnOrderEntity>>> list({OwnOrderStatus? status});

  Future<Either<Failure, OwnOrderEntity>> detail(int id);

  Future<Either<Failure, OwnOrderEntity>> create(OwnOrderPayload payload);

  Future<Either<Failure, OwnOrderEntity>> update(int id, OwnOrderPayload payload);

  Future<Either<Failure, OwnOrderEntity>> setStatus(int id, OwnOrderStatus status);

  Future<Either<Failure, void>> remove(int id);
}
