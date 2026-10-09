
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/fallback_localizations.dart';
import 'package:ustachi/features/main/presentation/widgets/main_tab_spec.dart';

import 'support/l10n_harness.dart';

Widget _app(Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      home: Scaffold(
        appBar: AppBar(title: const Text('sarlavha')),
        body: Builder(
          builder: (context) => Column(
            children: [
              Text(MaterialLocalizations.of(context).okButtonLabel),
              Text(CupertinoLocalizations.of(context).todayLabel),
            ],
          ),
        ),
      ),
    );

void main() {
  group('Har bir qo\'llab-quvvatlanadigan tilda ekran quriladi', () {
    for (final locale in AppLocale.values) {
      testWidgets(locale.languageCode, (tester) async {
        await tester.pumpWidget(_app(locale.flutterLocale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: '${locale.languageCode}: ekran qurilishida xato');
        expect(find.byType(AppBar), findsOneWidget);
      });
    }
  });

  testWidgets('Flutter bilmaydigan tilda ham MaterialLocalizations bor',
      (tester) async {

    for (final code in ['tg', 'tk']) {
      await tester.pumpWidget(_app(Locale(code)));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      expect(MaterialLocalizations.of(context), isNotNull, reason: code);
      expect(CupertinoLocalizations.of(context), isNotNull, reason: code);
    }
  });

  group('Buyurtmalar tabi yorlig\'i', () {

    for (final locale in AppLocale.values) {
      testWidgets('${locale.languageCode} — tor ekranda kesilmaydi',
          (tester) async {
        await useTestLocale(tester, locale);
        addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.uz));

        late List<MainTabSpec> specs;
        await tester.pumpWidget(
          TranslationProvider(
            child: MediaQuery(

              data: const MediaQueryData(size: Size(360, 800)),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (context) {
                    specs = mainTabSpecs(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(specs, hasLength(4));
        for (final spec in specs) {
          expect(spec.label.isNotEmpty, isTrue);
        }

        final expected = tr;
        expect(specs.first.label, expected.dashboard.title);
        expect(specs[3].label, expected.home.profile);
        expect(expected.orders.title.startsWith(specs[1].label), isTrue,
            reason: 'qisqartma asl sarlavhadan olinadi');
      });
    }
  });
}
