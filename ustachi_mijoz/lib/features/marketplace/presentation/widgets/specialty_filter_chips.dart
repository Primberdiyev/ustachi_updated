import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';

class SpecialtyFilterChips extends StatefulWidget {
  const SpecialtyFilterChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  State<SpecialtyFilterChips> createState() => _SpecialtyFilterChipsState();
}

class _SpecialtyFilterChipsState extends State<SpecialtyFilterChips> {
  List<SpecialtyEntity> _specialties = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<MarketplaceRepository>().specialties();
    if (!mounted || result.isLeft) return;
    setState(() => _specialties = result.right);
  }

  @override
  Widget build(BuildContext context) {
    if (_specialties.isEmpty) return const SizedBox.shrink();
    final colors = context.color;

    Widget chip(String label, int? id) {
      final selected = widget.selectedId == id;
      return Padding(
        padding: const EdgeInsets.only(right: ChizmaSpace.xs),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => widget.onSelected(id),
          labelStyle: context.text.body5.copyWith(
            color: selected
                ? colors.categorizedColor.onPrimary
                : colors.neutral.textBody,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          selectedColor: colors.categorizedColor.primary,
          backgroundColor: colors.neutral.surface,
          side: BorderSide(
            color: selected
                ? colors.categorizedColor.primary
                : colors.neutral.border,
          ),
          showCheckmark: false,
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          chip(context.t.masters.all, null),
          for (final specialty in _specialties)
            chip(localizedSpecialtyName(context, specialty.code, specialty.name), specialty.id),
        ],
      ),
    );
  }
}
