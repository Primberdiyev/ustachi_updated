import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ustachi/core/api/dio_settings.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/core/services/app_update/app_update_api.dart';
import 'package:ustachi/core/services/app_update/app_update_service.dart';
import 'package:ustachi/core/services/push/push_device_api.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/services/session_cleanup_service.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/features/auth/auth_injections.dart';
import 'package:ustachi/features/splash/di/splash_injections.dart';
import 'package:ustachi/features/profile/di/profile_injections.dart';
import 'package:ustachi/features/marketplace/marketplace_injections.dart';
import 'package:ustachi/features/orders/orders_injections.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  await StorageRepository.getInstance();
  final dioSettings = DioSettings();

  sl.registerLazySingleton<AppRouter>(AppRouter.new);
  sl.registerLazySingleton<SnackbarService>(SnackbarService.new);
  sl.registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSource.new);
  sl.registerLazySingleton<DioSettings>(() => dioSettings);
  sl.registerLazySingleton<Dio>(() => dioSettings.dio);
  sl.registerLazySingleton<Dio>(
    () => dioSettings.publicDio,
    instanceName: 'publicDio',
  );
  initAuthDependencies(sl);
  initSplashInjection(sl);
  initProfileInjection(sl);
  initMarketplaceInjection(sl);
  initOrdersDependencies(sl);
  sl.registerLazySingleton<SessionCleanupService>(SessionCleanupService.new);
  sl.registerLazySingleton<AppUpdateApi>(() => AppUpdateApi(sl<Dio>()));
  sl.registerLazySingleton<AppUpdateService>(
    () => AppUpdateService(api: sl<AppUpdateApi>()),
  );
  sl.registerLazySingleton<PushDeviceApi>(() => PushDeviceApi(sl<Dio>()));
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(api: sl<PushDeviceApi>()),
  );

  sl.registerLazySingleton<HisobStore>(HisobStore.new);
  sl<OrderDraftStore>().restore();
  sl<HisobStore>().restore();

  await sl<AuthLocalDataSource>().getUserToken();
  dioSettings.setBaseOptions();
}

Future resetLocator() async {
  await sl.reset();
  await setupLocator();
}
