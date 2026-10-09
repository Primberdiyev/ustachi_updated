import 'dart:async';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/home/presentation/widgets/my_orders_card.dart';
import 'package:ustachi/features/home/presentation/view/all_specialties_page.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/calculator_picker_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/marketplace/presentation/view/my_orders_page.dart';
import 'package:ustachi/features/home/presentation/widgets/home_header_widget.dart';
import 'package:ustachi/features/home/presentation/widgets/services_widget.dart';
import 'package:ustachi/features/profile/presentation/widgets/telegram_channel_card.dart';

void _openCalculators(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(

      settings: const RouteSettings(name: calculatorPickerRouteName),
      builder: (_) => const CalculatorPickerPage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_prefetchMasters());
    });
  }

  Future<void> _prefetchMasters() async {
    try {
      await sl<MarketplaceRepository>().mastersPage();
    } catch (_) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final colors = context.color;

    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(
        ChizmaSpace.lg,
        ChizmaSpace.md,
        ChizmaSpace.lg,
        ChizmaSpace.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeaderWidget(),
          const SizedBox(height: ChizmaSpace.xl),

          TextField(
            readOnly: true,
            onTap: () => _openCalculators(context),
            decoration: InputDecoration(
              hintText: uz(t.todayQuestion),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: colors.neutral.textMuted,
              ),
            ),
          ),
          const SizedBox(height: ChizmaSpace.xl),

          ChizmaEyebrow(t.calculate),
          const SizedBox(height: ChizmaSpace.md),
          _CalculateHero(
            onTap: () => _openCalculators(context),
          ),
          const SizedBox(height: ChizmaSpace.md),

          MyOrdersCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyOrdersPage()),
            ),
          ),
          const SizedBox(height: ChizmaSpace.xl),

          ChizmaSectionHeader(
            title: t.serviceType,
            actionLabel: t.all,
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AllSpecialtiesPage(),
              ),
            ),
          ),
          const SizedBox(height: ChizmaSpace.md),
          const ServicesWidget(),
          const SizedBox(height: ChizmaSpace.xl),
          const TelegramChannelCard(),
        ],
      ),
    );
  }
}

class _CalculateHero extends StatelessWidget {
  const _CalculateHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.home;
    final primary = colors.categorizedColor.primary;

    final onPrimary = colors.neutral.white;
    final radius = BorderRadius.circular(ChizmaRadius.lg);

    return Material(
      color: primary,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,

        splashColor: onPrimary.withValues(alpha: 0.12),
        highlightColor: onPrimary.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.lg),

          decoration: BoxDecoration(borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(ChizmaRadius.md),
                    ),
                    child: Icon(Icons.calculate_rounded,
                        size: 28, color: onPrimary),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.calculatePrice,
                          style: context.text.h3.copyWith(color: onPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.calculateHeroSubtitle,

                          style: context.text.body5.copyWith(
                            color: onPrimary.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 22, color: onPrimary.withValues(alpha: 0.9)),
                ],
              ),
              const SizedBox(height: ChizmaSpace.md),
              Divider(
                height: 1,
                color: onPrimary.withValues(alpha: 0.22),
              ),
              const SizedBox(height: ChizmaSpace.md),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Step(number: '1', label: t.step1)),
                  Expanded(child: _Step(number: '2', label: t.step2)),
                  Expanded(child: _Step(number: '3', label: t.step3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {

    final onPrimary = context.color.neutral.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: context.text.label.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: context.text.label
                .copyWith(color: onPrimary.withValues(alpha: 0.85)),
          ),
        ),
      ],
    );
  }
}
