import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<OrderRequestEntity>>> requests();

  Future<Either<Failure, List<MasterOrderEntity>>> orders();

  Future<Either<Failure, MasterOrderEntity>> historicalDetail(String orderId);

  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  });

  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited,
    String reason,
  });

  Future<Either<Failure, MasterOrderEntity>> completeStage(String orderId);
}
