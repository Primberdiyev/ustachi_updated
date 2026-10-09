import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/push/push_message.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/presentation/notification_open.dart';

class PushNavigator {
  const PushNavigator(this._router);

  final AppRouter _router;

  bool canOpen(PushMessage message) =>
      message.orderId != null &&
      _destinationOf(message) != NotificationDestination.none;

  void open(PushMessage message) {
    final orderId = message.orderId;
    if (orderId == null) return;

    final context = _router.navigatorKey.currentContext;
    if (context != null) {
      openNotification(
        context,
        AppNotificationEntity(
          id: 0,
          type: AppNotificationType.fromCode(message.topic),
          title: message.title,
          body: message.body,
          orderId: orderId,
        ),
      );
      return;
    }

    _openWithRouter(message, orderId);
  }

  NotificationDestination _destinationOf(PushMessage message) =>
      notificationDestinationFor(AppNotificationType.fromCode(message.topic));

  void _openWithRouter(PushMessage message, int orderId) {
    switch (_destinationOf(message)) {
      case NotificationDestination.openRequest:
        _router.push(OrderRequestPageRoute(requestId: '$orderId'));

      case NotificationDestination.chat:
        _router.navigate(const MainPageRoute(children: [ChattingPageRoute()]));

      case NotificationDestination.ownOrder:
        _router.push(OrderDetailPageRoute(orderId: '$orderId'));

      case NotificationDestination.none:
        return;
    }
  }
}
