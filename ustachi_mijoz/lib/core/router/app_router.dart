import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:ustachi/core/router/wrappers/home/chatting_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/home_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/proposal_wizard_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/proposal_results_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/main_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/masters_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/home/profile_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/masters/master_detail_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/onboarding/splash_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/onboarding/onboarding_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/auth/otp_confirm_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/auth/phone_auth_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/auth/complete_profile_page_wrapper.dart';
import 'package:ustachi/core/router/wrappers/auth/telegram_exchange_page_wrapper.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Wrapper,Route',
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashPageRoute.page, initial: true),
        AutoRoute(page: OnboardingPageRoute.page),

        AutoRoute(page: PhoneAuthPageRoute.page),
        AutoRoute(
          page: TelegramExchangePageRoute.page,
          path: '/app/auth/telegram/:code/',
        ),
        AutoRoute(page: OtpConfirmPageRoute.page),
        AutoRoute(page: CompleteProfilePageRoute.page),

        AutoRoute(page: ProposalWizardPageRoute.page),
        AutoRoute(page: ProposalResultsPageRoute.page),
        AutoRoute(page: MasterDetailPageRoute.page),
        AutoRoute(
          page: MainPageRoute.page,
          children: [
            AutoRoute(page: HomePageRoute.page),
            AutoRoute(page: MastersPageRoute.page),
            AutoRoute(page: ChattingPageRoute.page),
            AutoRoute(page: ProfilePageRoute.page),
          ],
        ),
      ];
}
