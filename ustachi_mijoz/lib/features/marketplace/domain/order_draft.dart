import 'package:flutter/foundation.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_naming.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';

@immutable
class ClientDraftItem {
  const ClientDraftItem({
    required this.localId,
    required this.option,
    required this.request,
    this.qty = 1,
  });

  final String localId;
  final ProposalOption option;
  final ProposalRequest request;
  final int qty;

  String get title => proposalOptionTitle(request, option.spec);

  String get sizeLabel => '${request.widthMm}×${request.heightMm} mm';

  ClientDraftItem copyWith({int? qty}) => ClientDraftItem(
        localId: localId,
        option: option,
        request: request,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'shape': request.shape.code,
      'shape_title': option.title,
      'shape_subtitle': option.subtitle,
      'openings': proposalOpeningCount(option.spec),
      'qty': qty,
      'width_mm': request.widthMm,
      'height_mm': request.heightMm,
      'material': request.material,
      'color_key': request.colorKey,
      'color_argb': request.colorArgb,
      'color_label': request.colorLabel,
      'has_sill': request.hasSill,
      'sill_width_cm': request.hasSill ? request.sillWidthCm : 0,
      'floor_gap_mm': request.floorGapMm,
      'door_on_right': request.doorOnRight,
      'spec': ProposalSpecCodec.encode(option.spec),
    };
  }
}

@immutable
class ClientOrderDraft {
  const ClientOrderDraft({this.items = const []});

  final List<ClientDraftItem> items;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get kinds => items.length;

  int get productCount => items.fold(0, (sum, i) => sum + i.qty);

  String get title {
    if (items.isEmpty) return 'Buyurtma';
    final first = items.first.title;
    if (items.length == 1) {
      return items.first.qty > 1 ? '$first × ${items.first.qty}' : first;
    }
    return '$first va yana ${items.length - 1} ta rom';
  }

  ClientOrderDraft add(ClientDraftItem item) =>
      ClientOrderDraft(items: [...items, item]);

  ClientOrderDraft removeAt(String localId) => ClientOrderDraft(
      items: items.where((i) => i.localId != localId).toList());

  ClientOrderDraft updateQty(String localId, int qty) => ClientOrderDraft(
        items: [
          for (final item in items)
            item.localId == localId
                ? item.copyWith(qty: qty.clamp(1, 99))
                : item,
        ],
      );

  Map<String, dynamic> toProposalJson() {
    if (items.isEmpty) return const {};
    final first = items.first.toJson();
    return {
      ...first,
      'version': 2,
      'items': [for (final item in items) item.toJson()],
      'item_kinds': kinds,
      'item_count': productCount,
    };
  }
}

class OrderDraftStore extends ValueNotifier<ClientOrderDraft> {
  OrderDraftStore() : super(const ClientOrderDraft());

  var _seq = 0;

  String add({
    required ProposalOption option,
    required ProposalRequest request,
    int qty = 1,
  }) {
    final id = 'item-${_seq++}';
    value = value.add(ClientDraftItem(
      localId: id,
      option: option,
      request: request,
      qty: qty,
    ));
    return id;
  }

  void setQty(String localId, int qty) => value = value.updateQty(localId, qty);

  void remove(String localId) => value = value.removeAt(localId);

  void clear() => value = const ClientOrderDraft();
}
