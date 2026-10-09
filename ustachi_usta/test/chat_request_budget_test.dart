
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_threads_page.dart';
import 'support/l10n_harness.dart';

class _CountingRemote implements MarketplaceRemoteDataSource {
  final counts = <String, int>{};

  int of(String name) => counts[name] ?? 0;
  void reset() => counts.clear();

  void _hit(String name) => counts[name] = of(name) + 1;

  var threadsResult = const <ChatThreadEntity>[
    ChatThreadEntity(
      id: 7,
      orderId: 3,
      orderTitle: 'Deraza',
      peer: PersonEntity(id: 2, fullName: 'Usta Aka'),
    ),
  ];

  @override
  Future<List<ChatThreadEntity>> threads({int? orderId}) async {
    _hit('threads');
    return threadsResult;
  }

  @override
  Future<List<ChatMessageEntity>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  }) async {
    _hit('messages');
    return const [];
  }

  @override
  Future<ChatMessageEntity> sendMessage(int threadId, String text) =>
      throw UnimplementedError();

  @override
  Future<List<OrderEntity>> list({String? status, String? scope}) async {
    _hit('list');
    return const [];
  }

  @override
  Future<List<OrderEntity>> feed() async {
    _hit('feed');
    return const [];
  }

  @override
  Future<NotificationPage> notifications({bool unreadOnly = false}) async {
    _hit('notifications');
    return const NotificationPage(items: [], unreadCount: 0);
  }

  @override
  Future<OrderEntity> detail(int id) => throw UnimplementedError();
  @override
  Future<OrderEntity> create(Map<String, dynamic> body) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> cancel(int id, {String reason = ''}) =>
      throw UnimplementedError();
  @override
  Future<List<OrderResponseEntity>> responses(int orderId) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> choose(int orderId, int responseId) =>
      throw UnimplementedError();
  @override
  Future<ReviewEntity> review(int orderId,
          {required int rating, String comment = ''}) =>
      throw UnimplementedError();
  @override
  Future<OrderResponseEntity> respond(int orderId, {String message = ''}) =>
      throw UnimplementedError();
  @override
  Future<OrderResponseEntity> withdraw(int orderId) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> advance(int orderId, {String note = ''}) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> invite(int orderId, List<int> masterIds) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> publishToEveryone(int orderId) =>
      throw UnimplementedError();
  @override
  Future<OrderEntity> decline(int orderId, {String reason = ''}) =>
      throw UnimplementedError();
  @override
  Future<List<MasterCardEntity>> masters({
    String? search,
    int? regionId,
    int? specialtyId,
  }) =>
      throw UnimplementedError();
  @override
  Future<MasterProfileEntity> masterProfile(int masterId) =>
      throw UnimplementedError();
  @override
  Future<void> markRead(int id) async => _hit('markRead');
  @override
  Future<void> markAllRead() async => _hit('markAllRead');
}

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(home: child),
      ),
    );

Future<void> _advance(WidgetTester tester, int seconds) async {
  for (var i = 0; i < seconds; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _settleSocket(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 20));
}

void main() {
  late _CountingRemote remote;

  setUp(() {
    remote = _CountingRemote();
    sl.registerSingleton<MarketplaceRepository>(
      MarketplaceRepositoryImpl(remote),
    );

    MarketplaceSocket.instance.disconnect();
  });

  tearDown(() => sl.unregister<MarketplaceRepository>());

  testWidgets('ChatPage ochilishi BITTA so\'rov yuboradi (dublikat yo\'q)',
      (tester) async {
    await tester.pumpWidget(_wrap(const ChatPage(threadId: 1)));
    await tester.pump();
    await tester.pump();

    expect(remote.of('messages'), 1,
        reason: 'sahifa ham, oqim ham alohida so\'ramasligi kerak');
    await _settleSocket(tester);
  });

  testWidgets('ChatPage YOPILGACH so\'rov UMUMAN ketmaydi', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_wrap(
      Navigator(
        key: navigator,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('ildiz')),
        ),
      ),
    ));
    await tester.pump();

    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const ChatPage(threadId: 1)),
    );
    await tester.pumpAndSettle();

    await _advance(tester, 12);
    expect(remote.of('messages'), greaterThan(1),
        reason: 'ochiq chat yangilanib turishi kerak');

    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    remote.reset();

    await _advance(tester, 60);
    expect(remote.of('messages'), 0,
        reason: 'yopilgan chatdan so\'rov ketmasligi SHART');
    await _settleSocket(tester);
  });

  testWidgets('ChatThreadsPage ochilishi BITTA so\'rov yuboradi',
      (tester) async {
    await tester.pumpWidget(_wrap(const ChatThreadsPage()));
    await tester.pump();
    await tester.pump();

    expect(remote.of('threads'), 1);
    await _settleSocket(tester);
  });

  testWidgets('Suhbatlar ro\'yxati ekrandan olib tashlansa SO\'ROV TO\'XTAYDI',
      (tester) async {
    await tester.pumpWidget(_wrap(const ChatThreadsPage()));
    await tester.pump();
    await _advance(tester, 20);
    expect(remote.of('threads'), greaterThan(1));

    await tester.pumpWidget(_wrap(const Scaffold(body: Text('boshqa'))));
    await tester.pump();
    remote.reset();

    await _advance(tester, 60);
    expect(remote.of('threads'), 0);
  });

  testWidgets('Chat ustiga ochilganda ro\'yxat so\'rovi TO\'XTAYDI',
      (tester) async {
    await tester.pumpWidget(_wrap(const ChatThreadsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usta Aka'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
    remote.reset();

    await _advance(tester, 30);
    expect(remote.of('messages'), greaterThan(0),
        reason: 'ochiq chat yangilanishi kerak');
    expect(remote.of('threads'), 0,
        reason: 'ko\'rinmayotgan ro\'yxat so\'rov yubormasligi kerak');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(remote.of('threads'), 1);
    await _settleSocket(tester);
  });

  group('MarketplaceSocket ushlovchilari', () {
    test('disconnect ushlovchilar sonini BUZMAYDI', () {
      final socket = MarketplaceSocket.instance;
      socket.acquire();
      socket.acquire();
      expect(socket.holders, 2);

      socket.disconnect();
      expect(socket.holders, 2,
          reason: 'hisoblagich tirik ekranlardan ajralib qolmasligi kerak');
      expect(socket.isConnected, isFalse);

      socket.release();
      socket.release();
      expect(socket.holders, 0);

      socket.disconnect(); 
    });
  });
}
