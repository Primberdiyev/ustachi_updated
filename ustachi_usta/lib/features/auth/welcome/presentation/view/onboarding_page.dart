import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/features/auth/presentation/widgets/language_chip.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/welcome/presentation/router/onboarding_router.dart';
import 'package:ustachi/features/auth/welcome/presentation/widgets/dot_indicator.dart';
import 'package:ustachi/features/auth/welcome/presentation/widgets/onboarding_page_content.dart';

Widget _art(String path) => Image.asset(path, fit: BoxFit.contain);

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.router,
  });

  final OnboardingRouter router;

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final currentPageNotifier = ValueNotifier<int>(0);
    final screenHeight = context.screenSize.height;
    final isSmallScreen = screenHeight < 700;

    final pages = [
      OnboardingPageContent(
        title: context.t.onboarding.step1.title,
        description: context.t.onboarding.step1.description,
        artwork: _art(AppImages.onboarding1),
      ),
      OnboardingPageContent(
        title: context.t.onboarding.step2.title,
        description: context.t.onboarding.step2.description,
        artwork: _art(AppImages.onboarding2),
      ),
      OnboardingPageContent(
        title: context.t.onboarding.step3.title,
        description: context.t.onboarding.step3.description,
        artwork: _art(AppImages.onboarding3),
      ),
    ];

    return Scaffold(
      backgroundColor: context.color.neutral.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: isSmallScreen ? 8.0 : 16.0,
              ),
              child: Row(
                children: [

                  const LanguageChip(),
                  const Spacer(),
                  TextButton(
                    onPressed: () => router.navigateToPhoneAuth(context),
                    child: Text(
                      context.t.common.skip,
                      style: context.text.body3.copyWith(
                        color: context.color.categorizedColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  currentPageNotifier.value = index;
                },
                children: pages,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isSmallScreen ? 8 : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DotIndicator(
                    currentPageNotifier: currentPageNotifier,
                    itemCount: pages.length,
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: currentPageNotifier,
                    builder: (context, currentPage, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              context.color.categorizedColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        onPressed: () {
                          if (currentPage < pages.length - 1) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            router.navigateToPhoneAuth(context);
                          }
                        },
                        child: Text(
                          currentPage == pages.length - 1
                              ? context.t.common.start
                              : context.t.common.next,
                          style: context.text.body3.copyWith(
                            color: context.color.neutral.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
