import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final error = colors.categorizedColor.error;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.logout_rounded, size: 20, color: error),
      label: Text(
        context.t.profile.logout,
        style: context.text.body1.copyWith(
          color: error,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: error.withValues(alpha: 0.04),
        side: BorderSide(color: error.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
