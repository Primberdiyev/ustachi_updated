
part of 'app_router.dart';

class CalculatePricesPageRoute extends PageRouteInfo<void> {
  const CalculatePricesPageRoute({List<PageRouteInfo>? children})
      : super(CalculatePricesPageRoute.name, initialChildren: children);

  static const String name = 'CalculatePricesPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalculatePricesPageWrapper();
    },
  );
}

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

class OrderDetailPageRoute extends PageRouteInfo<OrderDetailPageRouteArgs> {
  OrderDetailPageRoute({
    Key? key,
    required String orderId,
    List<PageRouteInfo>? children,
  }) : super(
          OrderDetailPageRoute.name,
          args: OrderDetailPageRouteArgs(key: key, orderId: orderId),
          initialChildren: children,
        );

  static const String name = 'OrderDetailPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrderDetailPageRouteArgs>();
      return OrderDetailPageWrapper(key: args.key, orderId: args.orderId);
    },
  );
}

class OrderDetailPageRouteArgs {
  const OrderDetailPageRouteArgs({this.key, required this.orderId});

  final Key? key;

  final String orderId;

  @override
  String toString() {
    return 'OrderDetailPageRouteArgs{key: $key, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderDetailPageRouteArgs) return false;
    return key == other.key && orderId == other.orderId;
  }

  @override
  int get hashCode => key.hashCode ^ orderId.hashCode;
}

class OrderRequestPageRoute extends PageRouteInfo<OrderRequestPageRouteArgs> {
  OrderRequestPageRoute({
    Key? key,
    required String requestId,
    List<PageRouteInfo>? children,
  }) : super(
          OrderRequestPageRoute.name,
          args: OrderRequestPageRouteArgs(key: key, requestId: requestId),
          initialChildren: children,
        );

  static const String name = 'OrderRequestPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrderRequestPageRouteArgs>();
      return OrderRequestPageWrapper(key: args.key, requestId: args.requestId);
    },
  );
}

class OrderRequestPageRouteArgs {
  const OrderRequestPageRouteArgs({this.key, required this.requestId});

  final Key? key;

  final String requestId;

  @override
  String toString() {
    return 'OrderRequestPageRouteArgs{key: $key, requestId: $requestId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderRequestPageRouteArgs) return false;
    return key == other.key && requestId == other.requestId;
  }

  @override
  int get hashCode => key.hashCode ^ requestId.hashCode;
}

class OrdersPageRoute extends PageRouteInfo<void> {
  const OrdersPageRoute({List<PageRouteInfo>? children})
      : super(OrdersPageRoute.name, initialChildren: children);

  static const String name = 'OrdersPageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersPageWrapper();
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
