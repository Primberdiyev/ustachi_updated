import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/order_proposal_items.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_picker_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_profile_page.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/invited_masters_block.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/order_items_block.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/order_widgets.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/waiting_for_masters.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderEntity? _order;
  List<OrderResponseEntity> _responses = const [];
  bool _loading = true;
  bool _busy = false;

  List<OrderProposalItem> _items = const [];

  bool _reviewAsked = false;

  void _applyOrder(OrderEntity order) {
    _order = order;
    _items = orderProposalItems(order.proposal);
  }

  StreamSubscription<OrderEntity>? _orderSub;
  StreamSubscription<List<OrderResponseEntity>>? _responsesSub;

  @override
  void initState() {
    super.initState();

    MarketplaceSocket.instance.acquire();
    _load();
    _watch();
  }

  void _watch() {
    final repo = sl<MarketplaceRepository>();
    _orderSub =
        repo.watchOrder(widget.orderId, immediate: false).listen((order) {
      if (!mounted) return;
      setState(() => _applyOrder(order));

      if (order.status.isOpen && _responsesSub == null) {
        _responsesSub = repo.watchResponses(widget.orderId).listen((items) {
          if (mounted) setState(() => _responses = items);
        });
      } else if (!order.status.isOpen) {
        _responsesSub?.cancel();
        _responsesSub = null;
      }
    });
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    _responsesSub?.cancel();
    MarketplaceSocket.instance.release();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = sl<MarketplaceRepository>();
    final orderResult = await repo.detail(widget.orderId);
    if (!mounted) return;

    if (orderResult.isLeft) {
      setState(() => _loading = false);
      sl<SnackbarService>().showMessage(orderResult.left.errorMessage);
      return;
    }
    final order = orderResult.right;

    var responses = const <OrderResponseEntity>[];
    if (order.status.isOpen) {
      final r = await repo.responses(widget.orderId);
      if (r.isRight) responses = r.right;
    }

    if (!mounted) return;
    setState(() {
      _applyOrder(order);
      _responses = responses;
      _loading = false;
    });

    if (!_reviewAsked &&
        order.status == OrderStatus.completed &&
        !order.hasReview) {
      _reviewAsked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_review());
      });
    }
  }

  Future<void> _choose(OrderResponseEntity response) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ustani tanlash'),
        content: Text(
          '${response.master.displayName} bilan ishlashni tasdiqlaysizmi? '
          'Boshqa ustalar javobi bekor bo\'ladi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tanlash'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final result =
        await sl<MarketplaceRepository>().choose(widget.orderId, response.id);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    await _load();
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buyurtmani bekor qilish'),
        content: const Text('Buyurtma bekor qilinsinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: context.color.categorizedColor.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final result = await sl<MarketplaceRepository>().cancel(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    await _load();
  }

  Future<void> _inviteMore(OrderEntity order) async {
    final picked = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute<List<int>>(
        builder: (_) => MasterPickerPage(
          summary: order.title,
          alreadyInvited: order.invites.map((i) => i.master.id).toSet(),
          actionLabel: 'Taklif qilish',
        ),
      ),
    );
    if (!mounted || picked == null || picked.isEmpty) return;

    setState(() => _busy = true);
    final result = await sl<MarketplaceRepository>().invite(order.id, picked);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    setState(() => _applyOrder(result.right));
  }

  Future<void> _openToEveryone(OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hammaga ochish'),
        content: const Text(
          'E\'lon hududingizdagi barcha ustalarga ko\'rinadi va ular javob '
          'bera oladi. Buni orqaga qaytarib bo\'lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ochish'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final result =
        await sl<MarketplaceRepository>().publishToEveryone(order.id);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    setState(() => _applyOrder(result.right));
  }

  Future<void> _openMasterProfile(OrderResponseEntity r) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => MasterProfilePage(
          masterId: r.master.id,
          onChat: () {
            Navigator.of(ctx).pop();
            _openChat(r.threadId, r.master.displayName);
          },
          onChoose: () {
            Navigator.of(ctx).pop();
            _choose(r);
          },
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _openChat(int? threadId, String title) async {
    if (threadId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          threadId: threadId,
          title: title,
          orderId: widget.orderId,
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _review() async {
    final result = await showModalBottomSheet<({int rating, String comment})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ReviewSheet(),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    final saved = await sl<MarketplaceRepository>().review(
      widget.orderId,
      rating: result.rating,
      comment: result.comment,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved.isLeft) {
      sl<SnackbarService>().showMessage(saved.left.errorMessage);
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final order = _order;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(
        title: const Text('Buyurtma'),

        actions: const [],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Buyurtma topilmadi'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.xxl + context.viewPaddingBottom,
                    ),
                    children: [
                      OrderCard(order: order, showResponses: false),
                      const SizedBox(height: ChizmaSpace.lg),

                      if (_items.isNotEmpty) ...[
                        OrderItemsBlock(items: _items),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.description.isNotEmpty) ...[
                        ChizmaEyebrow('Shartlaringiz'),
                        const SizedBox(height: ChizmaSpace.sm),
                        ChizmaSheet(
                          child: Text(
                            order.description,
                            style: context.text.body4
                                .copyWith(color: colors.neutral.textBody),
                          ),
                        ),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.status.isOpen && order.invites.isNotEmpty) ...[
                        InvitedMastersBlock(
                          order: order,
                          busy: _busy,
                          onInviteMore: () => _inviteMore(order),
                          onOpenToEveryone: order.isDirect
                              ? () => _openToEveryone(order)
                              : null,
                          onProfile: (masterId) => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  MasterProfilePage(masterId: masterId),
                            ),
                          ),
                        ),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.status.isOpen) ...[
                        ChizmaSectionHeader(
                          title: 'Javob bergan ustalar (${_responses.length})',
                        ),
                        const SizedBox(height: ChizmaSpace.md),
                        if (_responses.isEmpty)
                          WaitingForMasters(order: order)
                        else
                          for (final r in _responses) ...[
                            MasterResponseCard(
                              response: r,
                              standardTotal: order.calculatedPrice,
                              onProfile: () => _openMasterProfile(r),
                              onChat: () =>
                                  _openChat(r.threadId, r.master.displayName),
                              onChoose: _busy ? null : () => _choose(r),
                            ),
                            const SizedBox(height: ChizmaSpace.md),
                          ],
                      ],

                      if (!order.status.isFinished) ...[
                        _CancelBlock(
                          isOpen: order.status.isOpen,
                          busy: _busy,
                          onCancel: _cancel,
                        ),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.assignedMaster != null) ...[
                        ChizmaEyebrow('Tanlangan usta'),
                        const SizedBox(height: ChizmaSpace.sm),
                        _AssignedMasterCard(
                          order: order,
                          onChat: () async {
                            final threads = await sl<MarketplaceRepository>()
                                .threads(orderId: order.id);
                            if (!mounted || threads.isLeft) return;
                            final mine = threads.right.where(
                              (t) => t.peer.id == order.assignedMaster!.id,
                            );
                            if (mine.isNotEmpty) {
                              _openChat(mine.first.id,
                                  order.assignedMaster!.displayName);
                            }
                          },
                        ),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.stageEvents.isNotEmpty) ...[
                        ChizmaEyebrow('Ish jarayoni'),
                        const SizedBox(height: ChizmaSpace.sm),
                        _StageTimeline(order: order),
                        const SizedBox(height: ChizmaSpace.lg),
                      ],

                      if (order.status == OrderStatus.completed) ...[
                        if (order.hasReview)
                          _ReviewCard(review: order.review!)
                        else
                          ElevatedButton.icon(
                            onPressed: _busy ? null : _review,
                            icon: const Icon(Icons.star_outline_rounded),
                            label: const Text('Ustaga baho berish'),
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _AssignedMasterCard extends StatelessWidget {
  const _AssignedMasterCard({required this.order, this.onChat});

  final OrderEntity order;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final master = order.assignedMaster!;
    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.neutral.surface2,
                backgroundImage:
                    master.photo != null ? NetworkImage(master.photo!) : null,
                child: master.photo == null
                    ? Icon(Icons.person_outline,
                        color: colors.neutral.textMuted)
                    : null,
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      master.displayName,
                      style: context.text.h4
                          .copyWith(color: colors.neutral.textStrong),
                    ),
                    if (master.phoneNumber.isNotEmpty)
                      Text(
                        master.phoneNumber,
                        style: context.text.body5.copyWith(
                          color: colors.categorizedColor.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              // Raqamni ko'chirib yurmasin — bosilsa telefon ilovasi ochiladi.
              if (master.phoneNumber.isNotEmpty)
                _CallButton(phone: master.phoneNumber),
            ],
          ),

          if (onChat != null) ...[
            const SizedBox(height: ChizmaSpace.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Xabar yozish'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StageTimeline extends StatelessWidget {
  const _StageTimeline({required this.order});
  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final stage in order.activeStages) ...[
            () {
              final stageIdx = order.activeStages.indexOf(stage) + 1;
              final done = order.effectiveStageStep > stageIdx ||
                  (order.status == OrderStatus.completed);
              final current = order.stage == stage &&
                  order.status != OrderStatus.completed;
              final event = order.stageEvents
                  .where((e) => e.stage == stage)
                  .firstOrNull;
              final stageLabel = (!order.isRom && stage == OrderStage.installation)
                  ? 'Bajarilmoqda'
                  : stage.label;
              return Padding(
                padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : current
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: done
                          ? colors.categorizedColor.success
                          : current
                              ? colors.categorizedColor.primary
                              : colors.neutral.border,
                    ),
                    const SizedBox(width: ChizmaSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stageLabel,
                            style: context.text.body4.copyWith(
                              color: done || current
                                  ? colors.neutral.textStrong
                                  : colors.neutral.textMuted,
                              fontWeight: current ? FontWeight.w600 : null,
                            ),
                          ),
                          if (event?.note.isNotEmpty ?? false)
                            Text(
                              event!.note,
                              style: context.text.body5
                                  .copyWith(color: colors.neutral.textMuted),
                            ),
                        ],
                      ),
                    ),
                    if (event?.createdAt != null)
                      Text(
                        event!.createdAt!.formatDate,
                        style: context.text.label
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                  ],
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 22,
                  color: colors.categorizedColor.accent,
                ),
              const SizedBox(width: ChizmaSpace.sm),
              Text('Sizning bahoyingiz', style: context.text.body5),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              review.comment,
              style: context.text.body4.copyWith(color: colors.neutral.textBody),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet();

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: EdgeInsets.only(
        left: ChizmaSpace.lg,
        right: ChizmaSpace.lg,
        top: ChizmaSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + ChizmaSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ustaga baho bering',
            style: context.text.h3.copyWith(color: colors.neutral.textStrong),
          ),
          const SizedBox(height: ChizmaSpace.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: colors.categorizedColor.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.md),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: uz('Izoh (ixtiyoriy)'),
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(
              (rating: _rating, comment: _commentCtrl.text.trim()),
            ),
            child: const Text('Yuborish'),
          ),
        ],
      ),
    );
  }
}

