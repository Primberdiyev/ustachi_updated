
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/own_order_mapper.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_drawing.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';
import 'package:ustachi/features/orders/presentation/widgets/own_order_status_sheet.dart';

import 'orders_composite_test.dart' show FakeMarketplace;
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';

OwnOrderEntity ownOrder({
  int id = 7,
  OwnOrderStatus status = OwnOrderStatus.newOrder,
  DateTime? completedAt,
}) =>
    OwnOrderEntity(
      id: id,
      customerName: 'Aziz aka',
      customerAddress: 'Chilonzor 9',
      status: status,
      createdAt: DateTime(2026, 7, 25),
      completedAt: completedAt,
      items: const [
        OwnOrderItemEntity(
          title: '1500 × 1600 mm',
          qty: 2,
          materialLabel: 'Plastik',
          drawing: {
            'ar': 0.94,
            'w': 1500,
            'h': 1600,
            'lines': [
              [0.0, 0.5, 1.0, 0.5],
            ],
          },
        ),
      ],
    );

class StatusFakeOwn implements OwnOrdersRepository {
  StatusFakeOwn(this.current);

  OwnOrderEntity current;
  Failure? failure;
  OwnOrderStatus? requested;

  @override
  Future<Either<Failure, List<OwnOrderEntity>>> list({
    OwnOrderStatus? status,
  }) async =>
      Right([current]);

  @override
  Future<Either<Failure, OwnOrderEntity>> detail(int id) async =>
      Right(current);

  @override
  Future<Either<Failure, OwnOrderEntity>> create(
          OwnOrderPayload payload) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> update(
          int id, OwnOrderPayload payload) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> setStatus(
    int id,
    OwnOrderStatus status,
  ) async {
    requested = status;
    if (failure != null) return Left(failure!);
    current = ownOrder(
      id: id,
      status: status,
      completedAt: status.isClosed ? DateTime(2026, 7, 29) : null,
    );
    return Right(current);
  }

  @override
  Future<Either<Failure, void>> remove(int id) async => Right(null);
}

