import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:ustachi/features/profile/data/master_profile_cache.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';

class SessionCleanupService {
  Future<void> clearSessionData() async {
    MarketplaceSocket.instance.disconnect();
    await sl<ProfileLocalDataSource>().clear();
    await MasterProfileCache().clear();
    sl<OrderDraftStore>().clear();
    await sl<HisobStore>().clear();
  }
}
