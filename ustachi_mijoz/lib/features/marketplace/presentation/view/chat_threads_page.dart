import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/tab_visibility_mixin.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_page.dart';

class ChatThreadsPage extends StatefulWidget {
  const ChatThreadsPage({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<ChatThreadsPage> createState() => _ChatThreadsPageState();
}

class _ChatThreadsPageState extends State<ChatThreadsPage>
    with TabVisibilityMixin {
  List<ChatThreadEntity> _threads = const [];
  bool _loading = true;

  StreamSubscription<List<ChatThreadEntity>>? _sub;

  @override
  void initState() {
    super.initState();
    _watch();
  }

  @override
  void dispose() {
    _unwatch();
    super.dispose();
  }

  @override
  void onTabVisibilityChanged(bool visible) => visible ? _watch() : _unwatch();

  void _watch() {
    if (_sub != null) return;

    MarketplaceSocket.instance.acquire();

    _load();
    _sub = sl<MarketplaceRepository>()
        .watchThreads(immediate: false)
        .listen((items) {
      if (mounted) setState(() => _threads = items);
    });
  }

  void _unwatch() {
    if (_sub == null) return;
    _sub?.cancel();
    _sub = null;
    MarketplaceSocket.instance.release();
  }

  Future<void> _load() async {
    final result = await sl<MarketplaceRepository>().threads();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isRight) _threads = result.right;
    });
  }

  Future<void> _open(ChatThreadEntity thread) async {

    _unwatch();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          threadId: thread.id,
          title: thread.peer.displayName,
          orderId: thread.orderId,
        ),
      ),
    );

    if (mounted && isTabVisible) _watch();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: _threads.isEmpty
                ? _EmptyThreads()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.xxl + context.viewPaddingBottom,
                    ),
                    itemCount: _threads.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: ChizmaSpace.md),
                    itemBuilder: (context, i) => _ThreadTile(
                      thread: _threads[i],
                      onTap: () => _open(_threads[i]),
                    ),
                  ),
          );

    if (!widget.showAppBar) return body;
    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: const Text('Suhbatlar')),
      body: body,
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, this.onTap});

  final ChatThreadEntity thread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.neutral.surface2,
            backgroundImage: thread.peer.photo != null
                ? NetworkImage(thread.peer.photo!)
                : null,
            child: thread.peer.photo == null
                ? Icon(Icons.person_outline, color: colors.neutral.textMuted)
                : null,
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  thread.peer.displayName,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  thread.lastMessage ?? thread.orderTitle,
                  style: context.text.body5.copyWith(
                    color: thread.hasUnread
                        ? colors.neutral.textStrong
                        : colors.neutral.textMuted,
                    fontWeight: thread.hasUnread ? FontWeight.w600 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: ChizmaSpace.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (thread.lastMessageAt != null)
                Text(
                  thread.lastMessageAt!.formatTime,
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                ),
              if (thread.hasUnread) ...[
                const SizedBox(height: 4),
                ChizmaBadge('${thread.unreadCount}'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyThreads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ListView(
      children: [
        SizedBox(height: context.screenSize.height * 0.28),
        Icon(Icons.forum_outlined, size: 48, color: colors.neutral.textMuted),
        const SizedBox(height: ChizmaSpace.md),
        Text(
          'Hali suhbat yo\'q',
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ChizmaSpace.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.xxl),
          child: Text(
            'Buyurtmangizga usta javob berganda shu yerda yozishasiz.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
