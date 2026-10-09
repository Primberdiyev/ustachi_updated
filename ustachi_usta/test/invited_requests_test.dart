
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/open_orders_page.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';

OrderRequestEntity _request({
  String id = '1',
  bool isInvited = false,
  bool inviteDeclined = false,
  bool offerSent = false,
}) =>
    OrderRequestEntity(
      id: id,
      number: '#$id',
      title: '2 qanotli oq deraza',
      clientName: 'Mijoz',
      address: 'Chilonzor 5',
      distanceKm: 0,
      calculatedPrice: 4280636,
      expiresAt: DateTime(2030, 1, 1),
      isInvited: isInvited,
      inviteDeclined: inviteDeclined,
      offerSent: offerSent,
    );

OrdersState _state(List<OrderRequestEntity> requests) =>
    OrdersState(requests: requests);

Future<void> _pumpCard(WidgetTester tester, OrderRequestEntity request) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OrderRequestCard(
              request: request,
              now: DateTime(2026, 1, 1),
              onOffer: () {},
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  group('Ro\'yxat bo\'linishi', () {
    test('shaxsiy taklif ALOHIDA bo\'limda, ochiqlar orasida EMAS', () {
      final state = _state([
        _request(id: '1'),
        _request(id: '2', isInvited: true),
      ]);

      expect(state.invitedRequests.map((r) => r.id), ['2']);
      expect(state.publicOpenRequests.map((r) => r.id), ['1'],
          reason: 'bitta e\'lon ikki bo\'limda ko\'rinmasin');
    });

    test('javob berilgan taklif "Sizga taklif"da qolmaydi', () {
      final state = _state([_request(isInvited: true, offerSent: true)]);

      expect(state.invitedRequests, isEmpty);
      expect(state.awaitingRequests.length, 1,
          reason: 'u endi "taklif berilgan" bo\'limida');
    });

    test('RAD ETILGAN taklif qaytib chiqmaydi', () {
      final state = _state([
        _request(id: '3', isInvited: true, inviteDeclined: true),
      ]);

      expect(state.invitedRequests, isEmpty);

      expect(state.publicOpenRequests.length, 1);
    });

    test('copyWith taklif belgisini YO\'QOTMAYDI', () {
      final request = _request(isInvited: true).copyWith(offerSent: true);
      expect(request.isInvited, isTrue);
      expect(request.offerSent, isTrue);
    });
  });

  group('E\'lon kartasi', () {
    testWidgets('shaxsiy taklifda belgi va "Qabul qilaman" chiqadi',
        (tester) async {
      await _pumpCard(tester, _request(isInvited: true));

      expect(find.text(t.orders.open.invitedBadge), findsOneWidget);
      expect(find.text(t.orders.open.acceptInvite), findsOneWidget);
      expect(find.text(t.orders.offerBtn), findsNothing);
    });

    testWidgets('oddiy e\'londa belgi YO\'Q', (tester) async {
      await _pumpCard(tester, _request());

      expect(find.text(t.orders.open.invitedBadge), findsNothing);
      expect(find.text(t.orders.offerBtn), findsOneWidget);
    });

    testWidgets('rad etilgan taklif oddiy e\'longa aylanadi', (tester) async {
      await _pumpCard(tester, _request(isInvited: true, inviteDeclined: true));

      expect(find.text(t.orders.open.invitedBadge), findsNothing);
      expect(find.text(t.orders.offerBtn), findsOneWidget);
    });
  });

  group('Ochiq buyurtmalar sahifasi', () {
    testWidgets('taklif yo\'q bo\'lsa "Sizga taklif" bo\'limi KO\'RINMAYDI',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = OrdersBloc(repository: OrdersRepositoryInMemory());
      addTearDown(bloc.close);

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => TranslationProvider(
          child: MaterialApp(
            home: BlocProvider<OrdersBloc>.value(
              value: bloc,
              child: OpenOrdersPage(onOpenRequest: (_, __) {}),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(bloc.state.invitedRequests, isEmpty);
      expect(find.text(t.orders.open.tabInvited), findsNothing,
          reason: 'bo\'sh bo\'lim ro\'yxatni uzaytirib turmasin');

      expect(find.text(t.orders.open.tabWaiting), findsWidgets);
    });
  });
}
