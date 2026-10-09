import 'package:flutter/material.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

String languageChoiceLabel() => LanguageProvider().choice.label;

class LanguageModeSheet extends StatelessWidget {
  const LanguageModeSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const LanguageModeSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final current = LanguageProvider().choice;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          0,
          ChizmaSpace.lg,
          ChizmaSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: ChizmaSpace.sm,
                bottom: ChizmaSpace.sm,
              ),
              child: Text(
                context.t.profile.language,
                style: context.text.h4.copyWith(color: colors.neutral.textStrong),
              ),
            ),
            for (final choice in languageChoices)
              _LanguageOption(
                model: choice,
                selected: current.id == choice.id,
                onTap: () async {
                  await LanguageProvider().setChoice(choice);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final LanguageChoice model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.1) : colors.neutral.surface2,
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            border: Border.all(
              color: selected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  model.flag,
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.language_rounded,
                    color: selected ? primary : colors.neutral.textBody,
                  ),
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.title,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (model.hint.isNotEmpty)
                      Text(
                        model.hint,
                        style: context.text.label
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
