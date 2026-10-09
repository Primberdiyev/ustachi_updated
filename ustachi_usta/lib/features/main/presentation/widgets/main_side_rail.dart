import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/main/presentation/widgets/main_tab_spec.dart';

class MainSideRail extends StatelessWidget {
  const MainSideRail({super.key, required this.tabsRouter});

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final tabs = mainTabSpecs(context);

    return NavigationRail(
      backgroundColor: colors.neutral.surface,
      selectedIndex: tabsRouter.activeIndex,
      onDestinationSelected: tabsRouter.setActiveIndex,
      labelType: NavigationRailLabelType.all,
      indicatorColor: colors.categorizedColor.primary.withValues(alpha: 0.12),
      selectedIconTheme: IconThemeData(
        color: colors.categorizedColor.primary,
        size: 22,
      ),
      unselectedIconTheme: IconThemeData(
        color: colors.neutral.textMuted,
        size: 22,
      ),
      selectedLabelTextStyle: context.text.body5.copyWith(
        fontSize: 11,
        color: colors.categorizedColor.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: context.text.body5.copyWith(
        fontSize: 11,
        color: colors.neutral.textMuted,
      ),
      destinations: [
        for (final spec in tabs)
          NavigationRailDestination(
            icon: Icon(spec.icon),
            selectedIcon: Icon(spec.activeIcon),
            label: Padding(
              padding: const EdgeInsets.only(bottom: ChizmaSpace.xs),
              child: Text(spec.label),
            ),
          ),
      ],
    );
  }
}
