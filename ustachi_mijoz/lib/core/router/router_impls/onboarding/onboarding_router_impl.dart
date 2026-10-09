import 'package:auto_route/auto_route.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/auth/welcome/presentation/router/onboarding_router.dart';
import 'package:flutter/material.dart';

class OnboardingRouterImpl extends OnboardingRouter {
  @override
  void navigateToPhoneAuth(BuildContext context) {
    StorageRepository.putBool(
      key: StoreKeys.isFirstTime,
      value: false,
    );
    context.router.replaceAll([const PhoneAuthPageRoute()]);
  }
}
