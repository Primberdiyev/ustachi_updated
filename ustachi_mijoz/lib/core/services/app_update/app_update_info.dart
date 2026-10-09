import 'package:equatable/equatable.dart';

enum AppUpdateStatus {

  upToDate,

  optional,

  forced,
}

class AppUpdateInfo extends Equatable {
  const AppUpdateInfo({
    required this.status,
    required this.currentVersion,
    required this.latestVersion,
    required this.storeUrl,
    this.notes = const <String>[],
  });

  static const none = AppUpdateInfo(
    status: AppUpdateStatus.upToDate,
    currentVersion: '',
    latestVersion: '',
    storeUrl: '',
  );

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
        status: _statusFrom(json['status']),
        currentVersion: (json['current_version'] ?? '').toString(),
        latestVersion: (json['latest_version'] ?? '').toString(),
        storeUrl: (json['store_url'] ?? '').toString(),
        notes: [
          for (final line in (json['notes'] as List? ?? const []))
            if (line.toString().trim().isNotEmpty) line.toString().trim(),
        ],
      );

  static AppUpdateStatus _statusFrom(Object? raw) => switch (raw) {
        'optional' => AppUpdateStatus.optional,
        'required' => AppUpdateStatus.forced,
        _ => AppUpdateStatus.upToDate,
      };

  final AppUpdateStatus status;
  final String currentVersion;
  final String latestVersion;

  final String storeUrl;

  final List<String> notes;

  bool get shouldPrompt =>
      status != AppUpdateStatus.upToDate && storeUrl.isNotEmpty;

  bool get isForced => status == AppUpdateStatus.forced;

  @override
  List<Object?> get props =>
      [status, currentVersion, latestVersion, storeUrl, notes];
}
