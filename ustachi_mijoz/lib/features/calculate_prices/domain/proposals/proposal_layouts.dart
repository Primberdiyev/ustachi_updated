import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_door_lambri.dart'
    show proposalDoorLambriMm;
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_grid.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_library.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_templates.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

const _colMinMm = 420; 
const _colTargetMm = 550; 
const _casementMinMm = 400;
const _casementMaxMm = 900; 
const _tiltMaxMm =
    1600; 
const _doorMinMm = 700;
const _doorMaxMm = 900;

const proposalSingleLeafDoorUpToMm = 1000;
const _doorTargetMm = 800;
const _twinLeafMinMm = 550; 
const _sideMinMm = 400; 
const _sideMaxMm = 600;
const _ventMm = 500; 
const _doorPanelMm = 700; 
const _maxLayouts = 6;

const proposalVitrajDoorMinWidthMm = 6000;

const _vitrajDoorMinHeightMm = 2100;

const _transomQuota = 2;

const _hingeLeft = 1; 
const _hingeRight = 2; 
const _tilt = 3; 

const proposalTiltCategory = _tilt;
const _tiltReverse = 4; 
const _hingeLeftTilt = 5; 
const _hingeRightTilt = 6; 

bool _isMiddleColumn(int i, int n) =>
    n.isOdd ? i == n ~/ 2 : (i == n ~/ 2 - 1 || i == n ~/ 2);

int proposalCasementCategory({
  required int widthMm,
  required int heightMm,
  required bool leftSide,
}) {
  if (heightMm <= 520) return _tiltReverse;
  if (heightMm <= 800) return _tilt;
  if (widthMm <= 620 && heightMm <= 900) return _tilt;
  if (widthMm <= 700 && heightMm >= 1700) {
    return leftSide ? _hingeLeftTilt : _hingeRightTilt;
  }
  return leftSide ? _hingeLeft : _hingeRight;
}

enum ProposalColRole {
  fixed, 
  casement, 
  door, 
}

class ProposalCol {
  const ProposalCol(
    this.widthMm,
    this.role, {
    this.openCat = 0,
    this.hasHandle = true,
    this.topVentMm = 0,
    this.topFixedMm = 0,
    this.inTransom = true,
    this.sashToFloor = false,
    this.noLambri = false,
    this.lambriFill = false,
    this.panelLikeDoor = false,
  });

  final int widthMm;
  final ProposalColRole role;

  final bool panelLikeDoor;

  final int openCat;

  final bool hasHandle;

  final int topVentMm;

  final int topFixedMm;

  final bool inTransom;

  final bool sashToFloor;

  final bool noLambri;

  final bool lambriFill;

  @override
  String toString() =>
      '$widthMm:${role.name}:$openCat:${hasHandle ? 1 : 0}:v$topVentMm'
      ':f$topFixedMm:t${inTransom ? 1 : 0}:s${sashToFloor ? 1 : 0}'
      ':n${noLambri ? 1 : 0}:L${lambriFill ? 1 : 0}:P${panelLikeDoor ? 1 : 0}';
}

class ProposalLayout {
  const ProposalLayout({
    required this.cols,
    required this.title,
    this.subtitle = '',
    this.transomMm = 0,
    this.transomPanesMm = const [],
    this.topBandMm = 0,
    this.lambriMm = 0,
    this.lambriPerColumn = false,
    this.bandPattern = 1,
    this.doorPanelMm = 0,
    this.isPopular = false,
    this.transomVariant = false,
    this.exactWidths = false,
    this.pinFirst = false,
    this.plainDoorPosts = false,
  });

  final bool plainDoorPosts;

  final bool exactWidths;

  final bool pinFirst;

  final List<ProposalCol> cols;
  final String title;
  final String subtitle;

  final int transomMm;

  final List<int> transomPanesMm;

  final int topBandMm;

  final int lambriMm;

  final bool lambriPerColumn;

  final int bandPattern;

  final int doorPanelMm;

  final bool isPopular;

  final bool transomVariant;

  int get totalWidthMm => cols.fold(0, (p, c) => p + c.widthMm);

  String get signature => '${cols.join('|')}#t$transomMm#p$doorPanelMm'
      '#b$topBandMm#l$lambriMm${lambriPerColumn ? 'c' : ''}p$bandPattern'
      '#tp${transomPanesMm.join(',')}';

  ProposalTemplate toTemplate(ProposalType type, int widthMm, int heightMm) {
    final total = totalWidthMm;
    final h = heightMm.toDouble();
    double yy(int mm) => mm / h;

    final bandY = topBandMm > 0 ? yy(topBandMm) : 0.0;
    final ty = bandY + (transomMm > 0 ? yy(transomMm) : 0.0);
    final ly = lambriMm > 0 ? 1 - yy(lambriMm) : 1.0;

    final b = <double>[0.0];
    var acc = 0;
    for (final c in cols) {
      acc += c.widthMm;
      b.add(acc / total);
    }

    bool covered(ProposalCol c) => lambriMm > 0 && !c.noLambri;

    final lines = <FrameLine>[];
    if (topBandMm > 0) lines.add(FrameLine(0, bandY, 1, bandY));

    if (transomMm > 0) {
      var i0 = cols.indexWhere((c) => c.inTransom);
      var i1 = cols.lastIndexWhere((c) => c.inTransom);
      if (i0 < 0) {
        i0 = 0;
        i1 = cols.length - 1;
      }
      final tFrom = b[i0];
      final tTo = b[i1 + 1];
      lines.add(FrameLine(tFrom, ty, tTo, ty));
      if (transomPanesMm.length > 1) {
        final span = tTo - tFrom;
        final tSum = transomPanesMm.fold<int>(0, (p, e) => p + e);
        var ta = 0;
        for (var i = 0; i < transomPanesMm.length - 1; i++) {
          ta += transomPanesMm[i];
          final x = tFrom + span * ta / tSum;
          lines.add(FrameLine(x, bandY, x, ty));
        }
      }
    }

    for (var i = 1; i < b.length - 1; i++) {
      final l = cols[i - 1];
      final r = cols[i];
      final top = transomMm > 0 && l.inTransom && r.inTransom ? ty : bandY;
      final bottom = !lambriPerColumn && covered(l) && covered(r) ? ly : 1.0;
      lines.add(FrameLine(b[i], top, b[i], bottom));
    }

    if (lambriMm > 0) {
      var i = 0;
      while (i < cols.length) {
        if (cols[i].noLambri) {
          i++;
          continue;
        }
        var j = i;
        while (j + 1 < cols.length && !cols[j + 1].noLambri) {
          j++;
        }
        lines.add(FrameLine(b[i], ly, b[j + 1], ly));
        i = j + 1;
      }
    }

    final grouped = lambriMm > 0 &&
        cols.any((c) =>
            c.role != ProposalColRole.fixed && c.sashToFloor && !c.noLambri);

    final setups = <DefaultZoneSetup>[];
    for (var i = 0; i < cols.length; i++) {
      final c = cols[i];
      final cx = (b[i] + b[i + 1]) / 2;
      final colTop = c.inTransom ? ty : bandY;
      final colCovered = covered(c);
      final bodyBottom = colCovered ? ly : 1.0;

      var top = colTop;

      if (c.topVentMm > 0) {
        final vy = colTop + yy(c.topVentMm);
        lines.add(FrameLine(b[i], vy, b[i + 1], vy));
        setups.add(DefaultZoneSetup(
          zoneCenter: Offset(cx, (colTop + vy) / 2),
          openingCategory: _tilt,
          openingSingleSash: grouped,
        ));
        top = vy;
      }

      if (c.topFixedMm > 0) {
        final fy = colTop + yy(c.topFixedMm);
        lines.add(FrameLine(b[i], fy, b[i + 1], fy));
        top = fy;
      }

      if (c.lambriFill) {
        setups.add(DefaultZoneSetup(
          zoneCenter: Offset(cx, (colTop + bodyBottom) / 2),
          layoutCategory: 1,
        ));
      }

      switch (c.role) {
        case ProposalColRole.fixed:

          if (c.panelLikeDoor && doorPanelMm > 0) {
            final py = 1 - yy(doorPanelMm);
            lines.add(FrameLine(b[i], py, b[i + 1], py));
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, py + (1 - py) / 2),
              layoutCategory: 3, 
            ));
          }
        case ProposalColRole.casement:
        case ProposalColRole.door:
          final isDoor = c.role == ProposalColRole.door;
          final cat = c.openCat != 0
              ? c.openCat
              : isDoor

