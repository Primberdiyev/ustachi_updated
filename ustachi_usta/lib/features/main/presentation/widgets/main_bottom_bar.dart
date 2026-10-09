import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/main/presentation/widgets/main_bottom_tab.dart';
import 'package:ustachi/features/main/presentation/widgets/main_tab_spec.dart';

class MainBottomBar extends StatelessWidget {
  const MainBottomBar({super.key, required this.tabsRouter});

  static const double _maxHeight = 86;
  static const double _minHeight = 54;

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final tabs = mainTabSpecs(context);

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final contentHeight =
        (_maxHeight - bottomInset).clamp(_minHeight, _maxHeight);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        border: Border(top: BorderSide(color: colors.neutral.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: contentHeight,
          child: Row(
            children: [
              for (var index = 0; index < tabs.length; index++)
                Expanded(
                  child: MainBottomTab(
                    spec: tabs[index],
                    selected: tabsRouter.activeIndex == index,
                    onTap: () => tabsRouter.setActiveIndex(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
