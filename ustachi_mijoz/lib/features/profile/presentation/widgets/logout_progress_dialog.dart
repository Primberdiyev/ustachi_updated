import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class LogoutProgressDialog extends StatelessWidget {
  const LogoutProgressDialog({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const LogoutProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.profile;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: colors.neutral.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 44,
                width: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.categorizedColor.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.loggingOut,
                textAlign: TextAlign.center,
                style: context.text.body1.copyWith(
                  color: colors.neutral.black1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.loggingOutHint,
                textAlign: TextAlign.center,
                style:
                    context.text.body3.copyWith(color: colors.neutral.black3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
