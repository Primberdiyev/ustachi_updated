import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/presentation/order_visuals.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OrderStageTimeline extends StatelessWidget {
  const OrderStageTimeline({super.key, required this.order});

  final MasterOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        for (final stage in order.activeStages)
          _StageRow(
            stage: stage,
            order: order,
            isLastRow: stage == order.activeStages.last,
          ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.order,
    required this.isLastRow,
  });

  final OrderStage stage;
  final MasterOrderEntity order;
  final bool isLastRow;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final cat = colors.categorizedColor;

    final done = order.stageDates.containsKey(stage);
    final current = !done && stage == order.stage && !order.isCompleted;

    final markerColor = done
        ? cat.success
        : current
            ? cat.primary
            : colors.neutral.surface;
    final markerBorder = done
        ? cat.success
        : current
            ? cat.primary
            : colors.neutral.borderStrong;
    final markerFg =
        done || current ? colors.neutral.white : colors.neutral.textMuted;

    final completedAt = order.stageDates[stage];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: markerBorder),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 12, color: markerFg)
                    : Text(
                        '${stage.step}',
                        style: context.text.numericMuted.copyWith(
                          fontSize: 10,
                          color: markerFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              if (!isLastRow)
                Expanded(
                  child: Container(width: 1, color: colors.neutral.border),
                ),
            ],
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLastRow ? 0 : ChizmaSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stage.label(context),
                    style: context.text.body4.copyWith(
                      color: done || current
                          ? colors.neutral.textStrong
                          : colors.neutral.textMuted,
                      fontWeight:
                          done || current ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (completedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(context, completedAt),
                      style: context.text.numericMuted.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final month = context.t.common.months[date.month - 1];
    return '${date.day} $month · $hh:$mm';
  }
}
