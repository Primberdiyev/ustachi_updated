import 'dart:convert';

import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';

class OwnOrderOutbox {
  OwnOrderOutbox(this._repository);

  final OwnOrdersRepository _repository;

  static const _key = 'own_orders_outbox_v1';

  static bool shouldQueue(Failure failure) {
    if (failure is ServerFailure) {
      final code = failure.statusCode;
      return code == null || code == 0 || code >= 500;
    }
    return failure is! CacheFailure;
  }

  List<OwnOrderPayload> get pending {
    final raw = StorageRepository.getString(_key);
    if (raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list)
          if (item is Map) OwnOrderPayload.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

  int get pendingCount => pending.length;

  Future<void> add(OwnOrderPayload payload) async {
    final queue = [...pending];
    queue.removeWhere((item) =>
        item.syncClientId.isNotEmpty &&
        item.syncClientId == payload.syncClientId);
    queue.add(payload);
    await _write(queue);
  }

  Future<void> clear() => StorageRepository.deleteString(_key);

  Future<int> flush() async {
    final queue = pending;
    if (queue.isEmpty) return 0;

    final failed = <OwnOrderPayload>[];
    var sent = 0;

    for (final payload in queue) {
      final result = await _repository.create(payload);
      if (result.isRight) {
        sent++;
        continue;
      }
      if (shouldQueue(result.left)) failed.add(payload);
    }

    await _write(failed);
    return sent;
  }

  Future<void> _write(List<OwnOrderPayload> queue) async {
    if (queue.isEmpty) {
      await clear();
      return;
    }
    await StorageRepository.putString(
      _key,
      jsonEncode([for (final payload in queue) payload.toJson()]),
    );
  }
}
