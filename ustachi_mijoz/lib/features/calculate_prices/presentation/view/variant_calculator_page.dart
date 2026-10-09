import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/piece_size.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class VariantCalculatorPage extends StatefulWidget {
  const VariantCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<VariantCalculatorPage> createState() => _VariantCalculatorPageState();
}

class _VariantCalculatorPageState extends State<VariantCalculatorPage> {

  final List<_PieceInput> _inputs = [_PieceInput()];

  bool get _isTile => widget.specialty.variantPriceIsMaterial;

  SizeUnit get _unit => _isTile ? SizeUnit.m : SizeUnit.mm;

  String get _noun => _isTile ? 'yuza' : 'eshik';

  late SpecialtyVariant _selected = widget.specialty.variants.first;

  @override
  void dispose() {
    for (final p in _inputs) {
      p.dispose();
    }
    super.dispose();
  }

  List<PieceSize>? get _pieces {
    final sizes = [for (final p in _inputs) p.sizeIn(_unit)];
    return sizes.every((s) => s != null) ? sizes.cast<PieceSize>() : null;
  }

  double? get _area {
    final pieces = _pieces;
    return pieces == null ? null : PieceSize.totalArea(pieces);
  }

  int? get _total => _totalFor(_selected);

  int? _totalFor(SpecialtyVariant variant) {
    final pieces = _pieces;
    return pieces == null
        ? null
        : PieceSize.totalPrice(pieces, variant.pricePerM2);
  }

  void _addPiece() => setState(() => _inputs.add(_PieceInput()));

  void _removePiece(int index) =>
      setState(() => _inputs.removeAt(index).dispose());

  static String _areaLabel(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
  }

