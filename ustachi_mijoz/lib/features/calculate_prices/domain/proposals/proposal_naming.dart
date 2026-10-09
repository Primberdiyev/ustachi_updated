import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

String proposalRomTitle({
  required ProposalShape shape,
  required String colorLabel,
  required int openings,
}) {
  final color = colorLabel.trim().toLowerCase();
  return [
    if (openings > 0) '$openings qanotli' else 'Qo\'zg\'almas',
    if (color.isNotEmpty) color,
    _shapeWord(shape),
  ].join(' ');
}

String _shapeWord(ProposalShape shape) {
  final title = shape.title;
  final firstWord = title.split(' ').first;
  if (firstWord.length == 1) return title;
  return title.toLowerCase();
}

int proposalOpeningCount(FramePreviewSpec spec) {
  final zone = WindowZone.fromFramePreviewSpecWithDefaults(spec);
  return zone.hasAnyDirectlyAppliedOpening()
      ? zone.openingZoneRects().length
      : zone.groupedOpeningSashes().length;
}

String proposalOptionTitle(ProposalRequest request, FramePreviewSpec spec) =>
    proposalRomTitle(
      shape: request.shape,
      colorLabel: request.colorLabel,
      openings: proposalOpeningCount(spec),
    );
