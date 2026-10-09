import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';

class OrderSpecRow extends StatelessWidget {
  const OrderSpecRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  bool get _isLong => value.contains('\n') || value.length > 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final labelStyle =
        context.text.body5.copyWith(color: colors.neutral.textMuted);

    if (_isLong) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: ChizmaSpace.xs),
            for (final line in value.split('\n'))
              if (line.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: ChizmaSpace.xs),
                  child: Text(
                    line.trim(),
                    style: context.text.body4.copyWith(
                      color: colors.neutral.textStrong,
                      height: 1.4,
                    ),
                  ),
                ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.sm - 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: labelStyle)),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (emphasise ? context.text.numeric : context.text.body4)
                  .copyWith(
                color: colors.neutral.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
