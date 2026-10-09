import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/services/master_drawing_codec.dart';

abstract final class OrderDraftCodec {
  static const schema = 2;

  static Map<String, dynamic> encode(
    OrderDraft draft, {
    required int counter,
    String syncId = '',
  }) =>
      {
        'v': schema,
        'counter': counter,
        if (syncId.isNotEmpty) 'sync_id': syncId,
        'items': [
          for (final item in draft.items)
            {
              'id': item.localId,
              'w': item.drawing.widthMm,
              'h': item.drawing.heightMm,
              'spec': MasterDrawingCodec.encode(item.drawing.spec),
              'qty': item.qty,
              'material': item.materialLabel,
            },
        ],
      };

  static ({OrderDraft draft, int counter, String syncId})? decode(
    Object? raw,
  ) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    if (map['v'] != schema) return null;

    final rawItems = map['items'];
    if (rawItems is! List) return null;

    final items = <OrderDraftItem>[];
    for (final entry in rawItems) {
      if (entry is! Map) continue;
      final item = Map<String, dynamic>.from(entry);

      final spec = MasterDrawingCodec.decode(item['spec']);
      if (spec == null) continue;

      items.add(
        OrderDraftItem(
          localId: _string(item['id']),
          drawing: WindowDrawingSnapshot(
            widthMm: _int(item['w']),
            heightMm: _int(item['h']),
            spec: spec,
            preview: null,
          ),
          qty: _int(item['qty'], fallback: 1),
          materialLabel: _string(item['material']),
        ),
      );
    }

    if (items.isEmpty) return null;
    return (
      draft: OrderDraft(items: items),
      counter: _int(map['counter']),
      syncId: _string(map['sync_id']),
    );
  }

  static String _string(Object? value) => value?.toString() ?? '';

  static int _int(Object? value, {int fallback = 0}) =>
      value is num ? value.toInt() : fallback;
}
