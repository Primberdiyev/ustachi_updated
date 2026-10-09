import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

export 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart'
    show
        AppLocale,
        AppLocaleUtils,
        LocaleSettings,
        TranslationProvider,
        Translations;

export 'package:slang_flutter/slang_flutter.dart';

Widget withTranslations(Widget child) => TranslationProvider(child: child);

Future<void> useTestLocale(
  WidgetTester tester, [
  AppLocale locale = AppLocale.uz,
]) async {
  await tester.runAsync(() => LocaleSettings.setLocale(locale));
}

Translations get tr => LocaleSettings.instance.currentTranslations;
