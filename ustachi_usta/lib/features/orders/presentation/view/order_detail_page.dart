import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/order_visuals.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  MasterOrderEntity? _historicalOrder;
  String? _historicalError;
  bool _loadingHistorical = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<OrdersBloc>();
      final hasOrder =
          bloc.state.orders.any((item) => item.id == widget.orderId);
      if (!hasOrder) {
        _loadHistoricalOrder();
      }
    });
  }

  Future<void> _loadHistoricalOrder() async {
    if (_loadingHistorical) return;
    setState(() => _loadingHistorical = true);
    final result =
        await sl<OrdersRepository>().historicalDetail(widget.orderId);
    if (!mounted) return;
    setState(() {
      _loadingHistorical = false;
      if (result.isRight) {
        _historicalOrder = result.right;
      } else {
        _historicalError = result.left.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.detail;

    return BlocConsumer<OrdersBloc, OrdersState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
          return;
        }
        if (state.actionStatus.isSuccess) {
          final order = state.orders
              .where((item) => item.id == widget.orderId)
              .firstOrNull;
          if (order != null && !order.isOwn) {
            sl<SnackbarService>()
                .showMessage(context.t.orders.detail.stageSaved);
            Navigator.of(context).maybePop();
          }
        }
      },
      builder: (context, state) {
        final order = state.orders
                .where((item) => item.id == widget.orderId)
                .firstOrNull ??
            _historicalOrder;

        if (order == null) {
          if (_loadingHistorical || state.loadStatus.isLoading) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(),
            body: ChizmaEmptyState(
              icon: Icons.help_outline_rounded,
              title: t.notFound,
              message: _historicalError ?? '',
            ),
          );
        }

        final hasAction = OrderStageAction.isVisibleFor(order);
        final closedReason = order.closedReason;

        return Scaffold(
          backgroundColor: context.color.neutral.bg,
          appBar: AppBar(
            title: Text(order.number),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: ChizmaSpace.lg),
                child: Center(
                  child: ChizmaStatusPill(
                    order.pillLabel(context, DateTime.now()),
                    status: order.pillStatus(DateTime.now()),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: hasAction
              ? OrderStageActionBar(
                  order: order,
                  isBusy: state.actionStatus.isLoading,
                )
              : null,
          body: Column(
            children: [
              if (closedReason != null)
                _ClosedOrderNotice(order: order, reason: closedReason),
              Expanded(
                  child: OrderDetailView(order: order, showStageAction: false)),
            ],
          ),
        );
      },
    );
  }
}

class _ClosedOrderNotice extends StatelessWidget {
  const _ClosedOrderNotice({required this.order, required this.reason});

  final MasterOrderEntity order;
  final ClosedOrderReason reason;

  @override
  Widget build(BuildContext context) {
    final (title, detail) = switch (reason) {
      ClosedOrderReason.takenByAnother => (
          'Buyurtmani boshqa usta olgan',
          order.assignedMasterName,
        ),
      ClosedOrderReason.cancelled => (
          'Buyurtma mijoz tomonidan bekor qilingan',
          order.cancelledReason.isEmpty ? null : order.cancelledReason,
        ),
      ClosedOrderReason.expired => ('Buyurtma muddati tugagan', null),
      ClosedOrderReason.completed => ('Buyurtma yakunlangan', null),
    };
    final colors = context.color;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.categorizedColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colors.categorizedColor.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: colors.categorizedColor.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(detail),
                ],
                const SizedBox(height: 4),
                const Text('Buyurtma ma’lumotlari faqat ko‘rish uchun.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