                  ? (cx < 0.5 ? _hingeLeft : _hingeRight)
                  : proposalCasementCategory(
                      widthMm: c.widthMm,
                      heightMm: ((bodyBottom - top) * h).round(),
                      leftSide: cx < 0.5,
                    );
          if (isDoor && doorPanelMm > 0) {

            final py = 1 - yy(doorPanelMm);
            lines.add(FrameLine(b[i], py, b[i + 1], py));
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, top + (py - top) / 2),
              openingCategory: cat,
              openingIsDoor: true,
              openingSingleSash: true,
              openingHasHandle: c.hasHandle,
            ));
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, py + (1 - py) / 2),
              openingCategory: cat,
              openingIsDoor: true,
              openingSingleSash: true,
              openingHasHandle: c.hasHandle,
            ));
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, py + (1 - py) / 2),
              layoutCategory: 3, 
            ));
          } else if (colCovered && c.sashToFloor) {

            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, (top + ly) / 2),
              openingCategory: cat,
              openingIsDoor: isDoor,
              openingSingleSash: true,
              openingHasHandle: c.hasHandle,
            ));
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, (ly + 1) / 2),
              openingCategory: cat,
              openingIsDoor: isDoor,
              openingSingleSash: true,
              openingHasHandle: c.hasHandle,
            ));
          } else {
            setups.add(DefaultZoneSetup(
              zoneCenter: Offset(cx, (top + bodyBottom) / 2),
              openingCategory: cat,
              openingIsDoor: isDoor,
              openingSingleSash: grouped,
              openingHasHandle: c.hasHandle,
            ));
          }
      }

      if (colCovered && lambriPerColumn) {
        setups.add(DefaultZoneSetup(
          zoneCenter: Offset(cx, (ly + 1) / 2),
          layoutCategory: bandPattern,
        ));
      }
    }

    if (lambriMm > 0 && !lambriPerColumn) {
      var i = 0;
      while (i < cols.length) {
        if (cols[i].noLambri) {
          i++;
          continue;
        }
        var j = i;
        while (j + 1 < cols.length && !cols[j + 1].noLambri) {
          j++;
        }
        setups.add(DefaultZoneSetup(
          zoneCenter: Offset((b[i] + b[j + 1]) / 2, (ly + 1) / 2),
          layoutCategory: bandPattern,
        ));
        i = j + 1;
      }
    }

    final snapX = exactWidths
        ? (double v) => v
        : proposalSnapAxis([
            for (final l in lines) ...[l.startX, l.endX]
          ], widthMm);
    final widths = [
      for (var i = 0; i < cols.length; i++)
        ((snapX(b[i + 1]) - snapX(b[i])) * widthMm).round(),
    ];

    return ProposalTemplate(
      type: type,
      title: title,
      subtitle: subtitle.isEmpty ? _sizeSubtitle(widths) : subtitle,
      lines: lines,
      zoneSetups: setups,
      isPopular: isPopular,
      snapWidths: !exactWidths,
      pinFirst: pinFirst,
      plainDoorPosts: plainDoorPosts,
    );
  }

  String _sizeSubtitle(List<int> widths) {
    final parts = widths.join(' + ');
    final extras = <String>[
      if (transomMm > 0) 'tepa oyna',
      if (lambriMm > 0) 'pastida lambri',
    ];
    return extras.isEmpty ? '$parts mm' : '$parts mm · ${extras.join(' · ')}';
  }
}

List<ProposalLayout> proposalLayouts(
    ProposalType type, int widthMm, int heightMm) {
  if (widthMm <= 0 || heightMm <= 0) return const [];
  var raw = switch (type) {
    ProposalType.door => _doorLayouts(widthMm, heightMm),
    ProposalType.window => _windowLayouts(widthMm, heightMm),
    ProposalType.arch => const <ProposalLayout>[],
  };

  if (type == ProposalType.door && (widthMm >= 1400 || heightMm >= 2600)) {
    raw = raw.where((l) {
      final doorCols = l.cols.where((c) => c.role == ProposalColRole.door);
      final isStandaloneDoor =
          l.cols.every((c) => c.role == ProposalColRole.door);
      if (isStandaloneDoor && doorCols.length < 2) return false;
      if (doorCols.any((c) => c.widthMm >= 1400)) return false;
      return true;
    }).toList();
  }

  final seen = <String>{};
  final primary = <ProposalLayout>[];
  final transom = <ProposalLayout>[];
  for (final l in raw) {
    if (!seen.add(l.signature)) continue;
    (l.transomVariant ? transom : primary).add(l);
  }
  final quota = transom.isEmpty ? 0 : _transomQuota;
  return [
    ...primary.take(_maxLayouts - quota),
    ...transom.take(quota),
  ];
}

ProposalShape normalizedProposalShape(
    ProposalShape shape, int widthMm, int heightMm) {
  final isWindow =
      shape == ProposalShape.deraza || shape == ProposalShape.vitraj;
  if (!isWindow) return shape;

  final isVitraj = (widthMm >= 3000 && heightMm >= 2200) ||
      widthMm > proposalVitrajDoorMinWidthMm;
  return isVitraj ? ProposalShape.vitraj : ProposalShape.deraza;
}

