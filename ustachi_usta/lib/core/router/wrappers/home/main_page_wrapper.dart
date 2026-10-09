import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/router/router_impls/auth/auth_router_impl.dart';
import 'package:ustachi/core/router/router_impls/main/main_router_impl.dart';
import 'package:ustachi/features/auth/domain/services/master_onboarding_check.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/view/complete_profile_page.dart';
import 'package:ustachi/features/auth/presentation/view/master_onboarding_gate.dart';
import 'package:ustachi/features/main/presentation/view/main_page.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';
import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart';

@RoutePage()
class MainPageWrapper extends StatelessWidget {
  const MainPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final check = MasterOnboardingCheck(
      sl<ProfileRepository>(),
      MasterProfileApi(sl<Dio>()),
    );
    return MasterOnboardingGate(
      check: check.call,
      reconnects: Connectivity()
          .onConnectivityChanged
          .where((results) => results.any((r) => r != ConnectivityResult.none))
          .map<void>((_) {}),
      onSignIn: () async {
        await sl<AuthLocalDataSource>().clearUserData();
        if (context.mounted) AuthRouterImpl().replaceWithPhoneAuth(context);
      },
      personalBuilder: (user, saved) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: CompleteProfilePage(
          router: AuthRouterImpl(),
          initialUser: user,
          onSaved: saved,
        ),
      ),
      professionalBuilder: (saved) => MasterProfessionalPage(
        isOnboarding: true,
        onSaved: saved,
      ),
      readyBuilder: (_) => MainPage(router: MainRouterImpl()),
    );
  }
}
