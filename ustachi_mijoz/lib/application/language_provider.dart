import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/assets/app_icons.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

final List<LanguageChoice> languageChoices = [
  LanguageChoice(
    id: 'uz_latin',
    title: UzScript.latin.sample,
    hint: UzScript.latin.label,
    flag: AppIcons.flagUz,
    appLocale: AppLocale.uz,
    script: UzScript.latin,
  ),
  LanguageChoice(
    id: 'uz_cyrillic',
    title: UzScript.cyrillic.sample,
    hint: UzScript.cyrillic.label,
    flag: AppIcons.flagUz,
    appLocale: AppLocale.uz,
    script: UzScript.cyrillic,
  ),
  LanguageChoice(
    id: 'ru',
    title: 'Русский',
    hint: '',
    flag: AppIcons.flagRu,
    appLocale: AppLocale.ru,
  ),
];

class LanguageChoice {
  const LanguageChoice({
    required this.id,
    required this.title,
    required this.hint,
    required this.flag,
    required this.appLocale,
    this.script = UzScript.latin,
  });

  final String id;

  final String title;

  final String hint;
  final String flag;
  final AppLocale appLocale;
  final UzScript script;

  String get label => hint.isEmpty ? title : '$title · $hint';
}

class LanguageProvider {
  static final LanguageProvider _instance = LanguageProvider._internal();

  factory LanguageProvider() {
    return _instance;
  }

  LanguageProvider._internal();

  AppLocale get locale => LocaleSettings.currentLocale;

  LanguageChoice get choice => languageChoices.firstWhere(
        (c) =>
            c.appLocale == locale &&
            (c.appLocale != AppLocale.uz || c.script == ScriptProvider().script),
        orElse: () => languageChoices.first,
      );

  Future<void> setChoice(LanguageChoice choice) async {
    await setLocale(choice.appLocale);
    ScriptProvider().setScript(choice.script);
  }

  Future<void> setLocale(AppLocale appLocale) async {
    if (!AppLocale.values.contains(appLocale)) {
      return;
    }
    await StorageRepository.putString(
        StoreKeys.language, appLocale.languageCode);
    await LocaleSettings.setLocale(appLocale);
  }

  Future<void> loadLocale() async {
    final String localeCode = StorageRepository.getString(StoreKeys.language);
    if (localeCode == '') {
      await StorageRepository.putString(
          StoreKeys.language, AppLocale.uz.languageCode);
      LocaleSettings.setLocale(AppLocale.uz);
    } else {
      LocaleSettings.setLocale(
        AppLocale.values.firstWhere(
          (locale) => locale.languageCode == localeCode,
          orElse: () => AppLocale.uz,
        ),
      );
    }
  }
}
