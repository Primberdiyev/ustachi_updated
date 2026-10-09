import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/design_sytem/open_colors.dart';
import 'package:ustachi/core/utils/extensions.dart';

class WorkPreferenceCard extends StatelessWidget {
  const WorkPreferenceCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.description,
    this.isSaving = false,
    this.accentColor,
    this.compact = false,
  });

  final String title;
  final String statusText;
  final String? description;
  final IconData icon;
  final bool value;
  final bool isSaving;
  final ValueChanged<bool> onChanged;
  final Color? accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final accent = accentColor ?? colors.categorizedColor.success;

    if (compact) {
      return _buildCompact(context, accent, colors);
    }

    return Semantics(
      container: true,
      label: title,
      value: statusText,
      toggled: value,
      child: ChizmaSheet(
        onTap: isSaving ? null : () => onChanged(!value),
        padding: const EdgeInsets.all(ChizmaSpace.lg),
        borderColor: value ? accent.withValues(alpha: 0.38) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: value
                        ? accent.withValues(alpha: 0.13)
                        : colors.neutral.bg,
                    borderRadius: BorderRadius.circular(ChizmaRadius.md),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: value ? accent : colors.neutral.textMuted,
                  ),
                ),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.body4.copyWith(
                          color: colors.neutral.textStrong,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: ChizmaSpace.xs),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: Text(
                          statusText,
                          key: ValueKey(statusText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.body5.copyWith(
                            color: value ? accent : colors.neutral.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ChizmaSpace.sm),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: isSaving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: accent,
                            ),
                          )
                        : Switch.adaptive(
                            value: value,
                            onChanged: isSaving ? null : onChanged,
                          ),
                  ),
                ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: ChizmaSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 46 + ChizmaSpace.md),
                  Expanded(
                    child: Text(
                      description!,
                      style: context.text.label.copyWith(
                        color: colors.neutral.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, Color accent, OpenColors colors) {
    return Semantics(
      container: true,
      label: title,
      value: statusText,
      toggled: value,
      child: ChizmaSheet(
        onTap: isSaving ? null : () => onChanged(!value),
        padding: const EdgeInsets.all(ChizmaSpace.md),
        borderColor: value ? accent.withValues(alpha: 0.38) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: value
                        ? accent.withValues(alpha: 0.13)
                        : colors.neutral.bg,
                    borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: value ? accent : colors.neutral.textMuted,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 52,
                  height: 42,
                  child: Center(
                    child: isSaving
                        ? SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: accent,
                            ),
                          )
                        : Switch.adaptive(
                            value: value,
                            onChanged: onChanged,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChizmaSpace.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.body5.copyWith(
                      color: colors.neutral.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (description != null && description!.isNotEmpty)
                  Tooltip(
                    message: description!,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, top: 1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: colors.neutral.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ChizmaSpace.xs),
            Text(
              statusText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.label.copyWith(
                color: value ? accent : colors.neutral.textMuted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
