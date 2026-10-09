import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart'
    show proposalMaterialLabel;
import 'package:ustachi/features/marketplace/domain/order_draft.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_picker_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/proposal_detail_page.dart'
    show QtyStepper;

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key, this.onAddMore});

  final VoidCallback? onAddMore;

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _sending = false;

  OrderDraftStore get _store => sl<OrderDraftStore>();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMasters(ClientOrderDraft draft) async {
    FocusScope.of(context).unfocus();
    final picked = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute<List<int>>(
        builder: (_) => MasterPickerPage(
          summary: '${draft.kinds} xil · ${draft.productCount} dona · '
              'narxni usta aytadi',
          actionLabel: 'Yuborish',
        ),
      ),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    await _publish(draft, masterIds: picked);
  }

  Future<void> _publish(
    ClientOrderDraft draft, {
    List<int> masterIds = const [],
  }) async {
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);

    final result = await sl<MarketplaceRepository>().create({

      'title': draft.title,
      'description': _notesCtrl.text.trim(),
      'proposal': draft.toProposalJson(),
      'calculated_price': 0,
      'address': _addressCtrl.text.trim(),
      if (masterIds.isNotEmpty) 'master_ids': masterIds,
    });

    if (!mounted) return;
    setState(() => _sending = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }

    if (!inviteHonored(result.right, masterIds)) {
      sl<SnackbarService>().showMessage(
        'Tanlangan usta biriktirilmadi — buyurtma ochiq e\'lon bo\'lib '
        'joylandi. Buyurtma sahifasidan qayta taklif qilishingiz mumkin.',
      );
    }

    _store.clear();
    if (!mounted) return;
    Navigator.of(context).pop<OrderEntity>(result.right);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: const Text('Usta bilan bog\'lanish')),
      body: ValueListenableBuilder<ClientOrderDraft>(
        valueListenable: _store,
        builder: (context, draft, _) {
          if (draft.isEmpty) return const _EmptyBasket();

          return ListView(
            padding: EdgeInsets.fromLTRB(
              ChizmaSpace.lg,
              ChizmaSpace.lg,
              ChizmaSpace.lg,
              ChizmaSpace.xxl + context.viewPaddingBottom,
            ),
            children: [
              ChizmaEyebrow('Romlar (${draft.productCount} dona)'),
              const SizedBox(height: ChizmaSpace.sm),
              for (final item in draft.items) ...[
                _DraftItemCard(
                  item: item,
                  onQty: (v) => _store.setQty(item.localId, v),
                  onRemove:
                      draft.kinds > 1 ? () => _store.remove(item.localId) : null,
                ),
                const SizedBox(height: ChizmaSpace.sm),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  if (widget.onAddMore != null) {
                    widget.onAddMore!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Yana rom qo\'shish'),
              ),
              const SizedBox(height: ChizmaSpace.lg),

              _TotalSheet(draft: draft),
              const SizedBox(height: ChizmaSpace.lg),

              ChizmaEyebrow('Manzil'),
              const SizedBox(height: ChizmaSpace.sm),
              TextField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  hintText: uz('Ko\'cha, uy, xonadon'),
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: ChizmaSpace.lg),

              ChizmaEyebrow('Shartlaringiz'),
              const SizedBox(height: ChizmaSpace.sm),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: uz(
                      'Masalan: 2-qavat, lift yo\'q. Dam olish kunlari qulay.'),
                ),
              ),
              const SizedBox(height: ChizmaSpace.xl),

              ChizmaEyebrow('Kimga yuboramiz?'),
              const SizedBox(height: ChizmaSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sending ? null : () => _publish(draft),
                      child: _sending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Usta qidirish'),
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending ? null : () => _pickMasters(draft),
                      child: const Text('Usta tanlash'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ChizmaSpace.md),
              _WayHint(
                icon: Icons.campaign_outlined,
                title: 'Usta qidirish',
                text: 'E\'lon hududingizdagi hamma ustaga boradi. Javob '
                    'berganlaridan o\'zingiz birini tanlaysiz.',
              ),
              const SizedBox(height: ChizmaSpace.sm),
              _WayHint(
                icon: Icons.person_search_outlined,
                title: 'Usta tanlash',
                text: 'Ro\'yxatdan ustani o\'zingiz tanlaysiz — buyurtma faqat '
                    'unga boradi. Javob bermasa, keyin hammaga ochasiz.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WayHint extends StatelessWidget {
  const _WayHint({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: colors.neutral.textMuted),
        ),
        const SizedBox(width: ChizmaSpace.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title — ',
                  style: context.text.body5.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}

class _DraftItemCard extends StatelessWidget {
  const _DraftItemCard({
    required this.item,
    required this.onQty,
    this.onRemove,
  });

  final ClientDraftItem item;
  final ValueChanged<int> onQty;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final frame =
        item.request.isWhite ? null : Color(item.request.colorArgb);

    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: frameDrawingTileColor(context),
                  borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                  border: Border.all(color: colors.neutral.border),
                ),
                child: FrameDrawing(
                  spec: item.option.spec,
                  frameTint: frame,
                ),
              ),
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
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.sizeLabel} · ${proposalMaterialLabel(item.request.material)}',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: uz('O\'chirish'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              QtyStepper(value: item.qty, onChanged: onQty),
              const Spacer(),
              Text(
                '${item.qty} dona',
                style: context.text.body4.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalSheet extends StatelessWidget {
  const _TotalSheet({required this.draft});

  final ClientOrderDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${draft.kinds} xil · ${draft.productCount} dona',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Narx',
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Usta aytadi',
                style: context.text.h4.copyWith(
                  color: colors.categorizedColor.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChizmaSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_basket_outlined,
                size: 44, color: colors.neutral.textMuted),
            const SizedBox(height: ChizmaSpace.md),
            Text(
              'Savat bo\'sh',
              style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            ),
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              'Avval rom tanlang — variantlardan birini ochib "Davom etish" '
              'tugmasini bosing.',
              textAlign: TextAlign.center,
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
