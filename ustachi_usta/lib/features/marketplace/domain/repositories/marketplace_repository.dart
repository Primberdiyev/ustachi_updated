import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<OrderEntity>>> list({String? status, String? scope});
  Future<Either<Failure, List<OrderEntity>>> feed();
  Future<Either<Failure, OrderEntity>> detail(int id);
  Future<Either<Failure, OrderEntity>> create(Map<String, dynamic> body);
  Future<Either<Failure, OrderEntity>> cancel(int id, {String reason});

  Future<Either<Failure, List<OrderResponseEntity>>> responses(int orderId);
  Future<Either<Failure, OrderEntity>> choose(int orderId, int responseId);
  Future<Either<Failure, ReviewEntity>> review(
    int orderId, {
    required int rating,
    String comment,
  });

  Future<Either<Failure, OrderEntity>> invite(int orderId, List<int> masterIds);

  Future<Either<Failure, OrderEntity>> publishToEveryone(int orderId);

  Future<Either<Failure, OrderResponseEntity>> respond(int orderId, {String message});
  Future<Either<Failure, OrderResponseEntity>> withdraw(int orderId);
  Future<Either<Failure, OrderEntity>> advance(int orderId, {String note});

  Future<Either<Failure, OrderEntity>> decline(int orderId, {String reason});

  Future<Either<Failure, List<ChatThreadEntity>>> threads({int? orderId});
  Future<Either<Failure, List<ChatMessageEntity>>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  });
  Future<Either<Failure, ChatMessageEntity>> sendMessage(int threadId, String text);

  Future<Either<Failure, List<MasterCardEntity>>> masters({
    String? search,
    int? regionId,
    int? specialtyId,
  });

  Future<Either<Failure, MasterProfileEntity>> masterProfile(int masterId);

  Future<Either<Failure, NotificationPage>> notifications({bool unreadOnly});
  Future<Either<Failure, void>> markRead(int id);
  Future<Either<Failure, void>> markAllRead();

  Stream<OrderEntity> watchOrder(int id, {Duration interval, bool immediate});

  Stream<List<OrderEntity>> watchList({
    String? status,
    String? scope,
    Duration interval,
    bool immediate,
  });

  Stream<List<OrderEntity>> watchFeed({Duration interval, bool immediate});

  Stream<List<OrderResponseEntity>> watchResponses(int orderId, {Duration interval, bool immediate});

  Stream<List<ChatMessageEntity>> watchMessages(
    int threadId, {
    Duration interval,
    bool immediate,
    int Function()? after,
  });

  Stream<List<ChatThreadEntity>> watchThreads({Duration interval, bool immediate});

  Stream<NotificationPage> watchNotifications({Duration interval, bool immediate});
}
