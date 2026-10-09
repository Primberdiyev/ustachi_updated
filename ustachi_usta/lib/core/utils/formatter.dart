import 'package:flutter/widgets.dart';
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

abstract final class UzPhoneInput {
  static const String prefix = '+998 ';
  static const int prefixLength = prefix.length;

  static TextEditingController createController() =>
      TextEditingController.fromValue(
        const TextEditingValue(
          text: prefix,
          selection: TextSelection.collapsed(offset: prefixLength),
        ),
      );

  static TextInputFormatter createFormatter() => _UzPhoneTextInputFormatter();

  static String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  static bool hasNumber(String text) => digitsOf(text).length > 3;

  static String valueOf(String text) => hasNumber(text) ? text.trim() : '';
}

class _UzPhoneTextInputFormatter extends TextInputFormatter {
  _UzPhoneTextInputFormatter()
      : _maskFormatter = Formatters.phoneFormatter(
          mask: PhoneMaskTypes.onlyNumbers.formatter,
        );

  final TextInputFormatter _maskFormatter;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var localNumber = digits;

    if (localNumber.startsWith('998')) {
      localNumber = localNumber.substring(3);
    }

    if (localNumber.length > 9) {
      localNumber = localNumber.substring(0, 9);
    }

    final sanitizedValue = TextEditingValue(
      text: localNumber,
      selection: TextSelection.collapsed(offset: localNumber.length),
    );

    final maskedValue = _maskFormatter.formatEditUpdate(
      const TextEditingValue(),
      sanitizedValue,
    );
    final maskedNumber = maskedValue.text;
    final fullText = maskedNumber.isEmpty
        ? UzPhoneInput.prefix
        : '${UzPhoneInput.prefix}$maskedNumber';

    return TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: fullText.length),
    );
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
