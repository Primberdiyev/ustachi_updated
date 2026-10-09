import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_drawing.dart';
import 'package:ustachi/features/orders/presentation/order_spec_l10n.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_spec_row.dart';

class OrderRequestPage extends StatefulWidget {
  const OrderRequestPage({
    super.key,
    required this.requestId,
    required this.onClose,
  });

  final String requestId;
  final VoidCallback onClose;

  @override
  State<OrderRequestPage> createState() => _OrderRequestPageState();
}

class _OrderRequestPageState extends State<OrderRequestPage> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<OrdersBloc>();
      if (!bloc.state.loadStatus.isLoading) {
        bloc.add(OrdersLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _send(OrderRequestEntity request) {
    FocusScope.of(context).unfocus();
    context.read<OrdersBloc>().add(
          OrderOfferSent(
            requestId: request.id,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        );
  }

  Future<void> _confirmDecline(OrderRequestEntity request) async {
    final t = context.t.orders.request;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(request.isInvited ? t.declineInviteTitle : t.declineTitle),
        content: Text(
          request.isInvited ? t.declineInviteMessage : t.declineMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.t.auth.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.color.categorizedColor.error,
            ),
            child: Text(t.decline),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<OrdersBloc>().add(
          OrderRequestDeclined(request.id, invited: request.isInvited),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.request;
    final colors = context.color;

    return BlocConsumer<OrdersBloc, OrdersState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          (previous.loadStatus.isLoading && !current.loadStatus.isLoading),
      listener: (context, state) {
        if (!state.loadStatus.isLoading &&
            !state.requests.any((item) => item.id == widget.requestId)) {
          context.router.replace(
            OrderDetailPageRoute(orderId: widget.requestId),
          );
          return;
        }
        if (state.actionStatus.isSuccess) {
          sl<SnackbarService>().showMessage(t.sent);
          widget.onClose();
          return;
        }
        if (state.actionStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
        }
      },
      builder: (context, state) {
        final request = state.requests
            .where((item) => item.id == widget.requestId)
            .firstOrNull;

        if (request == null) {
          if (state.loadStatus.isLoading) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(),
            body: ChizmaEmptyState(
              icon: Icons.timer_off_outlined,
              title: t.expired,
              message: context.t.orders.emptyNewMessage,
            ),
          );
        }

        final isBusy = state.actionStatus.isLoading;

        return Scaffold(
          backgroundColor: colors.neutral.bg,
          appBar: AppBar(title: Text('${t.title} ${request.number}')),
          body: ChizmaPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClientRow(request: request),
                if (request.isInvited && !request.inviteDeclined) ...[
                  const SizedBox(height: ChizmaSpace.md),
                  _InvitedNote(),
                ],
                const SizedBox(height: ChizmaSpace.xl),
                ChizmaEyebrow(t.clientSpec),
                const SizedBox(height: ChizmaSpace.md),
                ChizmaSheet(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (request.drawings.isNotEmpty) ...[
                        for (final drawing in request.drawings) ...[
                          OrderDrawing(
                            spec: drawing.spec,
                            frameArgb: drawing.frameArgb,
                          ),
                          const SizedBox(height: ChizmaSpace.md),
                        ],
                      ] else if (request.drawing != null) ...[
                        OrderDrawing(
                          spec: request.drawing!,
                          frameArgb: request.frameArgb,
                        ),
                        const SizedBox(height: ChizmaSpace.md),
                      ],
                      for (final entry in request.spec.entries)
                        OrderSpecRow(
                          label: orderSpecLabel(context, entry.key),
                          value: orderSpecValue(context, entry.value),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: ChizmaSpace.xl),
                ChizmaEyebrow(t.priceOffer),
                const SizedBox(height: ChizmaSpace.md),
                if (!request.hasPrice)
                  ChizmaSheet(
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 18, color: colors.neutral.textMuted),
                        const SizedBox(width: ChizmaSpace.sm),
                        Expanded(
                          child: Text(
                            t.priceInChat,
                            style: context.text.body4.copyWith(
                              color: colors.neutral.textStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  OrderPriceBreakdown(request: request),
                const SizedBox(height: ChizmaSpace.lg),
                if (request.offerSent) ...[
                  _SentBanner(),
                ] else ...[
                  ChizmaEyebrow(t.note),
                  const SizedBox(height: ChizmaSpace.sm),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: t.notePlaceholder),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: OrderRequestActionBar(
            request: request,
            busy: isBusy,
            onSend: () => _send(request),
            onDecline: () => _confirmDecline(request),
          ),
        );
      },
    );
  }
}

class OrderRequestActionBar extends StatelessWidget {
  const OrderRequestActionBar({
    super.key,
    required this.request,
    required this.busy,
    required this.onSend,
    required this.onDecline,
  });

  final OrderRequestEntity request;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders.request;
    final danger = colors.categorizedColor.error;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (request.offerSent)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: busy ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: danger,
                    side: BorderSide(color: danger),
                    padding: const EdgeInsets.symmetric(
                      vertical: ChizmaSpace.md,
                    ),
                  ),
                  child: Text(t.withdrawOffer),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : onSend,
                  icon: busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(t.send),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: ChizmaSpace.md + 2,
                    ),
                    textStyle: context.text.body3
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (request.isInvited && !request.inviteDeclined) ...[
                const SizedBox(height: ChizmaSpace.xs),
                TextButton(
                  onPressed: busy ? null : onDecline,
                  style: TextButton.styleFrom(foregroundColor: danger),
                  child: Text(t.decline),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InvitedNote extends StatelessWidget {
  const _InvitedNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final accent = colors.categorizedColor.accent;

    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_pin_circle_outlined, size: 18, color: accent),
          const SizedBox(width: ChizmaSpace.sm),
          Expanded(
            child: Text(
              context.t.orders.open.invitedNote,
              style:
                  context.text.body5.copyWith(color: colors.neutral.textStrong),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({required this.request});

  final OrderRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.orders.request;
    final clientName = request.clientName.trim().isEmpty
        ? context.t.orders.detail.client
        : request.clientName.trim();
    final address = request.address.trim().isEmpty ? '-' : request.address;

    return Row(
      children: [
        ChizmaIconTile(icon: Icons.person_outline_rounded, size: 42),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clientName,
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$address · '
                '${t.distance(km: request.distanceKm.toStringAsFixed(1))}',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SentBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final info = colors.categorizedColor.info;
    final t = context.t.orders;

    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.md),
      decoration: BoxDecoration(
        color: info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: info.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 18, color: info),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.open.offerSent,
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.open.waitingClient,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({super.key, required this.request});

  final OrderRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.request;

    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OrderSpecRow(
            label: t.clientPrice,
            value: ChizmaMoney.format(request.calculatedPrice),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          _ChatNote(text: t.chatNote),
        ],
      ),
    );
  }
}

class _ChatNote extends StatelessWidget {
  const _ChatNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline_rounded,
            size: 16, color: colors.neutral.textMuted),
        const SizedBox(width: ChizmaSpace.sm),
        Expanded(
          child: Text(
            text,
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}