List<ProposalTemplate> proposalTemplatesFor(
  ProposalType type,
  int widthMm,
  int heightMm, {
  int floorGapMm = 0,
  bool doorOnRight = true,
  bool tShape = false,
}) {
  if (floorGapMm > 0 && type == ProposalType.door) {
    if (tShape) {
      return proposalTShapeTemplates(
        widthMm: widthMm,
        heightMm: heightMm,
        floorGapMm: floorGapMm,
      );
    }
    return [
      ...proposalBalkonBlokTemplates(
        widthMm: widthMm,
        heightMm: heightMm,
        floorGapMm: floorGapMm,
        doorOnRight: doorOnRight,
      ),

      if (widthMm - 1000 >= 700)
        ...proposalBalkonBlokSideTemplates(
          widthMm: widthMm,
          heightMm: heightMm,
          floorGapMm: floorGapMm,
          doorOnRight: doorOnRight,
        ),
    ];
  }
  final out = <ProposalTemplate>[];
  final layouts = proposalLayouts(type, widthMm, heightMm);
  if (layouts.isNotEmpty) {
    out.addAll(
        [for (final l in layouts) l.toTemplate(type, widthMm, heightMm)]);
  } else {
    out.addAll(
        proposalTemplatesForType(type).where((t) => t.fits(widthMm, heightMm)));
  }

  out.addAll(proposalLibraryMatches(type, widthMm, heightMm));
  return out;
}

List<ProposalTemplate> proposalBalkonBlokTemplates({
  required int widthMm,
  required int heightMm,
  required int floorGapMm,
  bool doorOnRight = true,
}) {
  final w = widthMm;
  final h = heightMm;

  if (h - 1000 < 300 || math.min(_doorMaxMm, w - 700) < _doorMinMm) return const [];
  final gap = floorGapMm.clamp(300, h - 1000);
  final doorW = _doorTargetMm.clamp(_doorMinMm, math.min(_doorMaxMm, w - 700));
  final winW = w - doorW;
  if (winW < 700) return const [];

  final xa = doorOnRight ? winW / w : doorW / w; 
  final wb = (h - gap) / h; 

  final winRegion = doorOnRight
      ? FrameRegion(0, 0, xa, wb, absorbedRight: true)
      : FrameRegion(xa, 0, 1, wb, absorbedLeft: true);
  final doorRegion = doorOnRight
      ? FrameRegion(xa, 0, 1, 1, hideOuterStrokeLeft: true)
      : FrameRegion(0, 0, xa, 1, hideOuterStrokeRight: true);

  double winCx(double frac) => doorOnRight ? xa * frac : xa + (1 - xa) * frac;
  final doorCx = doorOnRight ? (xa + 1) / 2 : xa / 2;

  ProposalTemplate build({
    required String title,
    required String subtitle,
    required List<FrameLine> winLines,
    required List<DefaultZoneSetup> winSetups,
    bool popular = false,
    int transomMm = 0,
  }) {

    final ty = transomMm > 0 ? transomMm / h : 0.0;
    return ProposalTemplate(
      type: ProposalType.door,
      title: title,
      subtitle: subtitle,
      lines: [

        FrameLine(xa, 0, xa, 1),

        doorOnRight ? FrameLine(0, wb, xa, wb) : FrameLine(xa, wb, 1, wb),
        if (transomMm > 0) FrameLine(0, ty, 1, ty),
        ...winLines,
      ],
      zoneSetups: [
        ...winSetups,
        DefaultZoneSetup(

          zoneCenter: Offset(doorCx, (ty + 1) / 2),
          openingCategory: doorOnRight ? _hingeRight : _hingeLeft,
          openingIsDoor: true,
        ),
      ],
      regions: [winRegion, doorRegion],
      isPopular: popular,
    );
  }

  final out = <ProposalTemplate>[

    build(
      title: 'Balkon blok',
      subtitle: 'Deraza ochiladi, eshik polgacha',
      winLines: const [],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(winCx(0.5), wb / 2),
          openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
        ),
      ],
      popular: true,
    ),
  ];

  if (winW >= 1100) {
    final xm = doorOnRight ? xa / 2 : xa + (1 - xa) / 2;
    out.add(build(
      title: 'Balkon blok, 2 bo\'lmali deraza',
      subtitle: 'Derazaning chekka tavaqasi ochiladi',
      winLines: [FrameLine(xm, 0, xm, wb)],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(doorOnRight ? xm / 2 : xm + (1 - xm) / 2, wb / 2),
          openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
        ),
      ],
    ));
  }

  out.add(build(
    title: 'Balkon blok, deraza qo\'zg\'almas',
    subtitle: 'Faqat eshik ochiladi',
    winLines: const [],
    winSetups: const [],
  ));

  final winH = h - gap;
  if (winH >= 1500) {
    final yv = _ventMm / h;
    out.add(build(
      title: 'Balkon blok, fortochkali',
      subtitle: 'Deraza tepasida fortochka, pasti yaxlit',
      winLines: [
        doorOnRight ? FrameLine(0, yv, xa, yv) : FrameLine(xa, yv, 1, yv),
      ],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(winCx(0.5), yv / 2),
          openingCategory: _tilt,
        ),
      ],
    ));
  }

  if (h >= 2600) {
    final ty = _ventMm / h;
    final winMidY = (ty + wb) / 2;
    out.add(build(
      transomMm: _ventMm,
      title: 'Balkon blok + tepa oyna',
      subtitle: 'Butun en bo\'ylab tepa oyna, eshik ustida ham',
      winLines: winW >= 1100
          ? [
              FrameLine(doorOnRight ? xa / 2 : xa + (1 - xa) / 2, ty,
                  doorOnRight ? xa / 2 : xa + (1 - xa) / 2, wb),
            ]
          : const [],
      winSetups: [
        DefaultZoneSetup(

          zoneCenter: Offset(
              winCx(winW >= 1100 ? (doorOnRight ? 0.25 : 0.75) : 0.5), winMidY),
          openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
        ),
      ],
    ));
  }
  return out;
}

