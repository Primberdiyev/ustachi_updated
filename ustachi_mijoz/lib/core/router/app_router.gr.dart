
part of 'app_router.dart';

class ChattingPageRoute extends PageRouteInfo<void> {
  const ChattingPageRoute({List<PageRouteInfo>? children})
      : super(ChattingPageRoute.name, initialChildren: children);

  static const String name = 'ChattingPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChattingPageWrapper();
    },
  );
}

class CompleteProfilePageRoute extends PageRouteInfo<void> {
  const CompleteProfilePageRoute({List<PageRouteInfo>? children})
      : super(CompleteProfilePageRoute.name, initialChildren: children);

  static const String name = 'CompleteProfilePageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CompleteProfilePageWrapper();
    },
  );
}

class HomePageRoute extends PageRouteInfo<void> {
  const HomePageRoute({List<PageRouteInfo>? children})
      : super(HomePageRoute.name, initialChildren: children);

  static const String name = 'HomePageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePageWrapper();
    },
  );
}

class MainPageRoute extends PageRouteInfo<void> {
  const MainPageRoute({List<PageRouteInfo>? children})
      : super(MainPageRoute.name, initialChildren: children);

  static const String name = 'MainPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPageWrapper();
    },
  );
}

class MasterDetailPageRoute extends PageRouteInfo<void> {
  const MasterDetailPageRoute({List<PageRouteInfo>? children})
      : super(MasterDetailPageRoute.name, initialChildren: children);

  static const String name = 'MasterDetailPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MasterDetailPageWrapper();
    },
  );
}

class MastersPageRoute extends PageRouteInfo<void> {
  const MastersPageRoute({List<PageRouteInfo>? children})
      : super(MastersPageRoute.name, initialChildren: children);

  static const String name = 'MastersPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MastersPageWrapper();
    },
  );
}

class OnboardingPageRoute extends PageRouteInfo<void> {
  const OnboardingPageRoute({List<PageRouteInfo>? children})
      : super(OnboardingPageRoute.name, initialChildren: children);

  static const String name = 'OnboardingPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingPageWrapper();
    },
  );
}

class OtpConfirmPageRoute extends PageRouteInfo<OtpConfirmPageRouteArgs> {
  OtpConfirmPageRoute({
    Key? key,
    required String phoneNumber,
    List<PageRouteInfo>? children,
  }) : super(
          OtpConfirmPageRoute.name,
          args: OtpConfirmPageRouteArgs(key: key, phoneNumber: phoneNumber),
          initialChildren: children,
        );

  static const String name = 'OtpConfirmPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpConfirmPageRouteArgs>();
      return OtpConfirmPageWrapper(
        key: args.key,
        phoneNumber: args.phoneNumber,
      );
    },
  );
}

class OtpConfirmPageRouteArgs {
  const OtpConfirmPageRouteArgs({this.key, required this.phoneNumber});

  final Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OtpConfirmPageRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpConfirmPageRouteArgs) return false;
    return key == other.key && phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode => key.hashCode ^ phoneNumber.hashCode;
}

class PhoneAuthPageRoute extends PageRouteInfo<void> {
  const PhoneAuthPageRoute({List<PageRouteInfo>? children})
      : super(PhoneAuthPageRoute.name, initialChildren: children);

  static const String name = 'PhoneAuthPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PhoneAuthPageWrapper();
    },
  );
}

class TelegramExchangePageRoute extends PageRouteInfo<void> {
  const TelegramExchangePageRoute({List<PageRouteInfo>? children})
      : super(TelegramExchangePageRoute.name, initialChildren: children);

  static const String name = 'TelegramExchangePageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TelegramExchangePageWrapper();
    },
  );
}

class ProfilePageRoute extends PageRouteInfo<void> {
  const ProfilePageRoute({List<PageRouteInfo>? children})
      : super(ProfilePageRoute.name, initialChildren: children);

  static const String name = 'ProfilePageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePageWrapper();
    },
  );
}

class ProposalResultsPageRoute
    extends PageRouteInfo<ProposalResultsPageRouteArgs> {
  ProposalResultsPageRoute({
    Key? key,
    required ProposalRequest request,
    List<PageRouteInfo>? children,
  }) : super(
          ProposalResultsPageRoute.name,
          args: ProposalResultsPageRouteArgs(key: key, request: request),
          initialChildren: children,
        );

  static const String name = 'ProposalResultsPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProposalResultsPageRouteArgs>();
      return ProposalResultsPageWrapper(key: args.key, request: args.request);
    },
  );
}

class ProposalResultsPageRouteArgs {
  const ProposalResultsPageRouteArgs({this.key, required this.request});

  final Key? key;

  final ProposalRequest request;

  @override
  String toString() {
    return 'ProposalResultsPageRouteArgs{key: $key, request: $request}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProposalResultsPageRouteArgs) return false;
    return key == other.key && request == other.request;
  }

  @override
  int get hashCode => key.hashCode ^ request.hashCode;
}

class ProposalWizardPageRoute extends PageRouteInfo<void> {
  const ProposalWizardPageRoute({List<PageRouteInfo>? children})
      : super(ProposalWizardPageRoute.name, initialChildren: children);

  static const String name = 'ProposalWizardPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProposalWizardPageWrapper();
    },
  );
}

class SplashPageRoute extends PageRouteInfo<void> {
  const SplashPageRoute({List<PageRouteInfo>? children})
      : super(SplashPageRoute.name, initialChildren: children);

  static const String name = 'SplashPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPageWrapper();
    },
  );
}
