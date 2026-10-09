import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_door_lambri.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_grid.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

class ProposalTemplate {
  const ProposalTemplate({
    required this.type,
    required this.title,
    this.subtitle = '',
    this.lines = const [],
    this.zoneSetups = const [],
    this.defaultOpeningCategory,
    this.defaultOpeningIsDoor = false,
    this.defaultOpeningSingleSash = false,
    this.minWidthMm = 0,
    this.minHeightMm = 0,
    this.maxWidthMm = 100000,
    this.maxHeightMm = 100000,
    this.isPopular = false,
    this.archHeightFactor = 0.0,
    this.regions = const [],
    this.snapToGrid = true,
    this.snapWidths = true,
    this.pinFirst = false,
    this.plainDoorPosts = false,
  });

  final bool plainDoorPosts;

  final ProposalType type;
  final String title;
  final String subtitle;
  final List<FrameLine> lines;
  final List<DefaultZoneSetup> zoneSetups;
  final int? defaultOpeningCategory; 
  final bool defaultOpeningIsDoor;
  final bool defaultOpeningSingleSash;

  final int minWidthMm;
  final int minHeightMm;
  final int maxWidthMm;
  final int maxHeightMm;

  final bool isPopular;

  final double archHeightFactor;

  final List<FrameRegion> regions;

  final bool pinFirst;

  final bool snapToGrid;

  final bool snapWidths;

  bool fits(int widthMm, int heightMm) =>
      widthMm >= minWidthMm &&
      widthMm <= maxWidthMm &&
      heightMm >= minHeightMm &&
      heightMm <= maxHeightMm;

  FramePreviewSpec buildSpec(int widthMm, int heightMm) {
    if (!snapToGrid) return _buildSpec(widthMm, heightMm, _same, _same);
    final x = snapWidths
        ? proposalSnapAxis([
            for (final l in lines) ...[l.startX, l.endX],
            for (final r in regions) ...[r.left, r.right],
          ], widthMm)
        : _same;
    final y = proposalSnapAxis([
      for (final l in lines) ...[l.startY, l.endY],
      for (final r in regions) ...[r.top, r.bottom],
      if (archHeightFactor > 0) archHeightFactor,
    ], heightMm);
    return _buildSpec(widthMm, heightMm, x, y);
  }

  static double _same(double v) => v;

  FramePreviewSpec _buildSpec(int widthMm, int heightMm,
      double Function(double) x, double Function(double) y) {

    return proposalDoorLowerLambri(_rawSpec(widthMm, heightMm, x, y),
        fixHeight: snapToGrid);
  }

  FramePreviewSpec _rawSpec(int widthMm, int heightMm,
      double Function(double) x, double Function(double) y) {
    return FramePreviewSpec(
      aspectRatio: widthMm / heightMm,
      widthMm: widthMm,
      heightMm: heightMm,
      lines: [
        for (final l in lines)
          FrameLine(x(l.startX), y(l.startY), x(l.endX), y(l.endY))
      ],
      defaultZoneSetups: zoneSetups,
      defaultOpeningCategory: defaultOpeningCategory,
      defaultOpeningIsDoor: defaultOpeningIsDoor,
      defaultOpeningSingleSash: defaultOpeningSingleSash,
      archHeightFactor:
          archHeightFactor > 0 ? y(archHeightFactor) : archHeightFactor,
      plainDoorPosts: plainDoorPosts,
      regions: [
        for (final r in regions)
          FrameRegion(
            x(r.left),
            y(r.top),
            x(r.right),
            y(r.bottom),
            sharedLeft: r.sharedLeft,
            sharedTop: r.sharedTop,
            sharedRight: r.sharedRight,
            sharedBottom: r.sharedBottom,
            absorbedLeft: r.absorbedLeft,
            absorbedTop: r.absorbedTop,
            absorbedRight: r.absorbedRight,
            absorbedBottom: r.absorbedBottom,
            hideOuterStrokeLeft: r.hideOuterStrokeLeft,
            hideOuterStrokeTop: r.hideOuterStrokeTop,
            hideOuterStrokeRight: r.hideOuterStrokeRight,
            hideOuterStrokeBottom: r.hideOuterStrokeBottom,
          ),
      ],
    );
  }
}

