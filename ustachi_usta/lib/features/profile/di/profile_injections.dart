import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:ustachi/features/profile/data/repository/profile_repository_impl.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';
import 'package:ustachi/features/profile/domain/use_cases/get_user_data_use_case.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

void initProfileInjection(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: getIt<Dio>(),
    ),
  );

  getIt.registerLazySingleton<ProfileLocalDataSource>(
    ProfileLocalDataSource.new,
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
      localDataSource: getIt<ProfileLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetUserDataUseCase>(
    () => GetUserDataUseCase(
      repository: getIt<ProfileRepository>(),
    ),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserDataUseCase: getIt<GetUserDataUseCase>(),
    ),
  );
}
