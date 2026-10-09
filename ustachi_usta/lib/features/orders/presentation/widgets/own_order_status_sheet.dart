import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/presentation/own_order_l10n.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OwnOrderStatusSheet extends StatelessWidget {
  const OwnOrderStatusSheet({super.key, required this.current});

  final OwnOrderStatus current;

  static const _icons = <OwnOrderStatus, IconData>{
    OwnOrderStatus.newOrder: Icons.fiber_new_outlined,
    OwnOrderStatus.inProgress: Icons.handyman_outlined,
    OwnOrderStatus.done: Icons.verified_outlined,
    OwnOrderStatus.debt: Icons.account_balance_wallet_outlined,
    OwnOrderStatus.cancelled: Icons.cancel_outlined,
  };

  static Future<OwnOrderStatus?> show(
    BuildContext context, {
    required OwnOrderStatus current,
  }) {
    return showModalBottomSheet<OwnOrderStatus>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.color.neutral.surface,
      builder: (_) => OwnOrderStatusSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          0,
          ChizmaSpace.lg,
          ChizmaSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.ownOrders.statusTitle,
              style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            ),
            const SizedBox(height: ChizmaSpace.md),
            for (final entry in _icons.entries)
              _StatusRow(
                status: entry.key,
                icon: entry.value,
                hint: entry.key.hint(context),
                selected: entry.key == current,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop(entry.key);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.status,
    required this.icon,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final OwnOrderStatus status;
  final IconData icon;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final accent = colors.categorizedColor.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.08)
                : colors.neutral.surface,
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            border: Border.all(
              color: selected ? accent : colors.neutral.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? accent : colors.neutral.textMuted,
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status.label(context),
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
