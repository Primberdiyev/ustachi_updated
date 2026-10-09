import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/masters/domain/models/master_card_item_model.dart';

class MasterCardItem extends StatelessWidget {
  const MasterCardItem({super.key, required this.model});
  final MasterCardItemModel model;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final openProfile =
        model.onTap == null ? null : () => model.onTap!(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
      child: ChizmaSheet(
        onTap: openProfile,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: model.name, imageUrl: model.imageUrl),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.h4.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: ChizmaSpace.xs),
                      Text(model.job,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.body4.copyWith(
                              color: primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChizmaSpace.md),
            Wrap(
              spacing: ChizmaSpace.sm,
              runSpacing: ChizmaSpace.sm,
              children: [
                _DetailTag(
                  icon: model.rating == null
                      ? Icons.star_outline_rounded
                      : Icons.star_rounded,
                  label: model.rating?.toStringAsFixed(1) ??
                      context.t.masters.notRated,
                  highlighted: model.rating != null,
                ),
                _DetailTag(
                    icon: Icons.work_history_outlined, label: model.experience),
              ],
            ),
            const SizedBox(height: ChizmaSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 17, color: colors.neutral.textMuted),
                const SizedBox(width: ChizmaSpace.xs),
                Expanded(
                  child: Text(model.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.body4
                          .copyWith(color: colors.neutral.textMuted)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.md),
              child: Divider(height: 1, color: colors.neutral.border),
            ),
            Text(model.price,
                style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: ChizmaSpace.md),

            Wrap(
              spacing: ChizmaSpace.sm,
              runSpacing: ChizmaSpace.sm,
              children: [
                FilledButton.icon(
                  onPressed: openProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: colors.neutral.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ChizmaRadius.md)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(context.t.masters.viewProfile),
                ),
                if (model.phone.trim().isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri(scheme: 'tel', path: model.phone),
                      mode: LaunchMode.externalApplication,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: colors.neutral.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ChizmaRadius.md)),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: Text(model.phone),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  const _DetailTag(
      {required this.icon, required this.label, this.highlighted = false});
  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final foreground = highlighted
        ? colors.categorizedColor.primary
        : colors.neutral.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? foreground.withValues(alpha: 0.08)
            : colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
      ),
      child: Text.rich(
          TextSpan(children: [
            WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(icon, size: 15, color: foreground))),
            TextSpan(text: label),
          ]),
          style: context.text.body5.copyWith(
              color: foreground,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.imageUrl});
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final primary = context.color.categorizedColor.primary;
    final trimmed = name.trim();
    final fallback = ColoredBox(
      color: primary.withValues(alpha: 0.08),
      child: Center(
        child: Text(
            trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
            style: context.text.h2.copyWith(color: primary)),
      ),
    );
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        child: SizedBox.square(
          dimension: 64,
          child: imageUrl.isEmpty
              ? fallback
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth:
                      (64 * MediaQuery.devicePixelRatioOf(context)).round(),
                  frameBuilder: (_, child, frame, synchronous) =>
                      synchronous || frame != null ? child : fallback,
                  errorBuilder: (_, __, ___) => fallback,
                ),
        ),
      ),
    );
  }
}
