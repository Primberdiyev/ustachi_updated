import 'package:ustachi/features/calculate_prices/presentation/view/electrical_calculator_page.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/area_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/beton_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/heating_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/masonry_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/roof_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/variant_calculator_page.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';
import 'package:ustachi/features/repair/presentation/view/repair_order_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';

/// Soha bosilganda: ta'miri bor sohada avval "Yangi ish / Ta'mir" so'raladi
/// (kran oqqani uchun kirgan mijoz isitish kalkulyatoriga tushib qolmasin).
/// Eshik-romda so'ralmaydi — "Ta'mir" uning o'z sahifasida turadi.
Future<void> openSpecialtyFlow(
  BuildContext context,
  SpecialtyEntity specialty,
) async {
  if (specialty.hasRepair && !specialty.isRom) {
    final repair = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => _WorkKindSheet(specialty: specialty),
    );
    if (repair == null || !context.mounted) return;
    if (repair) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: repairOrderRouteName),
          builder: (_) => RepairOrderPage(specialty: specialty),
        ),
      );
      return;
    }
  }
  if (!context.mounted) return;
  await _openNewWork(context, specialty);
}

class _WorkKindSheet extends StatelessWidget {
  const _WorkKindSheet({required this.specialty});
  final SpecialtyEntity specialty;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(specialty.name, style: context.text.h4),
            const SizedBox(height: ChizmaSpace.xs),
            Text(
              'Sizga nima kerak?',
              style: context.text.body5
                  .copyWith(color: context.color.neutral.textMuted),
            ),
            const SizedBox(height: ChizmaSpace.md),
            CalculatorOption(
              title: 'Ta\'mir',
              description: 'Buzilgan narsani tuzatish. O\'lcham kerak emas — '
                  'narxni usta ko\'rib aytadi.',
              leading: const Icon(Icons.build_outlined),
              selected: false,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: ChizmaSpace.sm),
            CalculatorOption(
              title: 'Yangi ish',
              description: specialty.hasCalculator
                  ? 'O\'rnatish yoki qurish — o\'lcham kiritiladi, narx hisoblanadi.'
                  : 'O\'rnatish yoki qurish — e\'lon berasiz, ustalar narx aytadi.',
              leading: const Icon(Icons.construction_outlined),
              selected: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openNewWork(
  BuildContext context,
  SpecialtyEntity specialty,
) async {
  switch (specialty.calculator) {
    case SpecialtyCalculator.rom:
      context.pushRouteSafe(const ProposalWizardPageRoute());
      return;

    case SpecialtyCalculator.area:

      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: areaCalculatorRouteName),
            builder: (_) => AreaCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.variant:
      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: variantCalculatorRouteName),
            builder: (_) => VariantCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.masonry:
      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: masonryCalculatorRouteName),
            builder: (_) => MasonryCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.roof:
      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: roofCalculatorRouteName),
            builder: (_) => RoofCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.beton:
      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: betonCalculatorRouteName),
            builder: (_) => BetonCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.heating:
      if (specialty.hasCalculator) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: heatingCalculatorRouteName),
            builder: (_) => HeatingCalculatorPage(specialty: specialty),
          ),
        );
        return;
      }

    case SpecialtyCalculator.electrical:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: electricalCalculatorRouteName),
        builder: (_) => ElectricalCalculatorPage(specialty: specialty),
      ));
      return;

    case SpecialtyCalculator.none:
      break;
  }

  final navigator = Navigator.of(context);
  final order = await navigator.push<OrderEntity>(
    MaterialPageRoute<OrderEntity>(
      builder: (_) => TradeOrderPage(specialty: specialty),
    ),
  );
  if (order == null) return;

  await navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => OrderDetailPage(orderId: order.id),
    ),
  );
}
