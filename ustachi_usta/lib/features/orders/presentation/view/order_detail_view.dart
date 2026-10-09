import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/order_drawing_spec.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/order_visuals.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_drawing.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_stage_timeline.dart';
import 'package:ustachi/features/orders/presentation/widgets/own_order_status_sheet.dart';
import 'package:ustachi/features/orders/presentation/order_spec_l10n.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_spec_row.dart';
import 'package:ustachi/features/orders/presentation/own_order_l10n.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({
    super.key,
    required this.order,
    this.showHeader = true,
    this.showStageAction = true,
  });

  final MasterOrderEntity order;

  final bool showHeader;

  final bool showStageAction;

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.detail;
    final now = DateTime.now();
    final isBusy = context.select<OrdersBloc, bool>(
      (bloc) => bloc.state.actionStatus.isLoading,
    );

    return ChizmaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            _ClientRow(order: order, now: now),
            const SizedBox(height: ChizmaSpace.xl),
          ],
          if (order.isOwn) ...[
            ChizmaEyebrow(context.t.ownOrders.statusRow),
            const SizedBox(height: ChizmaSpace.md),
            _OwnStatusCard(order: order, isBusy: isBusy),
          ] else ...[
            ChizmaEyebrow(t.stages),
            const SizedBox(height: ChizmaSpace.md),
            ChizmaSheet(child: OrderStageTimeline(order: order)),
          ],
          const SizedBox(height: ChizmaSpace.xl),
          if (order.drawings.isNotEmpty) ...[
            ChizmaEyebrow(t.drawings),
            const SizedBox(height: ChizmaSpace.md),
            _Drawings(drawings: order.drawings),
            const SizedBox(height: ChizmaSpace.xl),
          ],
          ChizmaEyebrow(t.spec),
          const SizedBox(height: ChizmaSpace.md),
          ChizmaSheet(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in order.spec.entries)
                  OrderSpecRow(
                    label: orderSpecLabel(context, entry.key),
                    value: orderSpecValue(context, entry.value),
                  ),
                if (order.totalPrice > 0)
                  OrderSpecRow(
                    label: t.total,
                    value: '${ChizmaMoney.format(order.totalPrice)} '
                        '${context.t.common.som}',
                    emphasise: true,
                  ),
                if (order.prepaid > 0)
                  OrderSpecRow(
                    label: t.prepaid,
                    value: ChizmaMoney.format(order.prepaid),
                  ),
                if (order.remainingPayment > 0)
                  OrderSpecRow(
                    label: t.remaining,
                    value: ChizmaMoney.format(order.remainingPayment),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.xl),
          if (order.isOwn)
            const SizedBox.shrink()
          else if (order.isCompleted)
            _CompletedBanner(order: order)
          else if (showStageAction)
            OrderStageAction(order: order, isBusy: isBusy),
        ],
      ),
    );
  }
}

class _OwnStatusCard extends StatelessWidget {
  const _OwnStatusCard({required this.order, required this.isBusy});

  final MasterOrderEntity order;
  final bool isBusy;

  Future<void> _change(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    final current = order.ownStatus;
    if (current == null) return;

    final picked = await OwnOrderStatusSheet.show(context, current: current);
    if (picked == null || picked == current) return;

    bloc.add(OwnOrderStatusChanged(orderId: order.id, status: picked));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = order.ownStatus;
    if (status == null) return const SizedBox.shrink();

    return Opacity(
      opacity: isBusy ? 0.6 : 1,
      child: ChizmaSheet(
        padding: EdgeInsets.zero,
        child: ChizmaListRow(
          leading: ChizmaIconTile(
            icon: switch (status) {
              OwnOrderStatus.done => Icons.verified_outlined,
              OwnOrderStatus.debt => Icons.account_balance_wallet_outlined,
              OwnOrderStatus.cancelled => Icons.cancel_outlined,
              OwnOrderStatus.inProgress => Icons.handyman_outlined,
              _ => Icons.fiber_new_outlined,
            },
            size: 42,
          ),
          title: status.label(context),
          subtitle: Text(
            isBusy
                ? context.t.ownOrders.saving
                : context.t.ownOrders.tapToChange,
          ),
          trailing: ChizmaStatusPill(
            order.pillLabel(context, now),
            status: order.pillStatus(now),
          ),
          showChevron: true,
          onTap: isBusy ? null : () => _change(context),
        ),
      ),
    );
  }
}

