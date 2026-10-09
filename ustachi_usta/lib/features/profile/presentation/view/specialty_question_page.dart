import 'package:flutter/material.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/presentation/specialty_icons.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart'
    show SpecialtyNoteField, SpecialtyRateField, SpecialtyVariantRateFields;

typedef SpecialtyAnswers = ({
  int? rate,
  Map<int, int> variantRates,
  String? note,
});

class SpecialtyQuestionPage extends StatefulWidget {
  const SpecialtyQuestionPage({
    super.key,
    required this.specialty,
    this.rate,
    this.variantRates = const <int, int>{},
    this.note,
  });

  final MasterSpecialty specialty;
  final int? rate;
  final Map<int, int> variantRates;
  final String? note;

  static Future<SpecialtyAnswers?> show(
    BuildContext context, {
    required MasterSpecialty specialty,
    int? rate,
    Map<int, int> variantRates = const <int, int>{},
    String? note,
  }) =>
      Navigator.of(context).push<SpecialtyAnswers>(
        MaterialPageRoute(
          builder: (_) => SpecialtyQuestionPage(
            specialty: specialty,
            rate: rate,
            variantRates: variantRates,
            note: note,
          ),
        ),
      );

  @override
  State<SpecialtyQuestionPage> createState() => _SpecialtyQuestionPageState();
}

class _SpecialtyQuestionPageState extends State<SpecialtyQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  late final _rate = TextEditingController(
    text: widget.rate == null || widget.rate == 0 ? '' : '${widget.rate}',
  );

  late final Map<int, TextEditingController> _variants = {
    for (final variant in widget.specialty.variants)
      variant.id: TextEditingController(
        text: widget.variantRates[variant.id] == null
            ? ''
            : '${widget.variantRates[variant.id]}',
      ),
  };

  late final _note = TextEditingController(text: widget.note ?? '');

  bool get _isRom => widget.specialty.isRom;
  bool get _isNote => widget.specialty.noteByMaster;

  String? _rateError;

  @override
  void dispose() {
    _rate.dispose();
    for (final controller in _variants.values) {
      controller.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  int _digits(TextEditingController controller) =>
      int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _done() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_isRom && !_isNote) {
      final empty = widget.specialty.asksRatePerVariant
          ? _variants.values.every((c) => _digits(c) <= 0)
          : _digits(_rate) <= 0;
      if (empty) {
        setState(() => _rateError = context.t.companyRates.onlyDigits);
        return;
      }
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop((
      rate: _isRom || _isNote || widget.specialty.asksRatePerVariant
          ? null
          : _digits(_rate),
      variantRates: {
        for (final entry in _variants.entries)
          if (_digits(entry.value) > 0) entry.key: _digits(entry.value),
      },
      note: _isNote ? _note.text.trim() : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final specialty = widget.specialty;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(specialty.name)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ChizmaSpace.lg,
              ChizmaSpace.lg,
              ChizmaSpace.lg,
              ChizmaSpace.xxl,
            ),
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.categorizedColor.primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                    ),
                    child: Icon(
                      specialtyIcon(specialty.code),
                      color: colors.categorizedColor.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Text(
                      specialty.name,
                      style: context.text.h4
                          .copyWith(color: colors.neutral.textStrong),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ChizmaSpace.xl),
              if (_isRom)
                const SizedBox.shrink()
              else if (_isNote)
                SpecialtyNoteField(
                  specialty: specialty,
                  controller: _note,
                  enabled: true,
                )
              else if (specialty.asksRatePerVariant)
                SpecialtyVariantRateFields(
                  specialty: specialty,
                  controllerFor: (id) => _variants[id]!,
                  enabled: true,
                )
              else
                SpecialtyRateField(
                  specialty: specialty,
                  controller: _rate,
                  enabled: true,
                ),
              if (_rateError != null) ...[
                const SizedBox(height: ChizmaSpace.xs),
                Text(
                  _rateError!,
                  style: context.text.label
                      .copyWith(color: colors.categorizedColor.error),
                ),
              ],
              const SizedBox(height: ChizmaSpace.xxl),
              BaseButton(
                onPressed: _done,
                text: context.t.common.done,
                backgroundColor: colors.categorizedColor.primary,
                textColor: colors.neutral.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
