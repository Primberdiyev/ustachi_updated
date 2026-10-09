import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/presentation/own_order_l10n.dart';

extension OrderStageVisuals on OrderStage {
  String label(BuildContext context) {
    final t = context.t.orders.stage;
    return switch (this) {
      OrderStage.accepted => t.accepted,
      OrderStage.measured => t.measured,
      OrderStage.production => t.production,
      OrderStage.installation => t.installation,
      OrderStage.handover => t.handover,
    };
  }
}

extension MasterOrderVisuals on MasterOrderEntity {
  Color stripeColor(BuildContext context, DateTime now) {
    final cat = context.color.categorizedColor;

    switch (ownStatus) {
      case OwnOrderStatus.done:
        return cat.success;
      case OwnOrderStatus.cancelled:
        return context.color.neutral.borderStrong;
      case OwnOrderStatus.debt:
        return cat.error;
      case null:
        break;
      default:
        return isLate(now) ? cat.error : cat.primary;
    }

    if (isCompleted) return cat.success;
    if (isLate(now)) return cat.error;
    return cat.primary;
  }

  ChizmaStatus pillStatus(DateTime now) {
    switch (ownStatus) {
      case OwnOrderStatus.done:
        return ChizmaStatus.done;
      case OwnOrderStatus.cancelled:
        return ChizmaStatus.neutral;
      case OwnOrderStatus.debt:
        return ChizmaStatus.danger;
      case null:
        break;
      default:
        return isLate(now) ? ChizmaStatus.danger : ChizmaStatus.progress;
    }

    if (isCompleted) return ChizmaStatus.done;
    if (isLate(now)) return ChizmaStatus.danger;
    return ChizmaStatus.progress;
  }

  String pillLabel(BuildContext context, DateTime now) {
    final t = context.t.orders;

    final own = ownStatus;
    if (own != null) {
      final lateDaysCount = lateDays(now);
      if (!own.isClosed && lateDaysCount > 0) {
        return t.lateDays(days: lateDaysCount.toString());
      }
      return own.label(context);
    }

    if (isCompleted) return t.segmentDone;

    final late = lateDays(now);
    if (late > 0) return t.lateDays(days: late.toString());

    return stage.label(context);
  }
}
