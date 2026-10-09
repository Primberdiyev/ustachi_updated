import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ustachi/features/auth/data/datasources/locations_remote_data_source.dart';
import 'package:ustachi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ustachi/features/auth/data/repositories/locations_repository_impl.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';
import 'package:ustachi/features/auth/domain/repositories/locations_repository.dart';
import 'package:ustachi/features/auth/domain/usecases/get_locations_usecases.dart';
import 'package:ustachi/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

void initAuthDependencies(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<SendCodeUseCase>(
    () => SendCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyCodeUseCase>(
    () => VerifyCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetMeUseCase>(
    () => GetMeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UpdateMeUseCase>(
    () => UpdateMeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(sl<Dio>(instanceName: 'publicDio')),
  );
  sl.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(sl<LocationsRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetRegionsUseCase>(
    () => GetRegionsUseCase(sl<LocationsRepository>()),
  );
  sl.registerLazySingleton<GetDistrictsUseCase>(
    () => GetDistrictsUseCase(sl<LocationsRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendCodeUseCase: sl<SendCodeUseCase>(),
      verifyCodeUseCase: sl<VerifyCodeUseCase>(),
      updateMeUseCase: sl<UpdateMeUseCase>(),
    ),
  );
}
