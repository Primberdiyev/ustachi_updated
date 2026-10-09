import 'package:auto_route/auto_route.dart';
import 'package:ustachi/features/home/presentation/view/home_page.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}