class _CancelBlock extends StatelessWidget {
  const _CancelBlock({
    required this.isOpen,
    required this.busy,
    required this.onCancel,
  });

  final bool isOpen;
  final bool busy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final error = colors.categorizedColor.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : onCancel,
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('Buyurtmani bekor qilish'),
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
          ),
        ),
        const SizedBox(height: ChizmaSpace.sm),
        Text(
          isOpen
              ? 'E\'lon olib tashlanadi va ustalarga ko\'rinmay qoladi. '
                  'Keyin yana hisoblab, qaytadan e\'lon berishingiz mumkin.'
              : 'Usta allaqachon ishni boshlagan bo\'lishi mumkin — bekor '
                  'qilishdan oldin u bilan chatda gaplashib oling.',
          style: context.text.label.copyWith(color: colors.neutral.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


/// Ustaga QO\'NG\'IROQ qilish tugmasi.
class _CallButton extends StatelessWidget {
  const _CallButton({required this.phone});

  final String phone;

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    try {
      final opened = await launchUrl(uri);
      if (!opened) sl<SnackbarService>().showMessage(phone);
    } catch (_) {
      sl<SnackbarService>().showMessage(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Material(
      color: colors.categorizedColor.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _call,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              Icon(Icons.call_rounded, size: 20, color: colors.neutral.white),
        ),
      ),
    );
  }
}
