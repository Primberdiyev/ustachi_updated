
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/country.dart';

CountryChoice _pick(Country country, [UzScript script = UzScript.latin]) =>
    countryChoices.firstWhere((c) => c.country == country && (!c.hasScript || c.script == script));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'uz.ustachi.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await StorageRepository.getInstance();
    await (await SharedPreferences.getInstance()).clear();
    await LanguageProvider().setLocale(AppLocale.uz);
    ScriptProvider().setScript(UzScript.latin);
  });

  test('O\'zbekiston ikki qator (lotin, kirill), qolgan davlatlar bittadan', () {
    final uz = countryChoices.where((c) => c.country == Country.uzbekistan).toList();
    expect(uz.map((c) => c.script), [UzScript.latin, UzScript.cyrillic]);
    expect(countryChoices.length, Country.values.length + 1);
    for (final c in countryChoices.where((c) => c.country != Country.uzbekistan)) {
      expect(c.hint, isEmpty, reason: c.country.code);
    }
  });

  test('qatorlar o\'z yozuvida: lotin va kirill', () {
    expect(_pick(Country.uzbekistan).label, '🇺🇿 O‘zbekiston · Lotin');
    expect(_pick(Country.uzbekistan, UzScript.cyrillic).label, '🇺🇿 Ўзбекистон · Кирилл');
    expect(_pick(Country.russia).label, '🇷🇺 Россия');
  });

  test('birinchi ochilish (davlat tanlanmagan): joriy tilga qarab', () {
    expect(LanguageProvider().needsCountry, isTrue);
    expect(LanguageProvider().choice.country, Country.uzbekistan);
  });

  test('O\'zbekiston kirill: davlat, til o\'zbekcha, yozuv kirill', () async {
    await LanguageProvider().setChoice(_pick(Country.uzbekistan, UzScript.cyrillic));

    expect(LanguageProvider().locale, AppLocale.uz);
    expect(ScriptProvider().script, UzScript.cyrillic);
    expect(LanguageProvider().choice.script, UzScript.cyrillic);
    expect(StorageRepository.getString(StoreKeys.country), 'UZ');
    expect(StorageRepository.getString(StoreKeys.uzScript), 'cyrillic');
  });

  test('boshqa davlatga o\'tganda yozuv lotinga qaytadi (o\'girilmaydi)', () async {
    await LanguageProvider().setChoice(_pick(Country.uzbekistan, UzScript.cyrillic));
    await LanguageProvider().setChoice(_pick(Country.kazakhstan));

    expect(LanguageProvider().locale, AppLocale.kk);
    expect(ScriptProvider().script, UzScript.latin);
    expect(LanguageProvider().choice.country, Country.kazakhstan);
    expect(LanguageProvider().needsCountry, isFalse);
  });

  test('qozoq → O\'zbekiston kirill → O\'zbekiston lotin', () async {
    await LanguageProvider().setChoice(_pick(Country.kazakhstan));
    await LanguageProvider().setChoice(_pick(Country.uzbekistan, UzScript.cyrillic));
    expect(LanguageProvider().choice, _pick(Country.uzbekistan, UzScript.cyrillic));

    await LanguageProvider().setChoice(_pick(Country.uzbekistan));
    expect(LanguageProvider().choice, _pick(Country.uzbekistan));
    expect(ScriptProvider().script, UzScript.latin);
  });

  test('eski saqlangan tanlov: rus tili + kirill — yuklanganda lotin', () async {
    await StorageRepository.putString(StoreKeys.language, 'ru');
    await StorageRepository.putString(StoreKeys.uzScript, 'cyrillic');

    ScriptProvider().load();

    expect(ScriptProvider().script, UzScript.latin);
  });

  test('o\'zbekcha + kirill saqlangan bo\'lsa yuklanganda kirill qoladi', () async {
    await StorageRepository.putString(StoreKeys.language, 'uz');
    await StorageRepository.putString(StoreKeys.uzScript, 'cyrillic');

    ScriptProvider().load();

    expect(ScriptProvider().script, UzScript.cyrillic);
  });
}
