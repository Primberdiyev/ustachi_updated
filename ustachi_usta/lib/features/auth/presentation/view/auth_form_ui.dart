import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/formatter.dart';

class AuthFormUi {
  const AuthFormUi._();

  static TextEditingController createPhoneController() =>
      UzPhoneInput.createController();

  static TextInputFormatter createPhoneFormatter() =>
      UzPhoneInput.createFormatter();

  static const String phonePrefix = UzPhoneInput.prefix;
  static const int phonePrefixLength = UzPhoneInput.prefixLength;

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