List<ProposalTemplate> proposalBalkonBlokSideTemplates({
  required int widthMm,
  required int heightMm,
  required int floorGapMm,
  bool doorOnRight = true,
}) {
  final w = widthMm;
  final h = heightMm;

  if (h - 1000 < 300) return const [];
  final gap = floorGapMm.clamp(300, h - 1000);
  const doorW = 600, sideW = 400;
  const secW = doorW + sideW; 
  final winW = w - secW;
  if (winW < 700) return const [];

  final xa = doorOnRight ? winW / w : secW / w; 

  final xs = doorOnRight ? xa + sideW / w : (secW - sideW) / w;
  final wb = (h - gap) / h;

  final winRegion = doorOnRight
      ? FrameRegion(0, 0, xa, wb, absorbedRight: true)
      : FrameRegion(xa, 0, 1, wb, absorbedLeft: true);
  final secRegion = doorOnRight
      ? FrameRegion(xa, 0, 1, 1, hideOuterStrokeLeft: true)
      : FrameRegion(0, 0, xa, 1, hideOuterStrokeRight: true);

  double winCx(double frac) => doorOnRight ? xa * frac : xa + (1 - xa) * frac;
  final sideCx = (xa + xs) / 2; 
  final doorCx = doorOnRight ? (xs + 1) / 2 : xs / 2;

  ProposalTemplate build({
    required String title,
    required List<FrameLine> winLines,
    required List<DefaultZoneSetup> winSetups,
    bool popular = false,
  }) =>
      ProposalTemplate(
        type: ProposalType.door,
        title: title,
        subtitle: 'Eshik yonidagi tor tavaqa shpingalet bilan ochiladi',
        lines: [
          FrameLine(xa, 0, xa, 1),
          FrameLine(xs, 0, xs, 1),
          doorOnRight ? FrameLine(0, wb, xa, wb) : FrameLine(xa, wb, 1, wb),
          ...winLines,
        ],
        zoneSetups: [
          ...winSetups,

          DefaultZoneSetup(
            zoneCenter: Offset(sideCx, 0.5),
            openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
            openingIsDoor: true,
            openingHasHandle: false,
          ),
          DefaultZoneSetup(
            zoneCenter: Offset(doorCx, 0.5),
            openingCategory: doorOnRight ? _hingeRight : _hingeLeft,
            openingIsDoor: true,
          ),
        ],
        regions: [winRegion, secRegion],
        isPopular: popular,
      );

  final out = <ProposalTemplate>[
    build(
      title: 'Balkon blok, juft eshik',
      winLines: const [],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(winCx(0.5), wb / 2),
          openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
        ),
      ],
    ),
  ];

  if (winW >= 1100) {
    final xm = doorOnRight ? xa / 2 : xa + (1 - xa) / 2;
    out.add(build(
      title: 'Balkon blok, juft eshik, 2 bo\'lmali deraza',
      winLines: [FrameLine(xm, 0, xm, wb)],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(doorOnRight ? xm / 2 : xm + (1 - xm) / 2, wb / 2),
          openingCategory: doorOnRight ? _hingeLeft : _hingeRight,
        ),
      ],
    ));
  }
  return out;
}

List<ProposalTemplate> proposalTShapeTemplates({
  required int widthMm,
  required int heightMm,
  required int floorGapMm,
}) {
  final w = widthMm;
  final h = heightMm;

  if (h - 1000 < 300 || math.min(_doorMaxMm, w - 1000) < _doorMinMm) return const [];
  final gap = floorGapMm.clamp(300, h - 1000);
  final doorW = _doorTargetMm.clamp(_doorMinMm, math.min(_doorMaxMm, w - 1000));
  final sideW = (w - doorW) / 2;

  if (sideW < 500) return const [];

  final x1 = sideW / w;
  final x2 = (sideW + doorW) / w;
  final wb = (h - gap) / h;

  final regions = [
    FrameRegion(0, 0, x1, wb, absorbedRight: true),
    FrameRegion(x1, 0, x2, 1,
        hideOuterStrokeLeft: true, hideOuterStrokeRight: true),
    FrameRegion(x2, 0, 1, wb, absorbedLeft: true),
  ];

  ProposalTemplate build({
    required String title,
    required String subtitle,
    required List<FrameLine> winLines,
    required List<DefaultZoneSetup> winSetups,
    bool popular = false,
    int transomMm = 0,
  }) {

    final ty = transomMm > 0 ? transomMm / h : 0.0;
    return ProposalTemplate(
      type: ProposalType.door,
      title: title,
      subtitle: subtitle,
      lines: [
        FrameLine(x1, 0, x1, 1),
        FrameLine(x2, 0, x2, 1),

        FrameLine(0, wb, x1, wb),
        FrameLine(x2, wb, 1, wb),
        if (transomMm > 0) FrameLine(0, ty, 1, ty),
        ...winLines,
      ],
      zoneSetups: [
        ...winSetups,
        DefaultZoneSetup(

          zoneCenter: Offset((x1 + x2) / 2, (ty + 1) / 2),
          openingCategory: _hingeRight,
          openingIsDoor: true,
        ),
      ],
      regions: regions,
      isPopular: popular,
    );
  }

  final out = <ProposalTemplate>[

    build(
      title: 'T blok, ikki deraza ochiladi',
      subtitle: 'Eshik o\'rtada, yon derazalar ochiladi',
      winLines: const [],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(x1 / 2, wb / 2),
          openingCategory: _hingeLeft,
        ),
        DefaultZoneSetup(
          zoneCenter: Offset((x2 + 1) / 2, wb / 2),
          openingCategory: _hingeRight,
        ),
      ],
      popular: true,
    ),
  ];

  if (sideW >= 1100) {
    final xl = x1 / 2;
    final xr = x2 + (1 - x2) / 2;
    out.add(build(
      title: 'T blok, 2 bo\'lmali derazalar',
      subtitle: 'Har derazaning chekka tavaqasi ochiladi',
      winLines: [
        FrameLine(xl, 0, xl, wb),
        FrameLine(xr, 0, xr, wb),
      ],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(xl / 2, wb / 2),
          openingCategory: _hingeLeft,
        ),
        DefaultZoneSetup(
          zoneCenter: Offset((xr + 1) / 2, wb / 2),
          openingCategory: _hingeRight,
        ),
      ],
    ));
  }

  out.add(build(
    title: 'T blok, derazalar qo\'zg\'almas',
    subtitle: 'Faqat eshik ochiladi',
    winLines: const [],
    winSetups: const [],
  ));

  if (h >= 2600) {
    final ty = _ventMm / h;
    final winMidY = (ty + wb) / 2;
    out.add(build(
      transomMm: _ventMm,
      title: 'T blok + tepa oyna',
      subtitle: 'Butun en bo\'ylab tepa oyna, eshik ustida ham',
      winLines: const [],
      winSetups: [
        DefaultZoneSetup(
          zoneCenter: Offset(x1 / 2, winMidY),
          openingCategory: _hingeLeft,
        ),
        DefaultZoneSetup(
          zoneCenter: Offset((x2 + 1) / 2, winMidY),
          openingCategory: _hingeRight,
        ),
      ],
    ));
  }
  return out;
}

List<ProposalLayout> _windowLayouts(int w, int h) {

  if (h <= 900) {
    var n = (w / _tiltMaxMm).ceil();
    while (n > 1 && w / n < _casementMinMm) {
      n--;
    }
    final widths = _splitEven(w, n);
    final cat = h <= 520 ? _tiltReverse : _tilt;
    return [
      ProposalLayout(
        cols: [
          for (final x in widths)
            ProposalCol(x, ProposalColRole.casement, openCat: cat)
        ],
        title: 'Fortochka',
        subtitle: 'Tepaga ochiladi',
        isPopular: true,
      ),
      ProposalLayout(
        cols: [for (final x in widths) ProposalCol(x, ProposalColRole.fixed)],
        title: 'Qo\'zg\'almas oyna',
        subtitle: 'Ochilmaydi — eng arzon',
      ),
    ];
  }

  if (w <= 700 && h >= 1600) {
    final out = <ProposalLayout>[
      ProposalLayout(
        cols: [
          ProposalCol(w, ProposalColRole.casement, openCat: _hingeRightTilt)
        ],
        title: 'Tor baland deraza',
        subtitle: 'Yonga va tepaga ochiladi',
        isPopular: true,
      ),
    ];
    if (h >= 2200) {
      out.add(ProposalLayout(
        cols: [
          ProposalCol(w, ProposalColRole.casement,
              openCat: _hingeRightTilt, topFixedMm: (h - 1800).clamp(500, 800)),
        ],
        title: 'Tepasi qo\'zg\'almas, pasti ochiladi',
      ));
    }
    out.add(ProposalLayout(
      cols: [ProposalCol(w, ProposalColRole.fixed)],
      title: 'Qo\'zg\'almas oyna',
      subtitle: 'Ochilmaydi — eng arzon',
    ));
    return out;
  }

  if (w > proposalVitrajDoorMinWidthMm && h >= _vitrajDoorMinHeightMm) {
    return _vitrajCenterDoorLayouts(w, h);
  }

  if (w >= 2800) return _balconyLayouts(w, h);

  return _classicWindowLayouts(w, h);
}

