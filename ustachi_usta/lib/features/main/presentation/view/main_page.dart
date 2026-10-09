import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/main/presentation/router/main_router.dart';
import 'package:ustachi/features/main/presentation/widgets/main_bottom_bar.dart';
import 'package:ustachi/features/main/presentation/widgets/main_side_rail.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.router});

  final MainRouter router;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const List<PageRouteInfo> _tabRoutes = [
    HomePageRoute(),
    OrdersPageRoute(),
    ChattingPageRoute(),
    ProfilePageRoute(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _releasePendingNotification();
  }

  void _releasePendingNotification() {
    if (!sl.isRegistered<PushNotificationService>()) return;
    final push = sl<PushNotificationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => push.appReady());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
        if (sl.isRegistered<PushNotificationService>()) {
        sl<PushNotificationService>().retryIfNeeded();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: _tabRoutes,
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final isExpanded = context.breakpoint.isExpanded;
        final body = SafeArea(top: true, bottom: false, child: child);

        return Scaffold(
          backgroundColor: context.color.neutral.bg,
          body: isExpanded
              ? Row(
                  children: [
                    MainSideRail(tabsRouter: tabsRouter),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: body),
                  ],
                )
              : body,
          bottomNavigationBar:
              isExpanded ? null : MainBottomBar(tabsRouter: tabsRouter),
        );
      },
    );
  }
}
