import 'package:ustachi/core/services/app_update/app_update_api.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';

class AppUpdateService {
  AppUpdateService({
    required AppUpdateApi api,
    DateTime Function()? clock,
  })  : _api = api,
        _now = clock ?? DateTime.now;

  final AppUpdateApi _api;
  final DateTime Function() _now;

  static const snoozeDuration = Duration(hours: 24);
  static const recheckInterval = Duration(hours: 6);

  static const _snoozedVersionKey = 'app_update_snoozed_version';
  static const _snoozedAtKey = 'app_update_snoozed_at';
  static const _checkedAtKey = 'app_update_checked_at';

  Future<AppUpdateInfo?> pendingUpdate({
    required String version,
    bool throttle = false,
  }) async {
    if (throttle && !_dueForRecheck()) return null;

    final info = await _api.check(version: version);

    if (info == null) return null;

    await StorageRepository.putInt(
      _checkedAtKey,
      _now().millisecondsSinceEpoch,
    );

    if (!info.shouldPrompt) return null;
    if (!info.isForced && _isSnoozed(info.latestVersion)) return null;
    return info;
  }

  Future<void> snooze(AppUpdateInfo info) async {
    await StorageRepository.putString(_snoozedVersionKey, info.latestVersion);
    await StorageRepository.putInt(
      _snoozedAtKey,
      _now().millisecondsSinceEpoch,
    );
  }

  bool _dueForRecheck() {
    final last = StorageRepository.getInt(_checkedAtKey);
    if (last <= 0) return true;
    final elapsed = _now().difference(
      DateTime.fromMillisecondsSinceEpoch(last),
    );

    return elapsed.isNegative || elapsed >= recheckInterval;
  }

  bool _isSnoozed(String version) {
    if (StorageRepository.getString(_snoozedVersionKey) != version) {
      return false;
    }
    final at = StorageRepository.getInt(_snoozedAtKey);
    if (at <= 0) return false;
    final elapsed = _now().difference(DateTime.fromMillisecondsSinceEpoch(at));
    return !elapsed.isNegative && elapsed < snoozeDuration;
  }
}
