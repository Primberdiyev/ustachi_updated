import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';

class OrderStripeSheet extends StatelessWidget {
  const OrderStripeSheet({
    super.key,
    required this.stripeColor,
    required this.child,
    this.onTap,
    this.selected = false,
  });

  final Color stripeColor;
  final Widget child;
  final VoidCallback? onTap;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.lg);
    final primary = colors.categorizedColor.primary;

    return Material(
      color: colors.neutral.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? primary : colors.neutral.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 3, child: ColoredBox(color: stripeColor)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(ChizmaSpace.md),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
