import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_codec.dart';

class OrderDraftStore extends ValueNotifier<OrderDraft> {
  OrderDraftStore() : super(const OrderDraft());

  static const _key = 'order_draft_v1';

  int _counter = 0;
  String? _syncId;

  Future<void> _writing = Future<void>.value();

  String nextId() => 'draft-${++_counter}';

  String get syncId {
    final existing = _syncId;
    if (existing != null) return existing;
    final created = 'ord-${DateTime.now().microsecondsSinceEpoch}';
    _syncId = created;
    _persist();
    return created;
  }

  void restore() {
    final raw = StorageRepository.getString(_key);
    if (raw.isEmpty) return;
    try {
      final decoded = OrderDraftCodec.decode(jsonDecode(raw));
      if (decoded == null) return;
      _counter = decoded.counter;
      _syncId = decoded.syncId.isEmpty ? null : decoded.syncId;
      value = decoded.draft;
    } catch (e) {
      debugPrint('[qoralama] tiklanmadi: $e');
    }
  }

  void add(OrderDraftItem item) => _update(value.add(item));

  void remove(String localId) => _update(value.removeAt(localId));

  void setQty(String localId, int qty) {
    if (qty < 1 || qty > 99) return;
    _update(value.updateQty(localId, qty));
  }

  void replace(String localId, OrderDraftItem item) =>
      _update(value.replace(localId, item));

  void duplicate(String localId) =>
      _update(value.duplicate(localId, nextId()));

  void clear() {
    _syncId = null;
    _counter = 0;
    _update(const OrderDraft());
  }

  void _update(OrderDraft next) {
    value = next;
    _persist();
  }

  void _persist() {
    final snapshot = value;
    final counter = _counter;
    final syncId = _syncId ?? '';

    _writing = _writing.then((_) async {
      try {
        if (snapshot.isEmpty) {
          await StorageRepository.deleteString(_key);
          return;
        }
        await StorageRepository.putString(
          _key,
          jsonEncode(
            OrderDraftCodec.encode(snapshot, counter: counter, syncId: syncId),
          ),
        );
      } catch (e) {
        debugPrint('[qoralama] saqlanmadi: $e');
      }
    });
  }

  @visibleForTesting
  Future<void> get pendingWrites => _writing;
}
