import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/api/error/safe_caller.dart';
import 'package:ustachi/core/utils/either.dart';
import 'dart:async';

import 'package:ustachi/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl with SafeCaller implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._remote);

  final MarketplaceRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<OrderEntity>>> list({String? status, String? scope}) =>
      safeCall(() => _remote.list(status: status, scope: scope));

  @override
  Future<Either<Failure, List<OrderEntity>>> feed() =>
      safeCall(() => _remote.feed());

  @override
  Future<Either<Failure, OrderEntity>> detail(int id) =>
      safeCall(() => _remote.detail(id));

  @override
  Future<Either<Failure, OrderEntity>> create(Map<String, dynamic> body) =>
      safeCall(() => _remote.create(body));

  @override
  Future<Either<Failure, OrderEntity>> cancel(int id, {String reason = ''}) =>
      safeCall(() => _remote.cancel(id, reason: reason));

  @override
  Future<Either<Failure, List<OrderResponseEntity>>> responses(int orderId) =>
      safeCall(() => _remote.responses(orderId));

  @override
  Future<Either<Failure, OrderEntity>> choose(int orderId, int responseId) =>
      safeCall(() => _remote.choose(orderId, responseId));

  @override
  Future<Either<Failure, ReviewEntity>> review(
    int orderId, {
    required int rating,
    String comment = '',
  }) =>
      safeCall(() => _remote.review(orderId, rating: rating, comment: comment));

  @override
  Future<Either<Failure, OrderEntity>> invite(int orderId, List<int> masterIds) =>
      safeCall(() => _remote.invite(orderId, masterIds));

  @override
  Future<Either<Failure, OrderEntity>> publishToEveryone(int orderId) =>
      safeCall(() => _remote.publishToEveryone(orderId));

  @override
  Future<Either<Failure, OrderEntity>> decline(int orderId, {String reason = ''}) =>
      safeCall(() => _remote.decline(orderId, reason: reason));

  @override
  Future<Either<Failure, OrderResponseEntity>> respond(
    int orderId, {
    String message = '',
  }) =>
      safeCall(() => _remote.respond(orderId, message: message));

  @override
  Future<Either<Failure, OrderResponseEntity>> withdraw(int orderId) =>
      safeCall(() => _remote.withdraw(orderId));

  @override
  Future<Either<Failure, OrderEntity>> advance(int orderId, {String note = ''}) =>
      safeCall(() => _remote.advance(orderId, note: note));

  @override
  Future<Either<Failure, List<ChatThreadEntity>>> threads({int? orderId}) =>
      safeCall(() => _remote.threads(orderId: orderId));

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  }) =>
      safeCall(() => _remote.messages(
            threadId,
            limit: limit,
            before: before,
            after: after,
          ));

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage(
    int threadId,
    String text,
  ) =>
      safeCall(() => _remote.sendMessage(threadId, text));

  @override
  Future<Either<Failure, List<MasterCardEntity>>> masters({
    String? search,
    int? regionId,
    int? specialtyId,
  }) =>
      safeCall(() => _remote.masters(
            search: search,
            regionId: regionId,
            specialtyId: specialtyId,
          ));

  @override
  Future<Either<Failure, MasterProfileEntity>> masterProfile(int masterId) =>
      safeCall(() => _remote.masterProfile(masterId));

  @override
  Future<Either<Failure, NotificationPage>> notifications({
    bool unreadOnly = false,
  }) =>
      safeCall(() => _remote.notifications(unreadOnly: unreadOnly));

  @override
  Future<Either<Failure, void>> markRead(int id) =>
      safeCall(() => _remote.markRead(id));

  @override
  Future<Either<Failure, void>> markAllRead() =>
      safeCall(() => _remote.markAllRead());

  MarketplaceSocket get _socket => MarketplaceSocket.instance;

  static const int _slowdownAfter = 4;

  static const Duration _maxFallback = Duration(seconds: 60);

  static const Duration _chatFallback = Duration(seconds: 15);

  static const int _chatPageSize = 50;

  Stream<T> _live<T>(
    Future<Either<Failure, T>> Function() fetch,
    Object Function(T value) identity,
    bool Function(SocketEvent event) relevant, {
    required Duration interval,
    required bool immediate,
    Duration maxFallback = _maxFallback,
  }) {
    late StreamController<T> controller;
    StreamSubscription<SocketEvent>? events;
    StreamSubscription<bool>? connection;
    Timer? pollTimer;
    Object? last;
    var closed = false;
    var fetching = false;
    var pollRounds = 0;

    DateTime? lastFetch = immediate ? null : DateTime.now();

    Future<void> refresh() async {
      if (closed || fetching) return;
      fetching = true;
      try {
        final result = await fetch();
        if (closed || result.isLeft) return;
        lastFetch = DateTime.now();
        final key = identity(result.right);
        if (last == null || last != key) {
          last = key;
          controller.add(result.right);
        }
      } finally {
        fetching = false;
      }
    }

    void stopPolling() {
      pollTimer?.cancel();
      pollTimer = null;
      pollRounds = 0;
    }

    void startPolling() {
      if (pollTimer != null || closed) return;
      final slowdown = 1 << (pollRounds ~/ _slowdownAfter);
      var next = interval * slowdown;
      if (next > maxFallback) next = maxFallback;
      pollTimer = Timer.periodic(next, (_) {
        if (_socket.isConnected || !_socket.isForeground) return;
        pollRounds++;
        refresh();
        if (pollRounds % _slowdownAfter == 0 && next < maxFallback) {
          pollTimer?.cancel();
          pollTimer = null;
          startPolling();
        }
      });
    }

    void start() {
      _socket.acquire();
      if (immediate) refresh();
      events = _socket.events.listen((e) {
        if (relevant(e)) refresh();
      });
      connection = _socket.connection.listen((alive) {
        if (alive) {
          stopPolling();
          final since = lastFetch;
          if (since == null || DateTime.now().difference(since) >= interval) {
            refresh();
          }
        } else {
          startPolling();
        }
      });
      if (!_socket.isConnected) startPolling();
    }

    controller = StreamController<T>(
      onListen: start,
      onCancel: () {
        closed = true;
        events?.cancel();
        connection?.cancel();
        stopPolling();
        _socket.release();
      },
    );
    return controller.stream;
  }

  @override
  Stream<OrderEntity> watchOrder(
    int id, {
    Duration interval = const Duration(seconds: 5),
    bool immediate = true,
  }) =>
      _live(
        () => detail(id),
        (o) => '${o.status.code}|${o.stage?.code}|${o.responsesCount}|'
            '${o.assignedMaster?.id}|${o.review?.id}',
        (e) => e.touchesOrders && (e.orderId == null || e.orderId == id),
        interval: interval,
        immediate: immediate,
      );

  @override
  Stream<List<OrderEntity>> watchList({
    String? status,
    String? scope,
    Duration interval = const Duration(seconds: 10),
    bool immediate = true,
  }) =>
      _live(
        () => list(status: status, scope: scope),
        _ordersKey,
        (e) => e.touchesOrders,
        interval: interval,
        immediate: immediate,
      );

  @override
  Stream<List<OrderEntity>> watchFeed({
    Duration interval = const Duration(seconds: 10),
    bool immediate = true,
  }) =>
      _live(
        feed,
        _ordersKey,
        (e) => e.touchesOrders,
        interval: interval,
        immediate: immediate,
      );

  @override
  Stream<List<OrderResponseEntity>> watchResponses(
    int orderId, {
    Duration interval = const Duration(seconds: 5),
    bool immediate = true,
  }) =>
      _live(
        () => responses(orderId),
        (rs) => rs.map((r) => '${r.id}:${r.status?.code}').join(','),
        (e) => e.touchesOrders && (e.orderId == null || e.orderId == orderId),
        interval: interval,
        immediate: immediate,
      );

  @override
  @override
  Stream<List<ChatMessageEntity>> watchMessages(
    int threadId, {
    Duration interval = const Duration(seconds: 4),
    bool immediate = true,
    int Function()? after,
  }) =>
      _live(
        () => messages(threadId, after: after?.call(), limit: _chatPageSize),
        (ms) => ms.isEmpty ? '' : '${ms.length}:${ms.last.id}',
        (e) => e.isChat && (e.threadId == null || e.threadId == threadId),
        interval: interval,
        immediate: immediate,
        maxFallback: _chatFallback,
      );

  @override
  Stream<List<ChatThreadEntity>> watchThreads({
    Duration interval = const Duration(seconds: 8),
    bool immediate = true,
  }) =>
      _live(
        threads,
        (ts) => ts
            .map((t) => '${t.id}:${t.unreadCount}:'
                '${t.lastMessageAt?.millisecondsSinceEpoch ?? 0}')
            .join(','),
        (e) => e.isChat,
        interval: interval,
        immediate: immediate,
        maxFallback: _chatFallback,
      );

  @override
  Stream<NotificationPage> watchNotifications({
    Duration interval = const Duration(seconds: 15),
    bool immediate = true,
  }) =>
      _live(
        () => notifications(),
        (p) => '${p.unreadCount}:${p.items.isEmpty ? '' : p.items.first.id}',
        (e) => !e.isPong && !e.isConnected,
        interval: interval,
        immediate: immediate,
      );

  String _ordersKey(List<OrderEntity> orders) => orders
      .map((o) => '${o.id}:${o.status.code}:${o.stage?.code}:'
          '${o.responsesCount}:${o.myResponseStatus?.code}')
      .join(',');
}
