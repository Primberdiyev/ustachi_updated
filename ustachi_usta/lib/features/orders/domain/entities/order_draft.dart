import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';

class OrderDraftItem {
  const OrderDraftItem({
    required this.localId,
    required this.drawing,
    this.qty = 1,
    this.materialLabel = '',
  });

  final String localId;

  final WindowDrawingSnapshot drawing;

  final int qty;

  final String materialLabel;

  String get title => drawing.sizeLabel;

  String get subtitle => materialLabel;

  OrderDraftItem copyWith({int? qty, String? localId}) => OrderDraftItem(
        localId: localId ?? this.localId,
        drawing: drawing,
        qty: qty ?? this.qty,
        materialLabel: materialLabel,
      );
}

class OrderDraft {
  const OrderDraft({this.items = const []});

  final List<OrderDraftItem> items;

  bool get isEmpty => items.isEmpty;
  int get productCount => items.fold(0, (sum, i) => sum + i.qty);

  OrderDraft add(OrderDraftItem item) =>
      OrderDraft(items: [...items, item]);

  OrderDraft removeAt(String localId) =>
      OrderDraft(items: items.where((i) => i.localId != localId).toList());

  OrderDraft updateQty(String localId, int qty) => OrderDraft(
        items: [
          for (final item in items)
            item.localId == localId ? item.copyWith(qty: qty) : item,
        ],
      );

  OrderDraft replace(String localId, OrderDraftItem item) => OrderDraft(
        items: [
          for (final existing in items)
            if (existing.localId == localId)
              item.copyWith(localId: localId, qty: existing.qty)
            else
              existing,
        ],
      );

  OrderDraft duplicate(String localId, String newLocalId) {
    final source = items.where((i) => i.localId == localId).firstOrNull;
    if (source == null) return this;
    return add(source.copyWith(localId: newLocalId, qty: 1));
  }
}
