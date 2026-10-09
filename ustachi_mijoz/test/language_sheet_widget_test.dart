
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/presentation/widgets/language_mode_sheet.dart';

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1284, 2778);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => LanguageModeSheet.show(context),
                child: const Text('ochish'),
              ),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('ochish'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Ustachi',
      packageName: 'uz.ustachi.mijoz',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageRepository.getInstance();
    await StorageRepository.clearStorage();
    await LanguageProvider().setLocale(AppLocale.uz);
    ScriptProvider().setScript(UzScript.latin);
  });

  testWidgets('oynada uch qator: lotin, kirill va ruscha', (tester) async {
    await _open(tester);

    expect(find.text("O'zbekcha"), findsOneWidget);
    expect(find.text('Lotin'), findsOneWidget);
    expect(find.text('Ўзбекча'), findsOneWidget);
    expect(find.text('Кирилл'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
  });

  testWidgets('kirill qatori: til o\'zbekcha, yozuv kirill, oyna yopiladi', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Ўзбекча'));
    await tester.pumpAndSettle();

    expect(ScriptProvider().script, UzScript.cyrillic);
    expect(LanguageProvider().locale, AppLocale.uz);
    expect(LanguageProvider().choice.id, 'uz_cyrillic');
    expect(find.text('Русский'), findsNothing);
  });

  testWidgets('ruscha qatori: yozuv lotinga qaytadi', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Ўзбекча'));
    await tester.pumpAndSettle();

    await _open(tester);
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(LanguageProvider().locale, AppLocale.ru);
    expect(ScriptProvider().script, UzScript.latin);
    expect(LanguageProvider().choice.id, 'ru');
  });
}