void main() {
  group('Bloc — holat o\'zgartirish', () {
    late FakeMarketplace marketplace;
    late StatusFakeOwn own;
    late OrdersBloc bloc;

    setUp(() {
      marketplace = FakeMarketplace();
      own = StatusFakeOwn(ownOrder());
      bloc = OrdersBloc(repository: marketplace, ownRepository: own);
    });

    tearDown(() => bloc.close());

    void seed() {
      marketplace.ordersList = [OwnOrderMapper.toMasterOrder(own.current)];
    }

    Future<void> load() async {
      seed();
      bloc.add(const OrdersLoadRequested());
      await bloc.stream.firstWhere((state) => state.loadStatus.isSuccess);
    }

    test('holat serverga yuboriladi va ro\'yxat yangilanadi', () async {
      await load();

      bloc.add(const OwnOrderStatusChanged(
        orderId: 'own:7',
        status: OwnOrderStatus.inProgress,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      expect(own.requested, OwnOrderStatus.inProgress);
      expect(bloc.state.orders.single.ownStatus, OwnOrderStatus.inProgress);
    });

    test('OPTIMISTIK: server javobidan OLDIN ekran o\'zgaradi', () async {
      await load();

      final states = <OrdersState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const OwnOrderStatusChanged(
        orderId: 'own:7',
        status: OwnOrderStatus.done,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);
      await subscription.cancel();

      final optimistic = states.first;
      expect(optimistic.actionStatus.isLoading, isTrue);
      expect(optimistic.orders.single.ownStatus, OwnOrderStatus.done,
          reason: 'kutmasdan darhol ko\'rinadi');
    });

    test('XATODA eski holat qaytariladi', () async {
      await load();
      own.failure = const ServerFailure('500', 500);

      bloc.add(const OwnOrderStatusChanged(
        orderId: 'own:7',
        status: OwnOrderStatus.cancelled,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isFailure);

      expect(bloc.state.orders.single.ownStatus, OwnOrderStatus.newOrder,
          reason: 'server rad qildi — ekran yolg\'on ko\'rsatmasin');
      expect(bloc.state.failure, isNotNull);
    });

    test('yakunlangan holat ARXIV segmentiga tushadi', () async {
      await load();

      bloc.add(const OwnOrderStatusChanged(
        orderId: 'own:7',
        status: OwnOrderStatus.done,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      expect(bloc.state.completedOrders, hasLength(1));
      expect(bloc.state.activeOrders, isEmpty);
    });

    test('arxivdan qaytsa yana FAOL bo\'ladi', () async {
      own = StatusFakeOwn(ownOrder(
        status: OwnOrderStatus.done,
        completedAt: DateTime(2026, 7, 29),
      ));
      bloc = OrdersBloc(repository: marketplace, ownRepository: own);
      await load();
      expect(bloc.state.completedOrders, hasLength(1));

      bloc.add(const OwnOrderStatusChanged(
        orderId: 'own:7',
        status: OwnOrderStatus.inProgress,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      expect(bloc.state.activeOrders, hasLength(1));
      expect(bloc.state.completedOrders, isEmpty);
    });

    test('marketplace buyurtmasida ishlamaydi', () async {
      await load();

      bloc.add(const OwnOrderStatusChanged(
        orderId: '42',
        status: OwnOrderStatus.done,
      ));
      await bloc.stream.firstWhere((state) => state.actionStatus.isFailure);

      expect(own.requested, isNull);
    });
  });

  group('Tafsilot ekrani', () {
    Future<void> pump(WidgetTester tester, OwnOrderEntity order) async {
      tester.view.physicalSize = const Size(428, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final marketplace = FakeMarketplace();
      final own = StatusFakeOwn(order);
      final bloc = OrdersBloc(repository: marketplace, ownRepository: own);
      addTearDown(bloc.close);

      await tester.pumpWidget(TranslationProvider(
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(
            home: BlocProvider.value(
              value: bloc,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: OrderDetailView(
                    order: OwnOrderMapper.toMasterOrder(order),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('o\'z buyurtmasida BOSQICH emas, HOLAT ko\'rinadi',
        (tester) async {
      await pump(tester, ownOrder(status: OwnOrderStatus.inProgress));

      expect(find.text('HOLAT'), findsOneWidget);
      expect(find.text('Jarayonda'), findsWidgets);
      expect(find.text('O\'zgartirish uchun bosing'), findsOneWidget);
    });

    testWidgets('chizma SAQLANGAN geometriyadan chiziladi', (tester) async {
      await pump(tester, ownOrder());

      expect(find.text('CHIZMALAR'), findsOneWidget);

      expect(find.text('1500 × 1600 mm'), findsOneWidget);
      expect(find.byType(OrderDrawing), findsOneWidget);
    });

    testWidgets('chizma bosilsa TO\'LIQ EKRAN + zoom ochiladi',
        (tester) async {

      await pump(tester, ownOrder());

      await tester.tap(find.byType(OrderDrawing));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('holat varag\'i ochiladi va tanlov yuboriladi', (tester) async {
      await pump(tester, ownOrder());

      await tester.tap(find.text('O\'zgartirish uchun bosing'));
      await tester.pumpAndSettle();

      expect(find.byType(OwnOrderStatusSheet), findsOneWidget);

      expect(find.text('Qoralama'), findsNothing);
      expect(find.text('Qarzdor'), findsOneWidget);
    });
  });

  group('Holat xaritasi', () {
    test('keyingi holat', () {
      expect(OwnOrderMapper.nextStatus(OwnOrderStatus.newOrder),
          OwnOrderStatus.inProgress);
      expect(OwnOrderMapper.nextStatus(OwnOrderStatus.inProgress),
          OwnOrderStatus.done);
      expect(OwnOrderMapper.nextStatus(OwnOrderStatus.done), isNull);
      expect(OwnOrderMapper.nextStatus(OwnOrderStatus.cancelled), isNull);
    });

    test('o\'z buyurtmasida pul maydonlari yo\'q', () {
      final order = OwnOrderMapper.toMasterOrder(ownOrder());
      expect(order.spec.containsKey(specDiscount), isFalse);
      expect(order.totalPrice, 0);
    });
  });
}