const _hingeLeft = 1; 
const _hingeRight = 2; 
const _tilt = 3; 

const proposalWindowTemplates = <ProposalTemplate>[

  ProposalTemplate(
    type: ProposalType.window,
    title: '1 bo\'lmali, ochiladi',
    subtitle: 'Butun deraza ochiladi',
    defaultOpeningCategory: _hingeLeft,
    maxWidthMm: 900,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '2 bo\'lmali, 1 tasi ochiladi',
    subtitle: 'Bir tomoni ochiladi, biri qo\'zg\'almas',
    lines: [FrameLine(0.5, 0, 0.5, 1)],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.75, 0.5),
        openingCategory: _hingeRight,
      ),
    ],
    isPopular: true,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '2 bo\'lmali, fortochkali',
    subtitle: 'Tepada kichik shamollatgich',
    lines: [
      FrameLine(0.5, 0, 0.5, 1),
      FrameLine(0, 0.35, 0.5, 0.35), 
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.25, 0.17),
        openingCategory: _tilt, 
      ),
    ],
    minWidthMm: 1000,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '3 bo\'lmali, 2 tasi ochiladi',
    subtitle: 'Ikki chekkasi ochiladi, o\'rtasi qo\'zg\'almas',
    lines: [
      FrameLine(1 / 3, 0, 1 / 3, 1),
      FrameLine(2 / 3, 0, 2 / 3, 1),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(1 / 6, 0.5),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(5 / 6, 0.5),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 1600,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: 'Qo\'zg\'almas oyna',
    subtitle: 'Ochilmaydi — eng arzon',
    maxWidthMm: 1300,
    maxHeightMm: 1600,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '2 bo\'lmali, ikkisi ochiladi',
    subtitle: 'Ikkala tomon ham ochiladi',
    lines: [FrameLine(0.5, 0, 0.5, 1)],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.25, 0.5),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(0.75, 0.5),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 1000,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '3 bo\'lmali, o\'rtasi ochiladi',
    subtitle: 'O\'rtasi ochiladi, chekkalari qo\'zg\'almas',
    lines: [
      FrameLine(1 / 3, 0, 1 / 3, 1),
      FrameLine(2 / 3, 0, 2 / 3, 1),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.5),
        openingCategory: _hingeLeft,
      ),
    ],
    minWidthMm: 1400,
  ),

  ProposalTemplate(
    type: ProposalType.window,
    title: '4 bo\'lmali, 2 tasi ochiladi',
    subtitle: 'To\'rt bo\'lma, ikki chekkasi ochiladi',
    lines: [
      FrameLine(0.25, 0, 0.25, 1),
      FrameLine(0.5, 0, 0.5, 1),
      FrameLine(0.75, 0, 0.75, 1),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.125, 0.5),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(0.875, 0.5),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 2000,
  ),
];

const proposalDoorTemplates = <ProposalTemplate>[

  ProposalTemplate(
    type: ProposalType.door,
    title: 'To\'liq oynali eshik',
    subtitle: 'Butun eshik oynali',
    defaultOpeningCategory: _hingeLeft,
    defaultOpeningIsDoor: true,
    defaultOpeningSingleSash: true,
    minHeightMm: 1900,
    isPopular: true,
  ),

  ProposalTemplate(
    type: ProposalType.door,
    title: 'Pastki panelli eshik',
    subtitle: 'Tepasi oyna, pasti panel',
    lines: [FrameLine(0, 0.62, 1, 0.62)],
    defaultOpeningCategory: _hingeLeft,
    defaultOpeningIsDoor: true,
    defaultOpeningSingleSash: true,
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.81),
        layoutCategory: 3, 
      ),
    ],
    minHeightMm: 1900,
  ),

  ProposalTemplate(
    type: ProposalType.door,
    title: 'Tepa oynali eshik',
    subtitle: 'Tepada qo\'zg\'almas oyna',
    lines: [FrameLine(0, 0.22, 1, 0.22)],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.6),
        openingCategory: _hingeLeft,
        openingIsDoor: true,
      ),
    ],
    minHeightMm: 2100,
  ),

  ProposalTemplate(
    type: ProposalType.door,
    title: 'Juft tavaqali eshik',
    subtitle: 'Ikki tavaqa ochiladi',
    lines: [FrameLine(0.5, 0, 0.5, 1)],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.25, 0.5),
        openingCategory: _hingeLeft,
        openingIsDoor: true,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(0.75, 0.5),
        openingCategory: _hingeRight,
        openingIsDoor: true,
      ),
    ],
    minWidthMm: 1100,
    minHeightMm: 1900,
  ),

  ProposalTemplate(
    type: ProposalType.door,
    title: 'Yarim oynali eshik',
    subtitle: 'Yarmi oyna, yarmi panel',
    lines: [FrameLine(0, 0.5, 1, 0.5)],
    defaultOpeningCategory: _hingeLeft,
    defaultOpeningIsDoor: true,
    defaultOpeningSingleSash: true,
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.75),
        layoutCategory: 3, 
      ),
    ],
    minHeightMm: 1900,
  ),
];

