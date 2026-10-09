import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/services/area_price_calculator.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class AreaCalculatorPage extends StatefulWidget {
  const AreaCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<AreaCalculatorPage> createState() => _AreaCalculatorPageState();
}

class _AreaCalculatorPageState extends State<AreaCalculatorPage> {
  final _areaCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  bool get _isPenthouse => widget.specialty.code == 'penthaus_gidro_tom';

  double? _area;

  @override
  void dispose() {
    _areaCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    super.dispose();
  }

  void _onAreaChanged(String raw) {
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    setState(() => _area = (parsed != null && parsed > 0) ? parsed : null);
  }

  SpecialtyEntity get _s => widget.specialty;

  void _onDimensionsChanged(String _) {
    double? parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
    final length = parse(_lengthCtrl.text);
    final width = parse(_widthCtrl.text);
    setState(() => _area = length != null &&
            width != null &&
            length.isFinite &&
            width.isFinite &&
            length > 0 &&
            width > 0 &&
            length <= 1000 &&
            width <= 1000
        ? length * width
        : null);
  }

  Widget _dimensionField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                label,
                style: context.text.body3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.color.neutral.textStrong,
                ),
              ),
            ),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(8),
              ],
              onChanged: _onDimensionsChanged,
              style: context.text.body2.copyWith(
                color: context.color.neutral.textStrong,
              ),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: uz('m'),
                suffixStyle: context.text.body3.copyWith(
                  color: context.color.neutral.textMuted,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      );

  String get _unit => _s.isPerMetre ? 'm' : 'm²';

  bool get _isMaterial => _s.variantPriceIsMaterial;

  AreaPrice? get _price => _area == null
      ? null
      : AreaPriceCalculator.calculate(widget.specialty.areaTiers, _area!);

  Future<void> _goNext() async {
    final price = _price;
    if (price == null) return;

    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: price.total,

          proposal: {
            if (_isPenthouse) ...{
              'length_m':
                  double.parse(_lengthCtrl.text.trim().replaceAll(',', '.')),
              'width_m':
                  double.parse(_widthCtrl.text.trim().replaceAll(',', '.')),
              'fixed_price': true,
              'includes_labor': true,
            },

            'area_m2': price.areaM2,
            'unit': _s.isPerMetre ? 'metr' : 'm²',

            if (!_isMaterial) 'unit_price': price.pricePerM2.round(),
            'cost_price': price.total,
            'total_price': price.total,
            'calculator': 'area',
          },

          summary: _isMaterial
              ? '${_areaLabel(price.areaM2)} $_unit'
              : '${_areaLabel(price.areaM2)} $_unit · '
                  '${formatSom(price.total.toDouble())} so\'m',
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

  static String _areaLabel(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final price = _price;
    final labels = AreaPriceCalculator.labels(widget.specialty.areaTiers,
        perMetre: _s.isPerMetre);

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
          if (_isPenthouse)
            const CalculatorStepHeader(
                step: 0,
                total: 1,
                title: 'Tom o‘lchamlari',
                label: 'PENTHAUS · GIDROIZOLYATSIYA'),

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
                        _isPenthouse
                            ? 'Uy o‘lchamini kiriting'
                            : _s.isPerMetre
                                ? 'Necha metr kerak?'
                                : 'Qancha maydonga kerak?',
                        style: context.text.h4
                            .copyWith(color: colors.neutral.textStrong),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _s.isPerMetre
                      ? 'Uzunligini metrda yozing (masalan, ikkinchi qavatga zina '
                          '— 4 metr). Aniq bilmasangiz taxminan yozing — usta '
                          'o\'lchovga kelganda aniqlashtiriladi.'
                      : 'Uzunlik × kenglik. Aniq bilmasangiz taxminan yozing — '
                          'usta o\'lchovga kelganda aniqlashtiriladi.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.lg),
                if (_isPenthouse) ...[
                  _dimensionField('Uy uzunligi', _lengthCtrl),
                  _dimensionField('Uy eni', _widthCtrl),
                  if (_area != null) Text('Maydon: ${_areaLabel(_area!)} m²'),
                  const SizedBox(height: ChizmaSpace.lg),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(ChizmaSpace.md),
                      decoration: BoxDecoration(
                          color: colors.neutral.surface2,
                          borderRadius: BorderRadius.circular(ChizmaRadius.md)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('424 000 so‘m / m²',
                                style: context.text.h4.copyWith(
                                    color: colors.neutral.textStrong)),
                            const SizedBox(height: ChizmaSpace.sm),
                            Text(
                                'Materiallar, ikki qatlam styajka, montaj va usta xizmati kiradi. Qo‘shimcha usta haqi qo‘shilmaydi.',
                                style: context.text.body5.copyWith(
                                    height: 1.5,
                                    color: colors.neutral.textMuted)),
                          ])),
                ] else
                  TextField(
                    controller: _areaCtrl,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [

                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onChanged: _onAreaChanged,
                    style: context.text.h2
                        .copyWith(color: colors.neutral.textStrong),
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: uz(_unit),
                      suffixStyle: context.text.body3
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          if (price != null) ...[
            _PriceSheet(
              price: price,
              areaLabel: _areaLabel(price.areaM2),
              unit: _unit,
              isMaterial: _isMaterial,
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ] else if (_area != null) ...[

            ChizmaSheet(
              color: colors.neutral.surface2,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: colors.neutral.textMuted),
                  const SizedBox(width: ChizmaSpace.sm),
                  Expanded(
                    child: Text(
                      'Bu o\'lcham uchun narx belgilanmagan — usta bilan '
                      'chatda kelishasiz.',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ],

          if (labels.isNotEmpty) ...[
            ChizmaEyebrow('Narxlar'),
            const SizedBox(height: ChizmaSpace.sm),
            ChizmaSheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < labels.length; i++) ...[
                    if (i > 0) const SizedBox(height: ChizmaSpace.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            labels[i].range,
                            style: context.text.body5
                                .copyWith(color: colors.neutral.textMuted),
                          ),
                        ),
                        Text(
                          '${formatSom(labels[i].pricePerM2)} so\'m/$_unit',
                          style: context.text.body5.copyWith(

                            color: price != null &&
                                    price.pricePerM2 == labels[i].pricePerM2
                                ? colors.categorizedColor.primary
                                : colors.neutral.textStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ChizmaSpace.lg),
          ],

          ElevatedButton.icon(
            onPressed: price == null ? null : _goNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Keyingi'),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Text(
            _isMaterial

                ? 'Bu — faqat materialning narxi. Ish haqini har usta o\'zi '
                    'belgilaydi: javob berganda har bir ustaning jami '
                    'summasini ko\'rasiz va solishtirasiz.'
                : 'Ko\'rsatilgan summa — mo\'ljal. Usta o\'lchovga kelib aniq '
                    'narxni aytadi; olib borish va tayyorgarlik ishlari alohida '
                    'kelishiladi.',
            textAlign: TextAlign.center,
            style: context.text.body4.copyWith(color: colors.neutral.textMuted),
          ),
          if (price != null) const PriceEstimateNotice(),
        ],
      ),
    );
  }
}

class _PriceSheet extends StatelessWidget {
  const _PriceSheet({
    required this.price,
    required this.areaLabel,
    required this.unit,
    required this.isMaterial,
  });

  final AreaPrice price;
  final String areaLabel;

  final String unit;

  final bool isMaterial;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(
            label: unit == 'm' ? 'Uzunligi' : 'Maydon',
            value: '$areaLabel $unit',
            color: colors.neutral.textBody,
          ),
          const SizedBox(height: ChizmaSpace.sm),
          _Row(
            label: isMaterial ? 'Material, 1 $unit' : '1 $unit narxi',
            value: '${formatSom(price.pricePerM2)} so\'m',
            color: colors.neutral.textBody,
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Divider(height: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  isMaterial ? 'Material tannarxi' : 'Jami',
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${formatSom(price.total.toDouble())} so\'m',
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.body5
                .copyWith(color: context.color.neutral.textMuted),
          ),
        ),
        Text(
          value,
          style: context.text.body5
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
