import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/country.dart';

class CountrySelectPage extends StatefulWidget {
  const CountrySelectPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  State<CountrySelectPage> createState() => _CountrySelectPageState();
}

class _CountrySelectPageState extends State<CountrySelectPage> {
  late CountryChoice _selected = LanguageProvider().choice;

  Future<void> _select(CountryChoice choice) async {
    HapticFeedback.selectionClick();
    setState(() => _selected = choice);
    await LanguageProvider().setChoice(choice);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.country;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(ChizmaSpace.lg),
        child: FilledButton(
          onPressed: () {
            widget.onDone?.call();
            if (widget.onDone == null) Navigator.of(context).maybePop();
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: colors.categorizedColor.primary,
          ),
          child: Text(t.continueBtn),
        ),
      ),
      body: SafeArea(
        child: ChizmaPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: ChizmaSpace.xl),
              Text(
                t.title,
                style: context.text.h2.copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: ChizmaSpace.sm),
              Text(
                t.subtitle,
                style: context.text.body4
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: ChizmaSpace.xl),
              for (final choice in countryChoices) ...[
                _CountryRow(
                  choice: choice,
                  selected: choice == _selected,
                  onTap: () => _select(choice),
                ),
                const SizedBox(height: ChizmaSpace.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final CountryChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final accent = colors.categorizedColor.primary;

    return ChizmaSheet(
      borderColor: selected ? accent : colors.neutral.border,
      color: selected ? accent.withValues(alpha: 0.06) : null,
      onTap: onTap,
      child: Row(
        children: [
          Text(choice.country.flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                m.Text(
                  choice.title,
                  style: context.text.body3.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (choice.hint.isNotEmpty)
                  m.Text(
                    choice.hint,
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                  ),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, size: 22, color: accent),
        ],
      ),
    );
  }
}
