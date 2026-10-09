import 'package:flutter/widgets.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

extension OrderStatusL10n on OrderStatus {
  String label(BuildContext context) {
    final t = context.t.orderFlow.status;
    return switch (this) {
      OrderStatus.published => t.published,
      OrderStatus.assigned => t.assigned,
      OrderStatus.completed => t.completed,
      OrderStatus.cancelled => t.cancelled,
      OrderStatus.expired => t.expired,
    };
  }
}

extension OrderStageL10n on OrderStage {
  String label(BuildContext context) {
    final t = context.t.orderFlow.stage;
    return switch (this) {
      OrderStage.accepted => t.accepted,
      OrderStage.measured => t.measured,
      OrderStage.production => t.production,
      OrderStage.installation => t.installation,
      OrderStage.handover => t.handover,
    };
  }
}

extension ResponseStatusL10n on ResponseStatus {
  String label(BuildContext context) {
    final t = context.t.orderFlow.response;
    return switch (this) {
      ResponseStatus.interested => t.interested,
      ResponseStatus.withdrawn => t.withdrawn,
      ResponseStatus.chosen => t.chosen,
      ResponseStatus.rejected => t.rejected,
    };
  }
}
