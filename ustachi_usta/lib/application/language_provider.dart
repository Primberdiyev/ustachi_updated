import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/country.dart';

class LanguageProvider {
  static final LanguageProvider _instance = LanguageProvider._internal();

  factory LanguageProvider() {
    return _instance;
  }

  LanguageProvider._internal();

  AppLocale get locale => LocaleSettings.currentLocale;

  Future<void> setLocale(AppLocale appLocale) async {
    if (!AppLocale.values.contains(appLocale)) {
      return;
    }
    await StorageRepository.putString(
        StoreKeys.language, appLocale.languageCode);
    await LocaleSettings.setLocale(appLocale);
  }

  Country get country =>
      Country.fromCode(StorageRepository.getString(StoreKeys.country));

  CountryChoice get choice {

    final current = needsCountry ? Country.fromLocale(locale) : country;
    return countryChoices.firstWhere(
      (c) =>
          c.country == current &&
          (!c.hasScript || c.script == ScriptProvider().script),
      orElse: () => countryChoices.first,
    );
  }

  Future<void> setChoice(CountryChoice choice) async {
    await StorageRepository.putString(StoreKeys.country, choice.country.code);
    await setLocale(choice.country.locale);
    ScriptProvider().setScript(choice.script);
  }

  bool get needsCountry =>
      StorageRepository.getString(StoreKeys.country).isEmpty;

  Future<void> loadLocale() async {
    final String localeCode = StorageRepository.getString(StoreKeys.language);
    if (localeCode == '') {
      await StorageRepository.putString(
          StoreKeys.language, AppLocale.uz.languageCode);
      await LocaleSettings.setLocale(AppLocale.uz);
    } else {
      await LocaleSettings.setLocale(
        AppLocale.values.firstWhere(
          (locale) => locale.languageCode == localeCode,
          orElse: () => AppLocale.uz,
        ),
      );
    }
  }
}
