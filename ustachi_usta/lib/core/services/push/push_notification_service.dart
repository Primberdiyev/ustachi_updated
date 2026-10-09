import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/services/push/push_device_api.dart';
import 'package:ustachi/core/services/push/notification_sound.dart';
import 'package:ustachi/core/services/push/push_message.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[push] fon xabari: ${message.messageId} ${message.data}');
}

class PushNotificationService {
  PushNotificationService({
    required PushDeviceApi api,
    FirebaseMessaging? messaging,
    NotificationSound? sound,
  })  : _api = api,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _sound = sound ?? NotificationSound();

  final PushDeviceApi _api;
  final FirebaseMessaging _messaging;
  final NotificationSound _sound;

  String? _token;

  bool _registered = false;

  void Function(PushMessage message)? onOpen;

  bool Function(PushMessage message)? canOpen;

  PushMessage? _pending;

  bool _ready = false;

  StreamSubscription<RemoteMessage>? _onMessage;
  StreamSubscription<RemoteMessage>? _onOpened;
  StreamSubscription<String>? _onTokenRefresh;

  Future<void> init() async {
    _onMessage = FirebaseMessaging.onMessage.listen(_handleForeground);
    _onOpened = FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);
    _onTokenRefresh = _messaging.onTokenRefresh.listen(_bind);

    try {
      final initial = await _messaging.getInitialMessage();
      if (initial != null) queuePending(_messageOf(initial));
    } catch (e) {
      debugPrint('[push] boshlang\'ich xabar o\'qilmadi: $e');
    }

    try {
      final settings = await _messaging.requestPermission();
      debugPrint('[push] ruxsat: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[push] foydalanuvchi RAD ETDI — telefon bildirishnomasi '
            'kelmaydi (ilova ichidagi xabarlar ishlaydi).');
      }
    } catch (e) {
      debugPrint('[push] ruxsat so\'ralmadi: $e');
    }

    await syncToken();
  }

  void appReady() {
    _ready = true;
    _flushPending();
    retryIfNeeded();
  }

  void retryIfNeeded() {
    if (_registered) return;
    unawaited(syncToken());
  }

  @visibleForTesting
  void queuePending(PushMessage message) {
    _pending = message;
    debugPrint('[push] yopiq holatdan ochildi: $message');
    _flushPending();
  }

  void _flushPending() {
    if (!_ready) return;
    final message = _pending;
    if (message == null) return;
    _pending = null;
    onOpen?.call(message);
  }

  Future<void> syncToken() async {
    if (!sl.isRegistered<AuthLocalDataSource>()) return;
    if (!sl<AuthLocalDataSource>().hasTokens) return;
    try {
      final token = await _fcmToken();
      if (token != null && token.isNotEmpty) {
        await _bind(token);
      } else {
        debugPrint('[push] token bo\'sh — qurilma FCM\'ga ulanmagan.');
      }
    } catch (e) {
      debugPrint('[push] token olinmadi: $e');
    }
  }

  Future<String?> _fcmToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      for (var attempt = 0; attempt < 6; attempt++) {
        final apns = await _messaging.getAPNSToken();
        if (apns != null && apns.isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    return _messaging.getToken();
  }

  Future<void> _bind(String token) async {
    _token = token;
    if (kDebugMode) debugPrint('[push] token: $token');
    _registered = await _api.register(token);
    if (!_registered) {
      debugPrint('[push] token SERVERGA bog\'lanmadi — ilova fondan '
          'qaytganda qayta urinamiz.');
    }
  }

  Future<void> forgetToken() async {
    _pending = null;
    _ready = false;
    _registered = false;
    final token = _token ?? await _safeToken();
    if (token == null) return;
    await _api.unregister(token);
    _token = null;
  }

  Future<String?> _safeToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  void _handleForeground(RemoteMessage message) =>
      showForeground(_messageOf(message));

  @visibleForTesting
  void showForeground(PushMessage push) {
    debugPrint('[push] foreground: $push');
    final text = [push.title, push.body].where((t) => t.isNotEmpty).join('\n');
    if (text.isEmpty) return;

    unawaited(_sound.play());

    final openable = onOpen != null && (canOpen?.call(push) ?? true);
    sl<SnackbarService>().showMessage(
      text,
      actionLabel: openable ? t.notifications.open : null,
      onAction: openable ? () => onOpen?.call(push) : null,
    );
  }

  void _handleOpened(RemoteMessage message) {
    final push = _messageOf(message);
    debugPrint('[push] bosildi: $push');
    onOpen?.call(push);
  }

  PushMessage _messageOf(RemoteMessage message) => PushMessage.fromData(
        message.data,
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );

  Future<void> dispose() async {
    await _sound.dispose();
    await _onMessage?.cancel();
    await _onOpened?.cancel();
    await _onTokenRefresh?.cancel();
  }
}
