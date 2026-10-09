
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';

final _now = DateTime(2026, 8, 3, 12);

OrderRequestEntity _request({
  bool offerSent = false,
  int responsesCount = 0,
  bool withDrawing = true,
}) =>
    OrderRequestEntity(
      id: '7',
      number: '#7',
      title: 'Deraza — 2 dona',
      summary: 'Yunusobod',
      clientName: 'Aziz',
      address: 'Toshkent',
      distanceKm: 0,
      calculatedPrice: 1000000,
      expiresAt: _now.add(const Duration(hours: 5)),
      offerSent: offerSent,
      responsesCount: responsesCount,
      material: 0,
      drawing: withDrawing
          ? const FramePreviewSpec(
              aspectRatio: 1500 / 1400,
              lines: [],
              widthMm: 1500,
              heightMm: 1400,
            )
          : null,
      spec: const {
        specSize: '1500×1400',
        specMaterial: specValuePlastic,
        specGlass: specValueDoubleGlass,
      },
    );

Future<void> _pump(
  WidgetTester tester,
  OrderRequestEntity request, {
  VoidCallback? onOffer,

  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OrderRequestCard(
                request: request,
                now: _now,
                onOffer: onOffer,
              ),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('ochiq e\'lon: chizma + belgilar + narx + "Taklif ber"',
      (tester) async {
    var tapped = false;
    await _pump(tester, _request(), onOffer: () => tapped = true);

    final tr = t.orders;

    expect(find.byType(FrameDrawing), findsOneWidget);
    expect(find.text('Deraza — 2 dona'), findsOneWidget);

    expect(find.textContaining('Aziz'), findsOneWidget);

    expect(find.text('1500×1400 mm'), findsOneWidget);
    expect(find.text(tr.spec.values.plastic), findsOneWidget);

    expect(find.text(tr.open.beFirst), findsOneWidget);

    expect(find.textContaining('5'), findsWidgets);

    expect(tester.takeException(), isNull);

    await tester.tap(find.text(tr.offerBtn));
    expect(tapped, isTrue);
  });

  testWidgets('taklif yuborilgan e\'lon: "kutilmoqda", tugma YO\'Q',
      (tester) async {
    await _pump(tester, _request(offerSent: true, responsesCount: 3));

    final tr = t.orders;

    expect(find.text(tr.open.offerSent), findsOneWidget);
    expect(find.text(tr.open.waitingClient), findsOneWidget);

    expect(find.text(tr.offerBtn), findsNothing);

    expect(find.text(tr.open.offersCount(count: '3')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chizmasiz eski e\'lon ham yiqilmaydi', (tester) async {
    await _pump(tester, _request(withDrawing: false), onOffer: () {});

    expect(find.byType(FrameDrawing), findsNothing);
    expect(find.byIcon(Icons.window_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TOR ekranda (320dp) karta toshmaydi', (tester) async {
    await _pump(
      tester,
      _request(responsesCount: 12),
      onOffer: () {},
      size: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });
}
