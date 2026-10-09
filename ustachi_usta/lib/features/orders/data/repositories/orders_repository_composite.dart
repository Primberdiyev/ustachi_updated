import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/own_order_mapper.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OrdersRepositoryComposite implements OrdersRepository {
  OrdersRepositoryComposite({
    required OrdersRepository marketplace,
    required OwnOrdersRepository own,
  })  : _marketplace = marketplace,
        _own = own;

  final OrdersRepository _marketplace;
  final OwnOrdersRepository _own;

  @override
  Future<Either<Failure, List<OrderRequestEntity>>> requests() =>
      _marketplace.requests();

  @override
  Future<Either<Failure, List<MasterOrderEntity>>> orders() async {
    final marketplaceFuture = _marketplace.orders();
    final ownFuture = _own.list();

    final marketplaceResult = await marketplaceFuture;
    final ownResult = await ownFuture;

    if (marketplaceResult.isLeft && ownResult.isLeft) {
      return Left(marketplaceResult.left);
    }

    final orders = <MasterOrderEntity>[
      if (marketplaceResult.isRight) ...marketplaceResult.right,
      if (ownResult.isRight)
        for (final order in ownResult.right)
          OwnOrderMapper.toMasterOrder(order),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Right(orders);
  }

  @override
  Future<Either<Failure, MasterOrderEntity>> historicalDetail(String orderId) =>
      _marketplace.historicalDetail(orderId);

  @override
  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  }) =>
      _marketplace.sendOffer(requestId: requestId, note: note);

  @override
  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited = false,
    String reason = '',
  }) =>
      _marketplace.declineRequest(requestId, invited: invited, reason: reason);

  @override
  Future<Either<Failure, MasterOrderEntity>> completeStage(
    String orderId,
  ) async {
    final ownId = OwnOrderMapper.serverIdOf(orderId);
    if (ownId == null) return _marketplace.completeStage(orderId);

    final current = await _own.detail(ownId);
    if (current.isLeft) return Left(current.left);

    final next = OwnOrderMapper.nextStatus(current.right.status);
    if (next == null) {
      return Left(ParsingFailure(t.ownOrders.alreadyDone));
    }

    final updated = await _own.setStatus(ownId, next);
    if (updated.isLeft) return Left(updated.left);
    return Right(OwnOrderMapper.toMasterOrder(updated.right));
  }
}
