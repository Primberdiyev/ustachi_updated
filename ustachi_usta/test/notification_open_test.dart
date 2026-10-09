
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/services/push/push_message.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/presentation/notification_open.dart';

void main() {
  group('Manzil jadvali', () {
    test('yangi e\'lon va SHAXSIY taklif — taklif berish sahifasiga', () {

      for (final type in [
        AppNotificationType.orderPublished,
        AppNotificationType.orderInvite,
      ]) {
        expect(
          notificationDestinationFor(type),
          NotificationDestination.openRequest,
          reason: '$type',
        );
      }
    });

    test('chat xabari — SUHBATGA', () {
      expect(
        notificationDestinationFor(AppNotificationType.chatMessage),
        NotificationDestination.chat,
      );
    });

    test('ish bo\'yicha xabarlar — BUYURTMA tafsilotiga', () {
      for (final type in [
        AppNotificationType.orderChosen,
        AppNotificationType.orderNotChosen,
        AppNotificationType.orderStage,
        AppNotificationType.orderCompleted,
        AppNotificationType.orderCancelled,
        AppNotificationType.reviewReceived,
        AppNotificationType.orderResponse,
      ]) {
        expect(
          notificationDestinationFor(type),
          NotificationDestination.ownOrder,
          reason: '$type',
        );
      }
    });

    test('tanilmagan tur — manzil YO\'Q (bo\'sh ekranga tushmaydi)', () {
      expect(
        notificationDestinationFor(AppNotificationType.unknown),
        NotificationDestination.none,
      );

      expect(
        notificationDestinationFor(AppNotificationType.orderInviteDeclined),
        NotificationDestination.none,
      );
    });

    test('HAR BIR tur jadvalda bor — yangisi e\'tiborsiz qolmaydi', () {
      for (final type in AppNotificationType.values) {

        expect(() => notificationDestinationFor(type), returnsNormally);
      }
    });
  });

  group('Push xabari', () {
    test('shaxsiy taklif ham "yangi e\'lon" deb qaraladi', () {
      const invite = PushMessage(topic: 'order_invite', orderId: 7);
      const published = PushMessage(topic: 'order_published', orderId: 7);

      expect(invite.isNewOrder, isTrue,
          reason: 'push bosilganda ham taklif berish sahifasi ochilsin');
      expect(published.isNewOrder, isTrue);
    });

    test('chat va boshqa turlar "yangi e\'lon" EMAS', () {
      const chat = PushMessage(topic: 'chat_message', orderId: 7);
      expect(chat.isNewOrder, isFalse);
      expect(chat.isChat, isTrue);

      const stage = PushMessage(topic: 'order_stage', orderId: 7);
      expect(stage.isNewOrder, isFalse);
      expect(stage.isChat, isFalse);
    });
  });

  group('Push va ro\'yxat BIR XIL qoidada', () {
    test('push "yangi e\'lon" desa, jadval ham taklif sahifasini beradi', () {
      for (final topic in ['order_published', 'order_invite']) {
        final message = PushMessage(topic: topic, orderId: 7);
        final type = AppNotificationType.fromCode(topic);

        expect(message.isNewOrder, isTrue, reason: topic);
        expect(
          notificationDestinationFor(type),
          NotificationDestination.openRequest,
          reason: 'push bilan ro\'yxat bir joyga olib borsin: $topic',
        );
      }
    });

    test('chat ikkalasida ham suhbat', () {
      const message = PushMessage(topic: 'chat_message', orderId: 7);
      expect(message.isChat, isTrue);
      expect(
        notificationDestinationFor(
          AppNotificationType.fromCode('chat_message'),
        ),
        NotificationDestination.chat,
      );
    });
  });
}
