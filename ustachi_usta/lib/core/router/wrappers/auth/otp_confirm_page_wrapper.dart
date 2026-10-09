import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/router_impls/auth/auth_router_impl.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/view/otp_confirm_page.dart';

@RoutePage()
class OtpConfirmPageWrapper extends StatelessWidget {
  const OtpConfirmPageWrapper({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: OtpConfirmPage(
        phoneNumber: phoneNumber,
        router: AuthRouterImpl(),
      ),
    );
  }
}
