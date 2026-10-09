import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/orders/data/datasources/own_orders_remote_data_source.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_api.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_composite.dart';
import 'package:ustachi/features/orders/data/repositories/own_orders_repository_impl.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';

void initOrdersDependencies(GetIt sl) {
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryComposite(
      marketplace: OrdersRepositoryApi(sl<MarketplaceRepository>()),
      own: sl<OwnOrdersRepository>(),
    ),
  );

  sl.registerLazySingleton<OrderDraftStore>(OrderDraftStore.new);

  sl.registerLazySingleton<OwnOrdersRemoteDataSource>(
    () => OwnOrdersRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<OwnOrdersRepository>(
    () => OwnOrdersRepositoryImpl(sl<OwnOrdersRemoteDataSource>()),
  );

  sl.registerLazySingleton<OwnOrderOutbox>(
    () => OwnOrderOutbox(sl<OwnOrdersRepository>()),
  );

  sl.registerLazySingleton<OrdersBloc>(
    () => OrdersBloc(
      repository: sl<OrdersRepository>(),
      ownRepository: sl<OwnOrdersRepository>(),
      outbox: sl<OwnOrderOutbox>(),
    ),
  );
}
