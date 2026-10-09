import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportSheet extends StatelessWidget {
  const SupportSheet({super.key});

  static const String phone = '+998993271870';
  static const String phonePretty = '+998 99 327 18 70';
  static const String email = 'ustachi@gmail.com';

  static const String telegram = '@ustachi_rasmiy';
  static const String telegramUrl = 'https://t.me/ustachi_rasmiy';

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SupportSheet(),
      );

  Future<void> _open(Uri uri, {String? copyOnFail}) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication)
        .catchError((_) => false);

    if (!ok && copyOnFail != null) {
      await Clipboard.setData(ClipboardData(text: copyOnFail));
      sl<SnackbarService>().showMessage(t.profile.help.copied);
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    sl<SnackbarService>().showMessage(t.profile.help.copied);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final tr = context.t.profile.help;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(ChizmaSpace.md),
        padding: const EdgeInsets.fromLTRB(
            ChizmaSpace.lg, ChizmaSpace.md, ChizmaSpace.lg, ChizmaSpace.lg),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          borderRadius: BorderRadius.circular(ChizmaRadius.lg),
          border: Border.all(color: colors.neutral.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.neutral.border,
                  borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: ChizmaSpace.lg),
            Row(
              children: [
                ChizmaIconTile(
                  icon: Icons.support_agent_rounded,
                  filled: true,
                ),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t.profile.support,
                        style: context.text.h4
                            .copyWith(color: colors.neutral.textStrong),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.subtitle,
                        style: context.text.body5
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChizmaSpace.lg),

            _ContactTile(
              icon: Icons.call_rounded,
              label: tr.callLabel,
              value: phonePretty,
              accent: colors.categorizedColor.success,
              onTap: () => _open(Uri.parse('tel:$phone'), copyOnFail: phone),
              onCopy: () => _copy(phone),
            ),
            const SizedBox(height: ChizmaSpace.sm),
            _ContactTile(
              icon: Icons.mail_outline_rounded,
              label: tr.emailLabel,
              value: email,
              accent: colors.categorizedColor.info,
              onTap: () => _open(Uri.parse('mailto:$email'), copyOnFail: email),
              onCopy: () => _copy(email),
            ),
            const SizedBox(height: ChizmaSpace.sm),
            _ContactTile(
              icon: Icons.send_rounded,
              label: tr.telegramLabel,
              value: telegram,
              accent: const Color(0xFF29A9EA),
              onTap: () => _open(Uri.parse(telegramUrl), copyOnFail: telegramUrl),
              onCopy: () => _copy(telegramUrl),
            ),

            const SizedBox(height: ChizmaSpace.md),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 15, color: colors.neutral.textMuted),
                const SizedBox(width: ChizmaSpace.sm),
                Expanded(
                  child: Text(
                    tr.workHours,
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
    required this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.md);

    return Material(
      color: colors.neutral.surface2,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        onLongPress: onCopy,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCopy,
                tooltip: uz(context.t.common.copy),
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.copy_rounded,
                    size: 18, color: colors.neutral.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
