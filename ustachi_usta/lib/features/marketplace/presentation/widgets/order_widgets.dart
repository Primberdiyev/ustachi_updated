import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/presentation/order_flow_l10n.dart';

String formatSom(double v) {
  final n = v.round();
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

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
    return ChizmaStatusPill(status.label(context), status: chizmaStatus);
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
        : stage.label(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stageName,
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
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
                      context.t.masters.estimate,
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                    const SizedBox(height: 2),
                    ChizmaPrice(formatSom(order.calculatedPrice.toDouble())),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showResponses && order.status.isOpen)
                ChizmaBadge(
                  context.t.masters
                      .responses(count: order.responsesCount.toString()),
                  icon: Icons.people_outline_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MasterResponseCard extends StatelessWidget {
  const MasterResponseCard({
    super.key,
    required this.response,
    this.onChat,
    this.onChoose,
    this.onProfile,
  });

  final OrderResponseEntity response;
  final VoidCallback? onChat;
  final VoidCallback? onChoose;

  final VoidCallback? onProfile;

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
                    ? Icon(Icons.person_outline,
                        color: colors.neutral.textMuted)
                    : null,
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      master.displayName.isEmpty
                          ? context.t.masters.master
                          : master.displayName,
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
                          context.t.masters.experienceYears(
                              years: '${master.experienceYears}'),
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
          if (response.message.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.md),
            Text(
              response.message,
              style:
                  context.text.body4.copyWith(color: colors.neutral.textBody),
            ),
          ],
          const SizedBox(height: ChizmaSpace.md),
          if (isChosen)
            ChizmaStatusPill(context.t.masters.chosen,
                status: ChizmaStatus.done)
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onProfile,
                    icon: const Icon(Icons.person_outline_rounded, size: 18),
                    label: Text(context.t.masters.title),
                  ),
                ),
                const SizedBox(width: ChizmaSpace.sm),
                IconButton.filledTonal(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  tooltip: uz(context.t.masters.write),
                ),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onChoose,
                    child: Text(context.t.masters.choose),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
