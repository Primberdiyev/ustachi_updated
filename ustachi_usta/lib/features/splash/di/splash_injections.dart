import 'package:get_it/get_it.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/features/splash/data/data_sources/splash_local_data_source.dart';
import 'package:ustachi/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:ustachi/features/splash/domain/repositories/splash_repository.dart';
import 'package:ustachi/features/splash/domain/use_cases/clear_session_use_case.dart';
import 'package:ustachi/features/splash/domain/use_cases/resolve_startup_use_case.dart';
import 'package:ustachi/features/splash/presentation/bloc/splash_bloc.dart';

void initSplashInjection(GetIt getIt) {
  getIt.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSource(
      getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      localDataSource: getIt<SplashLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ResolveStartupUseCase>(
    () => ResolveStartupUseCase(
      getIt<SplashRepository>(),
    ),
  );

  getIt.registerLazySingleton<ClearSessionUseCase>(
    () => ClearSessionUseCase(
      getIt<SplashRepository>(),
    ),
  );

  getIt.registerFactory<SplashBloc>(
    () => SplashBloc(
      resolveStartupUseCase: getIt<ResolveStartupUseCase>(),
      clearSessionUseCase: getIt<ClearSessionUseCase>(),
    ),
  );
}
