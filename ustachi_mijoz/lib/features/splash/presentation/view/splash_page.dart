import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
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
    context.read<ProfileBloc>().add(
          const ClearProfileEvent(),
        );
    context.read<SplashBloc>().add(
          const CheckTokenAvailableEvent(),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(const AssetImage(AppImages.logo), context);
  }

  bool _isAuthFailure(Failure? failure) {
    return failure is ServerFailure &&
        <int>[401, 403].contains(failure.statusCode);
  }

  bool _shouldClearSessionLocally(Failure? failure) {
    return failure is ServerFailure && failure.statusCode == 403;
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.color.categorizedColor.primary;
    final white = context.color.neutral.white;

    return Scaffold(
      backgroundColor: primary,
      body: MultiBlocListener(
        listeners: [
          BlocListener<SplashBloc, SplashState>(
            listenWhen: (previous, current) =>
                previous.destination != current.destination ||
                previous.status != current.status,
            listener: (context, state) {

              if (!state.status.isSuccess || state.destination == null) {
                return;
              }
              switch (state.destination!) {
                case SplashDestination.main:

                  context.read<ProfileBloc>().add(GetUserDataEvent());
                case SplashDestination.authSelection:

                  widget.router.navigateToPhoneAuth(context);
                case SplashDestination.onboarding:
                  widget.router.navigateToOnboarding(context);
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                previous.getUserDataStatus != current.getUserDataStatus,
            listener: (context, state) {
              if (state.getUserDataStatus.isSuccess) {
                widget.router.navigateToMain(context);
                return;
              }

              if (!state.getUserDataStatus.isFailure) {
                return;
              }

              if (_shouldClearSessionLocally(state.failure)) {
                context.read<SplashBloc>().add(
                      const ClearSessionAndOpenAuthEvent(),
                    );
              }
            },
          ),
        ],
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, splashState) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                final showRetry = splashState.status.isFailure ||
                    (profileState.getUserDataStatus.isFailure &&
                        !_isAuthFailure(profileState.failure));

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BrandMarkWidget(
                          decoration: primary,
                          iconColor: white,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          context.t.applicationName,
                          style: context.text.h1.copyWith(
                            color: white,
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          context.t.auth.selection.easyFindMaster,
                          style: context.text.body4.copyWith(
                            color: white.withValues(alpha: 0.62),
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (showRetry) ...[
                          const SizedBox(height: 28),
                          Text(
                            splashState.failure?.errorMessage ??
                                profileState.failure?.errorMessage ??
                                context.t.common.wentWrong,
                            style: context.text.body3.copyWith(color: white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              context.read<SplashBloc>().add(
                                    const CheckTokenAvailableEvent(),
                                  );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: white),
                              foregroundColor: white,
                            ),
                            child: Text(context.t.home.retry),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
