import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/core/utils/order_date.dart';

class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final chizmaStatus = switch (status) {
      OrderStatus.published => ChizmaStatus.progress,
      OrderStatus.assigned => ChizmaStatus.warning,
      OrderStatus.completed => ChizmaStatus.done,
      OrderStatus.cancelled => ChizmaStatus.danger,
      OrderStatus.expired => ChizmaStatus.neutral,
    };
    return ChizmaStatusPill(status.label, status: chizmaStatus);
  }
}

class OrderStageProgress extends StatelessWidget {
  const OrderStageProgress({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final stage = order.stage;
    if (stage == null) return const SizedBox.shrink();

    final step = order.effectiveStageStep;
    final total = order.effectiveStageTotal;
    final stageName = (!order.isRom && stage == OrderStage.installation)
        ? 'Bajarilmoqda'
        : stage.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stageName,
                style: context.text.h4
                    .copyWith(color: colors.neutral.textStrong),
              ),
            ),
            Text(
              '$step/$total',
              style: context.text.numeric
                  .copyWith(color: colors.neutral.textMuted),
            ),
          ],
        ),
        const SizedBox(height: ChizmaSpace.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(ChizmaRadius.pill),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            backgroundColor: colors.neutral.surface2,
            color: colors.categorizedColor.primary,
          ),
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.trailing,
    this.showResponses = true,
  });

  final OrderEntity order;
  final VoidCallback? onTap;
  final Widget? trailing;

  final bool showResponses;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.title,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              OrderStatusPill(order.status),
            ],
          ),

          if (order.isDirect && order.status.isOpen) ...[
            const SizedBox(height: ChizmaSpace.sm),
            const ChizmaBadge(
              'Tanlangan ustaga',
              icon: Icons.person_pin_circle_outlined,
              brass: true,
            ),
          ],

          if (order.createdAt != null || order.completedAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  order.completedAt != null
                      ? Icons.event_available_outlined
                      : Icons.schedule_rounded,
                  size: 14,
                  color: colors.neutral.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  order.completedAt != null
                      ? 'Yakunlandi: ${orderDateLabel(order.completedAt)}'
                      : orderDateLabel(order.createdAt),
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: colors.neutral.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    style: context.text.body5
                        .copyWith(color: colors.neutral.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: ChizmaSpace.md),

          if (order.status.isActive) ...[
            OrderStageProgress(order: order),
            const SizedBox(height: ChizmaSpace.md),
          ],

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(

                      order.hasPrice ? 'Narxi' : 'Narx',
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                    const SizedBox(height: 2),
                    if (order.hasPrice)
                      ChizmaPrice(formatSom(order.calculatedPrice.toDouble()))
                    else
                      Text(
                        'chatda kelishiladi',
                        style: context.text.body4.copyWith(
                          color: colors.neutral.textStrong,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showResponses && order.status.isOpen)
                ChizmaBadge(
                  '${order.responsesCount} javob',
                  icon: Icons.people_outline_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final ButtonStyle _compactActionStyle = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 12),
);

class MasterResponseCard extends StatelessWidget {
  const MasterResponseCard({
    super.key,
    required this.response,
    this.standardTotal,
    this.onChat,
    this.onChoose,
    this.onProfile,
  });

  final OrderResponseEntity response;

  final int? standardTotal;
  final VoidCallback? onChat;
  final VoidCallback? onChoose;

  final VoidCallback? onProfile;

  String? _diffNote(BuildContext context) {
    final standard = standardTotal;
    final total = response.serviceTotal;
    if (standard == null || standard <= 0 || total == null) return null;
    final diff = total - standard;
    if (diff == 0) return 'E\'londagi narx bilan bir xil';
    final amount = formatSom(diff.abs().toDouble());
    return diff > 0
        ? 'E\'londagi narxdan $amount yuqori'
        : 'E\'londagi narxdan $amount past';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final master = response.master;
    final isChosen = response.status == ResponseStatus.chosen;

    return ChizmaSheet(
      onTap: onProfile,
      borderColor: isChosen ? colors.categorizedColor.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.neutral.surface2,
                backgroundImage:
                    master.photo != null ? NetworkImage(master.photo!) : null,
                child: master.photo == null
                    ? Icon(Icons.person_outline, color: colors.neutral.textMuted)
                    : null,
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      master.displayName,
                      style: context.text.h4
                          .copyWith(color: colors.neutral.textStrong),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (master.specialty != null) master.specialty!,
                        if (master.experienceYears != null)
                          '${master.experienceYears} yil tajriba',

                        if (response.createdAt != null)
                          orderTimeAgo(response.createdAt),
                      ].join(' · '),
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (master.rating != null) ...[
                    Icon(Icons.star_rounded,
                        size: 18, color: colors.categorizedColor.accent),
                    const SizedBox(width: 2),
                    Text(
                      master.rating!.toStringAsFixed(1),
                      style: context.text.numeric,
                    ),
                  ],
                  if (onProfile != null)
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: colors.neutral.textMuted),
                ],
              ),
            ],
          ),

          if (response.serviceTotal != null) ...[
            const SizedBox(height: ChizmaSpace.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: ChizmaSpace.md,
                vertical: ChizmaSpace.sm,
              ),
              decoration: BoxDecoration(
                color: colors.neutral.surface2,
                borderRadius: BorderRadius.circular(ChizmaRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.handyman_outlined,
                      size: 16, color: colors.neutral.textMuted),
                  const SizedBox(width: ChizmaSpace.sm),
                  Expanded(
                    child: Text(
                      'Usta aytgan narx',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                  Text(
                    formatSom(response.serviceTotal!.toDouble()),
                    style: context.text.numeric.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.neutral.textStrong,
                    ),
                  ),
                ],
              ),
            ),
            if (_diffNote(context) case final note?) ...[
              const SizedBox(height: ChizmaSpace.xs),
              Text(
                note,
                style: context.text.label
                    .copyWith(color: colors.neutral.textMuted),
              ),
            ],
          ],
          if (response.message.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.md),
            Text(
              response.message,
              style: context.text.body4
                  .copyWith(color: colors.neutral.textBody),
            ),
          ],
          const SizedBox(height: ChizmaSpace.md),
          if (isChosen)
            const ChizmaStatusPill('Tanlangan usta', status: ChizmaStatus.done)
          else ...[

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onProfile,
                    style: _compactActionStyle,
                    icon: const Icon(Icons.person_outline_rounded, size: 18),
                    label: const Text('Usta haqida'),
                  ),
                ),
                const SizedBox(width: ChizmaSpace.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChat,
                    style: _compactActionStyle,
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 18),
                    label: const Text('Xabar yozish'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChizmaSpace.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onChoose,
                child: const Text('Tanlash'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