  Future<void> _goNext() async {
    final total = _total;
    if (total == null) return;

    final navigator = Navigator.of(context);
    final area = _area!;
    final pieces = _pieces!;
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: total,

          proposal: {
            'calculator': 'variant',
            'variant': _selected.name,
            if (_selected.note.isNotEmpty) 'variant_note': _selected.note,

            'area_m2': area,
            'unit': 'm²',
            'unit_price': _selected.pricePerM2.round(),
            'total_price': total,

            if (_isTile) ...{
              'surface_count': pieces.length,
              'surfaces': [for (final p in pieces) p.toJson()],
            } else ...{
              'door_count': pieces.length,
              'doors': [for (final p in pieces) p.toJson()],
            },
          },
          summary: [
            _selected.name,
            '${pieces.length} ta $_noun',
            '${_areaLabel(area)} m²',
            '${formatSom(total.toDouble())} so\'m',
          ].join(' · '),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final total = _total;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(widget.specialty.workName)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.lg,
          ChizmaSpace.lg,
          ChizmaSpace.xxl + context.viewPaddingBottom,
        ),
        children: [

          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SpecialtyVisuals.thumb(
                      context,
                      code: widget.specialty.code,
                      size: 32,
                      tint: colors.categorizedColor.primary,
                    ),
                    const SizedBox(width: ChizmaSpace.md),
                    Expanded(
                      child: Text(
                        _isTile
                            ? 'Kafel yotqiziladigan yuza'
                            : 'Eshik o\'lchami',
                        style: context.text.h4
                            .copyWith(color: colors.neutral.textStrong),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isTile
                      ? 'Har yuzaning (pol, devor) bo\'yi va enini metrda '
                          'yozing. Aniq bilmasangiz taxminan yozing — '
                          'usta o\'lchovga kelganda aniqlashtiriladi.'
                      : 'Har eshikning bo\'yi va enini millimetrda '
                          'yozing. Aniq bilmasangiz taxminan yozing — '
                          'usta o\'lchovga kelganda aniqlashtiriladi.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.lg),

                for (var i = 0; i < _inputs.length; i++) ...[
                  if (i > 0) const SizedBox(height: ChizmaSpace.md),
                  _PieceFields(

                    key: ObjectKey(_inputs[i]),
                    title: '${i + 1}-$_noun',
                    input: _inputs[i],
                    unit: _unit,
                    autofocus: i == _inputs.length - 1,
                    areaLabel: switch (_inputs[i].sizeIn(_unit)) {
                      final size? => _areaLabel(size.areaM2),
                      null => null,
                    },
                    onChanged: () => setState(() {}),
                    onRemove:
                        _inputs.length > 1 ? () => _removePiece(i) : null,
                  ),
                ],
                const SizedBox(height: ChizmaSpace.md),
                OutlinedButton.icon(
                  onPressed: _addPiece,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Yana $_noun qo\'shish'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          ChizmaEyebrow(
            widget.specialty.variantPriceIsMaterial
                ? 'Qaysi kafel?'
                : 'Qaysi darajada?',
          ),
          const SizedBox(height: ChizmaSpace.sm),
          for (final variant in widget.specialty.variants) ...[
            _VariantCard(
              variant: variant,
              selected: variant == _selected,

              total: _totalFor(variant),
              onTap: () => setState(() => _selected = variant),
            ),
            const SizedBox(height: ChizmaSpace.sm),
          ],
          const SizedBox(height: ChizmaSpace.md),

          if (total != null) ...[
            _TotalSheet(
              variant: _selected,
              areaLabel: _areaLabel(_area!),
              countLabel: _isTile ? 'Yuzalar soni' : 'Eshiklar soni',
              count: _inputs.length,
              total: total,
              isMaterial: widget.specialty.variantPriceIsMaterial,
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ],

          ElevatedButton.icon(
            onPressed: total == null ? null : _goNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Keyingi'),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Text(
            widget.specialty.variantPriceIsMaterial

                ? 'Bu — faqat materialning narxi. Usta ish haqini o\'zi '
                    'belgilaydi: javob berganda har bir ustaning jami '
                    'summasini ko\'rasiz va solishtirasiz.'
                : 'Ko\'rsatilgan summa — mo\'ljal. Usta o\'lchovga kelib aniq '
                    'narxni aytadi; o\'rnatish va furnitura alohida '
                    'kelishiladi.',
            textAlign: TextAlign.center,
            style: context.text.body4.copyWith(color: colors.neutral.textMuted),
          ),
          if (total != null) const PriceEstimateNotice(),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.selected,
    required this.total,
    required this.onTap,
  });

  final SpecialtyVariant variant;
  final bool selected;
  final int? total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;

    return ChizmaSheet(
      onTap: onTap,
      borderColor: selected ? primary : null,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: selected ? primary : colors.neutral.borderStrong,
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variant.name,
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (variant.size.isNotEmpty || variant.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (variant.size.isNotEmpty) variant.size,
                      if (variant.note.isNotEmpty) variant.note,
                    ].join(' · '),
                    style: context.text.body5
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '${formatSom(variant.pricePerM2)} so\'m/m²',
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
          if (total != null) ...[
            const SizedBox(width: ChizmaSpace.sm),
            Text(
              '${formatSom(total!.toDouble())} so\'m',
              style: context.text.body4.copyWith(
                color: selected ? primary : colors.neutral.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalSheet extends StatelessWidget {
  const _TotalSheet({
    required this.variant,
    required this.areaLabel,
    required this.countLabel,
    required this.count,
    required this.total,
    required this.isMaterial,
  });

  final SpecialtyVariant variant;
  final String areaLabel;

  final String countLabel;
  final int count;
  final int total;

  final bool isMaterial;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    Widget row(String label, String value) => Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
            ),
            Text(
              value,
              style: context.text.body5.copyWith(
                color: colors.neutral.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row(isMaterial ? 'Kafel' : 'Daraja', variant.name),
          if (variant.size.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.sm),
            row('O\'lchami', variant.size),
          ],
          const SizedBox(height: ChizmaSpace.sm),
          row(countLabel, '$count ta'),
          const SizedBox(height: ChizmaSpace.sm),
          row('Jami maydon', '$areaLabel m²'),
          const SizedBox(height: ChizmaSpace.sm),
          row(
            isMaterial ? 'Material, 1 m²' : '1 m² narxi',
            '${formatSom(variant.pricePerM2)} so\'m',
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Divider(height: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(

                  isMaterial ? 'Material uchun' : 'Jami',
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${formatSom(total.toDouble())} so\'m',
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

class _PieceInput {
  final heightCtrl = TextEditingController();
  final widthCtrl = TextEditingController();

  PieceSize? sizeIn(SizeUnit unit) {
    final h = unit.parseMm(heightCtrl.text);
    final w = unit.parseMm(widthCtrl.text);
    if (h == null || w == null) return null;
    return PieceSize(heightMm: h, widthMm: w);
  }

  void dispose() {
    heightCtrl.dispose();
    widthCtrl.dispose();
  }
}

class _PieceFields extends StatelessWidget {
  const _PieceFields({
    super.key,
    required this.title,
    required this.input,
    required this.unit,
    required this.autofocus,
    required this.areaLabel,
    required this.onChanged,
    required this.onRemove,
  });

  final String title;
  final _PieceInput input;
  final SizeUnit unit;
  final bool autofocus;

  final String? areaLabel;
  final VoidCallback onChanged;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final inMetres = unit == SizeUnit.m;

    Widget field(String label, TextEditingController ctrl, bool focus) =>
        Expanded(
          child: TextField(
            controller: ctrl,
            autofocus: focus,

            keyboardType: inMetres
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: [
              inMetres
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  : FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(inMetres ? 6 : 5),
            ],
            onChanged: (_) => onChanged(),
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            decoration: InputDecoration(
              labelText: uz(label),
              suffixText: uz(unit.label),
              suffixStyle:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.text.body4.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                tooltip: uz('O\'chirish'),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: colors.neutral.textMuted,
                ),
              ),
          ],
        ),
        const SizedBox(height: ChizmaSpace.sm),
        Row(
          children: [
            field('Bo\'yi', input.heightCtrl, autofocus),
            const SizedBox(width: ChizmaSpace.md),
            field('Eni', input.widthCtrl, false),
          ],
        ),
        if (areaLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            '$areaLabel m²',
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
        ],
      ],
    );
  }
}
