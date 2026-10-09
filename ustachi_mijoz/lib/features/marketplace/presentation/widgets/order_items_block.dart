import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/marketplace/domain/order_proposal_items.dart';

class OrderItemsBlock extends StatelessWidget {
  const OrderItemsBlock({
    super.key,
    required this.items,
  });

  final List<OrderProposalItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final count = orderItemsCount(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChizmaEyebrow(
          items.length > 1
              ? 'Romlar (${items.length} xil · $count dona)'
              : count > 1
                  ? 'Rom ($count dona)'
                  : 'Rom',
        ),
        const SizedBox(height: ChizmaSpace.sm),
        for (final item in items) ...[
          _ItemRow(
            item: item,
            onTap: () => showOrderItemSheet(context, item),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.onTap});

  final OrderProposalItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(item: item),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (item.sizeLabel != null) item.sizeLabel!,
                    if (item.materialLabel.isNotEmpty) item.materialLabel,
                  ].join(' · '),
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: ChizmaSpace.xs),

                Text(
                  '${item.qty} dona',
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: ChizmaSpace.xs),
          Icon(Icons.chevron_right_rounded,
              size: 20, color: colors.neutral.textMuted),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});

  final OrderProposalItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final spec = item.spec;
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: frameDrawingTileColor(context),
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
        border: Border.all(color: colors.neutral.border),
      ),
      child: spec == null
          ? Icon(Icons.window_outlined,
              size: 24, color: colors.neutral.textMuted)
          : FrameDrawing(
              spec: spec,
              frameTint: item.frameTint,
            ),
    );
  }
}

Future<void> showOrderItemSheet(
  BuildContext context,
  OrderProposalItem item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.color.neutral.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(ChizmaRadius.lg)),
    ),
    builder: (_) => _ItemSheet(item: item),
  );
}

class _ItemSheet extends StatelessWidget {
  const _ItemSheet({required this.item});

  final OrderProposalItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final spec = item.spec;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.md,
          ChizmaSpace.lg,
          ChizmaSpace.xxl + context.viewPaddingBottom,
        ),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.neutral.border,
                borderRadius: BorderRadius.circular(ChizmaRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          if (spec != null) ...[
            Container(
              height: 240,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(ChizmaSpace.lg),
              decoration: BoxDecoration(
                color: frameDrawingTileColor(context),
                borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                border: Border.all(color: colors.neutral.border),
              ),
              child: FrameDrawing(
                spec: spec,
                frameTint: item.frameTint,
                showDimensions: true,
              ),
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ],

          Text(
            item.title,
            style: context.text.h3.copyWith(color: colors.neutral.textStrong),
          ),
          if (item.shapeTitle.isNotEmpty || item.shapeSubtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (item.shapeTitle.isNotEmpty) item.shapeTitle,
                if (item.shapeSubtitle.isNotEmpty) item.shapeSubtitle,
              ].join(' · '),
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
          ],
          const SizedBox(height: ChizmaSpace.lg),

          if (item.specRows.isNotEmpty) ...[
            ChizmaSheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < item.specRows.length; i++) ...[
                    if (i > 0) const SizedBox(height: ChizmaSpace.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.specRows[i].$1,
                            style: context.text.body5
                                .copyWith(color: colors.neutral.textMuted),
                          ),
                        ),
                        Text(
                          item.specRows[i].$2,
                          style: context.text.body5.copyWith(
                            color: colors.neutral.textStrong,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ],

          if (item.qty > 1)
            ChizmaSheet(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Soni',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                  Text(
                    '${item.qty} dona',
                    style: context.text.body5.copyWith(
                      color: colors.neutral.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
