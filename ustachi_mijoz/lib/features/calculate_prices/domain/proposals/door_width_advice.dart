import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_rom_design.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_templates.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/rom_design.dart';

const int proposalSingleDoorSafeMaxMm = 900;

bool proposalIsWideSingleDoor({
  required ProposalShape shape,
  required int widthMm,
}) =>
    shape == ProposalShape.eshik &&
    widthMm > proposalSingleDoorSafeMaxMm &&
    widthMm < proposalSingleLeafDoorUpToMm;

List<int> proposalDoorLeafWidthsMm(ProposalRomDesign design) {
  final out = <int>[];
  void walk(RomCell c, double cw, double ch) {
    switch (c) {
      case RomZone():
        break;
      case RomSplit(:final axis, :final positionsMm, :final children):
        final vertical = axis == RomAxis.vertical;
        final size = vertical ? cw : ch;
        var prev = 0.0;
        for (var i = 0; i < children.length; i++) {
          final next = i < positionsMm.length ? positionsMm[i] : size;
          walk(children[i], vertical ? next - prev : cw,
              vertical ? ch : next - prev);
          prev = next;
        }
      case RomWing(:final function, :final content):
        if (function == RomWingFunction.door) out.add(cw.round());
        walk(content, cw, ch);
    }
  }

  for (final f in design.frames) {
    walk(f.root, f.widthMm, f.heightMm);
  }
  return out;
}

bool proposalHasOverwideDoorLeaf(
    ProposalTemplate t, int widthMm, int heightMm) {
  if (widthMm < proposalSingleLeafDoorUpToMm) return false;
  final ProposalRomDesign design;
  try {
    design =
        proposalRomDesign(t.buildSpec(widthMm, heightMm), widthMm, heightMm);
  } on RomDesignException {
    return false; 
  }
  return proposalDoorLeafWidthsMm(design)
      .any((w) => w > proposalSingleDoorSafeMaxMm);
}

const int proposalFixedSideDoorMaxMm = 1050;

bool proposalFixedSideDoorReplaces({
  required ProposalShape shape,
  required int widthMm,
}) =>
    shape == ProposalShape.eshik &&
    widthMm >= proposalSingleLeafDoorUpToMm &&
    widthMm <= proposalFixedSideDoorMaxMm;

const proposalWideSingleDoorText =
    'Eni 90 sm dan katta bir tavaqali eshik og\'irligi tufayli '
    'vaqt o\'tib osilib qolishi mumkin. Tavsiya: eshik yoniga '
    'qo\'zg\'almas qanot qo\'yish.';
