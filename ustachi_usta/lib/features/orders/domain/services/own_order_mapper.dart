import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/orders/domain/services/master_drawing_codec.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';

abstract final class OwnOrderMapper {
  static const String idPrefix = 'own:';

  static String idOf(int serverId) => '$idPrefix$serverId';

  static int? serverIdOf(String id) => id.startsWith(idPrefix)
      ? int.tryParse(id.substring(idPrefix.length))
      : null;

  static bool isOwnId(String id) => id.startsWith(idPrefix);

  static OrderStage stageFor(OwnOrderStatus status) => switch (status) {
        OwnOrderStatus.draft => OrderStage.accepted,
        OwnOrderStatus.newOrder => OrderStage.accepted,
        OwnOrderStatus.inProgress => OrderStage.production,
        OwnOrderStatus.done => OrderStage.handover,
        OwnOrderStatus.debt => OrderStage.handover,
        OwnOrderStatus.cancelled => OrderStage.handover,
      };

  static DateTime? completedAtFor(OwnOrderEntity order) =>
      order.status.isClosed ? (order.completedAt ?? order.createdAt) : null;

  static MasterOrderEntity toMasterOrder(OwnOrderEntity order) {
    final title = order.items.isEmpty ? '' : order.items.first.title;

    return MasterOrderEntity(
      id: idOf(order.id),
      number: order.number,
      title: title,
      summary: order.summary,
      clientName: order.customerName,
      address: order.customerAddress,
      totalPrice: 0,
      stage: stageFor(order.status),
      createdAt: order.createdAt,
      dueDate: order.deadline,
      completedAt: completedAtFor(order),
      spec: _spec(order),
      ownStatus: order.status,
      productCount: order.productCount,
      drawings: [
        for (final item in order.items)
          if (MasterDrawingCodec.decode(item.drawing)
              case final FramePreviewSpec spec)
            (spec: spec, frameArgb: null),
      ],
    );
  }

  static Map<String, String> _spec(OwnOrderEntity order) {
    final spec = <String, String>{};
    if (order.items.isNotEmpty) {
      spec[specProduct] =
          specItemsValue(order.items.length, order.productCount);
      final first = order.items.first;
      if (first.subtitle.isNotEmpty) spec[specMaterial] = first.subtitle;
    }
    if (order.customerPhone.isNotEmpty) spec[specPhone] = order.customerPhone;
    if (order.customerAddress.isNotEmpty) {
      spec[specAddress] = order.customerAddress;
    }
    if (order.note.isNotEmpty) spec[specNote] = order.note;
    return spec;
  }

  static OwnOrderStatus? nextStatus(OwnOrderStatus current) =>
      switch (current) {
        OwnOrderStatus.draft => OwnOrderStatus.newOrder,
        OwnOrderStatus.newOrder => OwnOrderStatus.inProgress,
        OwnOrderStatus.inProgress => OwnOrderStatus.done,
        OwnOrderStatus.debt => OwnOrderStatus.done,
        OwnOrderStatus.done => null,
        OwnOrderStatus.cancelled => null,
      };
}
