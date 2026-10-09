
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

LanguageChoice _byId(String id) => languageChoices.firstWhere((c) => c.id == id);

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

  test('uch qator: o\'zbekcha lotin, o\'zbekcha kirill, ruscha', () {
    expect(languageChoices.map((c) => c.id), ['uz_latin', 'uz_cyrillic', 'ru']);
    expect(languageChoices.map((c) => c.label), [
      "O'zbekcha · Lotin",
      'Ўзбекча · Кирилл',
      'Русский',
    ]);
  });

  test('sukut — o\'zbekcha lotin', () {
    expect(LanguageProvider().choice.id, 'uz_latin');
  });

  test('o\'zbekcha kirill: til o\'zbekcha qoladi, yozuv kirill', () async {
    await LanguageProvider().setChoice(_byId('uz_cyrillic'));

    expect(LanguageProvider().locale, AppLocale.uz);
    expect(ScriptProvider().script, UzScript.cyrillic);
    expect(LanguageProvider().choice.id, 'uz_cyrillic');
    expect(StorageRepository.getString(StoreKeys.language), 'uz');
    expect(StorageRepository.getString(StoreKeys.uzScript), 'cyrillic');
  });

  test('ruscha: yozuv lotinga qaytadi — rus matni o\'girilmaydi', () async {
    await LanguageProvider().setChoice(_byId('uz_cyrillic'));
    await LanguageProvider().setChoice(_byId('ru'));

    expect(LanguageProvider().locale, AppLocale.ru);
    expect(ScriptProvider().script, UzScript.latin);
    expect(LanguageProvider().choice.id, 'ru');
    expect(StorageRepository.getString(StoreKeys.uzScript), 'latin');
  });

  test('ruscha → o\'zbekcha kirill → o\'zbekcha lotin', () async {
    await LanguageProvider().setChoice(_byId('ru'));
    await LanguageProvider().setChoice(_byId('uz_cyrillic'));
    expect(LanguageProvider().choice.id, 'uz_cyrillic');

    await LanguageProvider().setChoice(_byId('uz_latin'));
    expect(LanguageProvider().choice.id, 'uz_latin');
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
