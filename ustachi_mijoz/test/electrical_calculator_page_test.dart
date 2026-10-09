import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/electrical_calculator_page.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

void main() {
  testWidgets(
      'Phone wizard validates distances and shows materials without labor',
      (tester) async {
    tester.view.physicalSize = const Size(430, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: ElectricalCalculatorPage(
      specialty: SpecialtyEntity(
          id: 6,
          code: 'elektrik',
          name: 'Elektrik',
          calculator: SpecialtyCalculator.electrical),
    )));
    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.text('1/4 · Uy va kirish qismi'), findsOneWidget);
    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(3), '20');
    await tester.enterText(inputs.at(4), '5');
    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.text('2/4 · Montaj va material'), findsOneWidget);
    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.text('3/4 · Yoritish'), findsOneWidget);
    await tester.tap(find.text('Materiallarni hisoblash'));
    await tester.pumpAndSettle();
    expect(find.text('2 674 000 so‘m'), findsOneWidget);
    expect(find.text('Xizmat haqi bu summaga kirmaydi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('3/4 · Yoritish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
