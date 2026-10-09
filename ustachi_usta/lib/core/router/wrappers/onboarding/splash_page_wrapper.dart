import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/router_impls/onboarding/splash_router_impl.dart';
import 'package:ustachi/features/splash/presentation/view/splash_page.dart';
import 'package:ustachi/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashPageWrapper extends StatelessWidget {
  const SplashPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashBloc>(),
      child: SplashPage(
        router: SplashRouterImpl(),
      ),
    );
  }
}
