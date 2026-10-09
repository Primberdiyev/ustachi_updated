part of 'orders_bloc.dart';

sealed class OrdersEvent {
  const OrdersEvent();
}

class OrdersLoadRequested extends OrdersEvent {
  const OrdersLoadRequested();
}

class OrdersSegmentChanged extends OrdersEvent {
  const OrdersSegmentChanged(this.segment);

  final OrdersSegment segment;
}

class OrderOfferSent extends OrdersEvent {
  const OrderOfferSent({
    required this.requestId,
    this.note,
  });

  final String requestId;
  final String? note;
}

class OrderRequestDeclined extends OrdersEvent {
  const OrderRequestDeclined(
    this.requestId, {
    this.invited = false,
    this.reason = '',
  });

  final String requestId;

  final bool invited;

  final String reason;
}

class OrderStageCompleted extends OrdersEvent {
  const OrderStageCompleted(this.orderId);

  final String orderId;
}

class OwnOrderStatusChanged extends OrdersEvent {
  const OwnOrderStatusChanged({required this.orderId, required this.status});

  final String orderId;
  final OwnOrderStatus status;
}
