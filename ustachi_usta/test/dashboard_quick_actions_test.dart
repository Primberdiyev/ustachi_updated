
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
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
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  group('ChizmaImageTile', () {
    testWidgets('rasm ikonkali plita bilan BIR XIL o\'lchamda', (tester) async {
      await _pump(
        tester,
        const Row(
          children: [
            ChizmaIconTile(icon: Icons.storefront_outlined),
            ChizmaImageTile(asset: 'assets/images/korxona.png'),
          ],
        ),
      );

      final iconTile = tester.getSize(find.byType(ChizmaIconTile));
      final imageTile = tester.getSize(find.byType(ChizmaImageTile));
      expect(imageTile, iconTile, reason: 'qatorlar hizadan chiqmasin');
    });

    testWidgets('o\'lcham berilsa ikkalasi ham bir xil kattaradi',
        (tester) async {

      await _pump(
        tester,
        const Row(
          children: [
            ChizmaIconTile(icon: Icons.storefront_outlined, size: 48),
            ChizmaImageTile(asset: 'assets/images/korxona.png', size: 48),
          ],
        ),
      );

      expect(tester.getSize(find.byType(ChizmaIconTile)), const Size(48, 48));
      expect(tester.getSize(find.byType(ChizmaImageTile)), const Size(48, 48));
    });

    testWidgets('rasm topilmasa qator BUZILMAYDI', (tester) async {
      await _pump(
        tester,
        const ChizmaImageTile(asset: 'assets/images/yoq-bunday-rasm.png'),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(ChizmaImageTile)), const Size(40, 40));
      expect(tester.takeException(), isNull);
    });
  });

  group('Qatorlar guruhi', () {
    testWidgets('uchala qator ham bor va TARTIBI to\'g\'ri', (tester) async {
      final tr = t.dashboard;
      await _pump(
        tester,
        ChizmaRowGroup(
          rows: [
            ChizmaListRow(
              title: tr.quickPortfolio,
              leading: const ChizmaIconTile(icon: Icons.photo_library_outlined),
            ),
            ChizmaListRow(
              title: tr.quickCompany,
              leading: const ChizmaImageTile(
                asset: 'assets/images/korxona.png',
              ),
            ),
            ChizmaListRow(
              title: tr.quickOpenOrders,
              leading: const ChizmaImageTile(
                asset: 'assets/images/buyurtmalar.png',
              ),
            ),
          ],
        ),
      );

      expect(find.text(tr.quickPortfolio), findsOneWidget);
      expect(find.text(tr.quickCompany), findsOneWidget);
      expect(find.text(tr.quickOpenOrders), findsOneWidget);

      final portfolioY = tester.getTopLeft(find.text(tr.quickPortfolio)).dy;
      final companyY = tester.getTopLeft(find.text(tr.quickCompany)).dy;
      final ordersY = tester.getTopLeft(find.text(tr.quickOpenOrders)).dy;
      expect(portfolioY, lessThan(companyY));
      expect(companyY, lessThan(ordersY));

      expect(find.byType(ChizmaImageTile), findsNWidgets(2));
    });
  });

  group('Qadam yorliqlari', () {
    test('uchala qadam ham tarjima qilingan', () {
      final tr = t.dashboard;
      for (final label in [tr.calcStep1, tr.calcStep2, tr.calcStep3]) {
        expect(label.trim(), isNotEmpty);
      }
    });
  });
}
