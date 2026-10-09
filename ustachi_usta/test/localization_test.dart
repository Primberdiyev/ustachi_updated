
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/country.dart';

const _dir = 'lib/core/utils/localization';

Map<String, dynamic> _locale(String code) => Map<String, dynamic>.from(
      jsonDecode(File('$_dir/$code.i18n.json').readAsStringSync()) as Map,
    );

Set<String> _keys(Map<String, dynamic> json, [String prefix = '']) {
  final keys = <String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map) {
      keys.addAll(_keys(Map<String, dynamic>.from(value), path));
    } else {
      keys.add(path);
    }
  });
  return keys;
}

void main() {
  group('Davlat → til', () {
    test('sakkizta davlat — tartibi + rus tili', () {

      expect(Country.values.map((c) => c.code).toList(),
          ['UZ', 'KZ', 'KG', 'TR', 'TJ', 'TM', 'RU', 'XX']);
    });

    test('har davlat O\'Z tiliga bog\'langan', () {
      expect(Country.uzbekistan.locale, AppLocale.uz);
      expect(Country.kazakhstan.locale, AppLocale.kk);
      expect(Country.kyrgyzstan.locale, AppLocale.ky);
      expect(Country.turkey.locale, AppLocale.tr);
      expect(Country.tajikistan.locale, AppLocale.tg);
      expect(Country.turkmenistan.locale, AppLocale.tk);
      expect(Country.russia.locale, AppLocale.ru);

      expect(Country.other.locale, AppLocale.en);
    });

    test('har tilga BITTA davlat — takror yo\'q', () {
      final locales = Country.values.map((c) => c.locale).toList();
      expect(locales.toSet().length, locales.length);
    });

    test('davlat nomi O\'Z TILIDA — foydalanuvchi hali til tanlamagan', () {

      expect(Country.kazakhstan.nativeName, 'Қазақстан');
      expect(Country.turkey.nativeName, 'Türkiye');
      expect(Country.tajikistan.nativeName, 'Тоҷикистон');
      expect(Country.russia.nativeName, 'Россия');
    });

    test('bayroq har davlatda bor va bo\'sh emas', () {
      for (final country in Country.values) {
        expect(country.flag.isNotEmpty, isTrue, reason: country.code);
      }
    });

    test('noma\'lum kod — O\'zbekistonga tushadi (xavfsiz default)', () {
      expect(Country.fromCode(null), Country.uzbekistan);
      expect(Country.fromCode(''), Country.uzbekistan);
      expect(Country.fromCode('ZZ'), Country.uzbekistan);
      expect(Country.fromCode('TR'), Country.turkey);
    });

    test('qurilma tilidan davlat taxmin qilinadi', () {
      expect(Country.fromLocale(AppLocale.ky), Country.kyrgyzstan);
      expect(Country.fromLocale(AppLocale.uz), Country.uzbekistan);
    });
  });

  group('Tarjima fayllari', () {
    test('har davlat tili uchun FAYL bor', () {
      for (final country in Country.values) {
        final code = country.locale.languageCode;
        expect(File('$_dir/$code.i18n.json').existsSync(), isTrue,
            reason: '$code.i18n.json yo\'q — ${country.nativeName} tanlansa '
                'til umuman almashmaydi');
      }
    });

    test('AppLocale ro\'yxati davlatlar bilan mos', () {
      final countryLocales = Country.values.map((c) => c.locale).toSet();
      expect(AppLocale.values.toSet(), countryLocales);
    });

    test('BARCHA kalitlar hamma tilda tarjima qilingan', () {

      final uz = _keys(_locale('uz'));

      for (final locale in AppLocale.values) {
        if (locale == AppLocale.uz) continue;
        final translated = _keys(_locale(locale.languageCode));
        final missing = uz.difference(translated);
        expect(missing, isEmpty,
            reason: '${locale.languageCode}: '
                '${missing.length} kalit yetishmaydi -> '
                '${missing.take(5).join(', ')}');
      }
    });

    test('ortiqcha (o\'zbekchada yo\'q) kalit ham bo\'lmaydi', () {

      final uz = _keys(_locale('uz'));
      for (final locale in AppLocale.values) {
        if (locale == AppLocale.uz) continue;
        final extra = _keys(_locale(locale.languageCode)).difference(uz);
        expect(extra, isEmpty,
            reason: '${locale.languageCode}: ortiqcha kalit');
      }
    });

    test('tarjimada BO\'SH qiymat yo\'q', () {
      for (final locale in AppLocale.values) {
        final json = _locale(locale.languageCode);
        void walk(Map<String, dynamic> map, String prefix) {
          map.forEach((key, value) {
            final path = prefix.isEmpty ? key : '$prefix.$key';
            if (value is Map) {
              walk(Map<String, dynamic>.from(value), path);
            } else {
              expect(value.toString().trim().isNotEmpty, isTrue,
                  reason: '${locale.languageCode} → $path bo\'sh');
            }
          });
        }

        walk(json, '');
      }
    });

    test('o\'rin egallovchilar (`\${phone}`) tarjimada SAQLANADI', () {

      for (final locale in AppLocale.values) {
        final json = _locale(locale.languageCode);
        final auth = json['auth'] as Map?;
        final otp = auth?['otp'] as Map?;
        final message = otp?['sentMessage']?.toString();
        if (message == null) continue;
        expect(message.contains(r'${phone}'), isTrue,
            reason: '${locale.languageCode}: sentMessage ichida raqam yo\'q');
      }
    });
  });
}
