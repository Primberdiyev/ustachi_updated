import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/services/beton_calculator.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class BetonCalculatorPage extends StatefulWidget {
  const BetonCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<BetonCalculatorPage> createState() => _BetonCalculatorPageState();
}

enum _Step {
  house('Uy o\'lchami'),
  section('Poydevor o\'lchami'),
  result('Hisob');

  const _Step(this.title);
  final String title;
}

class _BetonCalculatorPageState extends State<BetonCalculatorPage> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _innerCtrl = TextEditingController();
  final _fenceCtrl = TextEditingController();

  bool _fence = false;

  double? _fenceLength;

  int _step = 0;

  double? _length;
  double? _width;

  double _inner = 0;

  BetonSection _houseSection = BetonCalculator.defaultSection;
  BetonSection _fenceSection = BetonCalculator.fenceSection;

  BetonSection get _section => _fence ? _fenceSection : _houseSection;
  set _section(BetonSection s) {
    if (_fence) {
      _fenceSection = s;
    } else {
      _houseSection = s;
    }
  }

  bool get _hasPad => _section.padWidthM > 0 && _section.padHeightM > 0;

  static const _steps = _Step.values;

  static const _widthChoices = [30.0, 40.0, 50.0, 60.0];

  static const _heightChoices = [
    20.0,
    30.0,
    40.0,
    50.0,
    60.0,
    80.0,
    100.0,
    120.0,
  ];
  static const _padWidthChoices = [60.0, 90.0, 120.0];
  static const _padHeightChoices = [20.0, 30.0, 40.0, 50.0];

  _Step get _current => _steps[_step];

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _innerCtrl.dispose();
    _fenceCtrl.dispose();
    super.dispose();
  }

  double _price(String name) {
    final needle = name.trim().toLowerCase();
    for (final v in widget.specialty.variants) {
      if (v.name.trim().toLowerCase() == needle) return v.pricePerM2;
    }
    return 0;
  }

  double get _betonPrice => _price('Tayyor beton');
  double get _armaturaPrice => _price('Armatura');

  bool get _hasPrice => _betonPrice > 0 && _armaturaPrice > 0;

  BetonEstimate? get _estimate => _fence ? _fenceEstimate : _houseEstimate;

  BetonEstimate? get _fenceEstimate => _fenceLength == null
      ? null
      : BetonCalculator.calculateFence(
          lengthM: _fenceLength!,
          section: _fenceSection,
          betonPricePerM3: _betonPrice,
          armaturaPricePerM: _armaturaPrice,
        );

  BetonEstimate? get _houseEstimate => (_length == null || _width == null)
      ? null
      : BetonCalculator.calculate(
          houseLengthM: _length!,
          houseWidthM: _width!,
          innerWallsM: _inner,
          section: _houseSection,
          betonPricePerM3: _betonPrice,
          armaturaPricePerM: _armaturaPrice,
        );

  static double? _parse(String raw) {
    final value = double.tryParse(raw.trim().replaceAll(',', '.'));
    return (value == null || value <= 0) ? null : value;
  }

  static String _num(double value) {
    final rounded = (value * 100).round() / 100;
    return rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString().replaceAll('.', ',');
  }

  static String _cm(double metres) => _num(metres * 100);

  bool get _canProceed => switch (_current) {
        _Step.house =>
          _fence ? _fenceLength != null : (_length != null && _width != null),
        _Step.section => true,
        _Step.result => _estimate != null && _hasPrice,
      };

  String? get _missingReason {
    if (_current == _Step.house) {
      if (_fence) {
        return _fenceLength == null ? 'Devor uzunligini yozing.' : null;
      }
      if (_length == null) return 'Uy uzunligini yozing.';
      if (_width == null) return 'Uy enini yozing.';
      return null;
    }
    if (_current == _Step.result && !_hasPrice) {
      return 'Beton yoki armatura narxi hali kiritilmagan — tez orada '
          'qo\'shiladi.';
    }
    return null;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canProceed) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _goNext();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  Future<void> _goNext() async {
    final e = _estimate;
    if (e == null || !_hasPrice) return;

    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: e.total,
          proposal: {
            'calculator': 'variant',
            'engine': 'beton',
            'variant': _fence ? 'Devor (zabor) poydevori' : 'Poydevor',
            'beton_kind': _fence ? 'fence' : 'house',
            if (_fence) 'beton_fence_length_m': _fenceLength,

            'variant_note': [
              '${_num(e.betonM3)} m³ beton',
              '${_num(e.armaturaM)} m armatura',
              _fence
                  ? '${_num(e.lengthM)} m devor (zabor)'
                  : '${_num(e.lengthM)} m poydevor',
              '${_cm(_section.widthM)}×${_cm(_section.heightM)} sm',
            ].join(' · '),
            'area_m2': double.parse(e.betonM3.toStringAsFixed(2)),
            'unit': 'm³',
            'cost_price': e.total,
            'total_price': e.total,
            if (!_fence) 'beton_house_length_m': _length,
            if (!_fence) 'beton_house_width_m': _width,
            'beton_outer_m': double.parse(e.outerM.toStringAsFixed(2)),
            'beton_inner_m': double.parse(e.innerM.toStringAsFixed(2)),
            'beton_width_m': _section.widthM,
            'beton_height_m': _section.heightM,
            'beton_pad_width_m': _section.padWidthM,
            'beton_pad_height_m': _section.padHeightM,
            'beton_m3': double.parse(e.betonM3.toStringAsFixed(2)),
            'beton_armatura_m': double.parse(e.armaturaM.toStringAsFixed(2)),
            'beton_price_per_m3': _betonPrice,
            'beton_armatura_price_per_m': _armaturaPrice,
            'beton_cost': e.betonCost,
            'beton_armatura_cost': e.armaturaCost,
          },
          summary: '${_num(e.betonM3)} m³ beton · '
              '${_num(e.armaturaM)} m armatura',
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

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.neutral.black7,
        appBar: AppBar(
          leading: BackButton(onPressed: _back),
          title: const Text('Poydevor'),
        ),
        body: Column(
          children: [
            CalculatorStepHeader(
                step: _step,
                total: _steps.length,
                title: _current == _Step.house && _fence
                    ? 'Devor uzunligi'
                    : _current.title),
            Expanded(
              child: IndexedStack(
                index: _step,
                sizing: StackFit.expand,
                children: [
                  _houseStep(context),
                  _sectionStep(context),
                  _resultStep(context),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg,
                    ChizmaSpace.sm, ChizmaSpace.lg, ChizmaSpace.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_missingReason != null) ...[
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14, color: colors.neutral.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _missingReason!,
                              style: context.text.label
                                  .copyWith(color: colors.neutral.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ChizmaSpace.sm),
                    ],
                    Row(
                      children: [
                        if (_step > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _back,
                              child: const Text('Orqaga'),
                            ),
                          ),
                          const SizedBox(width: ChizmaSpace.md),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _canProceed ? _next : null,
                            child: Text(_current == _Step.result
                                ? 'Usta chaqirish'
                                : 'Keyingisi'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _houseStep(BuildContext context) {
    final colors = context.color;
    final perimeter = (_length == null || _width == null)
        ? 0.0
        : BetonCalculator.perimeterM(lengthM: _length!, widthM: _width!);

    final kindPicker = ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Poydevor nimaga quyiladi?',
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          ),
          const SizedBox(height: ChizmaSpace.md),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              ChoiceChip(
                label: const Text('Uy'),
                selected: !_fence,
                onSelected: (_) => setState(() => _fence = false),
              ),
              ChoiceChip(
                label: const Text('Devor (zabor)'),
                selected: _fence,
                onSelected: (_) => setState(() => _fence = true),
              ),
            ],
          ),
        ],
      ),
    );

    if (_fence) {
      return _StepBody(
        children: [
          kindPicker,
          const SizedBox(height: ChizmaSpace.lg),
          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Devor (zabor) uzunligini yozing',
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: 4),
                Text(
                  'Poydevor devor bo\'ylab to\'g\'ri quyiladi. Bir necha '
                  'tomon bo\'lsa — hammasining uzunligini qo\'shib yozing.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.lg),
                SizedBox(
                  width: 180,
                  child: _NumberField(
                    controller: _fenceCtrl,
                    label: 'Devor uzunligi',
                    suffix: 'm',
                    onChanged: (v) => setState(() => _fenceLength = _parse(v)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _StepBody(
      children: [
        kindPicker,
        const SizedBox(height: ChizmaSpace.lg),
        ChizmaSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Uyingizning o\'lchamini yozing',
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: 4),
              Text(
                'Poydevor uy atrofida yuradi — uzunligini o\'zimiz '
                'hisoblaymiz.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: ChizmaSpace.lg),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _lengthCtrl,
                      label: 'Uy uzunligi',
                      suffix: 'm',
                      onChanged: (v) => setState(() => _length = _parse(v)),
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: _NumberField(
                      controller: _widthCtrl,
                      label: 'Uy eni',
                      suffix: 'm',
                      onChanged: (v) => setState(() => _width = _parse(v)),
                    ),
                  ),
                ],
              ),
              if (perimeter > 0) ...[
                const SizedBox(height: ChizmaSpace.md),
                Text(
                  'Uy atrofi: ${_num(perimeter)} metr',
                  style: context.text.body4.copyWith(
                    color: colors.categorizedColor.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        ChizmaSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ichki devorlar tagiga ham poydevor quyiladimi?',
                style: context.text.body3
                    .copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: 4),
              Text(
                'Ichki devorlar uzunligini yozing. Bilmasangiz yoki '
                'quyilmasa — bo\'sh qoldiring. U yerda padushka kichikroq '
                'bo\'ladi.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: ChizmaSpace.md),
              SizedBox(
                width: 180,
                child: _NumberField(
                  controller: _innerCtrl,
                  label: 'Ichki devorlar',
                  suffix: 'm',
                  onChanged: (v) => setState(() => _inner = _parse(v) ?? 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionStep(BuildContext context) {
    final colors = context.color;

    return _StepBody(
      children: [
        ChizmaSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Poydevor qanday bo\'ladi?',
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: 4),
              Text(
                'Odatiy o\'lcham qo\'yilgan — ustangiz boshqacha desa '
                'to\'g\'rilang. Beton kubi shunga qarab hisoblanadi.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: ChizmaSpace.lg),
              SizedBox(
                height: 150,
                child: _SectionPicture(section: _section),
              ),
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaEyebrow('Poydevor eni'),
        const SizedBox(height: ChizmaSpace.sm),
        _CmChips(
          values: _widthChoices,
          selected: _section.widthM,
          onPick: (cm) =>
              setState(() => _section = _section.copyWith(widthM: cm / 100)),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaEyebrow('Poydevor bo\'yi (balandligi)'),
        const SizedBox(height: ChizmaSpace.sm),
        _CmChips(
          values: _heightChoices,
          selected: _section.heightM,
          onPick: (cm) =>
              setState(() => _section = _section.copyWith(heightM: cm / 100)),
        ),

        if (_fence) ...[
          const SizedBox(height: ChizmaSpace.lg),
          const ChizmaEyebrow('Yer ostidagi padushka'),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              ChoiceChip(
                label: const Text('Padushkasiz'),
                selected: !_hasPad,
                onSelected: (_) => setState(() =>
                    _section = _section.copyWith(padWidthM: 0, padHeightM: 0)),
              ),
              ChoiceChip(
                label: const Text('Padushka bilan'),
                selected: _hasPad,
                onSelected: (_) => setState(() {
                  if (_hasPad) return;
                  _section = _section.copyWith(
                    padWidthM: BetonCalculator.fencePadWidthM,
                    padHeightM: BetonCalculator.fencePadHeightM,
                  );
                }),
              ),
            ],
          ),
        ],
        if (_hasPad) ...[
          const SizedBox(height: ChizmaSpace.lg),
          const ChizmaEyebrow('Yer ostidagi padushka — eni'),
          const SizedBox(height: ChizmaSpace.sm),
          _CmChips(
            values: _padWidthChoices,
            selected: _section.padWidthM,
            onPick: (cm) => setState(
                () => _section = _section.copyWith(padWidthM: cm / 100)),
          ),
          const SizedBox(height: ChizmaSpace.lg),
          const ChizmaEyebrow('Padushka qalinligi'),
          const SizedBox(height: ChizmaSpace.sm),
          _CmChips(
            values: _padHeightChoices,
            selected: _section.padHeightM,
            onPick: (cm) => setState(
                () => _section = _section.copyWith(padHeightM: cm / 100)),
          ),
        ],
        const SizedBox(height: ChizmaSpace.md),
        Text(
          _hasPad
              ? 'Har metr poydevorga ${_num(_section.m3PerM)} m³ beton ketadi '
                  '(devor ${_num(_section.wallM3)} + padushka ${_num(_section.padM3)}).'
              : 'Har metr poydevorga ${_num(_section.m3PerM)} m³ beton ketadi.',
          style: context.text.label.copyWith(color: colors.neutral.textMuted),
        ),
      ],
    );
  }

  Widget _resultStep(BuildContext context) {
    final colors = context.color;
    final e = _estimate;
    if (e == null) return const SizedBox.shrink();

    Widget row(String name, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              Text(
                value,
                style: context.text.body5.copyWith(
                  color: strong
                      ? colors.neutral.textStrong
                      : colors.neutral.textBody,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );

    return _StepBody(
      children: [
        ChizmaSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_fence)
                row('Devor (zabor) uzunligi', '${_num(e.outerM)} m')
              else ...[
                row('Uy o\'lchami', '${_num(_length!)} × ${_num(_width!)} m'),
                row('Uy atrofi (tashqi poydevor)', '${_num(e.outerM)} m'),
                if (e.innerM > 0)
                  row('Ichki devorlar', '+ ${_num(e.innerM)} m'),
              ],
              row('Poydevor kesimi',
                  '${_cm(_section.widthM)} × ${_cm(_section.heightM)} sm'),
              row(
                'Padushka',
                _hasPad
                    ? '${_cm(_section.padWidthM)} × ${_cm(_section.padHeightM)} sm'
                    : 'yo\'q',
              ),
              Divider(height: 1, color: colors.neutral.border),
              const SizedBox(height: ChizmaSpace.sm),
              row('Tayyor beton', '${_num(e.betonM3)} m³', strong: true),
              row('Armatura', '${_num(e.armaturaM)} m', strong: true),
              if (_hasPrice) ...[
                Divider(height: 1, color: colors.neutral.border),
                const SizedBox(height: ChizmaSpace.sm),
                row('Beton (${formatSom(_betonPrice)} so\'m/m³)',
                    '${formatSom(e.betonCost.toDouble())} so\'m'),
                row('Armatura (${formatSom(_armaturaPrice)} so\'m/m)',
                    '${formatSom(e.armaturaCost.toDouble())} so\'m'),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Material tannarxi',
                        style: context.text.body4.copyWith(
                          color: colors.neutral.textStrong,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${formatSom(e.total.toDouble())} so\'m',
                      style: context.text.h4.copyWith(
                        color: colors.categorizedColor.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.sm),
        Text(
          'Bu — faqat materialning tannarxi (beton va armatura). Quyish '
          'haqini har usta o\'zi belgilaydi: javob berganda har bir '
          'ustaning jami summasini ko\'rasiz va solishtirasiz.',
          textAlign: TextAlign.center,
          style: context.text.body4.copyWith(color: colors.neutral.textMuted),
        ),
        if (_hasPrice) const PriceEstimateNotice(),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _CmChips extends StatelessWidget {
  const _CmChips({
    required this.values,
    required this.selected,
    required this.onPick,
  });

  final List<double> values;

  final double selected;
  final ValueChanged<double> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ChizmaSpace.sm,
      runSpacing: ChizmaSpace.sm,
      children: [
        for (final cm in values)
          ChoiceChip(
            label: Text('${cm.round()} sm'),
            selected: (selected * 100 - cm).abs() < 0.5,
            onSelected: (_) => onPick(cm),
          ),
      ],
    );
  }
}

class _SectionPicture extends StatelessWidget {
  const _SectionPicture({required this.section});

  final BetonSection section;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SectionPainter(section, context.color.neutral.textMuted),
        child: const SizedBox.expand(),
      );
}

class _SectionPainter extends CustomPainter {
  _SectionPainter(this.section, this.labelColor);

  final BetonSection section;
  final Color labelColor;

  static const _ground = Color(0xFFD9C9A8);
  static const _groundDeep = Color(0xFFC3B08C);
  static const _beton = Color(0xFF9AA0A6);
  static const _betonDark = Color(0xFF7C838A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    canvas.clipRect(Offset.zero & size);

    final bottomY = h * 0.92;
    final totalM = section.heightM + section.padHeightM;
    final widest =
        section.padWidthM > section.widthM ? section.padWidthM : section.widthM;

    final scaleX = (w * 0.5) / widest;
    final scaleY = (h * 0.78) / totalM;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final centerX = w / 2;

    final groundY = bottomY - (totalM * scale) + (section.heightM * scale) / 3;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, groundY),
        Paint()..color = const Color(0xFFEAF1F8));
    canvas.drawRect(
        Rect.fromLTWH(0, groundY, w, h - groundY), Paint()..color = _ground);
    canvas.drawRect(Rect.fromLTWH(0, bottomY, w, h - bottomY),
        Paint()..color = _groundDeep);

    final padW = section.padWidthM * scale;
    final padH = section.padHeightM * scale;
    final padRect =
        Rect.fromLTWH(centerX - padW / 2, bottomY - padH, padW, padH);
    canvas.drawRect(padRect, Paint()..color = _betonDark);

    final wallW = section.widthM * scale;
    final wallH = section.heightM * scale;
    final wallRect =
        Rect.fromLTWH(centerX - wallW / 2, padRect.top - wallH, wallW, wallH);
    canvas.drawRect(wallRect, Paint()..color = _beton);

    final rebar = Paint()
      ..color = const Color(0xFF8D5524)
      ..strokeWidth = 2;
    for (final f in [0.25, 0.5, 0.75]) {
      final x = wallRect.left + wallRect.width * f;
      canvas.drawLine(
          Offset(x, wallRect.top + 4), Offset(x, padRect.bottom - 4), rebar);
    }

    canvas.drawLine(
      Offset(0, groundY),
      Offset(w, groundY),
      Paint()
        ..color = _groundDeep
        ..strokeWidth = 1.5,
    );

    void label(String text, Offset at) {
      final painter = TextPainter(
        text: TextSpan(
          text: uz(text),
          style: TextStyle(color: labelColor, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at);
    }

    label('${(section.heightM * 100).round()} sm',
        Offset(wallRect.right + 6, wallRect.center.dy - 7));

    final hasPad = section.padWidthM > 0 && section.padHeightM > 0;
    label('${((hasPad ? section.padWidthM : section.widthM) * 100).round()} sm',
        Offset(padRect.center.dx - 18, padRect.bottom + 3));
  }

  @override
  bool shouldRepaint(_SectionPainter old) =>
      old.section.widthM != section.widthM ||
      old.section.heightM != section.heightM ||
      old.section.padWidthM != section.padWidthM ||
      old.section.padHeightM != section.padHeightM;
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.label.copyWith(color: colors.neutral.textBody),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: onChanged,
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: uz(suffix),
            suffixStyle:
                context.text.body3.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}
