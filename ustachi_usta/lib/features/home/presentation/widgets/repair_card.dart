import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/home/presentation/widgets/work_preference_card.dart';

class RepairCard extends StatelessWidget {
  const RepairCard({
    super.key,
    required this.value,
    required this.onChanged,
    this.isSaving = false,
    this.compact = false,
  });

  final bool value;
  final bool isSaving;
  final bool compact;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t.dashboard;
    return WorkPreferenceCard(
      title: t.repairTitle,
      statusText: value ? t.repairOn : t.repairOff,
      description: t.repairHint,
      icon: Icons.handyman_outlined,
      value: value,
      isSaving: isSaving,
      compact: compact,
      accentColor: context.color.categorizedColor.primary,
      onChanged: onChanged,
    );
  }
}
