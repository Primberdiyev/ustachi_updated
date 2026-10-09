import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_status.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/marketplace/presentation/tab_visibility_mixin.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/router/orders_router.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.router});

  final OrdersRouter router;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TabVisibilityMixin {
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const OrdersLoadRequested());
  }

  @override
  void onTabVisibilityChanged(bool visible) {
    if (!visible) return;
    final bloc = context.read<OrdersBloc>();
    if (bloc.state.loadStatus == Statuses.loading) return;
    bloc.add(const OrdersLoadRequested());
  }

  void _openOrder(BuildContext context, MasterOrderEntity order) {
    if (context.breakpoint.isExpanded) {
      setState(() => _selectedOrderId = order.id);
      return;
    }
    widget.router.openOrderDetail(context, orderId: order.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders;

    return Scaffold(
      backgroundColor: context.color.neutral.bg,
      appBar: AppBar(title: Text(t.personalTitle)),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final list = _OrdersList(
            state: state,
            onOrderTap: (order) => _openOrder(context, order),
            onRequestTap: (id) =>
                widget.router.openRequestOffer(context, requestId: id),
            selectedOrderId:
                context.breakpoint.isExpanded ? _selectedOrderId : null,
          );

          if (!context.breakpoint.isExpanded) return list;

          final selected = state.orders
              .where((order) => order.id == _selectedOrderId)
              .firstOrNull;

          return ChizmaMasterDetail(
            list: list,
            detail: selected == null
                ? ChizmaEmptyState(
                    icon: Icons.article_outlined,
                    title: t.title,
                    message: t.emptyActiveMessage,
                  )
                : OrderDetailView(order: selected),
          );
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.state,
    required this.onOrderTap,
    required this.onRequestTap,
    required this.selectedOrderId,
  });

  final OrdersState state;
  final ValueChanged<MasterOrderEntity> onOrderTap;
  final ValueChanged<String> onRequestTap;
  final String? selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders;
    final now = DateTime.now();

    const segments = [OrdersSegment.inProgress, OrdersSegment.completed];
    final selected = segments.indexOf(state.segment);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            ChizmaSpace.sm,
            context.pagePadding,
            ChizmaSpace.md,
          ),
          child: ChizmaSegmented(
            labels: [t.segmentActive, t.segmentDone],
            counts: segments.map(state.countFor).toList(),
            selectedIndex: selected < 0 ? 0 : selected,
            onChanged: (index) => context
                .read<OrdersBloc>()
                .add(OrdersSegmentChanged(segments[index])),
          ),
        ),
        Expanded(child: _buildBody(context, now)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DateTime now) {
    if (state.loadStatus.isLoading && state.orders.isEmpty) {
      return const _OrdersSkeleton();
    }

    if (state.loadStatus.isFailure && state.orders.isEmpty) {
      return ChizmaEmptyState(
        icon: Icons.cloud_off_outlined,
        title: context.t.orders.loadFailed,
        message: state.failure?.errorMessage ?? '',
        actionLabel: context.t.orders.retry,
        onAction: () =>
            context.read<OrdersBloc>().add(const OrdersLoadRequested()),
      );
    }

    return switch (state.segment) {
      OrdersSegment.completed =>
        _ordersList(context, now, state.completedOrders, _EmptyKind.done),
      _ => _ordersList(context, now, state.activeOrders, _EmptyKind.active),
    };
  }

  Widget _ordersList(
    BuildContext context,
    DateTime now,
    List<MasterOrderEntity> orders,
    _EmptyKind emptyKind,
  ) {
    final t = context.t.orders;

    if (orders.isEmpty) {
      return ChizmaEmptyState(
        icon: emptyKind == _EmptyKind.active
            ? Icons.handyman_outlined
            : Icons.task_alt_outlined,
        title: emptyKind == _EmptyKind.active
            ? t.emptyActiveTitle
            : t.emptyDoneTitle,
        message: emptyKind == _EmptyKind.active
            ? t.emptyActiveMessage
            : t.emptyDoneMessage,
      );
    }

    return _listView(
      context,
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          now: now,
          selected: order.id == selectedOrderId,
          onTap: () => onOrderTap(order),
        );
      },
    );
  }

  Widget _listView(
    BuildContext context, {
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            0,
            context.pagePadding,
            ChizmaSpace.xxl,
          ),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.sm),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}

enum _EmptyKind { active, done }

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            0,
            context.pagePadding,
            ChizmaSpace.xxl,
          ),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.sm),
          itemBuilder: (_, __) => Container(
            height: 96,
            decoration: BoxDecoration(
              color: colors.neutral.surface2,
              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
              border: Border.all(color: colors.neutral.border),
            ),
          ),
        ),
      ),
    );
  }
}
