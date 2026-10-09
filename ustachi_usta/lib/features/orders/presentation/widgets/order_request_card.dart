import 'package:ustachi/features/orders/presentation/specialty_icons.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';
import 'package:ustachi/features/orders/presentation/order_spec_l10n.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_stripe_sheet.dart';
import 'package:ustachi/core/utils/order_date.dart';

class OrderRequestCard extends StatelessWidget {
  const OrderRequestCard({
    super.key,
    required this.request,
    required this.now,
    this.onTap,
    this.onOffer,
    this.selected = false,
  });

  final OrderRequestEntity request;
  final DateTime now;
  final VoidCallback? onTap;

  final VoidCallback? onOffer;
  final bool selected;

  bool get _sent => request.offerSent;

  bool get _invited => request.isInvited && !request.inviteDeclined;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders;
    final expired = request.isExpired(now);

    return Opacity(
      opacity: _sent ? 0.86 : 1,
      child: OrderStripeSheet(
        stripeColor: _invited
            ? colors.categorizedColor.accent
            : (_sent
                ? colors.categorizedColor.info
                : (expired
                    ? colors.neutral.borderStrong
                    : colors.categorizedColor.warning)),
        selected: selected,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_invited || request.isRepair) ...[
              Wrap(
                spacing: ChizmaSpace.sm,
                runSpacing: ChizmaSpace.xs,
                children: [
                  if (_invited)
                    ChizmaBadge(
                      t.open.invitedBadge,
                      icon: Icons.person_pin_circle_outlined,
                      brass: true,
                    ),

                  if (request.isRepair)
                    ChizmaBadge(
                      t.open.repairBadge,
                      icon: Icons.build_outlined,
                    ),
                ],
              ),
              const SizedBox(height: ChizmaSpace.sm),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumb(request: request),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(child: _Head(request: request, now: now)),
              ],
            ),
            const SizedBox(height: ChizmaSpace.sm + 2),
            _MetaChips(request: request),
            const SizedBox(height: ChizmaSpace.sm + 2),
            Divider(height: 1, color: colors.neutral.border),
            const SizedBox(height: ChizmaSpace.sm + 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _PriceBlock(request: request)),
                const SizedBox(width: ChizmaSpace.sm),
                if (_sent)
                  _WaitingNote(label: t.open.waitingClient)
                else if (onOffer != null)
                  FilledButton.icon(
                    onPressed: onOffer,
                    icon: Icon(
                      _invited ? Icons.check_rounded : Icons.send_rounded,
                      size: 18,
                    ),
                    label: Text(_invited ? t.open.acceptInvite : t.offerBtn),
                    style: FilledButton.styleFrom(
                      textStyle: context.text.body4
                          .copyWith(fontWeight: FontWeight.w700),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ChizmaSpace.lg,
                        vertical: ChizmaSpace.md,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.request});

  final OrderRequestEntity request;

  static const double _size = 74;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final first = request.drawings.isNotEmpty ? request.drawings.first : null;
    final spec = first?.spec ?? request.drawing;
    final argb = first?.frameArgb ?? request.frameArgb;
    final extra = request.drawings.length - 1;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: frameDrawingTileColor(context),
              borderRadius: BorderRadius.circular(ChizmaRadius.sm),
              border: Border.all(color: colors.neutral.border),
            ),
            child: spec == null
                ? Icon(specialtyIcon(request.specialtyCode),
                    size: 30, color: colors.neutral.textMuted)
                : FrameDrawing(
                    spec: spec,
                    frameTint: argb == null ? null : Color(argb),
                  ),
          ),
          if (extra > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.categorizedColor.primary,
                  borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                ),
                child: Text(
                  '+$extra',
                  style: context.text.label.copyWith(
                    color: colors.neutral.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.request, required this.now});

  final OrderRequestEntity request;
  final DateTime now;

  String _countdown(BuildContext context) {
    final t = context.t.orders.request;
    final left = request.timeLeft(now);

    if (left == Duration.zero) return t.expired;
    final units = context.t.common;
    if (left.inHours >= 1) {
      return t.expiresIn(time: '${left.inHours} ${units.hoursShort}');
    }
    return t.expiresIn(time: '${left.inMinutes} ${units.minutesShort}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders;
    final left = request.timeLeft(now);
    final urgent = left > Duration.zero && left.inHours < 2;

    final client = request.clientName.trim().isEmpty
        ? t.detail.client
        : request.clientName.trim();
    final where = [
      client,
      if (request.summary.isNotEmpty) request.summary,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                request.title,
                style: context.text.body3.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: ChizmaSpace.sm),
            Flexible(
              child: request.offerSent
                  ? ChizmaStatusPill(t.open.offerSent,
                      status: ChizmaStatus.progress)
                  : ChizmaStatusPill(
                      _countdown(context),
                      status: request.isExpired(now)
                          ? ChizmaStatus.neutral
                          : (urgent
                              ? ChizmaStatus.danger
                              : ChizmaStatus.warning),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          where,
          style: context.text.body4.copyWith(color: colors.neutral.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              request.responsesCount == 0
                  ? Icons.bolt_rounded
                  : Icons.groups_2_outlined,
              size: 15,
              color: request.responsesCount == 0
                  ? colors.categorizedColor.success
                  : colors.neutral.textMuted,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                request.responsesCount == 0
                    ? t.open.beFirst
                    : t.open.offersCount(count: '${request.responsesCount}'),
                style: context.text.body5.copyWith(
                  color: request.responsesCount == 0
                      ? colors.categorizedColor.success
                      : colors.neutral.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (request.createdAt != null) ...[
              const SizedBox(width: 6),
              Text(
                '·',
                style: context.text.body5
                    .copyWith(color: colors.neutral.border),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  orderTimeAgo(request.createdAt),
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.request});

  final OrderRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (request.spec[specSize] != null) '${request.spec[specSize]} mm',
      for (final key in [specMaterial])
        if (request.spec[key] != null)
          orderSpecValue(context, request.spec[key]!),
    ];
    if (labels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: ChizmaSpace.xs,
      runSpacing: ChizmaSpace.xs,
      children: [for (final label in labels) _MetaTag(label)],
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.sm + 2, vertical: 5),
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Text(
        label,
        style: context.text.body5.copyWith(
          color: colors.neutral.textBody,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.request});

  final OrderRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders.request;

    if (!request.hasPrice) {
      return Text(
        t.priceInChat,
        style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        maxLines: 2,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.clientPrice,
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        ChizmaPrice(ChizmaMoney.format(request.calculatedPrice), large: true),
      ],
    );
  }
}

class _WaitingNote extends StatelessWidget {
  const _WaitingNote({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final info = context.color.categorizedColor.info;
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 17, color: info),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: context.text.body5.copyWith(
                color: info,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
