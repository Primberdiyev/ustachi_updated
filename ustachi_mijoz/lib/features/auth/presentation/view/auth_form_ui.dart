import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/formatter.dart';

class AuthFormUi {
  const AuthFormUi._();

  static TextEditingController createPhoneController() {
    return TextEditingController.fromValue(
      const TextEditingValue(
        text: phonePrefix,
        selection: TextSelection.collapsed(offset: phonePrefixLength),
      ),
    );
  }

  static TextInputFormatter createPhoneFormatter() {
    return _UzPhoneTextInputFormatter();
  }

  static const String phonePrefix = '+998 ';
  static const int phonePrefixLength = 5;

  static InputDecoration phoneInputDecoration(BuildContext context) {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final primaryColor = context.color.categorizedColor.primary;
    final foregroundColor = context.color.neutral.white;

    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static Widget buttonLoader(
    BuildContext context, {
    Color? color,
  }) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? context.color.neutral.white,
      ),
    );
  }
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
        ? AuthFormUi.phonePrefix
        : '${AuthFormUi.phonePrefix}$maskedNumber';

    return TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: fullText.length),
    );
  }
}
