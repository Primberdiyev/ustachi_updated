import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/core/router/app_router.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.openOrderDetail = true});

  final bool openOrderDetail;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationPage _page = const NotificationPage();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<MarketplaceRepository>().notifications();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isRight) _page = result.right;
    });
  }

  Future<void> _readAll() async {
    await sl<MarketplaceRepository>().markAllRead();
    if (mounted) _load();
  }

  Future<void> _open(AppNotificationEntity item) async {
    if (!item.isRead) {
      await sl<MarketplaceRepository>().markRead(item.id);
    }
    if (!mounted) return;

    if (item.type == AppNotificationType.chatMessage) {
      sl<AppRouter>().navigate(const MainPageRoute(children: [ChattingPageRoute()]));
    } else if (widget.openOrderDetail && item.orderId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailPage(orderId: item.orderId!),
        ),
      );
    }
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        actions: [
          if (_page.unreadCount > 0)
            TextButton(
              onPressed: _readAll,
              child: const Text('Hammasini o\'qish'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _page.items.isEmpty
                  ? _EmptyNotifications()
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        ChizmaSpace.lg,
                        ChizmaSpace.lg,
                        ChizmaSpace.lg,
                        ChizmaSpace.xxl + context.viewPaddingBottom,
                      ),
                      itemCount: _page.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: ChizmaSpace.sm),
                      itemBuilder: (context, i) => _NotificationTile(
                        item: _page.items[i],
                        onTap: () => _open(_page.items[i]),
                      ),
                    ),
            ),
    );
  }
}

IconData notificationIcon(AppNotificationType type) => switch (type) {
      AppNotificationType.orderPublished => Icons.campaign_outlined,
      AppNotificationType.orderResponse => Icons.how_to_reg_outlined,
      AppNotificationType.orderChosen => Icons.verified_outlined,
      AppNotificationType.orderNotChosen => Icons.info_outline_rounded,
      AppNotificationType.orderStage => Icons.timeline_outlined,
      AppNotificationType.orderCompleted => Icons.task_alt_rounded,
      AppNotificationType.orderCancelled => Icons.cancel_outlined,
      AppNotificationType.reviewReceived => Icons.star_outline_rounded,
      AppNotificationType.chatMessage => Icons.chat_bubble_outline_rounded,
      AppNotificationType.unknown => Icons.notifications_none_rounded,
    };

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, this.onTap});

  final AppNotificationEntity item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      color: item.isRead ? null : colors.categorizedColor.primary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChizmaIconTile(icon: notificationIcon(item.type), size: 36),
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
                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: context.text.body5
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (item.createdAt != null)
            Text(
              item.createdAt!.formatTime,
              style: context.text.label.copyWith(color: colors.neutral.textMuted),
            ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ListView(
      children: [
        SizedBox(height: context.screenSize.height * 0.3),
        Icon(Icons.notifications_none_rounded,
            size: 48, color: colors.neutral.textMuted),
        const SizedBox(height: ChizmaSpace.md),
        Text(
          'Bildirishnoma yo\'q',
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, this.openOrderDetail = true});

  final bool openOrderDetail;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  int _unread = 0;
  StreamSubscription<SocketEvent>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(); 

    _sub = MarketplaceSocket.instance.events.listen((event) {
      final count = event.unreadCount;
      if (count != null && mounted) setState(() => _unread = count);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final result = await sl<MarketplaceRepository>().notifications(unreadOnly: true);
    if (!mounted || result.isLeft) return;
    setState(() => _unread = result.right.unreadCount);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsPage(
          openOrderDetail: widget.openOrderDetail,
        ),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return InkResponse(
      onTap: _open,
      radius: 28,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(child: Icon(Icons.notifications_none_rounded)),
            if (_unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.categorizedColor.error,
                    borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    _unread > 99 ? '99+' : '$_unread',
                    textAlign: TextAlign.center,
                    style: context.text.label.copyWith(
                      color: colors.neutral.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
