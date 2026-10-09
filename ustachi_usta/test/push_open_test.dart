
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/push/push_device_api.dart';
import 'package:ustachi/core/services/push/push_message.dart';
import 'package:ustachi/core/services/push/push_navigator.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/push/notification_sound.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/services/snackbar_service.dart';

class _FakeApi implements PushDeviceApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeMessaging implements FirebaseMessaging {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.value();
}

class _FakeSound implements NotificationSound {
  int plays = 0;

  @override
  Future<void> play({DateTime Function() clock = DateTime.now}) async => plays++;

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

PushNotificationService _service(List<PushMessage> opened) =>
    PushNotificationService(api: _FakeApi(), messaging: _FakeMessaging())
      ..onOpen = opened.add;

PushMessage _push(String topic, {int? orderId = 7}) =>
    PushMessage(topic: topic, orderId: orderId);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ilova YOPIQ edi (bildirishnoma bosib ochildi)', () {
    test('ekran tayyor bo\'lgunicha KUTADI, keyin ochiladi', () {
      final opened = <PushMessage>[];
      final service = _service(opened);

      service.queuePending(_push('order_published'));
      expect(opened, isEmpty, reason: 'splash ustida ochilsa yo\'qoladi');

      service.appReady();
      expect(opened.single.orderId, 7);
    });

    test('ekran avval tayyor bo\'lsa DARHOL ochiladi', () {

      final opened = <PushMessage>[];
      _service(opened)
        ..appReady()
        ..queuePending(_push('chat_message'));
      expect(opened.single.topic, 'chat_message');
    });

    test('bir marta ochiladi — takroriy signal qaytarmaydi', () {
      final opened = <PushMessage>[];
      _service(opened)
        ..queuePending(_push('order_chosen'))
        ..appReady()
        ..appReady();

      expect(opened, hasLength(1));
    });

    test('LOGOUT kutayotgan xabarni bekor qiladi', () async {

      final opened = <PushMessage>[];
      final service = _service(opened)..queuePending(_push('order_stage'));

      await service.forgetToken();
      service.appReady();

      expect(opened, isEmpty);
    });
  });

  group('Ilova OCHIQ — "Ko\'rish" tugmasi', () {
    final navigator = PushNavigator(AppRouter());

    test('e\'lon, chat va buyurtma xabarlari ochiladi', () {
      expect(navigator.canOpen(_push('order_published')), isTrue);
      expect(navigator.canOpen(_push('order_invite')), isTrue);
      expect(navigator.canOpen(_push('chat_message')), isTrue);
      expect(navigator.canOpen(_push('order_chosen')), isTrue);
    });

    test('marshruti yo\'q xabarda tugma chiqmaydi', () {

      expect(navigator.canOpen(_push('order_invite_declined')), isFalse);
      expect(navigator.canOpen(_push('kelajakdagi_tur')), isFalse);
    });

    test('buyurtmasiz xabarda tugma chiqmaydi', () {
      expect(navigator.canOpen(_push('order_published', orderId: null)),
          isFalse);
    });
  });

  group('OCHIQ ilovada xabar kelganda', () {

    late _FakeSound sound;
    late PushNotificationService service;

    setUp(() {
      sound = _FakeSound();
      if (sl.isRegistered<SnackbarService>()) sl.unregister<SnackbarService>();
      sl.registerSingleton<SnackbarService>(SnackbarService());
      service = PushNotificationService(
        api: _FakeApi(),
        messaging: _FakeMessaging(),
        sound: sound,
      );
    });

    tearDown(() => sl.unregister<SnackbarService>());

    test('OHANG chalinadi', () {
      service.showForeground(
        const PushMessage(topic: 'order_chosen', orderId: 7,
            title: 'Sizni tanlashdi', body: 'Yunusobod'),
      );

      expect(sound.plays, 1);
    });

    test('BO\'SH xabarga ovoz ham yo\'q', () {

      service.showForeground(const PushMessage(topic: 'order_chosen', orderId: 7));

      expect(sound.plays, 0);
    });
  });
}
