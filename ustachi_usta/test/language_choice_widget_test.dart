
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/country.dart';
import 'package:ustachi/features/auth/presentation/view/country_select_page.dart';
import 'package:ustachi/features/auth/presentation/widgets/language_chip.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1284, 2778);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(home: Scaffold(body: Center(child: child))),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Ustachi Pro',
      packageName: 'com.ustachi.pro',
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

  testWidgets('sahifada O\'zbekiston ikki marta: lotin va kirill', (tester) async {
    await _pump(tester, const CountrySelectPage());

    expect(find.text('O‘zbekiston'), findsOneWidget);
    expect(find.text('Lotin'), findsOneWidget);
    expect(find.text('Ўзбекистон'), findsOneWidget);
    expect(find.text('Кирилл'), findsOneWidget);
    expect(find.text('Қазақстан'), findsOneWidget);
  });

  testWidgets('kirill qatori bosilsa: til o\'zbekcha, yozuv kirill', (tester) async {
    await _pump(tester, const CountrySelectPage());

    await tester.tap(find.text('Ўзбекистон'));
    await tester.pumpAndSettle();

    expect(ScriptProvider().script, UzScript.cyrillic);
    expect(LanguageProvider().locale, AppLocale.uz);
    expect(LanguageProvider().choice.country, Country.uzbekistan);

    expect(find.text('O‘zbekiston'), findsOneWidget);
  });

  testWidgets('boshqa davlat bosilsa yozuv lotinga qaytadi', (tester) async {
    await _pump(tester, const CountrySelectPage());
    await tester.tap(find.text('Ўзбекистон'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Россия'));
    await tester.pumpAndSettle();

    expect(LanguageProvider().locale, AppLocale.ru);
    expect(ScriptProvider().script, UzScript.latin);
  });

  testWidgets('tugma joriy tanlovni ko\'rsatadi va sahifani ochadi', (tester) async {
    await _pump(tester, const LanguageChip());
    expect(find.text('🇺🇿 O‘zbekiston · Lotin'), findsOneWidget);

    await tester.tap(find.byType(LanguageChip));
    await tester.pumpAndSettle();
    expect(find.byType(CountrySelectPage), findsOneWidget);

    await tester.tap(find.text('Ўзбекистон'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton)); 
    await tester.pumpAndSettle();

    expect(find.byType(CountrySelectPage), findsNothing);
    expect(find.text('🇺🇿 Ўзбекистон · Кирилл'), findsOneWidget);
  });
}