List<ProposalLayout> _vitrajCenterDoorLayouts(int w, int h) {

  final side = (w - 2 * _doorTargetMm) ~/ 2;
  final core = w - 2 * side; 
  final activeLeaf = core ~/ 2;
  final passiveLeaf = core - activeLeaf;

  final transom = h >= 2700 ? _ventMm : 0;

  final lambri = h - transom >= 2000 ? 600 : 0;

  final sideWidths = _vitrajSideCols(side, 700);

  List<ProposalCol> leftCols({required bool openable}) {
    final n = sideWidths.length;
    final a = n >= 3 ? n ~/ 2 - 1 : 0;
    final bIdx = n >= 3 ? n ~/ 2 : -1;
    return [
      for (var i = 0; i < n; i++)
        if (openable && (i == a || i == bIdx))
          ProposalCol(sideWidths[i], ProposalColRole.casement,
              openCat: i == a ? _hingeLeft : _hingeRight)
        else
          ProposalCol(sideWidths[i], ProposalColRole.fixed),
    ];
  }

  List<ProposalCol> doorCols() => [
        ProposalCol(activeLeaf, ProposalColRole.door, noLambri: true),
        ProposalCol(passiveLeaf, ProposalColRole.door,
            hasHandle: false, noLambri: true),
      ];

  List<ProposalCol> mirrored(List<ProposalCol> cols) => [
        for (final c in cols.reversed)
          ProposalCol(
            c.widthMm,
            c.role,
            openCat: switch (c.openCat) {
              _hingeLeft => _hingeRight,
              _hingeRight => _hingeLeft,
              _hingeLeftTilt => _hingeRightTilt,
              _hingeRightTilt => _hingeLeftTilt,
              final other => other,
            },
            hasHandle: c.hasHandle,
            noLambri: c.noLambri,
          ),
      ];

  List<ProposalCol> compose({required bool openable}) {
    final left = leftCols(openable: openable);
    return [...left, ...doorCols(), ...mirrored(left)];
  }

  final panes = <int>[side, core, side];

  return [
    ProposalLayout(
      transomMm: transom,
      transomPanesMm: transom > 0 ? panes : const [],
      lambriMm: lambri,
      cols: compose(openable: true),
      title: 'Vitraj: markazda juft eshik',
      subtitle: lambri > 0
          ? 'Kirish eshigi o\'rtada, yonlarda ochiluvchi oyna, pastida lambri'
          : 'Kirish eshigi o\'rtada, yonlarda ochiluvchi oyna',
      isPopular: true,
    ),
    ProposalLayout(
      transomMm: transom,
      transomPanesMm: transom > 0 ? panes : const [],
      cols: compose(openable: true),
      title: 'Vitraj: juft eshik, to\'liq bo\'yli oynalar',
      subtitle: 'Lambrisiz — yon oynalar polgacha yaxlit',
    ),
    ProposalLayout(
      transomMm: transom,
      transomPanesMm: transom > 0 ? panes : const [],
      lambriMm: lambri,
      cols: compose(openable: false),
      title: 'Vitraj: juft eshik, qo\'zg\'almas oynalar',
      subtitle: 'Faqat eshik ochiladi — eng arzon variant',
    ),
  ];
}

List<int> _vitrajSideCols(int mm, int target) {
  if (mm <= 0) return const [];
  var n = (mm / target).round().clamp(1, 16);
  while (n > 1 && mm / n < _colMinMm) {
    n--;
  }
  return _splitEven(mm, n);
}

