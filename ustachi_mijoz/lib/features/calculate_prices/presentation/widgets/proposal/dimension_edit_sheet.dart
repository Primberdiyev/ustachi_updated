import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_generator.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_dimension_edit.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart'
    hide proposalMinSideMm, proposalMaxWidthMm, proposalMaxHeightMm;
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';

typedef ProposalEditResult = ({ProposalRequest request, ProposalOption option});

class DimensionEditSheet extends StatefulWidget {
  const DimensionEditSheet({
    super.key,
    required this.target,
    required this.request,
    required this.option,
  });

  final FrameDimensionTarget target;
  final ProposalRequest request;
  final ProposalOption option;

  static Future<ProposalEditResult?> show(
    BuildContext context, {
    required FrameDimensionTarget target,
    required ProposalRequest request,
    required ProposalOption option,
  }) =>
      showModalBottomSheet<ProposalEditResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: context.color.neutral.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => DimensionEditSheet(target: target, request: request, option: option),
      );

  @override
  State<DimensionEditSheet> createState() => _DimensionEditSheetState();
}

const _minSide = proposalMinSideMm;
const _maxWidth = proposalMaxWidthMm;
const _maxHeight = proposalMaxHeightMm;
const _step = 50;

class _DimensionEditSheetState extends State<DimensionEditSheet> {
  late final _value = TextEditingController(text: '${widget.target.valueMm}')
    ..selection = TextSelection(baseOffset: 0, extentOffset: '${widget.target.valueMm}'.length);

  late ProposalRequest _request = widget.request;
  ProposalOption? _option;
  bool _sameShape = true;
  String? _error;

  late List<double> _breaks = widget.target.breaksMm;

  FrameDimensionTarget get _t => widget.target;
  int get _typed => int.tryParse(_value.text) ?? 0;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _recompute() => setState(_compute);

