import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/router_impls/auth/auth_router_impl.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/view/phone_auth_page.dart';

@RoutePage()
class PhoneAuthPageWrapper extends StatelessWidget {
  const PhoneAuthPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: PhoneAuthPage(
        router: AuthRouterImpl(),
      ),
    );
  }
}