List<ProposalLayout> _classicWindowLayouts(int w, int h) {
  final out0 = <ProposalLayout>[];

  final pSide = (w / 4).round().clamp(_casementMinMm, 700);
  final pCenter = w - 2 * pSide;
  if (pCenter >= 800 && pCenter <= 1300) {
    out0.add(ProposalLayout(
      cols: [
        ProposalCol(pSide, ProposalColRole.casement, openCat: _hingeLeft),
        ProposalCol(pCenter, ProposalColRole.fixed),
        ProposalCol(pSide, ProposalColRole.casement, openCat: _hingeRight),
      ],
      title: 'Panorama: o\'rtasi keng',
      subtitle: 'Chekkalari ochiladi, o\'rtasi yaxlit oyna',
    ));
  }

  final cw3 = _splitEven(w, 3);
  final threeFit = cw3.first >= _casementMinMm && cw3.last <= _casementMaxMm;

  if (threeFit && w >= 1200 && h >= 2000) {
    out0.add(ProposalLayout(
      cols: [
        ProposalCol(cw3[0], ProposalColRole.casement,
            openCat: _hingeLeft, topFixedMm: _ventMm),
        ProposalCol(cw3[1], ProposalColRole.fixed),
        ProposalCol(cw3[2], ProposalColRole.casement,
            openCat: _hingeRight, topFixedMm: _ventMm),
      ],
      title: 'Portal: o\'rtasi to\'liq bo\'yli',
      subtitle: 'Yonlari ochiladi, o\'rtasi yaxlit oyna',
    ));
  }

  if (threeFit && w >= 1200 && h >= 1600 && h < 2000) {
    out0.add(ProposalLayout(
      cols: [
        ProposalCol(cw3[0], ProposalColRole.casement, openCat: _hingeLeft),

        ProposalCol(cw3[1], ProposalColRole.fixed, topFixedMm: h - _ventMm),
        ProposalCol(cw3[2], ProposalColRole.casement, openCat: _hingeRight),
      ],
      title: 'O\'rtasi pastki bo\'lakli',
      subtitle: 'Yonlari ochiladi, o\'rta pastida alohida oyna',
    ));
  }

  if (threeFit && w >= 1600 && h >= 1100 && h <= 1700) {
    out0.add(ProposalLayout(
      cols: [
        ProposalCol(cw3[0], ProposalColRole.casement, openCat: _hingeLeft),
        ProposalCol(cw3[1], ProposalColRole.fixed,
            topVentMm: h >= 1300 ? _ventMm : 400),
        ProposalCol(cw3[2], ProposalColRole.casement, openCat: _hingeRight),
      ],
      title: '3 bo\'lmali, o\'rtasi fortochkali',
      subtitle: 'Chekkalari ochiladi, o\'rta tepasida fortochka',
      isPopular: true,
    ));
  }

  final counts = <int>[];
  for (var n = 1; n <= 6; n++) {
    final cw = w / n;
    if (cw >= _colMinMm && cw <= _casementMaxMm) counts.add(n);
  }
  if (counts.isEmpty) {
    counts.add(math.max(1, (w / _colTargetMm).round()));
  }
  counts.sort((a, b) =>
      (w / a - _colTargetMm).abs().compareTo((w / b - _colTargetMm).abs()));

  final out = <ProposalLayout>[];
  var fixedAdded = false;

  for (final n in counts.take(2)) {
    final widths = _splitEven(w, n);
    final canOpen =
        widths.every((x) => x >= _casementMinMm && x <= _casementMaxMm);

    final patterns = <({Map<int, int> open, String title, bool pop})>[];
    if (canOpen) {
      if (n == 1) {
        patterns.add((open: {0: 0}, title: '1 bo\'lmali, ochiladi', pop: true));
      } else if (n == 2) {
        patterns.add(
            (open: {1: 0}, title: '2 bo\'lmali, 1 tasi ochiladi', pop: true));
        patterns.add((
          open: {0: 0, 1: 0},
          title: '2 bo\'lmali, ikkisi ochiladi',
          pop: false
        ));
      } else if (n == 3) {

        patterns.add((
          open: {0: 0, 2: 0},
          title: '3 bo\'lmali, 2 chekkasi ochiladi',
          pop: true
        ));
        patterns.add((
          open: {1: 0},
          title: '3 bo\'lmali, o\'rtasi ochiladi',
          pop: false
        ));
      } else {

        final li = n ~/ 2 - 1;
        final ri = n ~/ 2;
        final tall = h >= 1600;
        patterns.add((
          open: {
            li: tall ? _hingeLeftTilt : _hingeLeft,
            ri: tall ? _hingeRightTilt : _hingeRight,
          },
          title: '$n bo\'lmali, o\'rtadagi 2 tasi ochiladi',
          pop: true
        ));
        patterns.add((
          open: {0: _hingeLeft, n - 1: _hingeRight},
          title: '$n bo\'lmali, 2 chekkasi ochiladi',
          pop: false
        ));
      }
    }

    for (var pi = 0; pi < patterns.length; pi++) {
      final p = patterns[pi];
      final cols = [
        for (var i = 0; i < n; i++)
          p.open.containsKey(i)
              ? ProposalCol(widths[i], ProposalColRole.casement,
                  openCat: p.open[i]!)
              : ProposalCol(widths[i], ProposalColRole.fixed),
      ];
      out.add(ProposalLayout(cols: cols, title: p.title, isPopular: p.pop));

      if (pi == 0 && h >= 1400) {
        final tMm = h >= 1700 ? 500 : 400;
        out.add(ProposalLayout(
          cols: cols,
          transomMm: tMm,
          transomPanesMm: _splitEven(w, n <= 2 ? n : n - 1),
          title: '${p.title} + tepa oyna',
          transomVariant: true,
        ));
      }
    }

    if (!fixedAdded) {
      out.add(ProposalLayout(
        cols: [
          for (var i = 0; i < n; i++)
            ProposalCol(widths[i], ProposalColRole.fixed)
        ],
        title: n == 1 ? 'Qo\'zg\'almas oyna' : '$n bo\'lmali, qo\'zg\'almas',
        subtitle: 'Ochilmaydi — eng arzon',
      ));
      fixedAdded = true;
    }
  }

  return [...out0, ...out];
}

List<ProposalLayout> _balconyLayouts(int w, int h) {
  var n = (w / 667).round().clamp(4, 12);
  while (n > 4 && w / n < 600) {
    n--;
  }
  while (w / n > 750) {
    n++;
  }
  final widths = _splitEven(w, n);
  final out = <ProposalLayout>[];

  if (h < 2100) {

    final vent = h >= 1400 ? _ventMm : 0;
    out.add(ProposalLayout(
      cols: [
        for (var i = 0; i < n; i++)
          i == 1
              ? ProposalCol(widths[i], ProposalColRole.casement,
                  openCat: _hingeLeft)
              : i == n - 2
                  ? ProposalCol(widths[i], ProposalColRole.casement,
                      openCat: _hingeRight)
                  : ProposalCol(widths[i], ProposalColRole.fixed,
                      topVentMm: i > 1 && i < n - 2 ? vent : 0),
      ],
      title: 'Balkon romi',
      isPopular: true,
    ));
    if (vent > 0) {

      out.add(ProposalLayout(
        cols: [
          for (var i = 0; i < n; i++)
            i == 1
                ? ProposalCol(widths[i], ProposalColRole.casement,
                    openCat: _hingeLeft)
                : i == n - 2
                    ? ProposalCol(widths[i], ProposalColRole.casement,
                        openCat: _hingeRight)
                    : ProposalCol(widths[i], ProposalColRole.fixed),
        ],
        title: 'Balkon romi, fortochkasiz',
      ));
    }

    if (n >= 8) {
      out.add(ProposalLayout(
        cols: [
          for (var i = 0; i < n; i++)
            i == 0 || i == n - 1
                ? ProposalCol(widths[i], ProposalColRole.fixed,
                    lambriFill: true)
                : (i == 2 || i == n - 4)
                    ? ProposalCol(widths[i], ProposalColRole.casement,
                        openCat: _hingeLeft)
                    : (i == 3 || i == n - 3)
                        ? ProposalCol(widths[i], ProposalColRole.casement,
                            openCat: _hingeRight)
                        : ProposalCol(widths[i], ProposalColRole.fixed),
        ],
        title: 'Lenta, chekkalari lambri',
        subtitle: 'Ikki juft ochiluvchi, chekka ustunlar lambri panel',
      ));
    }
    return out;
  }

  final lambri = (h - 1900).clamp(550, 800);
  final rem = h - 1900 - lambri;
  final band = rem >= 350 ? rem.clamp(350, 600) : 0;

  if (w >= 3500 && w <= 4500 && h >= 2600) {
    final fWidths = _splitEven(w, 5);
    out.add(ProposalLayout(
      transomMm: _ventMm,
      transomPanesMm: _splitEven(w, 3),
      lambriMm: (h - 2200).clamp(600, 900),
      lambriPerColumn: true,
      cols: [
        for (var i = 0; i < 5; i++)
          i == 1
              ? ProposalCol(fWidths[i], ProposalColRole.casement,
                  openCat: _hingeLeft)
              : i == 3
                  ? ProposalCol(fWidths[i], ProposalColRole.casement,
                      openCat: _hingeRight)
                  : ProposalCol(fWidths[i], ProposalColRole.fixed),
      ],
      title: 'Fasad romi, lambri bilan',
      subtitle: 'Tepa oynalar + pastida lambri',
      isPopular: true,
    ));
  }

  final nSide = (w * 0.19).round().clamp(550, 800);
  final nCenter = w - 2 * nSide;
  if (h >= 2400 && nCenter >= 1800 && nCenter <= 2400) {
    out.add(ProposalLayout(
      lambriMm: (h - 2200).clamp(500, 800),
      lambriPerColumn: true,
      bandPattern: 3, 
      cols: [
        ProposalCol(nSide, ProposalColRole.casement, openCat: _hingeLeft),
        ProposalCol(nCenter, ProposalColRole.fixed, noLambri: true),
        ProposalCol(nSide, ProposalColRole.casement, openCat: _hingeRight),
      ],
      title: 'Panorama rom',
      subtitle: 'O\'rtasi to\'liq oyna, yon oyoqlari panel',
    ));
  }

  if (w >= 4600 && n >= 7) {
    final vBand = h >= 2600 ? _ventMm : 0;
    final vLambri = 600;
    out.add(ProposalLayout(
      topBandMm: vBand,
      lambriMm: vLambri,
      cols: [
        for (var i = 0; i < n; i++)
          i == 1 || i == 2
              ? ProposalCol(widths[i], ProposalColRole.casement,
                  openCat: i == 1 ? _hingeLeft : _hingeRight)
              : i == n - 3 || i == n - 2
                  ? ProposalCol(widths[i], ProposalColRole.casement,
                      openCat: i == n - 3 ? _hingeLeft : _hingeRight)
                  : ProposalCol(widths[i], ProposalColRole.fixed,
                      topVentMm: _isMiddleColumn(i, n) ? _ventMm : 0),
      ],
      title: 'Ayvon romi',
      subtitle: 'Pastida lambri, o\'rtasida fortochka',
      isPopular: true,
    ));
  }

  out.add(ProposalLayout(
    topBandMm: band,
    lambriMm: lambri,
    cols: [
      for (var i = 0; i < n; i++)
        i == 0 || i == n - 1
            ? ProposalCol(widths[i], ProposalColRole.fixed, topVentMm: _ventMm)
            : i == 1
                ? ProposalCol(widths[i], ProposalColRole.casement,
                    openCat: _hingeLeftTilt)
                : i == n - 2
                    ? ProposalCol(widths[i], ProposalColRole.casement,
                        openCat: _hingeRightTilt)
                    : ProposalCol(widths[i], ProposalColRole.fixed),
    ],
    title: 'Balkon romi, pastida lambri',
    isPopular: out.isEmpty,
  ));

  if (h <= 2400) {

    out.add(ProposalLayout(
      cols: [
        for (var i = 0; i < n; i++)
          i == 0 || i == n - 1
              ? ProposalCol(widths[i], ProposalColRole.fixed,
                  topVentMm: _ventMm)
              : i == 1
                  ? ProposalCol(widths[i], ProposalColRole.casement,
                      openCat: _hingeLeftTilt)
                  : i == n - 2
                      ? ProposalCol(widths[i], ProposalColRole.casement,
                          openCat: _hingeRightTilt)
                      : ProposalCol(widths[i], ProposalColRole.fixed),
      ],
      title: 'Balkon romi',
    ));
  }
  return out;
}