const _arch = 0.35;

const proposalArchTemplates = <ProposalTemplate>[

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka oyna',
    subtitle: 'Tepasi kamar, pasti oyna',
    archHeightFactor: _arch,
    lines: [FrameLine(0, _arch, 1, _arch)],
    minWidthMm: 700,
    minHeightMm: 1500,
    isPopular: true,
  ),

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka, 2 bo\'lmali',
    subtitle: 'Kamar + pastda 2 bo\'lma',
    archHeightFactor: _arch,
    lines: [
      FrameLine(0, _arch, 1, _arch),
      FrameLine(0.5, _arch, 0.5, 1),
    ],
    minWidthMm: 1000,
    minHeightMm: 1500,
  ),

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka, pasti ochiladi',
    subtitle: 'Kamar + pastda ochiluvchi oyna',
    archHeightFactor: _arch,
    lines: [FrameLine(0, _arch, 1, _arch)],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.5 + _arch / 2),
        openingCategory: _hingeLeft,
      ),
    ],
    minWidthMm: 700,
    minHeightMm: 1500,
  ),

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka, juft ochiluvchi',
    subtitle: 'Kamar + ikkala tavaqa ochiladi',
    archHeightFactor: _arch,
    lines: [
      FrameLine(0, _arch, 1, _arch),
      FrameLine(0.5, _arch, 0.5, 1),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.25, 0.5 + _arch / 2),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(0.75, 0.5 + _arch / 2),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 1100,
    minHeightMm: 1800,
  ),

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka, markazi baland',
    subtitle: 'Yonlari ochiladi, markazi yaxlit oyna',
    archHeightFactor: 0.22,
    lines: [
      FrameLine(0, 0.22, 1, 0.22),
      FrameLine(1 / 3, 0.22, 1 / 3, 1),
      FrameLine(2 / 3, 0.22, 2 / 3, 1),
      FrameLine(0, 0.44, 1 / 3, 0.44),
      FrameLine(2 / 3, 0.44, 1, 0.44),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(1 / 6, 0.72),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(5 / 6, 0.72),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 1500,
    minHeightMm: 1900,
  ),

  ProposalTemplate(
    type: ProposalType.arch,
    title: 'Arka, fortochkali',
    subtitle: 'Markazida shamollatgich, yonlari ochiladi',
    archHeightFactor: 0.22,
    lines: [
      FrameLine(0, 0.22, 1, 0.22),
      FrameLine(1 / 3, 0.22, 1 / 3, 1),
      FrameLine(2 / 3, 0.22, 2 / 3, 1),
      FrameLine(1 / 3, 0.44, 2 / 3, 0.44),
    ],
    zoneSetups: [
      DefaultZoneSetup(
        zoneCenter: Offset(0.5, 0.33),
        openingCategory: _tilt,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(1 / 6, 0.61),
        openingCategory: _hingeLeft,
      ),
      DefaultZoneSetup(
        zoneCenter: Offset(5 / 6, 0.61),
        openingCategory: _hingeRight,
      ),
    ],
    minWidthMm: 1500,
    minHeightMm: 1900,
  ),
];

List<ProposalTemplate> proposalTemplatesForType(ProposalType type) =>
    switch (type) {
      ProposalType.door => proposalDoorTemplates,
      ProposalType.arch => proposalArchTemplates,
      ProposalType.window => proposalWindowTemplates,
    };
