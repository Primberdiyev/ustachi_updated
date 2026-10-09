import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';
import 'package:ustachi/core/services/app_update/app_update_service.dart';
import 'package:ustachi/core/services/app_update/app_update_sheet.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  late final AppRouter _router = sl<AppRouter>();
  late final AppUpdateService _service = sl<AppUpdateService>();

  AppUpdateInfo? _pending;
  bool _showing = false;

  Route<bool>? _sheetRoute;
  bool _reopen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router.addListener(_onRouteChanged);
    unawaited(_check());
  }

  @override
  void dispose() {
    _router.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_check(throttle: true));
    }
  }

  Future<void> _check({bool throttle = false}) async {
    final info = await _service.pendingUpdate(
      version: StorageRepository.version ?? '',
      throttle: throttle,
    );
    if (info == null || !mounted) return;
    _pending = info;
    _showIfReady();
  }

  void _onRouteChanged() {
    final sheet = _sheetRoute;

    if (sheet != null && sheet.isActive) {
      _sheetRoute = null;
      _reopen = true;
      sheet.navigator?.removeRoute(sheet);
      return;
    }
    _showIfReady();
  }

  bool get _onSplash => _router.current.name == SplashPageRoute.name;

  void _showIfReady() {
    final info = _pending;
    if (info == null || _showing || _onSplash) return;

    final context = _router.navigatorKey.currentContext;
    if (context == null) return;

    _showing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = mounted ? _router.navigatorKey.currentContext : null;
      if (ctx == null) {
        _showing = false;
        return;
      }
      unawaited(_present(ctx, info));
    });
  }

  Future<void> _present(BuildContext context, AppUpdateInfo info) async {
    final openFailedMessage =
        TranslationProvider.of(context).translations.appUpdate.openFailed;

    final wantsUpdate = await AppUpdateSheet.show(
      context,
      info: info,
      onLater: () => _service.snooze(info),
      onRoute: (route) => _sheetRoute = route,
    );
    _sheetRoute = null;

    if (wantsUpdate == true) {
      final opened = await AppUpdateSheet.openStore(info.storeUrl);
      if (!opened) {
        sl<SnackbarService>().showMessage(openFailedMessage);
      }
      if (info.isForced) {
        _showing = false;
        if (mounted) _showIfReady();
      }
      return;
    }

    if (wantsUpdate == null && (info.isForced || _reopen)) {
      _reopen = false;
      _showing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showIfReady();
      });
      return;
    }

    _reopen = false;
    _pending = null;
    _showing = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