List<ProposalLayout> _doorLayouts(int w, int h) {
  final out = <ProposalLayout>[];
  final tall = h >= 2200;

  final tMm = h >= 2500 ? 400 : 300;

  final maxDoor = math.min(_doorMaxMm, w - _sideMinMm);

  if (maxDoor < 600 || w < proposalSingleLeafDoorUpToMm) {
    final door = [ProposalCol(w, ProposalColRole.door)];
    out.add(ProposalLayout(
      cols: door,
      title: 'To\'liq oynali eshik',
      subtitle: 'Butun eshik oynali',
      isPopular: true,
    ));
    out.add(ProposalLayout(
      cols: door,
      doorPanelMm: _doorPanelMm,
      title: 'Pastki panelli eshik',
      subtitle: 'Tepasi oyna, pasti sendvich panel',
    ));
    if (tall) {
      out.add(ProposalLayout(
        cols: door,
        transomMm: tMm,
        title: 'Tepa oynali eshik',
        subtitle: 'Tepada qo\'zg\'almas oyna',
        transomVariant: true,
      ));
    }

    if (h >= 2600) {
      out.add(ProposalLayout(
        cols: door,
        transomMm: tMm,
        doorPanelMm: _doorPanelMm + 100, 
        title: 'Tepa oynali, pasti panelli eshik',
        subtitle: 'Tepada oyna, pastda sendvich panel',
      ));
    }
    return out;
  }

  if (w >= 4800 && h >= 2600) {
    const center = 1500;
    final side = (w - center) ~/ 2;
    final rightSide = w - center - side;
    final u = (side / 6).round().clamp(450, 620);
    List<ProposalCol> sideCols(int total) {
      final outer = (total - 2 * u) ~/ 2;
      final last = total - outer - 2 * u;
      return [
        ProposalCol(outer, ProposalColRole.fixed),
        ProposalCol(u, ProposalColRole.casement, openCat: _hingeLeft),
        ProposalCol(u, ProposalColRole.casement, openCat: _hingeRight),
        ProposalCol(last, ProposalColRole.fixed),
      ];
    }

    out.add(ProposalLayout(
      transomMm: _ventMm,
      transomPanesMm: [side, center, rightSide],
      lambriMm: 600,
      cols: [
        ...sideCols(side),
        const ProposalCol(center ~/ 2, ProposalColRole.door, noLambri: true),
        ProposalCol(center - center ~/ 2, ProposalColRole.door,
            hasHandle: false, noLambri: true),
        ...sideCols(rightSide),
      ],
      title: 'Katta fasad eshigi',
      subtitle: 'Markazda juft eshik, yonlarda lambrili oynalar',
      isPopular: true,
    ));
  }

  if (w >= 2000 && h >= 2000) {
    const core = _sideMinMm + _doorTargetMm; 
    final rest = w - core;
    final tG = h >= 2200 ? tMm : 0;
    if (rest >= 2 * _colMinMm && h - tG - 600 >= 1300) {
      final leftW = rest ~/ 2;
      final rightW = rest - leftW;
      final leftCols = _sideCols(leftW, 500);
      final rightCols = _sideCols(rightW, 500);
      out.add(ProposalLayout(
        transomMm: tG,
        transomPanesMm: tG > 0 ? [leftW, core, rightW] : const [],
        lambriMm: 600,
        lambriPerColumn: true,
        cols: [
          for (final x in leftCols) ProposalCol(x, ProposalColRole.fixed),

          const ProposalCol(_sideMinMm, ProposalColRole.door,
              openCat: _hingeLeft, hasHandle: false, sashToFloor: true),
          const ProposalCol(_doorTargetMm, ProposalColRole.door,
              sashToFloor: true),
          for (final x in rightCols) ProposalCol(x, ProposalColRole.fixed),
        ],
        title: 'Fasad eshigi, lambri bilan',
        subtitle:
            'Juft eshik (tor tavaqa shpingalet bilan) + oynalar, pastida lambri',
        isPopular: true,
      ));
    }
  }

  final fit = _doorSideFit(w);
  if (fit != null) {
    final (doorW, sideW) = fit;
    if (tall) {
      out.add(ProposalLayout(
        cols: [
          ProposalCol(sideW, ProposalColRole.door,
              openCat: _hingeLeft, hasHandle: false),
          ProposalCol(doorW, ProposalColRole.door),
        ],
        transomMm: tMm,
        title: 'Juft eshik, tor yonli + tepa oyna',
        subtitle: 'Tor tavaqa shpingalet bilan, tepada qo\'zg\'almas oyna',
        isPopular: true,
      ));
    }

    final lam = h - (tall ? tMm : 0) - 1200;
    if (lam >= 550 && lam <= 900) {
      out.add(ProposalLayout(
        transomMm: tall ? tMm : 0,
        lambriMm: lam,
        lambriPerColumn: true,
        cols: [
          ProposalCol(doorW, ProposalColRole.door,
              openCat: _hingeLeft, sashToFloor: true),
          ProposalCol(sideW, ProposalColRole.door,
              openCat: _hingeRight, hasHandle: false, sashToFloor: true),
        ],
        title: 'Juft eshik, pasti lambrili',
        subtitle: 'Tor tavaqa shpingalet bilan, pasti lambri panel',
      ));
    }
  }

  if (h >= 2400) {
    final core = w <= 2200 ? w - 2 * _sideMinMm : 1500;
    final half = core ~/ 2;
    final sideW = (w - core) ~/ 2;
    final sideR = w - core - sideW;
    if (half >= _twinLeafMinMm &&
        half <= _doorMaxMm &&
        sideW >= 380 &&
        sideW <= 1300) {
      out.add(ProposalLayout(
        transomMm: 500,
        cols: [
          ProposalCol(sideW, ProposalColRole.fixed, inTransom: false),
          ProposalCol(half, ProposalColRole.door),
          ProposalCol(core - half, ProposalColRole.door, hasHandle: false),
          ProposalCol(sideR, ProposalColRole.fixed, inTransom: false),
        ],
        title: 'Juft eshik + yon oynalar',
        subtitle: 'Yon oynalar to\'liq bo\'yli, eshik ustida oyna',
        isPopular: out.isEmpty,
      ));
    }
  }

  final half = w ~/ 2;
  if (half >= _twinLeafMinMm && half <= _doorMaxMm) {
    out.add(ProposalLayout(
      cols: [
        ProposalCol(half, ProposalColRole.door),
        ProposalCol(w - half, ProposalColRole.door, hasHandle: false),
      ],
      title: 'Juft tavaqali eshik',
      subtitle: 'Bir tavaqa asosiy, ikkinchisi shpingalet bilan',
      isPopular: out.isEmpty,
    ));
  }

  final (asymDoor, passive) = fit ?? (_doorTargetMm, w - _doorTargetMm);
  if (passive >= 350 && passive <= 600) {
    out.add(ProposalLayout(
      cols: [
        ProposalCol(passive, ProposalColRole.door,
            openCat: _hingeLeft, hasHandle: false),
        ProposalCol(asymDoor, ProposalColRole.door),
      ],
      title: 'Juft eshik, tor yonli',
      subtitle: 'Tor tavaqa shpingalet bilan ochiladi',
      isPopular: !tall,
    ));
  }

  final doorW = math.min(_doorTargetMm, maxDoor);
  final rest = w - doorW;
  if (rest >= _colMinMm) {
    if (rest ~/ 2 >= _colMinMm) {
      final leftW = rest ~/ 2;
      final rightW = rest - leftW;
      final cols = [
        for (final x in _sideCols(leftW, _colTargetMm))
          ProposalCol(x, ProposalColRole.fixed),
        ProposalCol(doorW, ProposalColRole.door),
        for (final x in _sideCols(rightW, _colTargetMm))
          ProposalCol(x, ProposalColRole.fixed),
      ];
      out.add(ProposalLayout(
        cols: cols,
        title: 'Eshik + yon oynalar',
        isPopular: out.isEmpty,
      ));
      if (tall) {
        out.add(ProposalLayout(
          cols: cols,
          transomMm: tMm,
          title: 'Eshik + yon oynalar + tepa oyna',
          transomVariant: true,
        ));
      }
    } else {
      out.add(ProposalLayout(
        cols: [
          ProposalCol(rest, ProposalColRole.fixed),
          ProposalCol(doorW, ProposalColRole.door),
        ],
        title: 'Eshik chetda + oyna',
        isPopular: out.isEmpty,
      ));
    }
  }
  return out;
}

