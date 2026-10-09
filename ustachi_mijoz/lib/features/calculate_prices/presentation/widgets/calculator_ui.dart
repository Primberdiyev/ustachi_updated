import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';

class CalculatorStepHeader extends StatelessWidget {
  const CalculatorStepHeader(
      {super.key,
      required this.step,
      required this.total,
      required this.title,
      this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 20),
      this.textPadding = EdgeInsets.zero,
      this.label});
  final int step;
  final int total;
  final String title;
  final String? label;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry textPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: textPadding,
          child: Text(label ?? 'Qadam ${step + 1} / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  color: colors.neutral.textMuted,
                  letterSpacing: 0.5)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: textPadding,
          child: Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.neutral.textStrong)),
        ),
        const SizedBox(height: 16),
        Semantics(
            value: '${step + 1} / $total',
            child: Row(children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                    child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                            color: i <= step
                                ? colors.categorizedColor.primary
                                : colors.neutral.border,
                            borderRadius: BorderRadius.circular(2)))),
              ],
            ])),
      ]),
    );
  }
}

class CalculatorOption extends StatelessWidget {
  const CalculatorOption(
      {super.key,
      required this.title,
      required this.selected,
      required this.onTap,
      this.description,
      this.note,
      this.leading,
      this.multiple = false});
  final String title;
  final String? description;
  final String? note;
  final Widget? leading;
  final bool selected;
  final bool multiple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final text = Theme.of(context).textTheme;
    return Semantics(
        selected: selected,
        button: true,
        child: ChizmaSheet(
            onTap: onTap,
            borderColor: selected ? primary : colors.neutral.border,
            color: colors.neutral.surface,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (leading != null) ...[
                  IconTheme(
                      data: IconThemeData(size: 22, color: primary),
                      child: leading!),
                  const SizedBox(width: 12),
                ],
                Expanded(
                    child: Text(title,
                        style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.neutral.textStrong))),
                const SizedBox(width: 12),
                Icon(
                    multiple
                        ? (selected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded)
                        : (selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked),
                    size: 20,
                    color: selected ? primary : colors.neutral.textMuted),
              ]),
              if (description?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(description!,
                    style: text.bodyMedium?.copyWith(
                        height: 1.45, color: colors.neutral.textMuted)),
              ],
              if (note?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: colors.neutral.surface2,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(note!,
                        style: text.labelLarge
                            ?.copyWith(color: colors.neutral.textStrong))),
              ],
            ])));
  }
}

class CalculatorSection extends StatelessWidget {
  const CalculatorSection(
      {super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ChizmaSheet(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.color.neutral.textStrong)),
        const SizedBox(height: 16),
        child,
      ])));
}
