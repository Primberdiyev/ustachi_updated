
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/app_update/app_update_api.dart';
import 'package:ustachi/core/services/app_update/app_update_gate.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';
import 'package:ustachi/core/services/app_update/app_update_sheet.dart';
import 'package:ustachi/core/services/app_update/app_update_service.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class _TestRouter extends AppRouter {
  @override
  List<AutoRoute> get routes => [
        NamedRouteDef(
          name: 'SplashPageRoute',
          path: '/',
          initial: true,
          builder: (_, __) => const Scaffold(body: Center(child: Text('SPLASH'))),
        ),
        NamedRouteDef(
          name: 'MainPageRoute',
          path: '/main',
          builder: (_, __) => const Scaffold(body: Center(child: Text('ASOSIY'))),
        ),
        NamedRouteDef(
          name: 'PhoneAuthPageRoute',
          path: '/auth',
          builder: (_, __) => const Scaffold(body: Center(child: Text('KIRISH'))),
        ),
      ];
}

class _FakeService extends AppUpdateService {
  _FakeService(this.info) : super(api: AppUpdateApi(Dio()));

  final AppUpdateInfo? info;
  int calls = 0;

  @override
  Future<AppUpdateInfo?> pendingUpdate({
    required String version,
    bool throttle = false,
  }) async {
    calls++;
    return info;
  }

  @override
  Future<void> snooze(AppUpdateInfo info) async {}
}

AppUpdateInfo _info({required bool forced}) => AppUpdateInfo.fromJson({
      'status': forced ? 'required' : 'optional',
      'current_version': '1.0.2',
      'latest_version': '1.0.3',
      'store_url': 'https://example.com/app',
      'notes': const <String>[],
    });

Future<_TestRouter> _pumpApp(WidgetTester tester, AppUpdateInfo? info) async {
  final router = _TestRouter();
  sl.registerSingleton<AppRouter>(router);
  sl.registerSingleton<AppUpdateService>(_FakeService(info));
  sl.registerSingleton<SnackbarService>(SnackbarService());
  addTearDown(() {
    sl.unregister<AppRouter>();
    sl.unregister<AppUpdateService>();
    sl.unregister<SnackbarService>();
  });

  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (_, __) => MaterialApp.router(
        routerConfig: router.config(),
        builder: (_, child) => AppUpdateGate(child: child ?? const SizedBox.shrink()),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  const requiredTitle = 'Yangilash talab qilinadi';
  const optionalTitle = 'Yangi versiya tayyor';
  const later = 'Keyinroq';

  testWidgets('SPLASH ustida varaq chiqmaydi, sahifa almashgach chiqadi', (tester) async {
    final router = await _pumpApp(tester, _info(forced: true));

    expect(find.text('SPLASH'), findsOneWidget);
    expect(find.byType(AppUpdateSheet), findsNothing, reason: 'splash o\'zini almashtiradi — ustiga chiqarib bo\'lmaydi');

    await router.navigatePath('/main');
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateSheet), findsOneWidget);
  });

  testWidgets('MAJBURIY varaqni sahifa almashuvi yopsa — qayta chiqadi', (tester) async {
    final router = await _pumpApp(tester, _info(forced: true));
    await router.navigatePath('/main');
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateSheet), findsOneWidget);

    await router.navigatePath('/auth');
    await tester.pumpAndSettle();

    expect(find.text('KIRISH'), findsOneWidget);
    expect(find.byType(AppUpdateSheet), findsOneWidget, reason: 'majburiy yangilanish yo\'qolmaydi');
    expect(find.text(requiredTitle), findsOneWidget, reason: 'yangi sahifa TAGIDA qolmaydi');
  });

  testWidgets('IXTIYORIY varaqda «Keyinroq» — boshqa so\'ralmaydi', (tester) async {
    final router = await _pumpApp(tester, _info(forced: false));
    await router.navigatePath('/main');
    await tester.pumpAndSettle();
    expect(find.text(optionalTitle), findsOneWidget);

    await tester.tap(find.text(later));
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateSheet), findsNothing);

    await router.navigatePath('/auth');
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateSheet), findsNothing);
  });

  testWidgets('yangilanish yo\'q — varaq umuman chiqmaydi', (tester) async {
    final router = await _pumpApp(tester, null);
    await router.navigatePath('/main');
    await tester.pumpAndSettle();

    expect(find.text('ASOSIY'), findsOneWidget);
    expect(find.byType(AppUpdateSheet), findsNothing);
    expect(find.byType(AppUpdateSheet), findsNothing);
  });
}
