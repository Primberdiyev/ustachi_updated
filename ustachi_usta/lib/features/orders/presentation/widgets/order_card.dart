import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/presentation/order_visuals.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_stripe_sheet.dart';
import 'package:ustachi/core/utils/order_date.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.now,
    this.onTap,
    this.selected = false,
  });

  final MasterOrderEntity order;
  final DateTime now;
  final VoidCallback? onTap;
  final bool selected;

  String _subtitle(BuildContext context) => [
        if (order.clientName.isNotEmpty)
          order.clientName
        else
          context.t.orders.detail.client,
        if (order.isOwn && order.productCount > 0)
          context.t.ownOrders.itemsCount(count: order.productCount.toString()),
        if (order.summary.isNotEmpty) order.summary,
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders;
    final accent = order.stripeColor(context, now);
    final showRating = order.isCompleted && order.rating != null;

    return OrderStripeSheet(
      stripeColor: accent,
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StageTile(color: accent, icon: _stageIcon()),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order.title.isEmpty
                                ? order.number
                                : '${order.number} · ${order.title}',
                            style: context.text.body4.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: ChizmaSpace.sm),
                        ChizmaStatusPill(
                          order.pillLabel(context, now),
                          status: order.pillStatus(now),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(context),
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    _MetaRow(order: order, now: now),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.md),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colors.neutral.border,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: order.totalPrice > 0
                      ? ChizmaPrice(ChizmaMoney.format(order.totalPrice))
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              if (showRating)
                _RatingStars(rating: order.rating!)
              else
                Text(
                  t.stepOf(
                    step: order.effectiveStageStep.toString(),
                    total: order.effectiveStageTotal.toString(),
                  ),
                  style: context.text.numericMuted.copyWith(fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.sm),
          _StageProgress(
            step: order.effectiveStageStep,
            total: order.effectiveStageTotal,
            color: accent,
          ),
        ],
      ),
    );
  }

  IconData _stageIcon() {
    switch (order.ownStatus) {
      case OwnOrderStatus.cancelled:
        return Icons.block_rounded;
      case OwnOrderStatus.debt:
        return Icons.account_balance_wallet_outlined;
      case null:
      default:
        break;
    }
    if (order.isCompleted) return Icons.done_all_rounded;
    return switch (order.stage) {
      OrderStage.accepted => Icons.assignment_turned_in_outlined,
      OrderStage.measured => Icons.straighten_rounded,
      OrderStage.production => Icons.handyman_outlined,
      OrderStage.installation => Icons.construction_rounded,
      OrderStage.handover => Icons.done_all_rounded,
    };
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final surface = context.color.neutral.surface;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.10), surface),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(
          color: Color.alphaBlend(color.withValues(alpha: 0.28), surface),
        ),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.order, required this.now});

  final MasterOrderEntity order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final muted = context.color.neutral.textMuted;
    final style = context.text.label.copyWith(
      color: muted,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );
    final completed = order.completedAt != null;

    return Row(
      children: [
        Icon(
          completed ? Icons.event_available_outlined : Icons.schedule_rounded,
          size: 13,
          color: muted,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            orderDateShort(
              completed ? order.completedAt : order.createdAt,
              now: now,
            ),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (order.unreadMessages > 0) ...[
          const SizedBox(width: ChizmaSpace.sm),
          _UnreadBadge(count: order.unreadMessages),
        ],
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.color.categorizedColor.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 11, color: c),
          const SizedBox(width: 3),
          Text(
            count > 99 ? '99+' : count.toString(),
            style: context.text.label.copyWith(color: c),
          ),
        ],
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  const _StageProgress({
    required this.step,
    required this.total,
    required this.color,
  });

  final int step;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final muted = context.color.neutral.border;

    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= step ? color : muted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final accent = context.color.categorizedColor.accent;
    final muted = context.color.neutral.borderStrong;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            Icons.star_rounded,
            size: 14,
            color: i <= rating ? accent : muted,
          ),
      ],
    );
  }
}
