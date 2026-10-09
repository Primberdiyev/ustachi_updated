import 'package:flutter/material.dart';

abstract class AuthRouter {
  void replaceWithHome(BuildContext context);

  void replaceWithPhoneAuth(BuildContext context);

  void navigateToOtpConfirm(
    BuildContext context, {
    required String phoneNumber,
  });

  void replaceWithCompleteProfile(BuildContext context);
}
