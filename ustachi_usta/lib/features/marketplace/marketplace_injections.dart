import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:ustachi/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';

void initMarketplaceInjection(GetIt getIt) {
  getIt.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<MarketplaceRepository>(
    () => MarketplaceRepositoryImpl(getIt<MarketplaceRemoteDataSource>()),
  );
}
