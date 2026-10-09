import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/auth/presentation/view/country_select_page.dart';

class LanguageChip extends StatefulWidget {
  const LanguageChip({super.key});

  @override
  State<LanguageChip> createState() => _LanguageChipState();
}

class _LanguageChipState extends State<LanguageChip> {
  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CountrySelectPage()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.neutral.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.neutral.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            m.Text(
              LanguageProvider().choice.label,
              style: context.text.label.copyWith(
                color: colors.neutral.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: colors.neutral.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
