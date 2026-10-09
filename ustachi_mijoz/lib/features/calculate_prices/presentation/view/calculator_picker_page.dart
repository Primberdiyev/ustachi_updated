import 'package:ustachi/features/calculate_prices/presentation/view/electrical_calculator_page.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/area_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/beton_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/heating_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/masonry_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/roof_calculator_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/variant_calculator_page.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/specialty_catalog.dart';

class CalculatorPickerPage extends StatefulWidget {
  const CalculatorPickerPage({super.key});

  @override
  State<CalculatorPickerPage> createState() => _CalculatorPickerPageState();
}

class _CalculatorPickerPageState extends State<CalculatorPickerPage> {
  SpecialtyCatalog get _catalog => sl<SpecialtyCatalog>();

  late bool _waiting = _catalog.isEmpty;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh({bool force = false}) async {
    await _catalog.ensureFresh(force: force);
    if (mounted && _waiting) setState(() => _waiting = false);
  }

  List<SpecialtyEntity> _calculable(List<SpecialtyEntity> all) =>
      all
          .where((s) =>
              s.hasCalculator && s.calculator != SpecialtyCalculator.rom)
          .toList();

  void _open(SpecialtyEntity specialty) {
    switch (specialty.calculator) {

      case SpecialtyCalculator.rom:
        context.pushRouteSafe(const ProposalWizardPageRoute());

      case SpecialtyCalculator.area:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: areaCalculatorRouteName),
            builder: (_) => AreaCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.variant:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: variantCalculatorRouteName),
            builder: (_) => VariantCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.masonry:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: masonryCalculatorRouteName),
            builder: (_) => MasonryCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.roof:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: roofCalculatorRouteName),
            builder: (_) => RoofCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.beton:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: betonCalculatorRouteName),
            builder: (_) => BetonCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.heating:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: heatingCalculatorRouteName),
            builder: (_) => HeatingCalculatorPage(specialty: specialty),
          ),
        );

      case SpecialtyCalculator.electrical:
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: electricalCalculatorRouteName),
          builder: (_) => ElectricalCalculatorPage(specialty: specialty),
        ));
        return;

      case SpecialtyCalculator.none:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.neutral.bg,
      appBar: AppBar(title: Text(context.t.home.calculatePrice)),
      body: RefreshIndicator(
        onRefresh: () => _refresh(force: true),

        child: ValueListenableBuilder<List<SpecialtyEntity>>(
          valueListenable: _catalog,
          builder: (context, all, _) => _body(context, _calculable(all)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, List<SpecialtyEntity> items) {
    if (items.isEmpty) {

      if (_waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(ChizmaSpace.xxl),
        children: [
          SizedBox(height: context.screenSize.height * 0.12),
          const ChizmaEmptyState(
            icon: Icons.calculate_outlined,
            title: 'Hozircha hisoblanadigan yo\'nalish yo\'q',
            message: 'Internetni tekshirib qayta urinib ko\'ring yoki '
                'kerakli ishni "Xizmat turlari" dan tanlab, ustaga '
                'to\'g\'ridan-to\'g\'ri e\'lon bering.',
          ),
          const SizedBox(height: ChizmaSpace.lg),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _refresh(force: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.t.common.retry),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        ChizmaSpace.lg,
        ChizmaSpace.lg,
        ChizmaSpace.lg,
        ChizmaSpace.xxl + context.viewPaddingBottom,
      ),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.md),
      itemBuilder: (context, index) {
        if (index == 0) return const _Header();
        final specialty = items[index - 1];
        return _CalculatorCard(
          specialty: specialty,
          onTap: () => _open(specialty),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.xs),
      child: Text(
        'Qaysi ish uchun narx kerak? Bir necha savoldan keyin taxminiy '
        'hisobni ko\'rasiz va o\'sha hisob bilan usta chaqirasiz.',
        style: context.text.body5.copyWith(color: colors.neutral.textMuted),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.specialty, required this.onTap});

  final SpecialtyEntity specialty;
  final VoidCallback onTap;

  String get _promise => switch (specialty.calculator) {
        SpecialtyCalculator.rom =>
          'O\'lcham va shaklni tanlaysiz — chizma chiqadi, narxni usta aytadi',
        SpecialtyCalculator.area => specialty.isPerMetre
            ? 'Uzunligini (metr) kiritasiz — narx darhol chiqadi'
            : 'Maydonni (m²) kiritasiz — narx darhol chiqadi',

        SpecialtyCalculator.variant => specialty.variantPriceIsMaterial
            ? 'Har yuzaning bo\'yi va enini yozasiz — narx darhol chiqadi'
            : 'Har eshikning bo\'yi va enini yozasiz — narx darhol chiqadi',
        SpecialtyCalculator.masonry =>
          'Devor o\'lchamini kiritasiz — g\'isht soni va narxi chiqadi',
        SpecialtyCalculator.roof =>
          'Tom shakli va materialini tanlaysiz — tom maydoni o\'zi chiqadi',
        SpecialtyCalculator.beton =>
          'Uy yoki devor (zabor) o\'lchamini kiritasiz — poydevorga necha '
              'kub beton ketishi chiqadi',
        SpecialtyCalculator.heating =>
          'Xonalarni yozasiz — isitishga nechta radiator kerakligi chiqadi',
        SpecialtyCalculator.electrical =>
          'Uy o‘lchami va yoritish — materiallar narxi',
        SpecialtyCalculator.none => '',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;

    return ChizmaSheet(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(ChizmaSpace.sm),
            decoration: BoxDecoration(
              color: colors.neutral.surface2,
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
            ),
            child: SpecialtyVisuals.thumb(
              context,
              code: specialty.code,
              size: 36,
              tint: primary,
            ),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(

                  specialty.workName,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _promise,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: ChizmaSpace.sm),
          Icon(Icons.chevron_right_rounded,
              size: 22, color: colors.neutral.textMuted),
        ],
      ),
    );
  }
}
