import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

abstract final class ChizmaSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

abstract final class ChizmaRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double pill = 999;
}

class ChizmaEyebrow extends StatelessWidget {
  const ChizmaEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(

      uz(text).toUpperCase(),
      style: context.text.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class ChizmaSectionHeader extends StatelessWidget {
  const ChizmaSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final primary = context.color.categorizedColor.primary;
    return Row(
      children: [
        Expanded(child: ChizmaEyebrow(title)),
        if (actionLabel != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(ChizmaRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ChizmaSpace.xs, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        actionLabel!,
                        style: context.text.body4.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: primary),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ChizmaSheet extends StatelessWidget {
  const ChizmaSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ChizmaSpace.lg),
    this.onTap,
    this.borderColor,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.lg);
    return Material(
      color: color ?? colors.neutral.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor ?? colors.neutral.border),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class ChizmaIconTile extends StatelessWidget {
  const ChizmaIconTile({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
    this.filled = false,
  });

  final IconData icon;

  final Color? color;
  final double size;

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.color.categorizedColor.primary;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled ? context.color.neutral.white : c,
      ),
    );
  }
}

class ChizmaImageTile extends StatelessWidget {
  const ChizmaImageTile({
    super.key,
    required this.asset,
    this.size = 40,
    this.padding = 4,
  });

  final String asset;
  final double size;

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.color.categorizedColor.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

enum ChizmaStatus { done, progress, warning, danger, neutral }

class ChizmaStatusPill extends StatelessWidget {
  const ChizmaStatusPill(this.label,
      {super.key, this.status = ChizmaStatus.neutral});

  final String label;
  final ChizmaStatus status;

  @override
  Widget build(BuildContext context) {
    final cat = context.color.categorizedColor;
    final c = switch (status) {
      ChizmaStatus.done => cat.success,
      ChizmaStatus.progress => cat.info,
      ChizmaStatus.warning => cat.warning,
      ChizmaStatus.danger => cat.error,
      ChizmaStatus.neutral => context.color.neutral.textMuted,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
        border: Border.all(color: c.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: context.text.label.copyWith(color: c),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class ChizmaBadge extends StatelessWidget {
  const ChizmaBadge(this.label, {super.key, this.brass = false, this.icon});

  final String label;
  final bool brass;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cat = context.color.categorizedColor;
    final c = brass ? cat.accent : cat.info;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: context.text.label.copyWith(color: c),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ChizmaPrice extends StatelessWidget {
  const ChizmaPrice(
    this.amount, {
    super.key,
    this.unit,
    this.large = false,
  });

  final String amount;

  final String? unit;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final base = large ? context.text.numericLg : context.text.numeric;
    final unitLabel = unit ?? context.t.common.som;
    return Text.rich(
      TextSpan(
        text: amount,
        style: base.copyWith(fontWeight: FontWeight.w600),
        children: [
          TextSpan(
            text: ' $unitLabel',
            style: context.text.numericMuted.copyWith(
              fontSize: (base.fontSize ?? 15) * 0.72,
            ),
          ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }
}

class ChizmaListRow extends StatelessWidget {
  const ChizmaListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: ChizmaSpace.lg, vertical: ChizmaSpace.md),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: ChizmaSpace.md),
            ],
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.text.h4.copyWith(
                      color: colors.neutral.textStrong,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: context.text.body5.copyWith(
                        color: colors.neutral.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: ChizmaSpace.md),
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
              ),
            ],
            if (showChevron)
              Padding(
                padding: const EdgeInsets.only(left: ChizmaSpace.xs),
                child: Icon(Icons.chevron_right_rounded,
                    size: 20, color: colors.neutral.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class ChizmaRowGroup extends StatelessWidget {
  const ChizmaRowGroup({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.lg);
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(Divider(
          height: 1,
          thickness: 1,
          indent: ChizmaSpace.lg,
          color: colors.neutral.border,
        ));
      }
      children.add(rows[i]);
    }
    return Material(
      color: colors.neutral.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: colors.neutral.border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class ChizmaChip extends StatelessWidget {
  const ChizmaChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final fg = selected ? colors.neutral.white : colors.neutral.textBody;
    return Material(
      color: selected ? primary : colors.neutral.surface2,
      borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: ChizmaSpace.md, vertical: ChizmaSpace.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ChizmaRadius.pill),
            border: Border.all(
              color: selected ? primary : colors.neutral.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: ChizmaSpace.xs + 2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: context.text.body4.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChizmaActionCard extends StatelessWidget {
  const ChizmaActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.brass = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool brass;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final c = brass
        ? colors.categorizedColor.accent
        : colors.categorizedColor.primary;
    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ChizmaIconTile(icon: icon, color: c, filled: true, size: 44),
          const SizedBox(height: ChizmaSpace.md),
          Text(
            title,
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

abstract final class ChizmaMoney {
  static const String _thinSpace = ' ';

  static String format(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_thinSpace);
      buffer.write(digits[i]);
    }

    return amount < 0 ? '-$buffer' : buffer.toString();
  }

  static String compact(int amount) {
    if (amount.abs() < 1000000) return format(amount);
    final millions = amount / 1000000;
    final text = millions.abs() >= 100
        ? millions.round().toString()
        : millions.toStringAsFixed(1).replaceAll('.0', '');
    return '$text mln';
  }
}

class ChizmaSegmented extends StatelessWidget {
  const ChizmaSegmented({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.counts = const <int?>[],
  });

  final List<String> labels;
  final List<int?> counts;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final row = Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _Segment(
                    label: labels[i],
                    count: i < counts.length ? counts[i] : null,
                    selected: i == selectedIndex,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          );
          return constraints.hasBoundedWidth ? row : IntrinsicWidth(child: row);
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.sm + 1);

    return Material(
      color: selected ? colors.neutral.surface : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.sm),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                label,
                style: context.text.body4.copyWith(
                  color: selected
                      ? colors.neutral.textStrong
                      : colors.neutral.textMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: ChizmaSpace.xs),
                Text(
                  '$count',
                  style: context.text.numericMuted.copyWith(
                    fontSize: 11,
                    color: selected
                        ? context.color.categorizedColor.primary
                        : colors.neutral.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChizmaEmptyState extends StatelessWidget {
  const ChizmaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.xxl,
          vertical: ChizmaSpace.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                border: Border.all(
                  color: colors.neutral.borderStrong,
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 26, color: colors.neutral.textMuted),
            ),
            const SizedBox(height: ChizmaSpace.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            ),
            const SizedBox(height: ChizmaSpace.xs + 2),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  context.text.body4.copyWith(color: colors.neutral.textMuted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: ChizmaSpace.lg),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ChizmaStatTile extends StatelessWidget {
  const ChizmaStatTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.md, vertical: ChizmaSpace.md),
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: context.text.numeric.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          ChizmaEyebrow(label),
        ],
      ),
    );
  }
}
