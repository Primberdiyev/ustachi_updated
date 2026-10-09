import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';

class SessionCleanupService {
  Future<void> clearSessionData() async {
    MarketplaceSocket.instance.disconnect();
  }
}
