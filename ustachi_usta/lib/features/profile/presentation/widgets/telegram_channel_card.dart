import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/icons/telegram_icon.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/presentation/widgets/support_sheet.dart';

class TelegramChannelCard extends StatelessWidget {
  const TelegramChannelCard({super.key});

  Future<void> _open() async {
    final ok = await launchUrl(
      Uri.parse(SupportSheet.telegramUrl),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!ok) {
      await Clipboard.setData(const ClipboardData(text: SupportSheet.telegramUrl));
      sl<SnackbarService>().showMessage(t.profile.help.copied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final tr = context.t.profile.help;
    return ChizmaSheet(
      onTap: _open,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Row(
        children: [
          const TelegramIcon(size: 40),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.telegramLabel,
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${SupportSheet.telegram} · ${tr.telegramHint}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.body5.copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, size: 18, color: colors.neutral.textMuted),
        ],
      ),
    );
  }
}
