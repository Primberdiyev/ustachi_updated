import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ustachi/features/splash/domain/entities/splash_destination.dart';
import 'package:ustachi/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ustachi/features/splash/presentation/router/splash_router.dart';
import 'package:ustachi/features/splash/presentation/widgets/brand_mark_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.router});
  final SplashRouter router;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ClearProfileEvent());
    context.read<SplashBloc>().add(const CheckTokenAvailableEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logo), context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.color.categorizedColor.primary;
    final white = context.color.neutral.white;
    return Scaffold(
      backgroundColor: primary,
      body: BlocConsumer<SplashBloc, SplashState>(
        listenWhen: (previous, current) =>
            previous.destination != current.destination ||
            previous.status != current.status,
        listener: (context, state) {
          if (!state.status.isSuccess || state.destination == null) return;
          switch (state.destination!) {

            case SplashDestination.main:
              widget.router.navigateToMain(context);
            case SplashDestination.phoneAuth:
              widget.router.navigateToPhoneAuth(context);
            case SplashDestination.onboarding:
              widget.router.navigateToOnboarding(context);
          }
        },
        builder: (context, state) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              BrandMarkWidget(decoration: primary, iconColor: white),
              const SizedBox(height: 28),
              Text(context.t.applicationName,
                  style: context.text.h1.copyWith(
                    color: white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  )),
              const SizedBox(height: 15),
              Text(context.t.auth.tagline,
                  textAlign: TextAlign.center,
                  style: context.text.body4.copyWith(
                      color: white.withValues(alpha: 0.62),
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w600)),
              if (state.status.isFailure) ...[
                const SizedBox(height: 28),
                Text(state.failure?.errorMessage ?? context.t.common.wentWrong,
                    textAlign: TextAlign.center,
                    style: context.text.body3.copyWith(color: white)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context
                      .read<SplashBloc>()
                      .add(const CheckTokenAvailableEvent()),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: white), foregroundColor: white),
                  child: Text(context.t.common.retry),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
