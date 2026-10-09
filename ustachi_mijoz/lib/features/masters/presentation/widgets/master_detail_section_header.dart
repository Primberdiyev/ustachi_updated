import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MasterDetailSectionHeader extends StatelessWidget {
  const MasterDetailSectionHeader({
    super.key,
    required this.title,
    this.actionText,
  });

  final String title;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = context.text;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: text.h4.copyWith(
              color: colors.neutral.black1,
            ),
          ),
        ),
        if (actionText != null)
          Text(
            actionText ?? '',
            style: text.body4.copyWith(
              color: colors.categorizedColor.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
