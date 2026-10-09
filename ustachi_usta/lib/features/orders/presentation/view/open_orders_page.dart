import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';

class OpenOrdersPage extends StatefulWidget {
  const OpenOrdersPage({super.key, required this.onOpenRequest});

  final void Function(BuildContext context, String requestId) onOpenRequest;

  @override
  State<OpenOrdersPage> createState() => _OpenOrdersPageState();
}

class _OpenOrdersPageState extends State<OpenOrdersPage> {
  _Tab _tab = _Tab.waiting;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const OrdersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders;
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(t.open.pageTitle)),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final invited = state.invitedRequests;
          final waiting = state.publicOpenRequests;
          final sent = state.awaitingRequests;

          final tabs = <_Tab>[
            if (invited.isNotEmpty) _Tab.invited,
            _Tab.waiting,
            _Tab.sent,
          ];
          final tab = tabs.contains(_tab) ? _tab : tabs.first;
          final list = switch (tab) {
            _Tab.invited => invited,
            _Tab.waiting => waiting,
            _Tab.sent => sent,
          };
          final now = DateTime.now();

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<OrdersBloc>().add(const OrdersLoadRequested()),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.pagePadding,
                        ChizmaSpace.sm,
                        context.pagePadding,
                        ChizmaSpace.sm,
                      ),
                      child: Column(
                        children: [
                          _StatStrip(
                            invited: invited.length,
                            waiting: waiting.length,
                            sent: sent.length,
                          ),
                          const SizedBox(height: ChizmaSpace.md),
                          ChizmaSegmented(
                            labels: [
                              for (final item in tabs) item.label(context),
                            ],
                            counts: [
                              for (final item in tabs)
                                switch (item) {
                                  _Tab.invited => invited.length,
                                  _Tab.waiting => waiting.length,
                                  _Tab.sent => sent.length,
                                },
                            ],
                            selectedIndex: tabs.indexOf(tab),
                            onChanged: (i) => setState(() => _tab = tabs[i]),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _Body(
                        state: state,
                        items: list,
                        now: now,
                        tab: tab,
                        onOpen: (id) => widget.onOpenRequest(context, id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _Tab {
  invited,
  waiting,
  sent;

  String label(BuildContext context) {
    final t = context.t.orders.open;
    return switch (this) {
      _Tab.invited => t.tabInvited,
      _Tab.waiting => t.tabWaiting,
      _Tab.sent => t.tabSent,
    };
  }
}

class _StatStrip extends StatelessWidget {
  const _StatStrip({
    required this.invited,
    required this.waiting,
    required this.sent,
  });

  final int invited;
  final int waiting;
  final int sent;

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.open;
    final colors = context.color;

    return ChizmaSheet(
      padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.md, vertical: ChizmaSpace.sm + 2),
      child: Row(
        children: [
          if (invited > 0) ...[
            Expanded(
              child: _Stat(
                label: t.tabInvited,
                value: invited,
                color: colors.categorizedColor.accent,
              ),
            ),
            Container(width: 1, height: 30, color: colors.neutral.border),
          ],
          Expanded(
            child: _Stat(
              label: t.tabWaiting,
              value: waiting,
              color: colors.neutral.textStrong,
            ),
          ),
          Container(width: 1, height: 30, color: colors.neutral.border),
          Expanded(
            child: _Stat(
              label: t.tabSent,
              value: sent,
              color: colors.categorizedColor.info,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: const EdgeInsets.only(left: ChizmaSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: context.text.h4
                .copyWith(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: ChizmaSpace.sm),
          Flexible(
            child: Text(
              label,
              style: context.text.label
                  .copyWith(color: colors.neutral.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.items,
    required this.now,
    required this.tab,
    required this.onOpen,
  });

  final OrdersState state;
  final List<OrderRequestEntity> items;
  final DateTime now;
  final _Tab tab;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders;

    if (state.loadStatus.isLoading && state.requests.isEmpty) {
      return const _Skeleton();
    }

    if (state.loadStatus.isFailure && state.requests.isEmpty) {
      return ChizmaEmptyState(
        icon: Icons.cloud_off_outlined,
        title: t.loadFailed,
        message: state.failure?.errorMessage ?? '',
        actionLabel: t.retry,
        onAction: () =>
            context.read<OrdersBloc>().add(const OrdersLoadRequested()),
      );
    }

    if (items.isEmpty) {
      return switch (tab) {
        _Tab.invited => ChizmaEmptyState(
            icon: Icons.person_pin_circle_outlined,
            title: t.open.emptyInvitedTitle,
            message: t.open.emptyInvitedMessage,
          ),
        _Tab.sent => ChizmaEmptyState(
            icon: Icons.hourglass_empty_rounded,
            title: t.open.emptySentTitle,
            message: t.open.emptySentMessage,
          ),
        _Tab.waiting => ChizmaEmptyState(
            icon: Icons.inbox_outlined,
            title: t.emptyNewTitle,
            message: t.emptyNewMessage,
          ),
      };
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        0,
        context.pagePadding,
        ChizmaSpace.xxl,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.sm),
      itemBuilder: (context, index) {
        final request = items[index];
        return OrderRequestCard(
          request: request,
          now: now,
          onTap: () => onOpen(request.id),
          onOffer: request.offerSent ? null : () => onOpen(request.id),
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        0,
        context.pagePadding,
        ChizmaSpace.xxl,
      ),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.sm),
      itemBuilder: (_, __) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: colors.neutral.surface2,
          borderRadius: BorderRadius.circular(ChizmaRadius.lg),
          border: Border.all(color: colors.neutral.border),
        ),
      ),
    );
  }
}
