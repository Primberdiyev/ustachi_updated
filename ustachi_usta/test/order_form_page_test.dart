
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';
import 'package:ustachi/features/orders/presentation/view/order_form_page.dart';
import 'support/l10n_harness.dart';

OrderDraftItem _item({String id = 'draft-1', int qty = 1}) => OrderDraftItem(
      localId: id,
      drawing: WindowDrawingSnapshot(
        widthMm: 1500,
        heightMm: 1600,
        spec: const FramePreviewSpec(aspectRatio: 0.94, lines: []),
        preview: (_) => const SizedBox.shrink(),
      ),
      qty: qty,
      materialLabel: 'Plastik',
    );

class FakeOwnOrdersRepository implements OwnOrdersRepository {
  OwnOrderPayload? saved;
  Failure? failure;

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

late OrderDraftStore store;
late FakeOwnOrdersRepository repository;

Future<void> _pump(WidgetTester tester, {int items = 1}) async {
  tester.view.physicalSize = const Size(428, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  store = OrderDraftStore();
  for (var i = 0; i < items; i++) {
    store.add(_item(id: 'draft-${i + 1}'));
  }
  repository = FakeOwnOrdersRepository();

  sl.registerSingleton<OrderDraftStore>(store);
  sl.registerSingleton<OwnOrdersRepository>(repository);
  sl.registerSingleton<OwnOrderOutbox>(OwnOrderOutbox(repository));
  sl.registerSingleton<SnackbarService>(SnackbarService());
  addTearDown(() {
    sl.unregister<OrderDraftStore>();
    sl.unregister<OwnOrdersRepository>();
    sl.unregister<OwnOrderOutbox>();
    sl.unregister<SnackbarService>();
  });

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(home: OrderFormPage()),
    ),
  ));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('qoralama tarkibi ko\'rinadi, pul maydonlari yo\'q', (tester) async {
    await _pump(tester, items: 2);

    expect(find.text('2 xil rom · 2 dona'), findsOneWidget);
    for (final label in ['Umumiy', 'Chegirma', 'Yakuniy narx', 'Avans', 'Qoldiq']) {
      expect(find.text(label), findsNothing, reason: label);
    }
    expect(find.textContaining('so\'m'), findsNothing);
  });

  testWidgets('TOPSHIRISH MUDDATI so\'ralmaydi', (tester) async {
    await _pump(tester);

    expect(find.text('Topshirish muddati'), findsNothing);
    expect(find.byIcon(Icons.event_outlined), findsNothing);
    expect(find.text('Qo\'shimcha izoh'), findsOneWidget);
  });

  testWidgets('ism bo\'sh bo\'lsa saqlanmaydi', (tester) async {
    await _pump(tester);

    await tester.tap(find.textContaining('Saqlash'));
    await tester.pump();

    expect(find.text('Ismni yozing'), findsOneWidget);
    expect(repository.saved, isNull);
  });

  testWidgets('saqlanganda payload to\'ldiriladi va qoralama tozalanadi',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
    await tester.tap(find.textContaining('Saqlash'));
    await tester.pumpAndSettle();

    final payload = repository.saved;
    expect(payload, isNotNull);
    expect(payload!.customerName, 'Aziz aka');
    expect(payload.items, hasLength(1));
    expect(payload.items.single.drawing, isNotEmpty);
    expect(payload.syncClientId, isNotEmpty);

    expect(store.value.isEmpty, isTrue);
  });

  testWidgets('SERVER RAD ETSA (400) qoralama saqlanib qoladi', (tester) async {
    await _pump(tester);
    repository.failure = const ServerFailure('Ism noto\'g\'ri', 400);

    await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
    await tester.tap(find.textContaining('Saqlash'));
    await tester.pumpAndSettle();

    expect(store.value.isEmpty, isFalse,
        reason: 'xatoni tuzatib qayta yuborish uchun qoralama kerak');
  });

  testWidgets('TARMOQ uzilsa buyurtma NAVBATGA qo\'yiladi', (tester) async {
    await _pump(tester);
    repository.failure = const ServerFailure('Internet yo\'q', null);

    await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
    await tester.tap(find.textContaining('Saqlash'));
    await tester.pumpAndSettle();

    expect(repository.saved, isNotNull);
    expect(store.value.isEmpty, isTrue);
  });

  group('RAQAM MAYDONI — +998 doim turadi', () {
    testWidgets('maydon ochilishida ham prefiks ko\'rinadi', (tester) async {
      await _pump(tester);

      expect(find.text('+998 '), findsOneWidget);
    });

    testWidgets('raqam prefiks ustiga formatlanadi', (tester) async {
      await _pump(tester);

      await tester.enterText(find.text('+998 '), '901234567');
      await tester.pump();

      expect(find.text('+998 90 123 45 67'), findsOneWidget);
    });

    testWidgets('prefiks o\'chirib bo\'lmaydi', (tester) async {
      await _pump(tester);

      await tester.enterText(find.text('+998 '), '');
      await tester.pump();

      expect(find.text('+998 '), findsOneWidget);
    });

    testWidgets('raqam kiritilmasa BO\'SH saqlanadi', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
      await tester.tap(find.textContaining('Saqlash'));
      await tester.pumpAndSettle();

      expect(repository.saved?.customerPhone, '');
    });

    testWidgets('kiritilgan raqam to\'liq saqlanadi', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Aziz aka');
      await tester.enterText(find.text('+998 '), '901234567');
      await tester.pump();
      await tester.tap(find.textContaining('Saqlash'));
      await tester.pumpAndSettle();

      expect(repository.saved?.customerPhone, '+998 90 123 45 67');
    });
  });

  test('sync ID qoralama davomida O\'ZGARMAYDI, tozalangach yangilanadi', () {
    final store = OrderDraftStore();
    final first = store.syncId;

    expect(store.syncId, first, reason: 'qayta yuborishda dublikat bo\'lmasin');

    store.clear();
    expect(store.syncId, isNot(first),
        reason: 'keyingi qoralama YANGI buyurtma');
  });
}
