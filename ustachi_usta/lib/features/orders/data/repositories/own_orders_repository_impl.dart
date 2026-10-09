import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/data/datasources/own_orders_remote_data_source.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';

class OwnOrdersRepositoryImpl with SafeCaller implements OwnOrdersRepository {
  OwnOrdersRepositoryImpl(this._remote);

  final OwnOrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<OwnOrderEntity>>> list({OwnOrderStatus? status}) =>
      safeCall(() => _remote.list(status: status));

  @override
  Future<Either<Failure, OwnOrderEntity>> detail(int id) =>
      safeCall(() => _remote.detail(id));

  @override
  Future<Either<Failure, OwnOrderEntity>> create(OwnOrderPayload payload) =>
      safeCall(() => _remote.create(payload));

  @override
  Future<Either<Failure, OwnOrderEntity>> update(
    int id,
    OwnOrderPayload payload,
  ) =>
      safeCall(() => _remote.update(id, payload));

  @override
  Future<Either<Failure, OwnOrderEntity>> setStatus(
    int id,
    OwnOrderStatus status,
  ) =>
      safeCall(() => _remote.setStatus(id, status));

  @override
  Future<Either<Failure, void>> remove(int id) =>
      safeCall(() => _remote.remove(id));
}
