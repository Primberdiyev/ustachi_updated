import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_naming.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/dimension_edit_sheet.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/frame_drawing_viewer.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart';
import 'package:ustachi/features/marketplace/domain/order_draft.dart';

class ProposalDetailPage extends StatefulWidget {
  const ProposalDetailPage({
    super.key,
    required this.option,
    required this.request,
    this.onCheckout,
  });

  final ProposalOption option;
  final ProposalRequest request;

  final VoidCallback? onCheckout;

  @override
  State<ProposalDetailPage> createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage> {
  int _qty = 1;

  late ProposalOption _option = widget.option;
  late ProposalRequest _request = widget.request;

  String? _basketId;

  void _syncBasket() {
    final store = sl<OrderDraftStore>();
    final id = _basketId;
    if (id != null) {
      store.setQty(id, _qty);
      return;
    }
    setState(() {
      _basketId = store.add(option: _option, request: _request, qty: _qty);
    });
  }

  Color? get _frameColor => _request.isWhite ? null : Color(_request.colorArgb);

  void _checkout() {
    _syncBasket();
    widget.onCheckout?.call();
  }

  Future<FramePreviewSpec?> _editDimension(FrameDimensionTarget target) async {
    final result = await DimensionEditSheet.show(
      context,
      target: target,
      request: _request,
      option: _option,
    );
    if (result == null || !mounted) return null;
    _apply(result);
    return _option.spec;
  }

  void _openViewer() => FrameDrawingViewer.open(
        context,
        spec: _option.spec,
        title: proposalOptionTitle(_request, _option.spec),
        heroTag: proposalDrawingHeroTag(_option),
        frameTint: _frameColor,
        showSill: _request.hasSill,
        onEditDimension: _editDimension,
      );

  void _apply(ProposalEditResult result) {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _option = result.option;
      _request = result.request;

      final id = _basketId;
      if (id != null) {
        final store = sl<OrderDraftStore>()..remove(id);
        _basketId = store.add(option: _option, request: _request, qty: _qty);
      }
    });
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('O\'lcham o\'zgartirildi'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final o = _option;
    final r = _request;
    final title = proposalOptionTitle(r, o.spec);

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(
        title: const Text('Rom tafsiloti'),
      ),

      bottomNavigationBar: _CheckoutBar(
        qty: _qty,
        onQty: (v) {
          setState(() => _qty = v);

          final id = _basketId;
          if (id != null) sl<OrderDraftStore>().setQty(id, v);
        },
        onContinue: _checkout,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.md, ChizmaSpace.lg, ChizmaSpace.xxl),
        children: [

          GestureDetector(
            onTap: _openViewer,
            child: Stack(
              children: [
                DrawingStage(
                  height: 320,
                  borderRadius: BorderRadius.circular(24),
                  topLeft: [_StageLabel(r.shape.title)],
                  child: Hero(
                    tag: proposalDrawingHeroTag(o),
                    child: FrameDrawing(
                      spec: o.spec,
                      frameTint: _frameColor,
                      showDimensions: true,
                      showSill: r.hasSill,
                      onDimensionTap: _editDimension,
                      onTap: _openViewer,
                    ),
                  ),
                ),
                Positioned(
                  right: ChizmaSpace.sm,
                  bottom: ChizmaSpace.sm,
                  child: _RoundIcon(icon: Icons.zoom_out_map_rounded, color: colors.neutral.textBody),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 15, color: colors.categorizedColor.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Ko\'k o\'lcham ustiga bosib o\'zgartiring',
                  style: context.text.label.copyWith(color: colors.neutral.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.lg),

          Text(title, style: context.text.h3.copyWith(color: colors.neutral.textStrong)),
          const SizedBox(height: 4),
          Text(
            [o.title, if (o.subtitle.isNotEmpty) o.subtitle].join(' · '),
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
          const SizedBox(height: ChizmaSpace.md),
          _Composition(option: o),
          const SizedBox(height: ChizmaSpace.lg),

          _SpecGrid(request: r),
          const SizedBox(height: ChizmaSpace.lg),

          const _NoPriceNote(),
        ],
      ),
    );
  }
}

class _NoPriceNote extends StatelessWidget {
  const _NoPriceNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.lg),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: primary),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Text(
              'Narxni usta aytadi. Buyurtma chizma va o\'lchamlar bilan '
              'ustalarga yuboriladi — oyna turi va narxni chatda kelishasiz.',
              style: context.text.body5.copyWith(color: colors.neutral.textBody),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: context.color.neutral.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      );
}

class _Composition extends StatelessWidget {
  const _Composition({required this.option});

