import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketEvent {
  const SocketEvent({
    required this.topic,
    this.orderId,
    this.threadId,
    this.unreadCount,
  });

  final String topic;
  final int? orderId;
  final int? threadId;
  final int? unreadCount;

  factory SocketEvent.fromJson(Map<String, dynamic> json) => SocketEvent(
        topic: json['topic']?.toString() ?? '',
        orderId: _asInt(json['order_id']),
        threadId: _asInt(json['thread_id']),
        unreadCount: _asInt(json['unread_count']),
      );

  static int? _asInt(Object? value) => switch (value) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v),
        _ => null,
      };

  bool get isConnected => topic == 'connected';
  bool get isPong => topic == 'pong';

  bool get touchesOrders =>
      topic.startsWith('order_') || topic == 'review_received';

  bool get isChat => topic == 'chat_message';

  @override
  String toString() => 'SocketEvent($topic, order=$orderId, thread=$threadId)';
}

class MarketplaceSocket {
  MarketplaceSocket._();

  static final MarketplaceSocket instance = MarketplaceSocket._();

  static const _pingInterval = Duration(seconds: 30);

  static const _linger = Duration(seconds: 15);

  static const _maxBackoff = Duration(minutes: 5);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _pingTimer;
  Timer? _retryTimer;
  Timer? _lingerTimer;
  AppLifecycleListener? _lifecycle;
  int _attempt = 0;
  var _disposed = false;

  var _ready = false;

  var _reconnectScheduled = false;

  var _foreground = true;
  var _connected = false;

  final _events = StreamController<SocketEvent>.broadcast();
  final _connection = StreamController<bool>.broadcast();

  Stream<SocketEvent> get events => _events.stream;

  Stream<bool> get connection => _connection.stream;

  bool get isConnected => _channel != null && _ready;

  bool get isForeground => _foreground;

  int _users = 0;

  int get holders => _users;

  void acquire() {
    _lingerTimer?.cancel();
    _lingerTimer = null;
    _users++;
    _watchLifecycle();
    final retryPending = _retryTimer?.isActive ?? false;
    if (_channel == null && !retryPending) connect();
  }

  void _watchLifecycle() {
    if (_lifecycle != null) return;
    try {
      _lifecycle = AppLifecycleListener(
        onPause: () {
          _foreground = false;
          _retryTimer?.cancel();
          _teardown();
          _setConnection(false);
        },
        onResume: () {
          _foreground = true;
          _attempt = 0; 
          if (_users > 0) connect();
        },
      );
    } catch (_) {
    }
  }

  void release() {
    if (_users > 0) _users--;
    if (_users != 0) return;
    _lingerTimer?.cancel();
    _lingerTimer = Timer(_linger, () {
      _lingerTimer = null;
      if (_users == 0) disconnect();
    });
  }

  void connect() {
    if (_disposed || _channel != null) return;
    _reconnectScheduled = false;
    _retryTimer?.cancel();

    final String? token;
    try {
      token = sl<AuthLocalDataSource>().userToken?.accessToken;
    } catch (_) {
      return;
    }
    if (token == null || token.isEmpty) return;

    final base = ApiUrls.socketBaseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');

    final uri = Uri.parse('$base/ws/events/?token=$token&app=master');

    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      channel.ready.then((_) {
        if (_channel != channel) return; 
        _attempt = 0;
        _ready = true;
        _setConnection(true);
        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(_pingInterval, (_) => _ping());
      }).catchError((Object e) {
        debugPrint("WS qo'l tekkizish muvaffaqiyatsiz: $e");
        _scheduleReconnect();
      });
      _sub = channel.stream.listen(
        _onData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WS ulanmadi: $e');
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    _attempt = 0; 
    try {
      final json = jsonDecode(raw.toString());
      if (json is! Map) return;
      final event = SocketEvent.fromJson(Map<String, dynamic>.from(json));
      if (event.isConnected) _setConnection(true);
      if (event.isPong) return;
      _events.add(event);
    } catch (_) {
    }
  }

  void _ping() {
    try {
      _channel?.sink.add('ping');
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectScheduled) return;
    _reconnectScheduled = true;

    _teardown();
    if (_disposed) return;
    _setConnection(false);

    if (_users == 0 || !_foreground) {
      _reconnectScheduled = false;
      return;
    }

    final seconds = (1 << _attempt.clamp(0, 9)).clamp(1, _maxBackoff.inSeconds);
    _attempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), connect);
  }

  void _setConnection(bool alive) {
    if (_connected == alive) return;
    _connected = alive;
    _connection.add(alive);
  }

  void _teardown() {
    _ready = false;
    _pingTimer?.cancel();
    _pingTimer = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _lifecycle?.dispose();
    _lifecycle = null;
    disconnect();
  }

  void disconnect() {
    _lingerTimer?.cancel();
    _lingerTimer = null;
    _retryTimer?.cancel();
    _reconnectScheduled = false;
    _teardown();
    _setConnection(false);
  }
}
