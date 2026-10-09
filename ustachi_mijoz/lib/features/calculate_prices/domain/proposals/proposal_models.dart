import 'package:equatable/equatable.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

enum ProposalType {
  window, 
  door, 
  arch, 
}

const proposalMinSideMm = 300;
const proposalMaxWidthMm = 12000;
const proposalMaxHeightMm = 4000;

enum ProposalShape {
  deraza('deraza', 'Deraza', ProposalType.window),
  eshik('eshik', 'Eshik', ProposalType.door),
  arka('arka', 'Arka', ProposalType.arch),

  fEshik('f_eshik', 'F eshik', ProposalType.door),

  tEshik('t_eshik', 'T eshik', ProposalType.door),

  vitraj('vitraj', 'Vitraj', ProposalType.window);

  const ProposalShape(this.code, this.title, this.type);

  final String code;

  final String title;

  final ProposalType type;

  bool get isBalcony => this == fEshik || this == tEshik;

  static ProposalShape fromCode(String? code) {
    for (final s in ProposalShape.values) {
      if (s.code == code) return s;
    }
    return ProposalShape.deraza;
  }
}

class ProposalRequest extends Equatable {
  const ProposalRequest({
    required this.type,
    required this.widthMm,
    required this.heightMm,
    this.material = 0,
    this.colorKey = 'WHITE',
    this.colorArgb = 0xFFFFFFFF,
    this.colorLabel = 'Oq',
    this.hasSill = false,
    this.sillWidthCm = 30,
    this.floorGapMm = 0,
    this.doorOnRight = true,
    this.shape = ProposalShape.deraza,
    this.fixedSideDoor = false,
  });

  final ProposalType type;
  final int widthMm;
  final int heightMm;

  final int material;

  final String colorKey;

  final int colorArgb;

  final String colorLabel;

  final bool hasSill;

  final int sillWidthCm;

  final int floorGapMm;

  final bool doorOnRight;

  final ProposalShape shape;

  final bool fixedSideDoor;

  bool get isWhite => colorKey == 'WHITE';

  ProposalRequest copyWith({
    ProposalType? type,
    int? widthMm,
    int? heightMm,
    int? material,
    String? colorKey,
    int? colorArgb,
    String? colorLabel,
    bool? hasSill,
    int? sillWidthCm,
    int? floorGapMm,
    bool? doorOnRight,
    ProposalShape? shape,
    bool? fixedSideDoor,
  }) {
    return ProposalRequest(
      type: type ?? this.type,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      material: material ?? this.material,
      colorKey: colorKey ?? this.colorKey,
      colorArgb: colorArgb ?? this.colorArgb,
      colorLabel: colorLabel ?? this.colorLabel,
      hasSill: hasSill ?? this.hasSill,
      sillWidthCm: sillWidthCm ?? this.sillWidthCm,
      floorGapMm: floorGapMm ?? this.floorGapMm,
      doorOnRight: doorOnRight ?? this.doorOnRight,
      shape: shape ?? this.shape,
      fixedSideDoor: fixedSideDoor ?? this.fixedSideDoor,
    );
  }

  @override
  List<Object?> get props => [
        type,
        widthMm,
        heightMm,
        material,
        colorKey,
        colorArgb,
        colorLabel,
        hasSill,
        sillWidthCm,
        floorGapMm,
        doorOnRight,
        shape,
        fixedSideDoor,
      ];
}

class ProposalOption extends Equatable {
  const ProposalOption({
    required this.spec,
    required this.title,
    this.subtitle = '',
    this.isPopular = false,
    this.pinFirst = false,
  });

  final FramePreviewSpec spec;

  final String title;
  final String subtitle;

  final bool isPopular;

  final bool pinFirst;

  @override
  List<Object?> get props => [spec, title, subtitle, isPopular, pinFirst];
}

class ProposalColor extends Equatable {
  const ProposalColor({
    required this.label,
    required this.argb,
    this.colorKey = 'COLOR',
  });

  final String label;
  final int argb;
  final String colorKey;

  bool get isWhite => colorKey == 'WHITE';

  static const white =
      ProposalColor(label: 'Oq', argb: 0xFFFFFFFF, colorKey: 'WHITE');

  @override
  List<Object?> get props => [label, argb, colorKey];
}

const proposalMaterialCodes = [0, 1, 2];

String proposalMaterialLabel(int? material) => switch (material) {
      0 => 'Plastik',
      1 => 'Alyuminiy',
      2 => 'Termo',
      _ => '',
    };
