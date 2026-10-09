
library;

import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

class CalculatePreviewSpecs {
  const CalculatePreviewSpecs._();

  static const FramePreviewSpec windowCenter = FramePreviewSpec(
    aspectRatio: 1,
    lines: [],
  );

  static const FramePreviewSpec doorBlank = FramePreviewSpec(
    aspectRatio: 900 / 2100,
    widthMm: 900,
    heightMm: 2100,
    lines: [],
  );

  static const FramePreviewSpec archBlank = FramePreviewSpec(
    aspectRatio: _arTall,
    archHeightFactor: _archTall,
    widthMm: 1500,
    heightMm: 2250,
    lines: [],
  );

  static const List<FramePreviewSpec> windowOpeningTypes = [
    FramePreviewSpec(aspectRatio: 1, lines: []),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.02, 0.24, 0.98, 0.50),
      FrameLine(0.02, 0.76, 0.98, 0.50),
    ]),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.98, 0.24, 0.02, 0.50),
      FrameLine(0.98, 0.76, 0.02, 0.50),
    ]),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.34, 0.02, 0.50, 0.98),
      FrameLine(0.66, 0.02, 0.50, 0.98),
    ]),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.18, 0.98, 0.50, 0.02),
      FrameLine(0.82, 0.98, 0.50, 0.02),
    ]),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.02, 0.24, 0.98, 0.50),
      FrameLine(0.02, 0.76, 0.98, 0.50),
      FrameLine(0.18, 0.98, 0.50, 0.02),
      FrameLine(0.82, 0.98, 0.50, 0.02),
    ]),
    FramePreviewSpec(aspectRatio: 1, lines: [
      FrameLine(0.98, 0.24, 0.02, 0.50),
      FrameLine(0.98, 0.76, 0.02, 0.50),
      FrameLine(0.18, 0.98, 0.50, 0.02),
      FrameLine(0.82, 0.98, 0.50, 0.02),
    ]),
  ];

  static const List<FramePreviewSpec> windowLeading = [
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0, 0, 1, 1),
        FrameLine(1, 0, 0, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0, 1, 0.5, 0),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0, 0.5, 1, 0.5),
        FrameLine(0, 1, 1, 0),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0, 0.5, 1, 0.5),
        FrameLine(0, 0, 1, 1),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowLeadingBars = [
    FramePreviewSpec(
      aspectRatio: 0.26,
      showFrame: false,
      showGlass: false,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.8,
      showFrame: false,
      showGlass: false,
      lines: [
        FrameLine(0, 0.5, 1, 0.5),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.48,
      showFrame: false,
      showGlass: false,
      lines: [
        FrameLine(0.3, 0, 0.3, 1),
        FrameLine(0.7, 0, 0.7, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.48,
      showFrame: false,
      showGlass: false,
      lines: [
        FrameLine(0.3, 0, 0.3, 1),
        FrameLine(0.7, 0, 0.7, 1),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowTrailing = [
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0, 0.33, 1, 0.33),
        FrameLine(0, 0.66, 1, 0.66),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0.25, 0, 0.25, 1),
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0.75, 0, 0.75, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.15, 0.1, 0.85, 0.02),
        FrameLine(0.85, 0.98, 0.15, 0.9),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.1, 0.1, 0.9, 0.16),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.15, 0.08, 0.85, 0.18),
        FrameLine(0.85, 0.82, 0.15, 0.92),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.12, 0.12, 0.88, 0.04),
        FrameLine(0.12, 0.88, 0.88, 0.96),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowTrailingSquares = [
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0, 0.33, 1, 0.33),
        FrameLine(0, 0.66, 1, 0.66),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [
        FrameLine(0.25, 0, 0.25, 1),
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0.75, 0, 0.75, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1,
      lines: [],
    ),
  ];

  static const List<FramePreviewSpec> windowTrailingTall = [
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.15, 0.1, 0.85, 0.02),
        FrameLine(0.85, 0.98, 0.15, 0.9),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.1, 0.1, 0.9, 0.16),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.15, 0.08, 0.85, 0.18),
        FrameLine(0.85, 0.82, 0.15, 0.92),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.62,
      lines: [
        FrameLine(0.12, 0.12, 0.88, 0.04),
        FrameLine(0.12, 0.88, 0.88, 0.96),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowLayouts = [
    FramePreviewSpec(
      aspectRatio: 0.82,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.82,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0, 0.25, 0.5, 0.25),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.82,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0.5, 0.25, 1, 0.25),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 0.82,
      lines: [
        FrameLine(0, 0.25, 1, 0.25),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowPremium = [
    FramePreviewSpec(
      aspectRatio: 1.08,
      lines: [
        FrameLine(0, 0.28, 1, 0.28),
        FrameLine(0.33, 0.28, 0.33, 1),
        FrameLine(0.66, 0.28, 0.66, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.08,
      lines: [
        FrameLine(0.33, 0, 0.33, 1),
        FrameLine(0.66, 0, 0.66, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.08,
      lines: [
        FrameLine(0, 0.28, 1, 0.28),
        FrameLine(0.33, 0.28, 0.33, 1),
        FrameLine(0.66, 0.28, 0.66, 1),
        FrameLine(0.33, 0.58, 0.66, 0.58),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.08,
      lines: [
        FrameLine(0, 0.24, 1, 0.24),
        FrameLine(0.5, 0.24, 0.5, 1),
      ],
    ),
  ];

  static const List<FramePreviewSpec> windowModern = [
    FramePreviewSpec(
      aspectRatio: 1.02,
      lines: [
        FrameLine(0, 0.22, 1, 0.22),
        FrameLine(0, 0.48, 0.55, 0.48),
        FrameLine(0.55, 0.22, 0.55, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.02,
      lines: [
        FrameLine(0, 0.3, 1, 0.3),
        FrameLine(0.5, 0, 0.5, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.02,
      lines: [
        FrameLine(0.35, 0, 0.35, 1),
        FrameLine(0.35, 0.25, 0.65, 0.25),
        FrameLine(0.65, 0, 0.65, 1),
      ],
    ),
    FramePreviewSpec(
      aspectRatio: 1.02,
      lines: [
        FrameLine(0.24, 0, 0.24, 1),
        FrameLine(0.76, 0, 0.76, 1),
        FrameLine(0, 0.3, 0.24, 0.3),
        FrameLine(0.76, 0.3, 1, 0.3),
      ],
    ),
  ];

  static List<ZoneHardwareTweak> get _halfAnd4QuarterTweaks => [
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.5),
          edge: HardwareEdge.left, 
          hingeShift: 0.5, 
          handleShiftFactor: 0.07, 
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.5),
          edge: HardwareEdge.right, 
          hingeShift: 1.05, 
          handleShiftFactor:
              -0.05, 
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.5),
          edge: HardwareEdge.top,
          hingeShift: 2.8, 
          handleShiftFactor: -0.03, 
          hingeScale: 0.8,
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.5),
          edge: HardwareEdge.bottom,
          hingeShift: 2.8, 
          handleShiftFactor: -0.06, 
          hingeScale: 0.8,
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.5),
          edge: HardwareEdge.left, 
          hingeShift: 1, 
          handleShiftFactor:
              0.001, 
          minZoneHeight: 0.9,
          hingeScale: 1, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.5),
          edge: HardwareEdge.right, 
          hingeShift: 0.5, 
          handleShiftFactor:
              0.015, 
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.5),
          edge: HardwareEdge.top,
          hingeShift: 2.8, 
          handleShiftFactor: -0.03, 
          hingeScale: 0.8,
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.5),
          edge: HardwareEdge.bottom,
          hingeShift: 2.8, 
          handleShiftFactor: -0.06, 
          hingeScale: 0.8,
          minZoneHeight: 0.9,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.167),
          edge: HardwareEdge.top,
          hingeFlushInset: 0.8, 
          handleFlushInset: 0.7, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.167),
          edge: HardwareEdge.bottom,
          hingeFlushInset:
              0.1, 
          handleFlushInset: 0.28, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.167),
          edge: HardwareEdge.left, 
          hingeFlushInset: 1, 
          handleFlushInset: 0.65, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.167),
          edge: HardwareEdge.right, 
          hingeFlushInset: 0.15, 
          handleFlushInset: 0.25, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.167),
          edge: HardwareEdge.top,
          hingeFlushInset: 0.8, 
          handleFlushInset:
              0.65, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.167),
          edge: HardwareEdge.bottom,
          hingeFlushInset:
              0.1, 
          handleFlushInset: 0.25, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.167),
          edge: HardwareEdge.right, 
          hingeFlushInset: 1, 
          handleFlushInset: 0.5, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.167),
          edge: HardwareEdge.left, 
          hingeFlushInset:
              0.15, 
          handleFlushInset: 0.35, 
          maxZoneHeight: 0.38,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.25),
          edge: HardwareEdge.left, 
          hingeShift: 0.8, 
          handleShiftFactor: 0.07, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.25),
          edge: HardwareEdge.right, 
          hingeShift: 1.7, 
          handleShiftFactor:
              -0.05, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.25),
          edge: HardwareEdge.top,
          hingeShift: 1.3, 
          handleShiftFactor:
              0.03, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.25),
          edge: HardwareEdge.bottom,
          hingeShift: 2.2, 
          handleShiftFactor: -0.06, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.25),
          edge: HardwareEdge.left, 
          hingeShift: 1.7, 
          handleShiftFactor:
              0.001, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.25),
          edge: HardwareEdge.right, 
          hingeShift: 1.0, 
          handleShiftFactor:
              0.025, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.25),
          edge: HardwareEdge.top,
          hingeShift: 1.4, 
          handleShiftFactor:
              0.03, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.25),
          edge: HardwareEdge.bottom,
          hingeShift: 2.2, 
          handleShiftFactor: -0.06, 
          minZoneHeight: 0.48,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.75),
          edge: HardwareEdge.left,
          hingeFlushInset: 1, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.75),
          edge: HardwareEdge.right,
          handleFlushInset: 0.3, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.75),
          edge: HardwareEdge.top,
          hingeShift: 2.2, 
          handleShiftFactor:
              -0.025, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.25, 0.75),
          edge: HardwareEdge.bottom,
          hingeShift: 1.3, 
          handleShiftFactor: -0.01, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.75),
          edge: HardwareEdge.left, 
          hingeShift: 1.3, 
          handleShiftFactor:
              0.001, 
          hingeScale: 0.8, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.75),
          edge: HardwareEdge.right,
          hingeFlushInset: 1.0, 
          handleShiftFactor:
              0.015, 
          hingeScale: 0.8,
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.75),
          edge: HardwareEdge.top,
          hingeShift: 3.1, 
          handleShiftFactor:
              -0.04, 
        ),
        ZoneHardwareTweak(
          zoneCenter: Offset(0.75, 0.75),
          edge: HardwareEdge.bottom,
          hingeShift: 2.2, 
          handleShiftFactor: -0.03,
        ),
      ];

  static List<List<FramePreviewSpec>> get windowTemplateGroups {
    const uniformFromRow = 2; 
    final raw = _windowTemplateGroupsRaw;
    return [
      for (var i = 0; i < raw.length; i++)
        if (i < uniformFromRow)
          raw[i]
        else
          [
            for (final spec in raw[i])
              spec.copyWith(uniformFrameThickness: true),
          ],
    ];
  }

  static List<List<FramePreviewSpec>> get _windowTemplateGroupsRaw => [
        [
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(1 / 3, 1 / 3, 1 / 3, 1),
              FrameLine(2 / 3, 1 / 3, 2 / 3, 1),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.right,
                handleShiftFactor: -0.07,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.left,
                handleShiftFactor: -0.0433,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.top,
                handleShiftFactor: 0.06, 
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.bottom,
                handleShiftFactor: -0.06,
                hingeShift:
                    1.3, 
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 2 / 3),
                edge: HardwareEdge.right,
                hingeShift: 1.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 2 / 3),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 2 / 3),
                edge: HardwareEdge.left,
                hingeShift: 1.3,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 2 / 3),
                edge: HardwareEdge.right,
                hingeShift: 1.0,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 2 / 3),
                edge: HardwareEdge.left,
                hingeShift: 1.2,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.50),
                edge: HardwareEdge.left, 
                hingeFlushInset:
                    2, 
                hingeScale: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.50),
                edge: HardwareEdge.right, 
                handleFlushInset:
                    0.2, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            lines: [
              FrameLine(1 / 3, 0, 1 / 3, 1),
              FrameLine(2 / 3, 0, 2 / 3, 1),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.left,
                handleFlushInset: 0.5, 
                hingeScale: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.2, 
                hingeScale: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.5),
                edge: HardwareEdge.left,
                handleFlushInset: 0.3, 
                hingeScale: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.5),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.2, 
                hingeScale: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.right,
                handleShiftFactor: 0.01,
                hingeScale: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.left,
                handleFlushInset: 0.3,
                hingeScale: 0.8,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(1 / 3, 1 / 3, 1 / 3, 1),
              FrameLine(2 / 3, 1 / 3, 2 / 3, 1),
              FrameLine(1 / 3, 0.58, 2 / 3, 0.58),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.right,
                handleShiftFactor: -0.07,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.left,
                handleShiftFactor: -0.0433,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.top,
                handleShiftFactor: 0.06,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.bottom,
                handleShiftFactor: -0.06,
                hingeShift: 1.3,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(0.5, 1 / 3, 0.5, 1),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.right,
                handleShiftFactor:
                    -0.06, 
                hingeFlushInset:
                    0.8, 
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.left,
                handleShiftFactor:
                    -0.03, 
                hingeFlushInset:
                    0.8, 
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.top,
                handleShiftFactor: 0.06,
                hingeScale: 0.6,
                hingeFlushInset: 0.8, 
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                edge: HardwareEdge.bottom,
                handleShiftFactor: -0.06,
                hingeShift: 0.5,
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1 / 6),
                hingeScale: 0.6,
                minZoneWidth: 0.9,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 1 / 6),
                edge: HardwareEdge
                    .left, 
                hingeScale: 0.6,
                hingeFlushInset: 0.75,
                handleFlushInset: 0.65,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 1 / 6),
                edge: HardwareEdge
                    .right, 
                hingeScale: 0.6,
                hingeFlushInset: -0.3,
                handleFlushInset: 0.18,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 1 / 6),
                edge: HardwareEdge
                    .top, 
                hingeScale: 0.6,
                hingeFlushInset: 0.5,
                handleFlushInset: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 1 / 6),
                edge: HardwareEdge
                    .bottom, 
                hingeScale: 0.6,
                hingeFlushInset: 0.2,
                handleFlushInset: 0.1,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 1 / 6),
                edge: HardwareEdge
                    .top, 
                hingeScale: 0.6,
                hingeFlushInset: 0.8,
                handleFlushInset: 0.6,
              ),

              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 1 / 6),
                edge: HardwareEdge
                    .bottom, 
                hingeScale: 0.6,
                hingeFlushInset: 0.1,
                handleFlushInset: 0.23,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 2 / 3),
                edge: HardwareEdge.left, 
                hingeAlongShift: 0.04,
                hingeFlushInset:
                    1.1, 
              ),

              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 2 / 3),
                edge:
                    HardwareEdge.right, 
                handleFlushInset: 0.3, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 2 / 3),
                edge: HardwareEdge.right, 
                hingeFlushInset: 1.3, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 2 / 3),
                edge: HardwareEdge.bottom,
                hingeFlushInset: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 2 / 3),
                edge: HardwareEdge.bottom,
                hingeFlushInset: 0.8,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.50),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.85,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.50),
                edge: HardwareEdge.right,
                handleFlushInset: 0.22,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.83),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.85,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.83),
                edge: HardwareEdge.right,
                handleFlushInset: 0.22,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0.5, 0, 0.5, 1),
            ],
            hardwareTweaks: _halfAnd4QuarterTweaks,
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0.5, 0, 0.5, 1),
              FrameLine(0, 1 / 3, 0.5, 1 / 3),
            ],
            hardwareTweaks: _halfAnd4QuarterTweaks,
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0.5, 0, 0.5, 1),
              FrameLine(0.5, 1 / 3, 1, 1 / 3),
            ],
            hardwareTweaks: _halfAnd4QuarterTweaks,
          ),
          FramePreviewSpec(
            aspectRatio: 600 / 1500,
            widthMm: 600,
            heightMm: 1500,
            lineThicknessScale: 1.7,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.6, 
                handleFlushInset: 0.45, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.6, 
                handleFlushInset: 0.3, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.top,
                hingeFlushInset: 0.7, 
                handleFlushInset: 0.45, 
                hingeScale: 1.0, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.bottom,
                hingeFlushInset: 0.15, 
                handleFlushInset: 0.2, 
                hingeScale: 1.0, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.left, 
                hingeFlushInset: 0.7,
                handleFlushInset: 0.43,
                handleScale: 0.8,
                minZoneHeight: 0.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.right, 
                hingeFlushInset: 0.75,
                handleFlushInset: 0.3,
                handleScale: 0.8,
                minZoneHeight: 0.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.top, 
                hingeShift: 3.6,
                handleShiftFactor: -0.04,
                hingeScale: 1.0,
                handleScale: 0.8,
                minZoneHeight: 0.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge:
                    HardwareEdge.bottom, 
                hingeShift: 3.2,
                handleShiftFactor: -0.065,
                hingeScale: 1.0,
                handleScale: 0.8,
                minZoneHeight: 0.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.444),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.45,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.444),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.3,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.444),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.15,
                handleFlushInset: 0.2,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.444),
                edge: HardwareEdge.bottom, 
                hingeFlushInset: 0.15,
                handleFlushInset: 0.2,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.45,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.3,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.15,
                handleFlushInset: 0.2,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.667),
                edge: HardwareEdge.bottom, 
                hingeFlushInset: 0.15,
                handleFlushInset: 0.2,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.889),
                edge: HardwareEdge.left,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.45,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.889),
                edge: HardwareEdge.right,
                hingeFlushInset: 0.6,
                handleFlushInset: 0.3,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.889),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.15,
                handleFlushInset: 0.2,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.889),
                edge: HardwareEdge.bottom, 
                hingeFlushInset: 0.7,
                handleFlushInset: 0.45,
                hingeScale: 1.0,
                handleScale: 0.8,
                maxZoneHeight: 0.4,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(0.5, 1 / 3, 0.5, 1),
              FrameLine(0, 8 / 15, 0.5, 8 / 15),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.left, 
                hingeFlushInset: 0.7,
                handleFlushInset: 0.55,
                hingeScale: 0.6, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.right, 
                hingeFlushInset: 0.7,
                handleFlushInset: 0.4,
                hingeScale: 0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.8,
                handleFlushInset: 0.5,
                hingeScale: 0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 0.167),
                edge:
                    HardwareEdge.bottom, 
                hingeFlushInset: 0.01,
                handleFlushInset: 0.2,
                hingeScale: 0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.767),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.2,
                handleFlushInset: 0.37,
                hingeScale: 0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.767),
                edge:
                    HardwareEdge.bottom, 
                hingeFlushInset: 0.9,
                handleFlushInset: 0.5,
                hingeScale: 0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.433),
                edge: HardwareEdge.left, 
                hingeFlushInset: 0.9,
                handleFlushInset: 0.65,
                hingeScale: 0.5,
                handleScale: 1.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.433),
                edge:
                    HardwareEdge.right, 
                hingeFlushInset: 0.2,
                handleFlushInset: 0.25,
                hingeScale: 0.5,
                handleScale: 1.5,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.433),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.01,
                handleFlushInset: 0.2,
                hingeScale: 3,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.433),
                edge:
                    HardwareEdge.bottom, 
                hingeFlushInset: 0.2,
                handleFlushInset: 0.2,
                hingeScale: 0.7,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.667),
                edge: HardwareEdge.top, 
                hingeShift: 3,
                handleShiftFactor: -0.04,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.667),
                edge:
                    HardwareEdge.bottom, 
                hingeShift: 2.2,
                handleShiftFactor: -0.03,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.667),
                edge:
                    HardwareEdge.right, 
                hingeFlushInset:
                    1, 
                hingeScale:
                    0.8, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 1500,
            widthMm: 1200,
            heightMm: 1500,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(0.5, 0, 0.5, 1),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.167),
                edge: HardwareEdge.top,
                hingeFlushInset: 1, 
                handleFlushInset:
                    0.7, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.167),
                edge: HardwareEdge.bottom,
                hingeFlushInset:
                    0.1, 
                handleFlushInset:
                    0.28, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.167),
                edge: HardwareEdge.left, 
                hingeFlushInset:
                    1, 
                handleFlushInset:
                    0.65, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 0.167),
                edge: HardwareEdge.right, 
                hingeFlushInset:
                    0.15, 
                handleFlushInset:
                    0.25, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.167),
                edge: HardwareEdge.top,
                hingeFlushInset: 0.8, 
                handleFlushInset:
                    0.65, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.167),
                edge: HardwareEdge.bottom,
                hingeFlushInset:
                    0.1, 
                handleFlushInset: 0.2, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.167),
                edge: HardwareEdge.right, 
                hingeFlushInset:
                    1, 
                handleFlushInset:
                    0.5, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(0.75, 0.167),
                edge: HardwareEdge.left, 
                hingeFlushInset:
                    0.15, 
                handleFlushInset:
                    0.4, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            lines: [
              FrameLine(1 / 3, 0, 1 / 3, 1),
              FrameLine(2 / 3, 0, 2 / 3, 1),
              FrameLine(1 / 3, 1 / 3, 2 / 3, 1 / 3),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.left,
                hingeScale: 0.8, 
                hingeFlushInset:
                    0.5, 
                handleFlushInset:
                    0.57, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.right, 
                hingeFlushInset: 0.1,
                hingeScale: 0.8, 
                handleFlushInset:
                    0.2, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.7, 
                handleFlushInset:
                    0.6, 
                hingeScale: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1 / 6, 0.5),
                edge: HardwareEdge.bottom, 
                hingeFlushInset:
                    0.7, 
                handleFlushInset: 0.4, 
                hingeScale: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.left,
                hingeScale: 0.8, 
                hingeFlushInset:
                    0.09, 
                handleFlushInset:
                    0.3, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.right,
                hingeScale: 0.8, 
                hingeFlushInset:
                    0.6, 
                handleFlushInset:
                    0.45, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.top, 
                hingeFlushInset: 0.8,
                handleFlushInset:
                    0.6, 
                hingeScale: 0.6,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(5 / 6, 0.5),
                edge: HardwareEdge.bottom,
                hingeFlushInset:
                    0.7, 
                handleFlushInset: 0.4, 
                hingeScale: 0.6,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            lines: [
              FrameLine(1 / 3, 0, 1 / 3, 1),
              FrameLine(2 / 3, 0, 2 / 3, 1),
              FrameLine(0, 1 / 3, 1 / 3, 1 / 3),
              FrameLine(2 / 3, 1 / 3, 1, 1 / 3),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1.0,
            widthMm: 1500,
            heightMm: 1500,
            displayScale: 1,
            lines: [
              FrameLine(0, 1 / 3, 1, 1 / 3),
              FrameLine(1 / 3, 1 / 3, 1 / 3, 1),
              FrameLine(2 / 3, 1 / 3, 2 / 3, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1800 / 1700,
            widthMm: 1800,
            heightMm: 1700,
            displayScale: 1,
            lines: [
              FrameLine(0, 500 / 1700, 1, 500 / 1700),
              FrameLine(500 / 1800, 500 / 1700, 500 / 1800, 1),
              FrameLine(1300 / 1800, 500 / 1700, 1300 / 1800, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1800 / 1700,
            widthMm: 1800,
            heightMm: 1700,
            displayScale: 1,
            lines: [
              FrameLine(500 / 1800, 0, 500 / 1800, 1),
              FrameLine(1300 / 1800, 0, 1300 / 1800, 1),
              FrameLine(0, 400 / 1700, 1, 400 / 1700),
              FrameLine(0, 1300 / 1700, 1, 1300 / 1700),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2200 / 1500,
            widthMm: 2200,
            heightMm: 1500,
            displayScale: 1,
            lines: [
              FrameLine(0, 500 / 1500, 1, 500 / 1500),
              FrameLine(733 / 2200, 0, 733 / 2200, 500 / 1500),
              FrameLine(1466 / 2200, 0, 1466 / 2200, 500 / 1500),
              FrameLine(550 / 2200, 500 / 1500, 550 / 2200, 1),
              FrameLine(1100 / 2200, 500 / 1500, 1100 / 2200, 1),
              FrameLine(1650 / 2200, 500 / 1500, 1650 / 2200, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 1500,
            widthMm: 2200,
            heightMm: 1500,
            displayScale: 1,
            lines: [
              FrameLine(0, 500 / 1500, 1, 500 / 1500),
              FrameLine(0.5, 0, 0.5, 500 / 1500),
              FrameLine(550 / 2200, 500 / 1500, 550 / 2200, 1),
              FrameLine(1100 / 2200, 500 / 1500, 1100 / 2200, 1),
              FrameLine(1650 / 2200, 500 / 1500, 1650 / 2200, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 3000 / 1500,
            widthMm: 3000,
            heightMm: 1500,
            displayScale: 0.96,
            detailAspectRatioScale: 0.94,
            lines: [
              FrameLine(0, 500 / 1500, 1, 500 / 1500),
              FrameLine(1000 / 3000, 0, 1000 / 3000, 500 / 1500),
              FrameLine(2000 / 3000, 0, 2000 / 3000, 500 / 1500),
              FrameLine(600 / 3000, 500 / 1500, 600 / 3000, 1),
              FrameLine(1200 / 3000, 500 / 1500, 1200 / 3000, 1),
              FrameLine(1800 / 3000, 500 / 1500, 1800 / 3000, 1),
              FrameLine(2400 / 3000, 500 / 1500, 2400 / 3000, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 4000 / 3000,
            widthMm: 4000,
            heightMm: 3000,
            displayScale: 0.96,
            detailAspectRatioScale: 0.96,
            lines: [
              FrameLine(0, 500 / 3000, 1, 500 / 3000),
              FrameLine(0, 2200 / 3000, 1, 2200 / 3000),
              FrameLine(800 / 4000, 0, 800 / 4000, 500 / 3000),
              FrameLine(2000 / 4000, 0, 2000 / 4000, 500 / 3000),
              FrameLine(3200 / 4000, 0, 3200 / 4000, 500 / 3000),
              FrameLine(800 / 4000, 500 / 3000, 800 / 4000, 1),
              FrameLine(1600 / 4000, 500 / 3000, 1600 / 4000, 1),
              FrameLine(2400 / 4000, 500 / 3000, 2400 / 4000, 1),
              FrameLine(3200 / 4000, 500 / 3000, 3200 / 4000, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 3600 / 1500,
            widthMm: 3600,
            heightMm: 1500,
            displayScale: 0.94,
            detailAspectRatioScale: 0.94,
            lines: [
              FrameLine(0, 400 / 1500, 1, 400 / 1500),
              FrameLine(1200 / 3600, 0, 1200 / 3600, 400 / 1500),
              FrameLine(2400 / 3600, 0, 2400 / 3600, 400 / 1500),
              FrameLine(720 / 3600, 400 / 1500, 720 / 3600, 1),
              FrameLine(1440 / 3600, 400 / 1500, 1440 / 3600, 1),
              FrameLine(2160 / 3600, 400 / 1500, 2160 / 3600, 1),
              FrameLine(2880 / 3600, 400 / 1500, 2880 / 3600, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 3600 / 1500,
            widthMm: 3600,
            heightMm: 1500,
            displayScale: 0.94,
            detailAspectRatioScale: 0.94,
            lines: [
              FrameLine(0, 500 / 1500, 1, 500 / 1500),
              FrameLine(0, 1000 / 1500, 1, 1000 / 1500),
              FrameLine(900 / 3600, 0, 900 / 3600, 1),
              FrameLine(1800 / 3600, 0, 1800 / 3600, 1),
              FrameLine(2700 / 3600, 0, 2700 / 3600, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2000 / 2500,
            widthMm: 2000,
            heightMm: 2500,
            displayScale: 0.90,
            lines: [
              FrameLine(0, 400 / 2500, 1, 400 / 2500),
              FrameLine(0, 1900 / 2500, 1, 1900 / 2500),
              FrameLine(1 / 3, 0, 1 / 3, 400 / 2500),
              FrameLine(2 / 3, 0, 2 / 3, 400 / 2500),
              FrameLine(0.5, 400 / 2500, 0.5, 1900 / 2500),
              FrameLine(1 / 3, 1900 / 2500, 1 / 3, 1),
              FrameLine(2 / 3, 1900 / 2500, 2 / 3, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2500 / 2500,
            widthMm: 2500,
            heightMm: 2500,
            displayScale: 0.90,
            lines: [
              FrameLine(0, 500 / 2500, 1, 500 / 2500),
              FrameLine(0, 2000 / 2500, 1, 2000 / 2500),
              FrameLine(0.5, 0, 0.5, 500 / 2500),
              FrameLine(1 / 3, 500 / 2500, 1 / 3, 2000 / 2500),
              FrameLine(2 / 3, 500 / 2500, 2 / 3, 2000 / 2500),
              FrameLine(0.5, 2000 / 2500, 0.5, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2000 / 3000,
            widthMm: 2000,
            heightMm: 3000,
            displayScale: 0.85,
            lines: [
              FrameLine(0, 500 / 3000, 1, 500 / 3000),
              FrameLine(0, 2200 / 3000, 1, 2200 / 3000),
              FrameLine(0.5, 0, 0.5, 500 / 3000),
              FrameLine(1 / 3, 500 / 3000, 1 / 3, 1),
              FrameLine(2 / 3, 500 / 3000, 2 / 3, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2500 / 3000,
            widthMm: 2500,
            heightMm: 3000,
            displayScale: 0.85,
            lines: [
              FrameLine(0, 600 / 3000, 1, 600 / 3000),
              FrameLine(0, 2400 / 3000, 1, 2400 / 3000),
              FrameLine(1 / 3, 0, 1 / 3, 600 / 3000),
              FrameLine(2 / 3, 0, 2 / 3, 600 / 3000),
              FrameLine(0.25, 600 / 3000, 0.25, 1),
              FrameLine(0.5, 600 / 3000, 0.5, 1),
              FrameLine(0.75, 600 / 3000, 0.75, 1),
            ],
          ),
        ],
      ];

  static List<List<FramePreviewSpec>> get doorTemplateGroups => [
        [
          FramePreviewSpec(
            aspectRatio: 2000 / 2300,
            widthMm: 2000,
            heightMm: 2300,
            lines: [
              FrameLine(600 / 2000, 0, 600 / 2000, 1),
              FrameLine(1400 / 2000, 0, 1400 / 2000, 1),
              FrameLine(0, 1500 / 2300, 600 / 2000, 1500 / 2300),
              FrameLine(1400 / 2000, 1500 / 2300, 1, 1500 / 2300),
            ],
            regions: [
              FrameRegion(0, 0, 600 / 2000, 1500 / 2300, absorbedRight: true),
              FrameRegion(
                600 / 2000,
                0,
                1400 / 2000,
                1,
                hideOuterStrokeLeft: true,
                hideOuterStrokeRight: true,
              ),
              FrameRegion(1400 / 2000, 0, 1, 1500 / 2300, absorbedLeft: true),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2000 / 2300,
            widthMm: 2000,
            heightMm: 2300,
            lines: [
              FrameLine(1200 / 2000, 0, 1200 / 2000, 1),
              FrameLine(0, 1500 / 2300, 1200 / 2000, 1500 / 2300),
            ],
            regions: [
              FrameRegion(0, 0, 1200 / 2000, 1500 / 2300, absorbedRight: true),
              FrameRegion(1200 / 2000, 0, 1, 1, hideOuterStrokeLeft: true),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2000 / 2300,
            widthMm: 2000,
            heightMm: 2300,
            lines: [
              FrameLine(800 / 2000, 0, 800 / 2000, 1),
              FrameLine(800 / 2000, 1500 / 2300, 1, 1500 / 2300),
            ],
            regions: [
              FrameRegion(0, 0, 800 / 2000, 1, hideOuterStrokeRight: true),
              FrameRegion(800 / 2000, 0, 1, 1500 / 2300, absorbedLeft: true),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2000 / 2800,
            widthMm: 2000,
            heightMm: 2800,
            lines: [
              FrameLine(600 / 2000, 500 / 2800, 600 / 2000, 1),
              FrameLine(1400 / 2000, 500 / 2800, 1400 / 2000, 1),
              FrameLine(0, 500 / 2800, 1, 500 / 2800),
              FrameLine(0, 2000 / 2800, 600 / 2000, 2000 / 2800),
              FrameLine(1400 / 2000, 2000 / 2800, 1, 2000 / 2800),
            ],
            regions: [
              FrameRegion(0, 0, 1, 500 / 2800, sharedBottom: true),
              FrameRegion(
                0,
                500 / 2800,
                600 / 2000,
                2000 / 2800,
                absorbedRight: true,
                sharedTop: true,
              ),
              FrameRegion(
                600 / 2000,
                500 / 2800,
                1400 / 2000,
                1,
                sharedTop: true,
                hideOuterStrokeLeft: true,
                hideOuterStrokeRight: true,
              ),
              FrameRegion(
                1400 / 2000,
                500 / 2800,
                1,
                2000 / 2800,
                absorbedLeft: true,
                sharedTop: true,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2000 / 2800,
            widthMm: 2000,
            heightMm: 2800,
            lines: [
              FrameLine(1200 / 2000, 500 / 2800, 1200 / 2000, 1),
              FrameLine(0, 500 / 2800, 1, 500 / 2800),
              FrameLine(0, 2000 / 2800, 1200 / 2000, 2000 / 2800),
            ],
            regions: [
              FrameRegion(0, 0, 1, 500 / 2800, sharedBottom: true),
              FrameRegion(
                0,
                500 / 2800,
                1200 / 2000,
                2000 / 2800,
                absorbedRight: true,
                sharedTop: true,
              ),
              FrameRegion(
                1200 / 2000,
                500 / 2800,
                1,
                1,
                sharedTop: true,
                hideOuterStrokeLeft: true,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2000 / 2800,
            widthMm: 2000,
            heightMm: 2800,
            lines: [
              FrameLine(800 / 2000, 500 / 2800, 800 / 2000, 1),
              FrameLine(0, 500 / 2800, 1, 500 / 2800),
              FrameLine(800 / 2000, 2000 / 2800, 1, 2000 / 2800),
            ],
            regions: [
              FrameRegion(0, 0, 1, 500 / 2800, sharedBottom: true),
              FrameRegion(
                0,
                500 / 2800,
                800 / 2000,
                1,
                sharedTop: true,
                hideOuterStrokeRight: true,
              ),
              FrameRegion(
                800 / 2000,
                500 / 2800,
                1,
                2000 / 2800,
                absorbedLeft: true,
                sharedTop: true,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 800 / 1800,
            widthMm: 800,
            heightMm: 1800,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            lines: [],
            defaultOpeningCategory: 2, 
            defaultOpeningIsDoor: true,
          ),
          FramePreviewSpec(
            aspectRatio: 800 / 1800,
            widthMm: 800,
            heightMm: 1800,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 1000 / 1800, 1, 1000 / 1800),
            ],
            defaultOpeningCategory: 2, 
            defaultOpeningIsDoor: true,
            defaultOpeningSingleSash: true, 
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 0.78),
                layoutCategory: 3, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 800 / 1800,
            widthMm: 800,
            heightMm: 1800,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(400 / 800, 0, 400 / 800, 1000 / 1800),
              FrameLine(0, 1000 / 1800, 1, 1000 / 1800),
            ],
            defaultOpeningCategory: 2, 
            defaultOpeningIsDoor: true,
            defaultOpeningSingleSash: true, 
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 0.78),
                layoutCategory: 3, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 800 / 2300,
            widthMm: 800,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 1.28,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 1300 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 1300 / 2300),
                edge: HardwareEdge.left, 
                handleFlushInset: 0.43,
                handleScale: 0.8,
                minZoneWidth: 0.9,
                minZoneHeight: 0.8,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 800 / 2300,
            widthMm: 800,
            heightMm: 2300,
            displayScale: 0.78,
            detailAspectRatioScale: 1.28,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(0, 1500 / 2300, 1, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 900 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 1900 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.5, 900 / 2300),
                edge: HardwareEdge.left, 
                handleFlushInset: 0.43,
                handleScale: 0.8,
                minZoneWidth: 0.9,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 800 / 2300,
            widthMm: 800,
            heightMm: 2300,
            displayScale: 0.78,
            detailAspectRatioScale: 1.28,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300), 
              FrameLine(400 / 800, 300 / 2300, 400 / 800,
                  1500 / 2300), 
              FrameLine(
                  0, 1500 / 2300, 1, 1500 / 2300), 
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(0.25, 900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(0.75, 900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(0.5, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 1, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(0.25, 900 / 2300),
                edge: HardwareEdge.left, 
                handleFlushInset: 0.43,
                handleScale: 0.8,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2000,
            widthMm: 1200,
            heightMm: 2000,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(400 / 1200, 0, 400 / 1200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(200 / 1200, 0.5), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(800 / 1200, 0.5), 
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2000,
            widthMm: 1200,
            heightMm: 2000,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(800 / 1200, 0, 800 / 1200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(400 / 1200, 0.5), 
                openingCategory: 1, 
                openingIsDoor: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1000 / 1200, 0.5), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1200 / 2000,
            widthMm: 1200,
            heightMm: 2000,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(400 / 1200, 0, 400 / 1200, 1), 
              FrameLine(
                  0, 1200 / 2000, 1, 1200 / 2000), 
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(200 / 1200, 600 / 2000), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(200 / 1200, 1600 / 2000), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(800 / 1200, 600 / 2000), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(800 / 1200, 1600 / 2000), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2000,
            widthMm: 1200,
            heightMm: 2000,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(800 / 1200, 0, 800 / 1200, 1), 
              FrameLine(0, 1200 / 2000, 1, 1200 / 2000), 
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(400 / 1200, 600 / 2000), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(400 / 1200, 1600 / 2000), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1000 / 1200, 600 / 2000), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1000 / 1200, 1600 / 2000), 
                openingCategory: 2,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(400 / 1200, 0.5),
                edge: HardwareEdge.left, 
                handleFlushInset: 0.45, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2300,
            widthMm: 1200,
            heightMm: 2300,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(400 / 1200, 300 / 2300, 400 / 1200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter:
                    Offset(200 / 1200, 1300 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter:
                    Offset(800 / 1200, 1300 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(200 / 1200, 1300 / 2300),
                edge: HardwareEdge.left,
                hingeFlushInset: 1.2,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(800 / 1200, 1300 / 2300),
                edge: HardwareEdge.right,
                hingeFlushInset: 1.2,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2300,
            widthMm: 1200,
            heightMm: 2300,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(800 / 1200, 300 / 2300, 800 / 1200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter:
                    Offset(400 / 1200, 1300 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter:
                    Offset(1000 / 1200, 1300 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(400 / 1200, 1300 / 2300),
                edge: HardwareEdge.left,
                hingeFlushInset: 1.2,
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1000 / 1200, 1300 / 2300),
                edge: HardwareEdge.right,
                hingeFlushInset: 1.2,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1200 / 2300,
            widthMm: 1200,
            heightMm: 2300,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(800 / 1200, 300 / 2300, 800 / 1200, 1),
              FrameLine(0, 1500 / 2300, 800 / 1200, 1500 / 2300),
              FrameLine(800 / 1200, 1500 / 2300, 1, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(400 / 1200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(400 / 1200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1000 / 1200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1000 / 1200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1200 / 2300,
            widthMm: 1200,
            heightMm: 2300,
            displayScale: 0.85,
            lineThicknessScale: 1.3,
            uniformFrameThickness: true,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(400 / 1200, 300 / 2300, 400 / 1200, 1),
              FrameLine(0, 1500 / 2300, 400 / 1200, 1500 / 2300),
              FrameLine(400 / 1200, 1500 / 2300, 1, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(200 / 1200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(200 / 1200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(800 / 1200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(800 / 1200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2000,
            widthMm: 2200,
            heightMm: 2000,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(900 / 2200, 0, 900 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 0.5),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 0.5),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 0.5),
                frameThicknessFactor: 2,
                frameInsetFactor: 2,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 1700 / 2000,
            widthMm: 1700,
            heightMm: 2000,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 1700, 0, 500 / 1700, 1),
              FrameLine(900 / 1700, 0, 900 / 1700, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 1700, 0.5),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 1700, 0.5),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 1700 / 2000,
            widthMm: 1700,
            heightMm: 2000,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 1700, 0, 500 / 1700, 1),
              FrameLine(900 / 1700, 0, 900 / 1700, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 1700, 0.5),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 1700, 0.5),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 1700, 0.5),
                frameThicknessFactor: 2,
                frameInsetFactor: 2,
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2000,
            widthMm: 2200,
            heightMm: 2000,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(900 / 2200, 0, 900 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(0, 1200 / 2000, 1, 1200 / 2000),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 600 / 2000), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1600 / 2000), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 600 / 2000), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1600 / 2000), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 0.5),
                frameThicknessFactor: 1.5,
                frameInsetFactor: 2,
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(500 / 2200, 300 / 2300, 1700 / 2200, 300 / 2300),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(500 / 2200, 1500 / 2300, 1700 / 2200, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(500 / 2200, 300 / 2300, 500 / 2200, 1),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(1700 / 2200, 300 / 2300, 1700 / 2200, 1),
              FrameLine(500 / 2200, 1500 / 2300, 1700 / 2200, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 1.5, 
                frameInsetFactor: 2, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2000,
            widthMm: 2200,
            heightMm: 2000,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(900 / 2200, 0, 900 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 0.5),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 0.5),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 0.5),
                frameThicknessFactor: 1.5, 
                frameInsetFactor: 2, 
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(500 / 2200, 300 / 2300, 1700 / 2200, 300 / 2300),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1300 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(500 / 2200, 300 / 2300, 500 / 2200, 1),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(1700 / 2200, 300 / 2300, 1700 / 2200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1300 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(1100 / 2200, 0, 1100 / 2200, 300 / 2300),
              FrameLine(500 / 2200, 300 / 2300, 500 / 2200, 1),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(1700 / 2200, 300 / 2300, 1700 / 2200, 1),
              FrameLine(500 / 2200, 1500 / 2300, 1700 / 2200, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1300 / 2300),
                openingCategory: 2, 
                openingIsDoor: true,
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(500 / 2200, 1500 / 2300, 1700 / 2200, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: 2200 / 2300,
            widthMm: 2200,
            heightMm: 2300,
            displayScale: 0.85,
            detailAspectRatioScale: 0.78, 
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(500 / 2200, 0, 500 / 2200, 1),
              FrameLine(1700 / 2200, 0, 1700 / 2200, 1),
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(900 / 2200, 300 / 2300, 900 / 2200, 1),
              FrameLine(0, 1500 / 2300, 1, 1500 / 2300),
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(700 / 2200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1300 / 2200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(700 / 2200, 1300 / 2300),
                frameThicknessFactor: 2, 
                frameInsetFactor: 1.5, 
              ),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: 3200 / 2300,
            widthMm: 3200,
            heightMm: 2300,
            displayScale: 0.92, 
            detailAspectRatioScale: 0.55, 
            frameBandScale: 0.7,
            lineThicknessScale: 1.3,
            lines: [
              FrameLine(1000 / 3200, 0, 1000 / 3200, 1),
              FrameLine(2200 / 3200, 0, 2200 / 3200, 1),
              FrameLine(0, 300 / 2300, 1, 300 / 2300),
              FrameLine(0, 1500 / 2300, 1, 1500 / 2300),
              FrameLine(500 / 3200, 300 / 2300, 500 / 3200, 1), 
              FrameLine(1400 / 3200, 300 / 2300, 1400 / 3200, 1), 
              FrameLine(2700 / 3200, 300 / 2300, 2700 / 3200, 1), 
            ],
            defaultZoneSetups: [
              DefaultZoneSetup(
                zoneCenter: Offset(1200 / 3200, 900 / 2300), 
                openingCategory: 1, 
                openingIsDoor: true,
                openingHasHandle: false, 
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1200 / 3200, 1900 / 2300), 
                openingCategory: 1,
                openingIsDoor: true,
                openingHasHandle: false,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1800 / 3200, 900 / 2300), 
                openingCategory: 2, 
                openingIsDoor: true,
                openingSingleSash: true,
              ),
              DefaultZoneSetup(
                zoneCenter: Offset(1800 / 3200, 1900 / 2300), 
                openingCategory: 2,
                openingIsDoor: true,
                openingSingleSash: true,
                layoutCategory: 3, 
              ),
            ],
            hardwareTweaks: [
              ZoneHardwareTweak(
                zoneCenter: Offset(1200 / 3200, 1300 / 2300), 
                frameThicknessFactor: 1.5, 
              ),
              ZoneHardwareTweak(
                zoneCenter: Offset(1800 / 3200, 1300 / 2300), 
                frameThicknessFactor: 1.5, 
              ),
            ],
          ),
        ],
      ];

  static const double _archTall = 750 / 2250; 
  static const double _archSemi = 900 / 2300; 
  static const double _archLow = 0.20; 

  static const double _arTall = 1500 / 2250; 
  static const double _arWide = 1800 / 2300; 

  static List<List<FramePreviewSpec>> get archTemplateGroups => const [
        [
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [],
          ),
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [FrameLine(0, _archTall, 1, _archTall)],
          ),
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [
              FrameLine(0, _archTall, 1, _archTall),
              FrameLine(0.5, _archTall, 0.5, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [
              FrameLine(0, _archTall, 1, _archTall),
              FrameLine(1 / 3, _archTall, 1 / 3, 1),
              FrameLine(2 / 3, _archTall, 2 / 3, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [
              FrameLine(0, _archTall, 1, _archTall),
              FrameLine(0.5, _archTall, 0.5, 1),
              FrameLine(0, 0.7, 1, 0.7),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arTall,
            archHeightFactor: _archTall,
            widthMm: 1500,
            heightMm: 2250,
            lines: [
              FrameLine(0.5, 0, 0.5, 1),
              FrameLine(0, _archTall, 1, _archTall),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(1 / 3, _archSemi, 1 / 3, 1),
              FrameLine(2 / 3, _archSemi, 2 / 3, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(0.5, _archSemi, 0.5, 1),
              FrameLine(0, 0.68, 1, 0.68),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(0.5, _archSemi, 0.5, 1),
              FrameLine(0, 0.62, 0.5, 0.62),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(1 / 3, _archSemi, 1 / 3, 1),
              FrameLine(2 / 3, _archSemi, 2 / 3, 1),
              FrameLine(0, 0.62, 1, 0.62),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(0.5, _archSemi, 0.5, 1),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archSemi,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archSemi, 1, _archSemi),
              FrameLine(0.5, _archSemi, 0.5, 1),
              FrameLine(0.5, 0.62, 1, 0.62),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archLow,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0.5, 0, 0.5, 1),
              FrameLine(0, _archLow, 1, _archLow),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archLow,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archLow, 1, _archLow),
            ],
          ),
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archLow,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archLow, 1, _archLow),
              FrameLine(1 / 3, _archLow, 1 / 3, 1),
              FrameLine(2 / 3, _archLow, 2 / 3, 1),
            ],
          ),
        ],
        [
          FramePreviewSpec(
            aspectRatio: _arWide,
            archHeightFactor: _archLow,
            widthMm: 1800,
            heightMm: 2300,
            lines: [
              FrameLine(0, _archLow, 1, _archLow),
              FrameLine(1 / 3, _archLow, 1 / 3, 1),
              FrameLine(2 / 3, _archLow, 2 / 3, 1),
            ],
          ),
        ],
      ];
}
