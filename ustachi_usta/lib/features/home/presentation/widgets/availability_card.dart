import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/home/presentation/widgets/work_preference_card.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({
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
      title: t.availableTitle,
      statusText: value ? t.availableOn : t.availableOff,
      icon: Icons.work_outline_rounded,
      value: value,
      isSaving: isSaving,
      compact: compact,
      onChanged: onChanged,
    );
  }
}
