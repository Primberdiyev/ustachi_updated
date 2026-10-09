import 'package:ustachi/core/design_sytem/widgets/list_loading_placeholder.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/order_widgets.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

enum _OrderTab { searching, inProgress, finished }

class _MyOrdersPageState extends State<MyOrdersPage> {
  _OrderTab _tab = _OrderTab.searching;
  List<OrderEntity> _orders = const [];
  bool _loading = true;
  String? _error;
  int _loadVersion = 0;
  Future<void>? _pendingLoad;

  StreamSubscription<List<OrderEntity>>? _sub;

  @override
  void initState() {
    super.initState();

    MarketplaceSocket.instance.acquire();
    _load();

    _sub = sl<MarketplaceRepository>()
        .watchList(immediate: false)
        .listen((orders) {
      if (!mounted) return;

      ++_loadVersion;
      setState(() {
        _orders = orders;
        _error = null;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    MarketplaceSocket.instance.release();
    super.dispose();
  }

  Future<void> _load() =>
      _pendingLoad ??= _fetch().whenComplete(() => _pendingLoad = null);

  Future<void> _fetch() async {
    final version = ++_loadVersion;
    setState(() {
      _loading = _orders.isEmpty;
      _error = null;
    });
    try {
      final result = await sl<MarketplaceRepository>()
          .list()
          .timeout(const Duration(seconds: 20));
      if (!mounted || version != _loadVersion) return;
      setState(() {
        if (result.isRight) {
          _orders = result.right;
        } else {
          _error = result.left.errorMessage;
        }
      });
    } catch (error) {
      if (!mounted || version != _loadVersion) return;
      setState(() => _error = error is TimeoutException
          ? context.t.common.loadingTimeout
          : context.t.common.wentWrong);
    } finally {
      if (mounted && version == _loadVersion) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _open(OrderEntity order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: order.id),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    final searching = _orders.where((o) => o.status.isOpen).toList();
    final inProgress = _orders.where((o) => o.status.isActive).toList();
    final finished = _orders.where((o) => o.status.isFinished).toList();
    final groups = {
      _OrderTab.searching: searching,
      _OrderTab.inProgress: inProgress,
      _OrderTab.finished: finished,
    };
    final visible = groups[_tab]!;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: Text(context.t.profile.myOrders)),
      body: _loading
          ? ListView(
              padding: const EdgeInsets.all(ChizmaSpace.lg),
              children: const [ListLoadingPlaceholder()],
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? _EmptyOrders(error: _error, onRetry: _load)
                  : Column(
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: ChizmaSpace.lg),
                            child: Row(children: [
                              Expanded(child: Text(_error!)),
                              TextButton(
                                  onPressed: _load,
                                  child: Text(context.t.common.retry)),
                            ]),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ChizmaSpace.lg,
                            ChizmaSpace.md,
                            ChizmaSpace.lg,
                            ChizmaSpace.md,
                          ),
                          child: ChizmaSegmented(

                            labels: const [
                              'Qidirilmoqda',
                              'Jarayonda',
                              'Yakunlangan',
                            ],
                            counts: [
                              searching.length,
                              inProgress.length,
                              finished.length,
                            ],
                            selectedIndex: _OrderTab.values.indexOf(_tab),
                            onChanged: (i) =>
                                setState(() => _tab = _OrderTab.values[i]),
                          ),
                        ),
                        Expanded(
                          child: visible.isEmpty
                              ? _EmptyTab(tab: _tab)
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    ChizmaSpace.lg,
                                    0,
                                    ChizmaSpace.lg,
                                    ChizmaSpace.xxl + context.viewPaddingBottom,
                                  ),
                                  itemCount: visible.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: ChizmaSpace.md),
                                  itemBuilder: (context, i) => OrderCard(
                                    order: visible[i],
                                    onTap: () => _open(visible[i]),
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({this.error, required this.onRetry});
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: context.screenSize.height * 0.25),
        Icon(
          error == null ? Icons.inbox_outlined : Icons.wifi_off_rounded,
          size: 48,
          color: colors.neutral.textMuted,
        ),
        const SizedBox(height: ChizmaSpace.md),
        Text(
          error ?? 'Hali buyurtma bermagansiz',
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ChizmaSpace.sm),
        if (error != null)
          Center(
              child: TextButton(
                  onPressed: onRetry, child: Text(context.t.common.retry)))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.xxl),
            child: Text(
              'Narx hisoblab, yoqqan variantni tanlang va "Usta bilan '
              'bog\'lanish" tugmasini bosing.',
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.tab});

  final _OrderTab tab;

  @override
  Widget build(BuildContext context) {
    final (icon, title, message) = switch (tab) {
      _OrderTab.searching => (
          Icons.search_rounded,
          'Qidiruvdagi buyurtma yo\'q',
          'Narx hisoblab "Usta bilan bog\'lanish" tugmasini bossangiz, e\'lon '
              'shu yerda paydo bo\'ladi.',
        ),
      _OrderTab.inProgress => (
          Icons.handyman_outlined,
          'Jarayondagi ish yo\'q',
          'Ustani tanlaganingizdan keyin ish shu bo\'limga o\'tadi: o\'lchov, '
              'ishlab chiqarish, o\'rnatish.',
        ),
      _OrderTab.finished => (
          Icons.task_alt_rounded,
          'Yakunlangan buyurtma yo\'q',
          'Topshirilgan ishlar shu yerda saqlanadi — baho berish ham shu '
              'yerdan.',
        ),
    };

    return ChizmaEmptyState(icon: icon, title: title, message: message);
  }
}
