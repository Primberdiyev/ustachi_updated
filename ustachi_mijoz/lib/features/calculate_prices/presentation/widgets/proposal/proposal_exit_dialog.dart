import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';

class ProposalExitDialog extends StatelessWidget {
  const ProposalExitDialog({super.key, required this.basketCount});

  final int basketCount;

  static Future<bool> show(BuildContext context, {required int basketCount}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ProposalExitDialog(basketCount: basketCount),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final hasBasket = basketCount > 0;

    return Dialog(
      backgroundColor: colors.neutral.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.xl, vertical: ChizmaSpace.xl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(ChizmaSpace.xl, 28, ChizmaSpace.xl, ChizmaSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.window_outlined, color: primary, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                'Takliflardan chiqasizmi?',
                textAlign: TextAlign.center,
                style: context.text.h3.copyWith(color: colors.neutral.textStrong, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                hasBasket
                    ? 'Savatdagi romlar va kiritilgan o\'lchamlar saqlanmaydi.'
                    : 'Kiritilgan o\'lchamlar saqlanmaydi — qayta hisoblash uchun ularni boshidan kiritasiz.',
                textAlign: TextAlign.center,
                style: context.text.body3.copyWith(color: colors.neutral.textMuted, height: 1.4),
              ),
              if (hasBasket) ...[
                const SizedBox(height: ChizmaSpace.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.md, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.neutral.surface2,
                    borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 18, color: primary),
                      const SizedBox(width: ChizmaSpace.sm),
                      Flexible(
                        child: Text(
                          'Savatda $basketCount ta rom bor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.body4.copyWith(color: colors.neutral.textStrong, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: ChizmaSpace.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colors.neutral.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Chiqish',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.body2.copyWith(color: colors.neutral.textBody, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Qolish',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.body2.copyWith(color: colors.neutral.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
