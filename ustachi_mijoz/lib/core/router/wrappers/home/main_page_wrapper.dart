import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/router_impls/main/main_router_impl.dart';
import 'package:ustachi/features/main/presentation/view/main_page.dart';

@RoutePage()
class MainPageWrapper extends StatelessWidget {
  const MainPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MainPage(
      router: MainRouterImpl(),
    );
  }
}
