import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/application/theme_provider.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

String themeModeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
      ThemeMode.light => context.t.profile.themeLight,
      ThemeMode.dark => context.t.profile.themeDark,
      ThemeMode.system => context.t.profile.themeSystem,
    };

class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const ThemeModeSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final provider = ThemeProvider();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.lg),
        child: ListenableBuilder(
          listenable: provider,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: ChizmaSpace.sm, bottom: ChizmaSpace.sm),
                child: Text(
                  context.t.profile.theme,
                  style: context.text.h4.copyWith(color: colors.neutral.textStrong),
                ),
              ),
              for (final (mode, icon, hint) in [
                (ThemeMode.light, Icons.light_mode_outlined, null),
                (ThemeMode.dark, Icons.dark_mode_outlined, null),
                (ThemeMode.system, Icons.phone_iphone_rounded, context.t.profile.themeSystemHint),
              ])
                _ThemeOption(
                  icon: icon,
                  title: themeModeLabel(context, mode),
                  hint: hint,
                  selected: provider.mode == mode,
                  onTap: () {
                    provider.setTheme(mode);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.hint,
  });

  final IconData icon;
  final String title;
  final String? hint;
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
            border: Border.all(color: selected ? primary : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? primary : colors.neutral.textBody),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (hint != null)
                      Text(hint!, style: context.text.label.copyWith(color: colors.neutral.textMuted)),
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
