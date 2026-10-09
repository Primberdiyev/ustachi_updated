import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class MyOrdersCard extends StatelessWidget {
  const MyOrdersCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final radius = BorderRadius.circular(ChizmaRadius.lg);

    return Semantics(
      button: true,
      child: Material(
        color: colors.neutral.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: primary.withValues(alpha: 0.18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.07),
                primary.withValues(alpha: 0.01),
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(ChizmaSpace.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(ChizmaRadius.md),
                    ),
                    child: Icon(Icons.assignment_outlined,
                        color: primary, size: 26),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.t.profile.myOrders,
                          style: context.text.h4.copyWith(
                            color: colors.neutral.textStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: ChizmaSpace.xs),
                        Text(
                          context.t.home.ordersSubtitle,
                          style: context.text.body5.copyWith(
                            color: colors.neutral.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.arrow_forward_rounded,
                        color: primary, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
