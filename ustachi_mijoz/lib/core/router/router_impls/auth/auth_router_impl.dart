import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';

class AuthRouterImpl implements AuthRouter {

  @override
  void replaceWithHome(BuildContext context) =>
      context.router.root.replaceAll([const MainPageRoute()]);

  @override
  void replaceWithPhoneAuth(BuildContext context) =>
      context.router.root.replaceAll([const PhoneAuthPageRoute()]);

  @override
  void navigateToOtpConfirm(
    BuildContext context, {
    required String phoneNumber,
  }) =>
      context.router.push(OtpConfirmPageRoute(phoneNumber: phoneNumber));

  @override
  void replaceWithCompleteProfile(BuildContext context) =>
      context.router.replaceAll([const CompleteProfilePageRoute()]);
}
