import 'package:ustachi/core/api/api_list.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';

abstract final class OwnOrderModel {
  static List<OwnOrderEntity> listFrom(Object? raw) => [
        for (final item in apiList(raw))
          if (item is Map) fromJson(Map<String, dynamic>.from(item)),
      ];

  static OwnOrderEntity fromJson(Map<String, dynamic> json) => OwnOrderEntity(
        id: _int(json['id']),
        syncClientId: _string(json['sync_client_id']),
        customerName: _string(json['customer_name']),
        customerPhone: _string(json['customer_phone']),
        customerAddress: _string(json['customer_address']),
        deadline: _date(json['deadline']),
        note: _string(json['note']),
        status: OwnOrderStatus.fromWire(json['status']),
        createdAt: _date(json['created_at']) ?? DateTime.now(),
        completedAt: _date(json['completed_at']),
        items: [
          for (final item in (json['items'] as List? ?? const []))
            if (item is Map) itemFrom(Map<String, dynamic>.from(item)),
        ],
      );

  static OwnOrderItemEntity itemFrom(Map<String, dynamic> json) =>
      OwnOrderItemEntity(
        id: json['id'] is num ? _int(json['id']) : null,
        title: _string(json['title']),
        materialLabel: _string(json['material_label']),
        widthMm: _int(json['width_mm']),
        heightMm: _int(json['height_mm']),
        qty: _int(json['qty']) == 0 ? 1 : _int(json['qty']),
        drawing: json['drawing'] is Map
            ? Map<String, dynamic>.from(json['drawing'] as Map)
            : const <String, dynamic>{},
      );

  static int _int(Object? value) => switch (value) {
        final int v => v,
        final num v => v.round(),
        final String v => int.tryParse(v) ?? 0,
        _ => 0,
      };

  static String _string(Object? value) => value?.toString() ?? '';

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
