import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

enum Country {
  uzbekistan('UZ', '🇺🇿', 'O‘zbekiston', AppLocale.uz),
  kazakhstan('KZ', '🇰🇿', 'Қазақстан', AppLocale.kk),
  kyrgyzstan('KG', '🇰🇬', 'Кыргызстан', AppLocale.ky),
  turkey('TR', '🇹🇷', 'Türkiye', AppLocale.tr),
  tajikistan('TJ', '🇹🇯', 'Тоҷикистон', AppLocale.tg),
  turkmenistan('TM', '🇹🇲', 'Türkmenistan', AppLocale.tk),

  russia('RU', '🇷🇺', 'Россия', AppLocale.ru),

  other('XX', '🌍', 'Other countries', AppLocale.en);

  const Country(this.code, this.flag, this.nativeName, this.locale);

  final String code;
  final String flag;

  final String nativeName;

  final AppLocale locale;

  static Country fromCode(String? code) => values.firstWhere(
        (country) => country.code == code,
        orElse: () => Country.uzbekistan,
      );

  static Country fromLocale(AppLocale locale) => values.firstWhere(
        (country) => country.locale == locale,
        orElse: () => Country.uzbekistan,
      );
}

class CountryChoice {
  const CountryChoice(this.country, [this.script = UzScript.latin]);

  final Country country;
  final UzScript script;

  bool get hasScript => country == Country.uzbekistan;

  String get title => hasScript && script == UzScript.cyrillic
      ? 'Ўзбекистон'
      : country.nativeName;

  String get hint => hasScript ? script.label : '';

  String get label => '${country.flag} $title${hint.isEmpty ? '' : ' · $hint'}';
}

final List<CountryChoice> countryChoices = [
  for (final country in Country.values)
    if (country == Country.uzbekistan) ...[
      const CountryChoice(Country.uzbekistan, UzScript.latin),
      const CountryChoice(Country.uzbekistan, UzScript.cyrillic),
    ] else
      CountryChoice(country),
];
