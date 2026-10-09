import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';

class SpecialtyCatalog extends ValueNotifier<List<SpecialtyEntity>> {
  SpecialtyCatalog(this._repository) : super(const []) {
    _restore();
  }

  final MarketplaceRepository _repository;

  static const Duration ttl = Duration(hours: 6);

  static const int _schema = 13;

  DateTime? _fetchedAt;

  Future<void>? _inFlight;

  bool get isEmpty => value.isEmpty;

  bool get _isFresh {
    final at = _fetchedAt;
    if (at == null || value.isEmpty) return false;
    return DateTime.now().difference(at) < ttl;
  }

  Future<void> ensureFresh({bool force = false}) {
    if (!force && _isFresh) return Future<void>.value();
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<void> _fetch() async {
    final result = await _repository.specialties();
    if (result.isLeft) {

      return;
    }
    _fetchedAt = DateTime.now();
    value = result.right;
    await _save(result.right);
  }

  void _restore() {
    try {

      final raw = StorageRepository.getString(StoreKeys.specialtyCatalog);
      if (raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      if (decoded['v'] != _schema) return;
      final items = SpecialtyEntity.listFrom(decoded['items']);
      if (items.isEmpty) return;
      value = items;
      final at = DateTime.tryParse('${decoded['at']}');

      _fetchedAt = at;
    } catch (_) {

    }
  }

  Future<void> _save(List<SpecialtyEntity> items) async {
    try {
      await StorageRepository.putString(
        StoreKeys.specialtyCatalog,
        jsonEncode({
          'v': _schema,
          'at': DateTime.now().toIso8601String(),
          'items': [for (final s in items) s.toJson()],
        }),
      );
    } catch (_) {

    }
  }
}
