import 'package:ustachi/features/orders/domain/services/master_drawing_codec.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';

class OwnOrderPayload {
  const OwnOrderPayload({
    required this.customerName,
    required this.items,
    this.syncClientId = '',
    this.customerPhone = '',
    this.customerAddress = '',
    this.deadline,
    this.note = '',
    this.status = OwnOrderStatus.newOrder,
  });

  factory OwnOrderPayload.fromDraft({
    required OrderDraft draft,
    required String customerName,
    String syncClientId = '',
    String customerPhone = '',
    String customerAddress = '',
    DateTime? deadline,
    String note = '',
    OwnOrderStatus status = OwnOrderStatus.newOrder,
  }) {
    return OwnOrderPayload(
      customerName: customerName,
      syncClientId: syncClientId,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      deadline: deadline,
      note: note,
      status: status,
      items: [
        for (final item in draft.items)
          OwnOrderItemEntity(
            title: item.drawing.sizeLabel,
            materialLabel: item.materialLabel,
            widthMm: item.drawing.widthMm,
            heightMm: item.drawing.heightMm,
            qty: item.qty,
            drawing: MasterDrawingCodec.encode(item.drawing.spec),
          ),
      ],
    );
  }

  factory OwnOrderPayload.fromJson(Map<String, dynamic> json) =>
      OwnOrderPayload(
        syncClientId: _string(json['sync_client_id']),
        customerName: _string(json['customer_name']),
        customerPhone: _string(json['customer_phone']),
        customerAddress: _string(json['customer_address']),
        deadline: json['deadline'] is String
            ? DateTime.tryParse(json['deadline'] as String)
            : null,
        note: _string(json['note']),
        status: OwnOrderStatus.fromWire(json['status']),
        items: [
          for (final item in (json['items'] as List? ?? const []))
            if (item is Map) _itemFrom(Map<String, dynamic>.from(item)),
        ],
      );

  static OwnOrderItemEntity _itemFrom(Map<String, dynamic> json) =>
      OwnOrderItemEntity(
        title: _string(json['title']),
        materialLabel: _string(json['material_label']),
        widthMm: _int(json['width_mm']),
        heightMm: _int(json['height_mm']),
        qty: _int(json['qty']) == 0 ? 1 : _int(json['qty']),
        drawing: json['drawing'] is Map
            ? Map<String, dynamic>.from(json['drawing'] as Map)
            : const <String, dynamic>{},
      );

  static String _string(Object? value) => value?.toString() ?? '';

  static int _int(Object? value) => switch (value) {
        final int v => v,
        final num v => v.round(),
        final String v => int.tryParse(v) ?? 0,
        _ => 0,
      };

  final String syncClientId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime? deadline;
  final String note;
  final OwnOrderStatus status;
  final List<OwnOrderItemEntity> items;

  static String? _date(DateTime? value) => value == null
      ? null
      : '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        if (syncClientId.isNotEmpty) 'sync_client_id': syncClientId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        if (deadline != null) 'deadline': _date(deadline),
        'note': note,
        'status': status.wire,
        'items': [
          for (var i = 0; i < items.length; i++)
            {
              'position': i,
              'title': items[i].title,
              'material_label': items[i].materialLabel,
              'width_mm': items[i].widthMm,
              'height_mm': items[i].heightMm,
              'qty': items[i].qty,
              'drawing': items[i].drawing,
            },
        ],
      };
}