class _Drawings extends StatelessWidget {
  const _Drawings({required this.drawings});

  final List<OrderDrawingSpec> drawings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < drawings.length; index++) ...[
          if (index > 0) const SizedBox(height: ChizmaSpace.md),
          OrderDrawing(
            spec: drawings[index].spec,
            frameArgb: drawings[index].frameArgb,
          ),
        ],
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({required this.order, required this.now});

  final MasterOrderEntity order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Row(
      children: [
        ChizmaIconTile(
          icon: Icons.person_outline_rounded,
          size: 42,
        ),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.clientName.isEmpty
                    ? context.t.orders.detail.client
                    : order.clientName,
                style: context.text.h4.copyWith(
                  color: colors.neutral.textStrong,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                order.address,
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Mijoz raqami TANLANGANDAN keyin keladi — usta u bilan
              // bevosita bog'lana oladi. Raqamning O'ZI tugma: alohida
              // doira qo'ysak qator tor ekranda sig'masdi.
              if (order.clientPhone.isNotEmpty) ...[
                const SizedBox(height: 4),
                _CallButton(phone: order.clientPhone),
              ],
            ],
          ),
        ),
        const SizedBox(width: ChizmaSpace.sm),
        ChizmaStatusPill(
          order.pillLabel(context, now),
          status: order.pillStatus(now),
        ),
      ],
    );
  }
}

class OrderStageActionBar extends StatelessWidget {
  const OrderStageActionBar({
    super.key,
    required this.order,
    required this.isBusy,
  });

  final MasterOrderEntity order;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.md,
          ChizmaSpace.lg,
          ChizmaSpace.md,
        ),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          border: Border(top: BorderSide(color: colors.neutral.border)),
        ),
        child: OrderStageAction(order: order, isBusy: isBusy),
      ),
    );
  }
}

class OrderStageAction extends StatelessWidget {
  const OrderStageAction({
    super.key,
    required this.order,
    required this.isBusy,
  });

  static bool isVisibleFor(MasterOrderEntity order) =>
      !order.isOwn && !order.isCompleted && !order.isReadOnlyHistory;

  final MasterOrderEntity order;
  final bool isBusy;

  String _label(BuildContext context) {
    final t = context.t.orders.detail;
    if (order.isRom && order.stage == OrderStage.accepted) {
      return t.markMeasured;
    }
    return t.finishOrder;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isBusy
            ? null
            : () =>
                context.read<OrdersBloc>().add(OrderStageCompleted(order.id)),
        icon: isBusy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_rounded, size: 18),
        label: Text(
          _label(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.order});

  final MasterOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final cat = context.color.categorizedColor;
    final t = context.t.orders.detail;

    return ChizmaSheet(
      borderColor: cat.success.withValues(alpha: 0.35),
      color: cat.success.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 20, color: cat.success),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Text(
              t.completed,
              style: context.text.body4.copyWith(
                color: cat.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (order.rating != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: i <= order.rating!
                        ? cat.accent
                        : context.color.neutral.borderStrong,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}


/// Mijozga QO'NG'IROQ qilish — raqamning o'zi tugma.
class _CallButton extends StatelessWidget {
  const _CallButton({required this.phone});

  final String phone;

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    try {
      final opened = await launchUrl(uri);
      if (!opened) sl<SnackbarService>().showMessage(phone);
    } catch (_) {
      // Telefon ilovasi yo'q (emulyator, planshet) — raqamni ko'rsatamiz.
      sl<SnackbarService>().showMessage(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.color.categorizedColor.primary;

    return InkWell(
      onTap: _call,
      borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call_rounded, size: 15, color: primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.body5
                    .copyWith(color: primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
