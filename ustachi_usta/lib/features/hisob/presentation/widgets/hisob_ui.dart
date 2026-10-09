
library;

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_format.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

export 'package:ustachi/features/hisob/domain/hisob_format.dart';

class Option<T> {
  const Option(this.value, this.label, {this.hint = '', this.enabled = true, this.swatch, this.leading});

  final T value;
  final String label;
  final String hint;

  final bool enabled;

  final Color? swatch;

  final Widget? leading;
}

Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<Option<T>> options,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = sheetContext.color;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.sm),
                child: Text(title, style: sheetContext.text.h4.copyWith(color: colors.neutral.textStrong)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.lg),
                  children: [
                    for (final o in options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
                        child: ChizmaSheet(
                          onTap: o.enabled ? () => Navigator.of(sheetContext).pop(o.value) : null,
                          borderColor: o.value == selected ? colors.categorizedColor.primary : null,
                          color: o.value == selected ? colors.categorizedColor.primary.withValues(alpha: 0.06) : null,
                          child: Row(
                            children: [
                              if (o.swatch != null) ...[
                                ColorSwatchDot(o.swatch!, size: 28),
                                const SizedBox(width: ChizmaSpace.md),
                              ],
                              if (o.leading != null) ...[
                                o.leading!,
                                const SizedBox(width: ChizmaSpace.md),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      o.label,
                                      style: sheetContext.text.body3.copyWith(
                                        color: o.enabled ? colors.neutral.textStrong : colors.neutral.textMuted,
                                        fontWeight: o.value == selected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    if (o.hint.isNotEmpty)
                                      Text(
                                        o.hint,
                                        style: sheetContext.text.label.copyWith(color: colors.neutral.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                              if (!o.enabled)
                                ChizmaBadge('Tez kunda')
                              else if (o.value == selected)
                                Icon(Icons.check_circle_rounded, color: colors.categorizedColor.primary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<double?> askNumber(
  BuildContext context, {
  required String title,
  required double initial,
  String suffix = '',
  bool decimal = false,
  double? min,
  double? max,
}) {

  final controller = TextEditingController();
  return showDialog<double>(
    context: context,
    builder: (dialogContext) {
      String? error;
      return StatefulBuilder(
        builder: (context, setState) {
          void submit() {
            final text = controller.text.trim();
            final value = text.isEmpty ? initial : double.tryParse(text.replaceAll(',', '.').replaceAll(' ', ''));
            if (value == null) {
              setState(() => error = 'Son kiriting');
              return;
            }
            if (min != null && value < min) {
              setState(() => error = 'Kamida ${qtyText(min)}');
              return;
            }
            if (max != null && value > max) {
              setState(() => error = 'Ko\'pi bilan ${qtyText(max)}');
              return;
            }
            Navigator.of(dialogContext).pop(value);
          }

          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]'))],
              decoration: InputDecoration(hintText: qtyText(initial), suffixText: suffix, errorText: error),
              onSubmitted: (_) => submit(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Bekor')),
              FilledButton(onPressed: submit, child: Text('Tayyor')),
            ],
          );
        },
      );
    },
  );
}

Future<double?> askArchRise(BuildContext context, hisob.FrameDesign design) => askNumber(
      context,
      title: 'Arka (yoy) balandligi, 0 — arkasiz',
      initial: design.archRiseMm > 0 ? design.archRiseMm : defaultArchRiseMm(design),
      suffix: 'mm',
      min: 0,
      max: design.heightMm - 100,
    );

double defaultArchRiseMm(hisob.FrameDesign design) {
  final half = design.widthMm / 2;
  final cap = design.heightMm / 2;
  return ((half < cap ? half : cap) / 10).round() * 10.0;
}

Color? frameColorOf(int? argb) => argb == null ? null : Color(argb);

class ColorSwatchDot extends StatelessWidget {
  const ColorSwatchDot(this.color, {super.key, this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: context.color.neutral.borderStrong),
        ),
      );
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.icon,
    this.swatch,
    this.leading,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;

  final Color? swatch;

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg, vertical: ChizmaSpace.md),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: colors.neutral.textMuted),
              const SizedBox(width: ChizmaSpace.md),
            ],
            Expanded(
              child: Text(label, style: context.text.body4.copyWith(color: colors.neutral.textBody)),
            ),
            if (swatch != null) ...[
              ColorSwatchDot(swatch!),
              const SizedBox(width: ChizmaSpace.sm),
            ],
            if (leading != null) ...[
              leading!,
              const SizedBox(width: ChizmaSpace.sm),
            ],
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.body4.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right_rounded, color: colors.neutral.textMuted),
          ],
        ),
      ),
    );
  }
}
