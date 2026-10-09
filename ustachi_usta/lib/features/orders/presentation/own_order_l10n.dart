import 'package:flutter/widgets.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';

extension OwnOrderStatusL10n on OwnOrderStatus {
  String label(BuildContext context) {
    final t = context.t.ownOrders.status;
    return switch (this) {
      OwnOrderStatus.draft => t.draft,
      OwnOrderStatus.newOrder => t.newOrder,
      OwnOrderStatus.inProgress => t.inProgress,
      OwnOrderStatus.done => t.done,
      OwnOrderStatus.debt => t.debt,
      OwnOrderStatus.cancelled => t.cancelled,
    };
  }

  String hint(BuildContext context) {
    final t = context.t.ownOrders.hint;
    return switch (this) {
      OwnOrderStatus.draft => '',
      OwnOrderStatus.newOrder => t.newOrder,
      OwnOrderStatus.inProgress => t.inProgress,
      OwnOrderStatus.done => t.done,
      OwnOrderStatus.debt => t.debt,
      OwnOrderStatus.cancelled => t.cancelled,
    };
  }
}
