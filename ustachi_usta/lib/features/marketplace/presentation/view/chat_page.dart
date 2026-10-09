import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/chat_order_banner.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.threadId,
    this.title,
    this.orderId,
  });

  final int threadId;

  final int? orderId;

  final String? title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _pollInterval = Duration(seconds: 5);

  static const _pageSize = 50;

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<ChatMessageEntity> _messages = const [];
  bool _loading = true;
  bool _sending = false;

  bool _hasOlder = true;
  bool _loadingOlder = false;
  StreamSubscription<List<ChatMessageEntity>>? _sub;

  int? get _lastId => _messages.isEmpty ? null : _messages.last.id;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    MarketplaceSocket.instance.acquire();
    _load(initial: true);
    _sub = sl<MarketplaceRepository>()
        .watchMessages(
          widget.threadId,
          interval: _pollInterval,
          immediate: false,
          after: () => _lastId ?? 0,
        )
        .listen((items) {
      if (!mounted || items.isEmpty) return;
      setState(() {
        _messages = _merge(_messages, items);
        _loading = false;
      });
      _scrollToEnd();
    });
  }

  static List<ChatMessageEntity> _merge(
    List<ChatMessageEntity> current,
    List<ChatMessageEntity> incoming,
  ) {
    final seen = current.map((m) => m.id).toSet();
    return [
      ...current,
      for (final m in incoming)
        if (seen.add(m.id)) m,
    ];
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients || _loadingOlder || !_hasOlder) return;
    final position = _scrollCtrl.position;
    if (position.pixels < position.maxScrollExtent - 200) return;
    unawaited(_loadOlder());
  }

  Future<void> _loadOlder() async {
    if (_loadingOlder || !_hasOlder || _messages.isEmpty) return;
    setState(() => _loadingOlder = true);

    final result = await sl<MarketplaceRepository>().messages(
      widget.threadId,
      before: _messages.first.id,
      limit: _pageSize,
    );
    if (!mounted) return;

    setState(() {
      _loadingOlder = false;
      if (result.isLeft) return;
      final older = result.right;
      if (older.isEmpty) {
        _hasOlder = false;
        return;
      }
      final seen = _messages.map((m) => m.id).toSet();
      _messages = [
        for (final m in older)
          if (!seen.contains(m.id)) m,
        ..._messages,
      ];
      if (older.length < _pageSize) _hasOlder = false;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    MarketplaceSocket.instance.release();
    super.dispose();
  }

  Future<void> _load({bool initial = false}) async {
    final result = await sl<MarketplaceRepository>()
        .messages(widget.threadId, limit: _pageSize);
    if (!mounted || result.isLeft) {
      if (mounted && initial) setState(() => _loading = false);
      return;
    }
    final incoming = result.right;
    setState(() {
      _messages = incoming;
      _loading = false;
      _hasOlder = incoming.length >= _pageSize;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.jumpTo(0);
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final result =
        await sl<MarketplaceRepository>().sendMessage(widget.threadId, text);
    if (!mounted) return;
    setState(() => _sending = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    _inputCtrl.clear();
    setState(() => _messages = [..._messages, result.right]);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: Text(widget.title ?? context.t.chat.conversation)),
      body: Column(
        children: [
          if (widget.orderId != null) ChatOrderBanner(orderId: widget.orderId!),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _EmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        padding: const EdgeInsets.all(ChizmaSpace.lg),
                        itemCount: _messages.length + (_loadingOlder ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: ChizmaSpace.md),
                              child: Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          return _Bubble(
                            message: _messages[_messages.length - 1 - i],
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.md, ChizmaSpace.sm,
                  ChizmaSpace.md, ChizmaSpace.sm),
              decoration: BoxDecoration(
                color: colors.neutral.surface,
                border: Border(
                  top: BorderSide(color: colors.neutral.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: uz(context.t.chat.messageHint),
                      ),
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.sm),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChizmaSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 44, color: colors.neutral.textMuted),
            const SizedBox(height: ChizmaSpace.md),
            Text(
              context.t.chat.emptyChat,
              style:
                  context.text.body4.copyWith(color: colors.neutral.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final mine = message.isMine;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(ChizmaRadius.lg),
      topRight: const Radius.circular(ChizmaRadius.lg),
      bottomLeft: Radius.circular(mine ? ChizmaRadius.lg : ChizmaRadius.sm),
      bottomRight: Radius.circular(mine ? ChizmaRadius.sm : ChizmaRadius.lg),
    );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.75),
        margin: const EdgeInsets.only(bottom: ChizmaSpace.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: ChizmaSpace.md, vertical: ChizmaSpace.sm),
        decoration: BoxDecoration(
          color:
              mine ? colors.categorizedColor.primary : colors.neutral.surface,
          borderRadius: radius,
          border: mine ? null : Border.all(color: colors.neutral.border),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: context.text.body4.copyWith(
                color: mine ? colors.neutral.white : colors.neutral.textStrong,
              ),
            ),
            if (message.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                message.createdAt!.formatTime,
                style: context.text.label.copyWith(
                  color: mine
                      ? colors.neutral.white.withValues(alpha: 0.75)
                      : colors.neutral.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