  void _compute() {
    final v = _typed;
    final base = widget.request;
    if (!_t.isTotal) {
      final r = proposalEditSegment(
        current: widget.option,
        request: base,
        horizontal: _t.horizontal,
        breaksMm: _t.breaksMm,
        index: _t.index,
        newMm: v,
      );
      _option = r.option;
      _request = r.request;
      _error = r.error;
      _sameShape = true;
      _breaks = proposalSegmentBreaks(_t.breaksMm, _t.index, v) ?? _t.breaksMm;
      return;
    }

    final max = _t.horizontal ? _maxWidth : _maxHeight;
    _breaks = [0, v.toDouble()];
    String? error;
    if (v < _minSide || v > max) {
      error = '${_t.horizontal ? 'Eni' : 'Bo\'yi'} $_minSide–$max mm oralig\'ida bo\'lsin';
    } else if (!_t.horizontal && base.floorGapMm > 0 && v - base.floorGapMm < 1000) {
      error = 'Bo\'yi kamida ${base.floorGapMm + 1000} mm bo\'lsin (derazadan yergacha ${base.floorGapMm} mm)';
    }
    if (error != null) {
      _option = null;
      _error = error;
      _request = base;
      return;
    }
    final req = _t.horizontal ? base.copyWith(widthMm: v) : base.copyWith(heightMm: v);
    final r = proposalResize(current: widget.option, request: req);
    _option = r?.option;
    _sameShape = r?.sameShape ?? true;
    _request = req;
    _error = r == null ? 'Bu o\'lchamda variant topilmadi' : null;
  }

  void _bump(int delta) {
    final next = math.max(0, _typed + delta);
    _value.text = '$next';
    _recompute();
  }

  String get _title {
    if (_t.isTotal) return _t.horizontal ? 'Umumiy eni' : 'Umumiy bo\'yi';
    return _t.horizontal ? 'Chapdan ${_t.index + 1}-bo\'lak eni' : 'Tepadan ${_t.index + 1}-bo\'lak bo\'yi';
  }

  String get _hint => _t.isTotal
      ? 'Rom shakli yangi o\'lchamga moslanadi'
      : 'Umumiy ${_t.horizontal ? 'eni' : 'bo\'yi'} ${_t.breaksMm.last.round()} mm o\'zgarmaydi — qo\'shni bo\'lak moslashadi';

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final option = _option;
    final unchanged = _typed == _t.valueMm;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: ChizmaSpace.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.neutral.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.xl, ChizmaSpace.md, ChizmaSpace.sm, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_t.horizontal ? Icons.swap_horiz_rounded : Icons.swap_vert_rounded, color: primary),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_title, style: context.text.h4.copyWith(color: colors.neutral.textStrong)),
                        Text(_hint, style: context.text.label.copyWith(color: colors.neutral.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: uz('Yopish'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.xl, ChizmaSpace.lg, ChizmaSpace.xl, ChizmaSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_t.isTotal) ...[
                    _SegmentsPreview(
                      original: _t.breaksMm,
                      breaks: _breaks,
                      index: _t.index,
                      horizontal: _t.horizontal,
                    ),
                    const SizedBox(height: ChizmaSpace.lg),
                  ],
                  Row(
                    children: [
                      _StepButton(icon: Icons.remove_rounded, label: '−$_step', onTap: () => _bump(-_step)),
                      const SizedBox(width: ChizmaSpace.sm),
                      Expanded(
                        child: TextField(
                          controller: _value,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5)
                          ],
                          onChanged: (_) => _recompute(),
                          style:
                              context.text.h2.copyWith(color: colors.neutral.textStrong, fontWeight: FontWeight.w800),
                          decoration: InputDecoration(
                            suffixText: uz('mm'),
                            filled: true,
                            fillColor: colors.neutral.surface2.withValues(alpha: 0.6),
                            contentPadding: const EdgeInsets.symmetric(vertical: ChizmaSpace.md),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ChizmaRadius.lg)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                              borderSide: BorderSide(color: colors.neutral.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                              borderSide: BorderSide(color: primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ChizmaSpace.sm),
                      _StepButton(icon: Icons.add_rounded, label: '+$_step', onTap: () => _bump(_step)),
                    ],
                  ),
                  const SizedBox(height: ChizmaSpace.sm),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _error != null
                        ? Row(
                            key: ValueKey(_error),
                            children: [
                              Icon(Icons.error_outline_rounded, size: 16, color: colors.categorizedColor.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: context.text.label.copyWith(color: colors.categorizedColor.error),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            key: const ValueKey('was'),
                            'Hozir: ${_t.valueMm} mm',
                            textAlign: TextAlign.center,
                            style: context.text.label.copyWith(color: colors.neutral.textMuted),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.xl, 0, ChizmaSpace.xl, ChizmaSpace.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (option != null && !_sameShape)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.categorizedColor.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.categorizedColor.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: colors.categorizedColor.warning, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Shakl mos kelmadi — «${option.title}» ga o\'zgartirildi.',
                              style: context.text.label.copyWith(color: colors.neutral.textStrong),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: option == null || unchanged
                        ? null
                        : () => Navigator.of(context).pop((request: _request, option: option)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      disabledBackgroundColor: colors.neutral.surface2,
                    ),
                    child: Text(
                      'Qo\'llash',
                      style: context.text.body3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: option == null || unchanged ? colors.neutral.textMuted : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentsPreview extends StatelessWidget {
  const _SegmentsPreview({
    required this.original,
    required this.breaks,
    required this.index,
    required this.horizontal,
  });

  final List<double> original;
  final List<double> breaks;
  final int index;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final warning = colors.categorizedColor.warning;
    final total = breaks.last - breaks.first;
    final n = breaks.length - 1;

    Widget cell(int i) {
      final mm = (breaks[i + 1] - breaks[i]).round();
      final was = (original[i + 1] - original[i]).round();
      final selected = i == index;
      final changed = !selected && mm != was;
      final tone = selected ? primary : (changed ? warning : colors.neutral.textMuted);
      return Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: selected ? 0.16 : (changed ? 0.14 : 0.07)),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: tone.withValues(alpha: selected || changed ? 0.7 : 0.25), width: selected ? 1.5 : 1),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              changed ? '$was → $mm' : '$mm',
              style: context.text.label.copyWith(
                color: selected || changed ? tone : colors.neutral.textBody,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    int flex(int i) => math.max(((breaks[i + 1] - breaks[i]) / total * 1000).round(), 120);

    final cells = [for (var i = 0; i < n; i++) Expanded(flex: flex(i), child: cell(i))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          horizontal ? 'Bo\'laklar · chapdan o\'ngga' : 'Bo\'laklar · tepadan pastga',
          style: context.text.label.copyWith(color: colors.neutral.textMuted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: ChizmaSpace.xs),
        if (horizontal)
          SizedBox(height: 48, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells))
        else
          Center(
            child: SizedBox(
              width: 140,
              height: math.min(56.0 * n, 170),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
            ),
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Material(
      color: colors.categorizedColor.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(ChizmaRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: colors.categorizedColor.primary),
                Text(
                  label,
                  style:
                      context.text.label.copyWith(color: colors.categorizedColor.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
