import 'package:equatable/equatable.dart';

enum AppNotificationType {
  orderPublished('order_published'),
  orderResponse('order_response'),
  orderChosen('order_chosen'),
  orderNotChosen('order_not_chosen'),
  orderStage('order_stage'),
  orderCompleted('order_completed'),
  orderCancelled('order_cancelled'),
  reviewReceived('review_received'),
  chatMessage('chat_message'),
  unknown('unknown');

  const AppNotificationType(this.code);
  final String code;

  static AppNotificationType fromCode(String? code) =>
      AppNotificationType.values.firstWhere(
        (e) => e.code == code,
        orElse: () => AppNotificationType.unknown,
      );
}

class AppNotificationEntity extends Equatable {
  const AppNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    this.body = '',
    this.orderId,
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final AppNotificationType type;
  final String title;
  final String body;
  final int? orderId;
  final bool isRead;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, isRead];
}

class NotificationPage extends Equatable {
  const NotificationPage({this.unreadCount = 0, this.items = const []});

  final int unreadCount;
  final List<AppNotificationEntity> items;

  @override
  List<Object?> get props => [unreadCount, items];
}