enum _DoorFill { glass, panel, lambri }

const proposalFixedSideDoorLeafMm = 800;
const proposalFixedSideMinMm = 100;

List<ProposalLayout> proposalDoorFixedSideLayouts(int w, int h) {
  final side = w - proposalFixedSideDoorLeafMm;
  if (side < proposalFixedSideMinMm) return const [];
  final out = <ProposalLayout>[];
  for (final (fill, name) in const [
    (_DoorFill.glass, 'Eshik + qo\'zg\'almas qanot'),
    (_DoorFill.panel, 'Pastki panelli eshik + qo\'zg\'almas qanot'),
    (_DoorFill.lambri, 'Pasti lambrili eshik + qo\'zg\'almas qanot'),
  ]) {
    final lambri = fill == _DoorFill.lambri;

    final door = ProposalCol(proposalFixedSideDoorLeafMm, ProposalColRole.door,
        sashToFloor: lambri);
    final fixed = ProposalCol(side, ProposalColRole.fixed,
        panelLikeDoor: fill == _DoorFill.panel);
    for (final (cols, where) in [
      ([door, fixed], 'o\'ngda'),
      ([fixed, door], 'chapda'),
    ]) {
      out.add(ProposalLayout(
        cols: cols,

        doorPanelMm: fill == _DoorFill.panel ? proposalDoorLambriMm : 0,
        lambriMm: lambri ? proposalDoorLambriMm : 0,
        lambriPerColumn: lambri,
        title: '$name ($where)',
        exactWidths: true,

        pinFirst: true,

        plainDoorPosts: true,
      ));
    }
  }
  return out;
}

(int, int)? _doorSideFit(int w) {
  final side0 = w - _doorTargetMm;
  if (side0 >= _sideMinMm && side0 <= _sideMaxMm) {
    return (_doorTargetMm, side0);
  }
  final door1 = w - _sideMinMm;
  if (door1 >= _doorMinMm && door1 <= _doorMaxMm) return (door1, _sideMinMm);
  final side2 = w - _doorMaxMm;
  if (side2 >= _sideMinMm && side2 <= _sideMaxMm) return (_doorMaxMm, side2);

  if (w >= 1000 && door1 >= 600 && door1 < _doorMinMm) {
    return (door1, _sideMinMm);
  }
  return null;
}

List<int> _splitEven(int mm, int n) {
  if (n <= 1) return [mm];
  final base = mm ~/ n;
  return [
    for (var i = 0; i < n; i++) i == n - 1 ? mm - base * (n - 1) : base,
  ];
}

List<int> _sideCols(int mm, int target) {
  if (mm <= 0) return const [];
  var n = (mm / target).round().clamp(1, 4);
  while (n > 1 && mm / n < _colMinMm) {
    n--;
  }
  return _splitEven(mm, n);
}
