import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/main/presentation/router/main_router.dart';

class MainRouterImpl implements MainRouter {
  @override
  void navigateToChatting(BuildContext context) => context.router.navigate(
        ChattingPageRoute(),
      );

  @override
  void navigateToHome(BuildContext context) => context.router.navigate(
        HomePageRoute(),
      );

  @override
  void navigateToProfile(BuildContext context) => context.router.navigate(
        ProfilePageRoute(),
      );
}
