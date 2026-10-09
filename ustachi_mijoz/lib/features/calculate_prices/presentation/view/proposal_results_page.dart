import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_generator.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_exit_dialog.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_naming.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/order_draft.dart';
import 'package:ustachi/features/marketplace/presentation/view/create_order_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/proposal_detail_page.dart';

class ProposalResultsPage extends StatelessWidget {
  const ProposalResultsPage({super.key, required this.request});

  final ProposalRequest request;

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await ProposalExitDialog.show(
          context,
          basketCount: sl<OrderDraftStore>().value.productCount,
        );
        if (shouldExit && context.mounted) {
          sl<OrderDraftStore>().clear();
          clearProposalFlow(Navigator.of(context));
        }
      },
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final options = const ProposalGenerator().generate(request);
    return Scaffold(
      backgroundColor: context.color.neutral.black7,
      appBar: AppBar(
        title: const Text('Variantlar'),
      ),
      bottomNavigationBar: _BasketBar(
        onCheckout: () => _checkout(context),
      ),
      body: options.isEmpty
          ? _EmptyState(request: request)
          : _ProposalList(
              options: options,
              request: request,
              frameColor: request.isWhite ? null : Color(request.colorArgb),
              onOpen: (option) => _openDetail(context, option),
            ),
    );
  }

  Future<void> _openDetail(BuildContext context, ProposalOption option) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(

        settings: const RouteSettings(name: proposalDetailRouteName),
        builder: (pageContext) => ProposalDetailPage(
          option: option,
          request: request,

          onCheckout: () => _checkout(pageContext),
        ),
      ),
    );
  }

  void _restartWizard(BuildContext context) {
    context.pushRouteSafe(const ProposalWizardPageRoute());
  }

  Future<void> _checkout(BuildContext context) async {

    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        settings: const RouteSettings(name: proposalBasketRouteName),

        builder: (pageContext) => CreateOrderPage(
          onAddMore: () => _restartWizard(pageContext),
        ),
      ),
    );
    if (created == null) return;

    clearProposalFlow(navigator);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: created.id),
      ),
    );
  }
}

enum _OpeningFilter {
  all('Hammasi'),
  fixed('Qo\'zg\'almas'),
  one('1 ta ochiladi'),
  many('2+ ochiladi');

  const _OpeningFilter(this.label);
  final String label;

  bool accepts(int openings) => switch (this) {
        all => true,
        fixed => openings == 0,
        one => openings == 1,
        many => openings >= 2,
      };
}

class _ProposalList extends StatefulWidget {
  const _ProposalList({
    required this.options,
    required this.request,
    required this.frameColor,
    required this.onOpen,
  });

  final List<ProposalOption> options;
  final ProposalRequest request;
  final Color? frameColor;
  final ValueChanged<ProposalOption> onOpen;

  @override
  State<_ProposalList> createState() => _ProposalListState();
}

class _ProposalListState extends State<_ProposalList> {
  var _filter = _OpeningFilter.all;

  late List<int> _openings = _count(widget.options);

  @override
  void didUpdateWidget(covariant _ProposalList old) {
    super.didUpdateWidget(old);
    if (!identical(old.options, widget.options)) _openings = _count(widget.options);
  }

  static List<int> _count(List<ProposalOption> options) => [
        for (final o in options)
          frameWingCount(frameDrawingPlacements(
            o.spec,
            (o.spec.widthMm ?? 1500).toDouble(),
            (o.spec.heightMm ?? 1500).toDouble(),
          )),
      ];

  @override
  Widget build(BuildContext context) {
    final filters = [
      for (final f in _OpeningFilter.values)
        if (f == _OpeningFilter.all || _openings.any(f.accepts)) f,
    ];
    final visible = [
      for (var i = 0; i < widget.options.length; i++)
        if (_filter.accepts(_openings[i])) widget.options[i],
    ];

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        ChizmaSpace.lg,
        ChizmaSpace.md,
        ChizmaSpace.lg,
        ChizmaSpace.xxl + context.viewPaddingBottom,
      ),
      itemCount: visible.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.md),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _Header(
            count: widget.options.length,
            filters: filters.length > 2 ? filters : const [],
            filter: _filter,
            onFilter: (f) => setState(() => _filter = f),
          );
        }
        final option = visible[i - 1];
        return ProposalOptionCard(
          option: option,
          frameColor: widget.frameColor,
          showSill: widget.request.hasSill,

          titleOverride: proposalOptionTitle(widget.request, option.spec),
          onDetails: () => widget.onOpen(option),
          onTap: () => widget.onOpen(option),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.filters,
    required this.filter,
    required this.onFilter,
  });

  final int count;
  final List<_OpeningFilter> filters;
  final _OpeningFilter filter;
  final ValueChanged<_OpeningFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count ta variant topildi',
          style: context.text.h3.copyWith(color: colors.neutral.textStrong),
        ),
        const SizedBox(height: 2),
        Text(
          'O\'zingizga mos shaklni tanlang · narxni usta aytadi',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        if (filters.isNotEmpty) ...[
          const SizedBox(height: ChizmaSpace.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in filters) ...[
                  if (f != filters.first) const SizedBox(width: ChizmaSpace.xs + 2),
                  ChoiceChip(
                    label: Text(f.label),
                    selected: f == filter,
                    onSelected: (_) => onFilter(f),
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.request});
  final ProposalRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChizmaSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: colors.neutral.textMuted),
            const SizedBox(height: ChizmaSpace.md),
            Text(
              'Bu o\'lcham uchun tayyor variant topilmadi',
              style: context.text.h4.copyWith(color: colors.neutral.textStrong),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              'O\'lchamni (${request.widthMm}×${request.heightMm} mm) o\'zgartirib ko\'ring.',
              style: context.text.body5.copyWith(color: colors.neutral.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ChizmaSpace.lg),
            ElevatedButton(
              onPressed: () => context.maybePopSafe(),
              child: const Text('O\'zgartirish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketBar extends StatelessWidget {
  const _BasketBar({required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ValueListenableBuilder<ClientOrderDraft>(
      valueListenable: sl<OrderDraftStore>(),
      builder: (context, draft, _) {
        if (draft.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.md),
          child: Material(
            color: colors.neutral.surface,
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.12),

            child: InkWell(
              onTap: onCheckout,
              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(ChizmaSpace.md),
                child: Row(
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 20, color: colors.categorizedColor.primary),
                    const SizedBox(width: ChizmaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${draft.productCount} ta rom tanlandi',
                            style: context.text.body5.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Narxni usta aytadi · ko\'rish uchun bosing',
                            style: context.text.label.copyWith(color: colors.neutral.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg, vertical: ChizmaSpace.sm + 2),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Usta bilan bog\'lanish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