  final ProposalOption option;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final w = (option.spec.widthMm ?? 1500).toDouble();
    final h = (option.spec.heightMm ?? 1500).toDouble();
    final parts = frameComposition(frameDrawingPlacements(option.spec, w, h));
    if (parts.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: ChizmaSpace.xs + 2,
      runSpacing: ChizmaSpace.xs + 2,
      children: [
        for (final p in parts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm + 2, vertical: 5),
            decoration: BoxDecoration(
              color: colors.categorizedColor.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(ChizmaRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.contains('qo\'zg\'almas') || p.contains('panel')
                      ? Icons.crop_square_rounded
                      : Icons.open_in_full_rounded,
                  size: 14,
                  color: colors.categorizedColor.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  p,
                  style: context.text.label.copyWith(color: colors.neutral.textBody, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: colors.neutral.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      ),
      child: Text(
        text,
        style: context.text.label.copyWith(
          color: colors.neutral.textBody,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.request});

  final ProposalRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final sillApplies = r.type != ProposalType.door || r.floorGapMm > 0;
    final tiles = <(IconData, String, String)>[
      (Icons.straighten_rounded, 'O\'lcham', '${r.widthMm} × ${r.heightMm} mm'),
      (Icons.layers_outlined, 'Material', proposalMaterialLabel(r.material)),
      if (sillApplies) (Icons.table_rows_outlined, 'Tokcha', r.hasSill ? '${r.sillWidthCm} sm' : 'Yo\'q'),
      (Icons.palette_outlined, 'Rang', r.colorLabel),
      if (r.floorGapMm > 0) (Icons.height_rounded, 'Derazadan yergacha', '${r.floorGapMm} mm'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - ChizmaSpace.sm) / 2;
        return Wrap(
          spacing: ChizmaSpace.sm,
          runSpacing: ChizmaSpace.sm,
          children: [
            for (final (icon, label, value) in tiles)
              SizedBox(
                width: width,
                child: _SpecTile(
                  icon: icon,
                  label: label,
                  value: value,
                  swatch: label == 'Rang' && !r.isWhite ? Color(r.colorArgb) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.icon, required this.label, required this.value, this.swatch});

  final IconData icon;
  final String label;
  final String value;
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Material(
      color: colors.neutral.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.categorizedColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: colors.categorizedColor.primary),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: context.text.label.copyWith(color: colors.neutral.textMuted)),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (swatch != null) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: swatch,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.neutral.border),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            value,
                            style: context.text.body5.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.qty,
    required this.onQty,
    required this.onContinue,
  });

  final int qty;
  final ValueChanged<int> onQty;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.md, ChizmaSpace.lg, ChizmaSpace.md),
        child: Row(
          children: [
            QtyStepper(value: qty, onChanged: onQty),
            const SizedBox(width: ChizmaSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    qty > 1 ? '$qty dona' : '1 dona',
                    style: context.text.label.copyWith(color: colors.neutral.textMuted),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Narxni usta aytadi',
                      style: context.text.body4.copyWith(
                        color: colors.categorizedColor.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg, vertical: ChizmaSpace.md),
                minimumSize: Size.zero,
              ),
              child: const Text('Davom etish'),
            ),
          ],
        ),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: context.text.body4.copyWith(
                color: colors.neutral.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(ChizmaSpace.sm),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.neutral.textStrong : colors.neutral.border,
        ),
      ),
    );
  }
}
