
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/beton_calculator_page.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

const _specialty = SpecialtyEntity(
  id: 1,
  code: 'beton',
  name: 'Beton',
  unit: 'm³',
  variants: [
    SpecialtyVariant(name: 'Tayyor beton', pricePerM2: 390000),
    SpecialtyVariant(name: 'Armatura', pricePerM2: 7500),
  ],
);

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1284, 2778);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => const MaterialApp(home: BetonCalculatorPage(specialty: _specialty)),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Keyingisi'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sukut — uy poydevori: uy uzunligi va eni so\'raladi', (tester) async {
    await _open(tester);
    expect(find.text('Poydevor nimaga quyiladi?'), findsOneWidget);
    expect(find.text('Uy uzunligi'), findsOneWidget);
    expect(find.text('Devor uzunligi'), findsNothing);
  });

  testWidgets('devor (zabor): uzunlik → 30 × 50 sm padushkasiz → 3 m³, 100 m, 1 920 000 so\'m', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Devor (zabor)'));
    await tester.pumpAndSettle();
    expect(find.text('Uy uzunligi'), findsNothing);

    expect(find.text('Devor uzunligini yozing.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '20');
    await tester.pumpAndSettle();
    await _next(tester);

    expect(find.text('Har metr poydevorga 0,15 m³ beton ketadi.'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Padushkasiz')).selected, isTrue);
    expect(find.text('PADUSHKA QALINLIGI'), findsNothing);
    await _next(tester);

    expect(find.text('Devor (zabor) uzunligi'), findsOneWidget);
    expect(find.text('3 m³'), findsOneWidget);
    expect(find.text('100 m'), findsOneWidget);
    expect(find.textContaining('1 920 000'), findsOneWidget);
  });

  testWidgets('devor (zabor): mijoz padushka qo\'shsa o\'lchamlari chiqadi va kub ko\'payadi', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Devor (zabor)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '20');
    await tester.pumpAndSettle();
    await _next(tester);

    final withPad = find.widgetWithText(ChoiceChip, 'Padushka bilan');
    await tester.ensureVisible(withPad);
    await tester.pumpAndSettle();
    await tester.tap(withPad);
    await tester.pumpAndSettle();
    expect(find.text('PADUSHKA QALINLIGI'), findsOneWidget);
    await _next(tester);

    expect(find.text('6,6 m³'), findsOneWidget);
    expect(find.text('60 × 30 sm'), findsOneWidget);
  });

  testWidgets('uy poydevori o\'zgarmagan: 6 × 4 uy — 12 m³, 5 430 000 so\'m', (tester) async {
    await _open(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), '4');
    await tester.pumpAndSettle();
    await _next(tester);
    await _next(tester);
    expect(find.text('12 m³'), findsOneWidget);
    expect(find.textContaining('5 430 000'), findsOneWidget);
  });
}
