import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';
import 'package:ustachi/features/repair/domain/repair_problem.dart';

class RepairOrderPage extends StatefulWidget {
  const RepairOrderPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<RepairOrderPage> createState() => _RepairOrderPageState();
}

enum _Step {
  problem('Nima buzilgan?'),
  detail('Qo\'shimcha ma\'lumot');

  const _Step(this.title);
  final String title;
}

class _RepairOrderPageState extends State<RepairOrderPage> {
  final _countCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  int _step = 0;
  final _problems = <String>{};
  late final List<RepairOption> _options = repairOptionsFor(widget.specialty);

  bool get _isRom => widget.specialty.isRom;
  bool get _otherSelected => _problems.contains(RepairOption.otherCode);
  RepairMaterial? _material;

  int? _floor;

  static const _steps = _Step.values;
  static const _maxFloorChip = 5;

  _Step get _current => _steps[_step];

  int get _count {
    final value = int.tryParse(_countCtrl.text.trim());
    return (value == null || value <= 0) ? 1 : value;
  }

  bool get _canProceed => switch (_current) {

        _Step.problem => _problems.isNotEmpty,
        _Step.detail => !_otherSelected || _noteCtrl.text.trim().length >= 10,
      };

  String? get _missingReason {
    if (_current == _Step.problem && _problems.isEmpty) {
      return 'Nima buzilganini belgilang (bir nechtasini tanlash mumkin).';
    }
    if (_current == _Step.detail &&
        _otherSelected &&
        _noteCtrl.text.trim().length < 10) {
      return 'Muammoni qisqacha yozib bering — usta nima kerakligini bilsin.';
    }
    return null;
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _toggle(RepairOption option) => setState(() {
        if (!_problems.remove(option.code)) _problems.add(option.code);
      });

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

  String get _description {
    final lines = <String>[
      for (final p in _options)
        if (_problems.contains(p.code) && !p.isOther) '• ${p.title}',
    ];
    // Soni va material — faqat eshik-romda so'raladi.
    final head = [
      if (_isRom) '$_count ta rom/eshik',
      if (_isRom && _material != null && _material != RepairMaterial.bilmayman)
        _material!.title,
      if (_floor != null) '$_floor-qavat',
    ].join(' · ');
    final note = _noteCtrl.text.trim();
    return [
      if (head.isNotEmpty) head,
      ...lines,
      if (note.isNotEmpty) note,
    ].join('\n');
  }

  String get _summary {
    final first = _options.firstWhere((p) => _problems.contains(p.code));
    final more = _problems.length - 1;
    return more > 0 ? '${first.title} va yana $more ta' : first.title;
  }

  Future<void> _goNext() async {
    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          isRepair: true,
          initialDescription: _description,
          summary: 'Ta\'mir · $_summary',

          proposal: {
            'engine': 'repair',
            'repair_problems': [
              for (final p in _options)
                if (_problems.contains(p.code)) p.code,
            ],
            if (_isRom) 'repair_count': _count,
            if (_isRom && _material != null) 'repair_material': _material!.code,
            if (_floor != null) 'repair_floor': _floor,
          },
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
          title: const Text('Ta’mirlash'),
        ),
        body: Column(
          children: [
            CalculatorStepHeader(
                step: _step, total: _steps.length, title: _current.title),
            Expanded(
              child: IndexedStack(
                index: _step,
                sizing: StackFit.expand,
                children: [
                  _problemStep(context),
                  _detailStep(context),
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
                            child: Text(_current == _Step.detail
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

  Widget _problemStep(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            'Bir nechtasini belgilashingiz mumkin. Ta\'mir narxini usta '
            'ko\'rib aytadi — shuning uchun bu yerda narx yo\'q.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final p in _options) ...[
          _ProblemCard(
            problem: p,
            selected: _problems.contains(p.code),
            onTap: () => _toggle(p),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
      ],
    );
  }

  Widget _detailStep(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        if (_isRom) ...[
          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nechta rom yoki eshik?',
                  style:
                      context.text.h4.copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: ChizmaSpace.md),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (_) => setState(() {}),
                    style: context.text.h4
                        .copyWith(color: colors.neutral.textStrong),
                    decoration: InputDecoration(
                      hintText: '1',
                      suffixText: uz('dona'),
                      suffixStyle: context.text.body3
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),
          const ChizmaEyebrow('Romi qaysi materialdan?'),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              for (final m in RepairMaterial.values)
                ChoiceChip(
                  label: Text(m.title),
                  selected: _material == m,
                  onSelected: (_) =>
                      setState(() => _material = _material == m ? null : m),
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.lg),
        ],
        const ChizmaEyebrow('Nechanchi qavat?'),
        const SizedBox(height: ChizmaSpace.sm),
        Wrap(
          spacing: ChizmaSpace.sm,
          runSpacing: ChizmaSpace.sm,
          children: [
            for (var floor = 1; floor <= _maxFloorChip; floor++)
              ChoiceChip(
                label: Text(floor == _maxFloorChip ? '$floor+' : '$floor'),
                selected: _floor == floor,
                onSelected: (_) =>
                    setState(() => _floor = _floor == floor ? null : floor),
              ),
          ],
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaEyebrow('Qo\'shimcha izoh'),
        const SizedBox(height: ChizmaSpace.sm),
        ChizmaSheet(
          child: TextField(
            controller: _noteCtrl,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            style:
                context.text.body4.copyWith(color: colors.neutral.textStrong),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: uz(_isRom
                  ? 'Masalan: oshxona derazasi shamol o\'tkazyapti, '
                      'tutqichi ham bo\'shagan.'
                  : 'Masalan: qachondan beri, qayerda, nima qilib ko\'rdingiz.'),
            ),
          ),
        ),
        const SizedBox(height: ChizmaSpace.md),
        Text(
          'Keyingi qadamda manzilni yozasiz va e\'lonni yuborasiz. E\'lon '
          'faqat TA\'MIRGA CHIQADIGAN ustalarga boradi, ular o\'z narxini '
          'aytadi.',
          textAlign: TextAlign.center,
          style: context.text.label.copyWith(color: colors.neutral.textMuted),
        ),
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

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({
    required this.problem,
    required this.selected,
    required this.onTap,
  });

  final RepairOption problem;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CalculatorOption(
        title: problem.title,
        description: problem.desc.isEmpty ? null : problem.desc,
        selected: selected,
        onTap: onTap,
        leading: Icon(problem.icon),
        multiple: true);
  }
}
