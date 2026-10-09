import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkService {
  Future<bool> get isConnected;
}

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
