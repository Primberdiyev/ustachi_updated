import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/assets/lib/gen/assets.gen.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/main/presentation/router/main_router.dart';
import 'package:ustachi/features/main/presentation/widgets/nav_bar_item.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.router,
  });
  final MainRouter router;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final PageController pageController = PageController();

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
    final locale = context.t;

    return AutoTabsScaffold(

      backgroundColor: context.color.neutral.bg,
      routes: [
        const HomePageRoute(),
        const MastersPageRoute(),
        const ChattingPageRoute(),
        const ProfilePageRoute(),
      ],

      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: SafeArea(top: true, bottom: false, child: child),
      ),
      bottomNavigationBuilder: (context, tabsRouter) {
        final colors = context.color;
        final text = context.text;

        final bottomInset = MediaQuery.paddingOf(context).bottom;
        final contentHeight = (90 - bottomInset).clamp(56.0, 90.0);

        return DecoratedBox(

          decoration: BoxDecoration(
            color: colors.neutral.surface,
          ),

          child: SafeArea(
            top: false,
            child: SizedBox(
              height: contentHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavBarItem(
                    label: locale.home.main,
                    selected: tabsRouter.activeIndex == 0,
                    onTap: () {
                      tabsRouter.setActiveIndex(0);
                    },
                    inActiveIconPath: Assets.images.home.path,
                    activeIconPath: Assets.images.homeActive.path,
                    activeTextStyle: text.body2.copyWith(
                      color: colors.categorizedColor.primary,
                    ),
                    passiveTextStyle: text.body2.copyWith(
                      color: colors.neutral.black2,
                    ),
                  ),
                  NavBarItem(
                    label: context.t.home.masters,
                    selected: tabsRouter.activeIndex == 1,
                    onTap: () {
                      tabsRouter.setActiveIndex(1);
                    },
                    inActiveIconPath: Assets.images.findMaster.path,
                    activeIconPath: Assets.images.findMaster.path,
                    activeTextStyle: text.body2.copyWith(
                      color: colors.categorizedColor.primary,
                    ),
                    passiveTextStyle: text.body2.copyWith(
                      color: colors.neutral.black2,
                    ),
                  ),
                  NavBarItem(
                    label: locale.home.chatting,
                    selected: tabsRouter.activeIndex == 2,
                    onTap: () {
                      tabsRouter.setActiveIndex(2);
                    },
                    inActiveIconPath: Assets.images.chat.path,
                    activeIconPath: Assets.images.chatActive.path,
                    activeTextStyle: text.body2.copyWith(
                      color: colors.categorizedColor.primary,
                    ),
                    passiveTextStyle: text.body2.copyWith(
                      color: colors.neutral.black2,
                    ),
                  ),
                  NavBarItem(
                    label: locale.home.profile,
                    selected: tabsRouter.activeIndex == 3,
                    onTap: () {
                      tabsRouter.setActiveIndex(3);
                    },
                    inActiveIconPath: Assets.images.user.path,
                    activeIconPath: Assets.images.userActive.path,
                    activeTextStyle: text.body2.copyWith(
                      color: colors.categorizedColor.primary,
                    ),
                    passiveTextStyle: text.body2.copyWith(
                      color: colors.neutral.black2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
