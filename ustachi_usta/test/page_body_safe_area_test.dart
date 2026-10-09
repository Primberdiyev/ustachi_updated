
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';

const _navBar = 48.0;
const _screen = Size(390, 844);

Future<Rect> _pump(WidgetTester tester, {Widget? bottomBar}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = _screen * 3;
  tester.view.padding = const FakeViewPadding(bottom: _navBar * 3);
  tester.view.viewPadding = const FakeViewPadding(bottom: _navBar * 3);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      bottomNavigationBar: bottomBar,
      body: ChizmaPageBody(
        child: Column(
          children: [

            const SizedBox(height: 2000),
            FilledButton(onPressed: () {}, child: const Text('Oxirgi')),
          ],
        ),
      ),
    ),
  ));
  await tester.pump();

  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -3000));
  await tester.pumpAndSettle();

  return tester.getRect(find.byType(FilledButton));
}

void main() {
  testWidgets('oxirgi vidjet TIZIM TUGMALARI ustida qoladi', (tester) async {
    final rect = await _pump(tester);

    expect(rect.bottom, lessThanOrEqualTo(_screen.height - _navBar));
  });

  testWidgets('pastki panel bo\'lsa bo\'shliq IKKI MARTA qo\'shilmaydi',
      (tester) async {

    final withBar = await _pump(
      tester,
      bottomBar: const SizedBox(height: 60, child: ColoredBox(color: Colors.red)),
    );

    expect(withBar.bottom, lessThanOrEqualTo(_screen.height - 60));
    expect(withBar.bottom, greaterThan(_screen.height - 60 - _navBar),
        reason: 'ortiqcha 48pt qo\'shilmagan');
  });
}
