import 'package:auto_route/auto_route.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/auth/presentation/view/country_select_page.dart';
import 'package:ustachi/features/splash/presentation/router/splash_router.dart';
import 'package:flutter/material.dart';

class SplashRouterImpl extends SplashRouter {
  @override
  Future<void> navigateToPhoneAuth(BuildContext context) =>
      context.router.replace(const PhoneAuthPageRoute());

  @override
  Future<void> navigateToMain(BuildContext context) =>
      context.router.replaceAll([const MainPageRoute()]);

  @override
  Future<void> navigateToOnboarding(BuildContext context) async {
    if (LanguageProvider().needsCountry) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CountrySelectPage()),
      );
    }
    if (context.mounted) {
      await context.router.replace(const OnboardingPageRoute());
    }
  }
}
