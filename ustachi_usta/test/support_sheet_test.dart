
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/presentation/widgets/support_sheet.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: const MaterialApp(home: Scaffold(body: SupportSheet())),
    ),
  ));
  await tester.pump();
}

void main() {
  test('bog\'lanish ma\'lumotlari — AYNAN foydalanuvchi bergani', () {
    expect(SupportSheet.phone, '+998993271870');
    expect(SupportSheet.email, 'ustachi2026@gmail.com');

    expect(SupportSheet.phonePretty.replaceAll(' ', ''), SupportSheet.phone);
  });

  testWidgets('telefon, pochta va Telegram kanal ko\'rinadi', (tester) async {
    await _pump(tester);

    expect(find.text(SupportSheet.phonePretty), findsOneWidget);
    expect(find.text(SupportSheet.email), findsOneWidget);
    expect(find.text(t.profile.help.callLabel), findsOneWidget);
    expect(find.text(t.profile.help.emailLabel), findsOneWidget);

    expect(find.text(SupportSheet.telegram), findsOneWidget);
    expect(find.text(t.profile.help.telegramLabel), findsOneWidget);
    expect(SupportSheet.telegramUrl, 'https://t.me/${SupportSheet.telegram.substring(1)}');

    expect(find.text(t.profile.help.workHours), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('har qator uchun NUSXALASH tugmasi bor', (tester) async {
    await _pump(tester);
    expect(find.byIcon(Icons.copy_rounded), findsNWidgets(3));
  });

  testWidgets('tor ekranda ham toshmaydi', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    await _pump(tester);
    expect(tester.takeException(), isNull);
  });
}
