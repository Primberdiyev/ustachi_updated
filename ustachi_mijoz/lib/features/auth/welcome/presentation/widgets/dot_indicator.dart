import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/extensions.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.currentPageNotifier,
    required this.itemCount,
  });

  final ValueNotifier<int> currentPageNotifier;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPageNotifier,
      builder: (context, currentPage, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? context.color.categorizedColor.primary
                    : context.color.categorizedColor.primary
                        .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}
