import 'package:flutter/material.dart';

abstract class SplashRouter {
  Future<void> navigateToMain(BuildContext context);

  Future<void> navigateToOnboarding(BuildContext context);

  Future<void> navigateToPhoneAuth(BuildContext context);
}
