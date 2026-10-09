part of 'orders_bloc.dart';

enum OrdersSegment {
  fresh,
  inProgress,
  completed;

  bool get isFresh => this == OrdersSegment.fresh;
}

@freezed
abstract class OrdersState with _$OrdersState {
  const factory OrdersState({
    @Default(Statuses.initial) Statuses loadStatus,

    @Default(Statuses.initial) Statuses actionStatus,
    @Default(OrdersSegment.fresh) OrdersSegment segment,
    @Default(<OrderRequestEntity>[]) List<OrderRequestEntity> requests,
    @Default(<MasterOrderEntity>[]) List<MasterOrderEntity> orders,
    Failure? failure,
  }) = _OrdersState;

  const OrdersState._();

  List<OrderRequestEntity> get openRequests =>
      requests.where((request) => !request.offerSent).toList();

  List<OrderRequestEntity> get awaitingRequests =>
      requests.where((request) => request.offerSent).toList();

  List<OrderRequestEntity> get invitedRequests => requests
      .where((r) => r.isInvited && !r.offerSent && !r.inviteDeclined)
      .toList();

  List<OrderRequestEntity> get publicOpenRequests =>
      openRequests.where((r) => !r.isInvited || r.inviteDeclined).toList();

  List<MasterOrderEntity> get activeOrders =>
      orders.where((order) => !order.isCompleted).toList();

  List<MasterOrderEntity> get completedOrders =>
      orders.where((order) => order.isCompleted).toList();

  int countFor(OrdersSegment segment) => switch (segment) {
        OrdersSegment.fresh => requests.length,
        OrdersSegment.inProgress => activeOrders.length,
        OrdersSegment.completed => completedOrders.length,
      };
}
