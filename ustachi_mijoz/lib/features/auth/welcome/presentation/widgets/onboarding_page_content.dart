import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.artwork,
  });

  final String title;
  final String description;
  final Widget artwork;

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;
    final isSmallScreen = screenHeight < 700;

    const textPadding = EdgeInsets.symmetric(horizontal: 24);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              height:
                  isSmallScreen ? screenHeight * 0.03 : screenHeight * 0.05),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: SizedBox(
              height:
                  isSmallScreen ? screenHeight * 0.36 : screenHeight * 0.44,
              child: artwork,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 28),
          Padding(
            padding: textPadding,
            child: Column(
              children: [
                Text(
                  title,
                  style: context.text.h2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 10 : 16),
                Text(
                  description,
                  style: context.text.body3.copyWith(
                    color: context.color.neutral.textBody,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
