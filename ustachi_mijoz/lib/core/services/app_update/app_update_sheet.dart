import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateSheet extends StatelessWidget {
  const AppUpdateSheet({
    super.key,
    required this.info,
    required this.onUpdate,
    this.onLater,
  });

  final AppUpdateInfo info;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;

  static Future<bool?> show(
    BuildContext context, {
    required AppUpdateInfo info,
    required Future<void> Function() onLater,
    void Function(Route<bool> route)? onRoute,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: !info.isForced,
      enableDrag: !info.isForced,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetContext) {
        final route = ModalRoute.of<bool>(sheetContext);
        if (route != null) onRoute?.call(route);
        return PopScope(
          canPop: !info.isForced,
          child: AppUpdateSheet(
            info: info,
            onUpdate: () => Navigator.of(sheetContext).pop(true),
            onLater: info.isForced
                ? null
                : () async {
                    await onLater();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop(false);
                    }
                  },
          ),
        );
      },
    );
  }

  static Future<bool> openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final cat = colors.categorizedColor;
    final t = context.t.appUpdate;
    final forced = info.isForced;

    final tone = cat.primary;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.md,
          vertical: ChizmaSpace.md,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          borderRadius: BorderRadius.circular(ChizmaRadius.lg + 8),
          border: Border.all(color: colors.neutral.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Center(
              child: Container(
                margin: const EdgeInsets.only(top: ChizmaSpace.sm, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.neutral.borderStrong.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: ChizmaSpace.md),

                    Container(
                      padding: const EdgeInsets.all(ChizmaSpace.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tone.withValues(alpha: 0.12),
                            tone.withValues(alpha: 0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                        border: Border.all(
                          color: tone.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [

                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: tone.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tone.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tone.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              forced
                                  ? Icons.system_security_update_warning_rounded
                                  : Icons.rocket_launch_rounded,
                              color: tone,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: ChizmaSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t.eyebrow.toUpperCase(),
                                      style: context.text.label.copyWith(
                                        color: tone,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: ChizmaSpace.xs + 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tone.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                            ChizmaRadius.pill),
                                      ),
                                      child: Text(
                                        forced ? 'MUHIM' : 'TAYYOR',
                                        style: context.text.label.copyWith(
                                          color: tone,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  forced
                                      ? t.titleRequired
                                      : t.titleOptional,
                                  style: context.text.h4.copyWith(
                                    color: colors.neutral.textStrong,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: ChizmaSpace.lg),

                    _VersionRow(info: info, tone: tone),

                    const SizedBox(height: ChizmaSpace.md),

                    Text(
                      forced ? t.bodyRequired : t.bodyOptional,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textBody,
                        height: 1.45,
                      ),
                    ),

                    if (info.notes.isNotEmpty) ...[
                      const SizedBox(height: ChizmaSpace.lg),
                      _Notes(notes: info.notes, tone: tone),
                    ],
                    const SizedBox(height: ChizmaSpace.lg),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                ChizmaSpace.xl,
                ChizmaSpace.md,
                ChizmaSpace.xl,
                ChizmaSpace.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tone,
                        foregroundColor: colors.neutral.white,
                        minimumSize: const Size.fromHeight(52),
                        elevation: 2,
                        shadowColor: tone.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: Text(
                        t.update,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  if (onLater != null) ...[
                    const SizedBox(height: ChizmaSpace.sm),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onLater,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.neutral.textMuted,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ChizmaRadius.md),
                          ),
                        ),
                        child: Text(
                          t.later,
                          style: TextStyle(
                            color: colors.neutral.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.info, required this.tone});

  final AppUpdateInfo info;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.appUpdate;

    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.md),
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Row(
        children: [
          _VersionChip(
            label: t.versionFrom,
            version: info.currentVersion,
            color: colors.neutral.textMuted,
            background: colors.neutral.surface,
            borderColor: colors.neutral.border,
            isNew: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.md),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: tone,
              ),
            ),
          ),
          _VersionChip(
            label: t.versionTo,
            version: info.latestVersion,
            color: tone,
            background: tone.withValues(alpha: 0.12),
            borderColor: tone.withValues(alpha: 0.35),
            isNew: true,
          ),
        ],
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.version,
    required this.color,
    required this.background,
    required this.borderColor,
    required this.isNew,
  });

  final String label;
  final String version;
  final Color color;
  final Color background;
  final Color borderColor;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.md,
          vertical: ChizmaSpace.sm + 2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: context.text.label.copyWith(
                    color: context.color.neutral.textMuted,
                    fontSize: 10,
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              version,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.body4.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes({required this.notes, required this.tone});

  final List<String> notes;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.lg),
      decoration: BoxDecoration(
        color: colors.neutral.surface2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: tone,
              ),
              const SizedBox(width: ChizmaSpace.xs),
              Expanded(
                child: ChizmaEyebrow(context.t.appUpdate.whatsNew),
              ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.md),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: tone,
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.sm + 2),
                  Expanded(
                    child: Text(
                      note,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textBody,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
