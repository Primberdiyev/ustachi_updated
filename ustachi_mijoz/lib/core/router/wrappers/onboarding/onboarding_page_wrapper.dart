import 'package:auto_route/auto_route.dart';
import 'package:ustachi/core/router/router_impls/onboarding/onboarding_router_impl.dart';
import 'package:ustachi/features/auth/welcome/presentation/view/onboarding_page.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OnboardingPageWrapper extends StatelessWidget {
  const OnboardingPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      router: OnboardingRouterImpl(),
    );
  }
}
