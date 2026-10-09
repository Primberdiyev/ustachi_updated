
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_form_page.dart';
import 'support/l10n_harness.dart';

MasterOrderEntity _order(String id) => MasterOrderEntity(
      id: id,
      number: '#$id',
      title: 'Mijoz buyurtmasi',
      clientName: 'Aziz aka',
      address: 'Yunusobod',
      totalPrice: 1000000,
      stage: OrderStage.measured,
      createdAt: DateTime(2026, 7, 28),
    );

class FakeOrdersRepository implements OrdersRepository {
  FakeOrdersRepository(this.responses);

  final List<List<MasterOrderEntity>> responses;
  int calls = 0;

  @override
  Future<Either<Failure, List<MasterOrderEntity>>> orders() async {
    final i = calls++;
    return Right(responses[i < responses.length ? i : responses.length - 1]);
  }

  @override
  Future<Either<Failure, List<OrderRequestEntity>>> requests() async =>
      Right(const []);

  @override
  Future<Either<Failure, MasterOrderEntity>> historicalDetail(
          String orderId) async =>
      Right(_order(orderId));

  @override
  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  }) async =>
      Right(null);

  @override
  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited = false,
    String reason = '',
  }) async =>
      Right(null);

  @override
  Future<Either<Failure, MasterOrderEntity>> completeStage(
          String orderId) async =>
      Right(_order(orderId));
}

class FakeOwnOrdersRepository implements OwnOrdersRepository {
  Failure? failure;
  OwnOrderPayload? saved;

  @override
  Future<Either<Failure, OwnOrderEntity>> create(
      OwnOrderPayload payload) async {
    saved = payload;
    if (failure != null) return Left(failure!);
    return Right(OwnOrderEntity(
      id: 7,
      customerName: payload.customerName,
      status: OwnOrderStatus.newOrder,
      createdAt: DateTime(2026, 7, 28),
    ));
  }

  @override
  Future<Either<Failure, OwnOrderEntity>> detail(int id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<OwnOrderEntity>>> list(
          {OwnOrderStatus? status}) async =>
      Right(const []);

  @override
  Future<Either<Failure, void>> remove(int id) async => Right(null);

  @override
  Future<Either<Failure, OwnOrderEntity>> setStatus(
          int id, OwnOrderStatus status) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> update(
          int id, OwnOrderPayload payload) async =>
      throw UnimplementedError();
}

late OrdersBloc bloc;
late FakeOrdersRepository marketplace;
late FakeOwnOrdersRepository own;
late OrderDraftStore store;

Future<void> _pumpForm(WidgetTester tester) async {
  tester.view.physicalSize = const Size(428, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  store = OrderDraftStore()
    ..add(OrderDraftItem(
      localId: 'draft-1',
      drawing: WindowDrawingSnapshot(
        widthMm: 1500,
        heightMm: 1600,
        spec: const FramePreviewSpec(aspectRatio: 0.94, lines: []),
        preview: (_) => const SizedBox.shrink(),
      ),
      qty: 1,
      materialLabel: 'Plastik',
    ));

  own = FakeOwnOrdersRepository();

  marketplace = FakeOrdersRepository([
    const [],
    [_order('new-1')],
  ]);
  bloc = OrdersBloc(
    repository: marketplace,
    ownRepository: own,
    outbox: OwnOrderOutbox(own),
  );

  sl.registerSingleton<OrderDraftStore>(store);
  sl.registerSingleton<OwnOrdersRepository>(own);
  sl.registerSingleton<OwnOrderOutbox>(OwnOrderOutbox(own));
  sl.registerSingleton<SnackbarService>(SnackbarService());
  sl.registerSingleton<OrdersBloc>(bloc);
  addTearDown(() {
    sl.unregister<OrderDraftStore>();
    sl.unregister<OwnOrdersRepository>();
    sl.unregister<OwnOrderOutbox>();
    sl.unregister<SnackbarService>();
    sl.unregister<OrdersBloc>();
    bloc.close();
  });

  bloc.add(const OrdersLoadRequested());
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: const MaterialApp(home: OrderFormPage()),
    ),
  ));
  await tester.pumpAndSettle();
  expect(bloc.state.orders, isEmpty, reason: 'boshlang\'ich holat');
}

Future<void> _save(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
  await tester.pump();
  await tester.tap(find.textContaining('Saqlash'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('buyurtma saqlangach ro\'yxat blogi QAYTA o\'qiydi',
      (tester) async {
    await _pumpForm(tester);
    final before = marketplace.calls;

    await _save(tester);

    expect(own.saved, isNotNull, reason: 'buyurtma serverga ketdi');
    expect(marketplace.calls, greaterThan(before),
        reason: 'saqlashdan keyin ro\'yxat qayta so\'ralishi kerak');

    expect(bloc.state.orders.map((o) => o.id), contains('new-1'));
  });

  testWidgets('TARMOQ uzilganda ham yangilanadi va ro\'yxat BO\'SHAB QOLMAYDI',
      (tester) async {
    await _pumpForm(tester);

    marketplace = FakeOrdersRepository([
      [_order('old-1')],
    ]);
    bloc.add(const OrdersLoadRequested());
    await tester.pumpAndSettle();

    own.failure = const ServerFailure('Internet yo\'q', null);
    await _save(tester);

    expect(store.value.isEmpty, isTrue);
    expect(bloc.state.orders, isNotEmpty);
  });
}
