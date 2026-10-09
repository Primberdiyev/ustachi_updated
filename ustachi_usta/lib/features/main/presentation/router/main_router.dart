import 'package:flutter/material.dart';

abstract class MainRouter {
  void navigateToHome(BuildContext context);

  void navigateToCalculatePrices(BuildContext context);

  void navigateToChatting(BuildContext context);

  void navigateToProfile(BuildContext context);
}
