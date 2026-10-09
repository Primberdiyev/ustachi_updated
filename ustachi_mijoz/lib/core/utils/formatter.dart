import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:yaml/yaml.dart';

class Formatters {
  static MaskTextInputFormatter phoneFormatter({String? mask}) =>
      MaskTextInputFormatter(
        mask: mask ?? PhoneMaskTypes.onlyNumbersAndDash.formatter,
        filter: {'#': RegExp(r'[+0-9]')},
        type: MaskAutoCompletionType.lazy,
      );

  static final cardNumberFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final cardExpirationDateFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static Future<String?> getAppVersion() async {
    final String asset = await rootBundle.loadString("pubspec.yaml");
    if (asset.isNotEmpty) {
      var yaml = loadYaml(asset);
      return yaml["version"] ?? "";
    }
    return null;
  }
}

enum PhoneMaskTypes {
  onlyNumbers,
  onlyNumbersAndDash,
  withCountryCode,
  withCountryCodeAndPlus,
  withCountryCodeAndPlusAndSpaces,
  withCountryCodeAndPlusAndDash,
}

extension PhoneMaskFormatter on PhoneMaskTypes {
  String get formatter {
    switch (this) {
      case PhoneMaskTypes.onlyNumbers:
        return '## ### ## ##';
      case PhoneMaskTypes.onlyNumbersAndDash:
        return '##-###-##-##';
      case PhoneMaskTypes.withCountryCode:
        return '998#########'; 
      case PhoneMaskTypes.withCountryCodeAndPlus:
        return '+998#########';
      case PhoneMaskTypes.withCountryCodeAndPlusAndSpaces:
        return '+998 ## ### ## ##';
      case PhoneMaskTypes.withCountryCodeAndPlusAndDash:
        return '+998 ##-###-##-##';
    }
  }
}
