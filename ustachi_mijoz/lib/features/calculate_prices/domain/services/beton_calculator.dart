
library;

class BetonSection {
  const BetonSection({
    required this.widthM,
    required this.heightM,
    required this.padWidthM,
    required this.padHeightM,
  });

  final double widthM;
  final double heightM;
  final double padWidthM;
  final double padHeightM;

  double get wallM3 => widthM * heightM;

  double get padM3 => padWidthM * padHeightM;

  double get m3PerM => wallM3 + padM3;

  BetonSection copyWith({
    double? widthM,
    double? heightM,
    double? padWidthM,
    double? padHeightM,
  }) =>
      BetonSection(
        widthM: widthM ?? this.widthM,
        heightM: heightM ?? this.heightM,
        padWidthM: padWidthM ?? this.padWidthM,
        padHeightM: padHeightM ?? this.padHeightM,
      );
}

class BetonEstimate {
  const BetonEstimate({
    required this.outerM,
    required this.innerM,
    required this.betonM3,
    required this.armaturaM,
    required this.betonCost,
    required this.armaturaCost,
  });

  final double outerM;

  final double innerM;

  double get lengthM => outerM + innerM;

  final double betonM3;

  final double armaturaM;

  final int betonCost;
  final int armaturaCost;

  int get total => betonCost + armaturaCost;
}

abstract final class BetonCalculator {

  static const defaultWidthM = 0.40;
  static const defaultHeightM = 0.60;

  static const defaultPadWidthM = 0.90;
  static const defaultPadHeightM = 0.40;

  static const innerPadShare = 0.5;

  static const armaturaPerM = 5.0;

  static const defaultSection = BetonSection(
    widthM: defaultWidthM,
    heightM: defaultHeightM,
    padWidthM: defaultPadWidthM,
    padHeightM: defaultPadHeightM,
  );

  static const fenceWidthM = 0.30;
  static const fenceHeightM = 0.50;

  static const fencePadWidthM = 0.60;
  static const fencePadHeightM = 0.30;

  static const fenceArmaturaPerM = 5.0;

  static const fenceSection = BetonSection(
    widthM: fenceWidthM,
    heightM: fenceHeightM,
    padWidthM: 0,
    padHeightM: 0,
  );

  static BetonEstimate? calculateFence({
    required double lengthM,
    BetonSection section = fenceSection,
    required double betonPricePerM3,
    required double armaturaPricePerM,
  }) {
    if (lengthM <= 0) return null;
    final beton = lengthM * section.m3PerM;
    final armatura = lengthM * fenceArmaturaPerM;
    return BetonEstimate(
      outerM: lengthM,
      innerM: 0,
      betonM3: beton,
      armaturaM: armatura,
      betonCost: (beton * betonPricePerM3).round(),
      armaturaCost: (armatura * armaturaPricePerM).round(),
    );
  }

  static double perimeterM({
    required double lengthM,
    required double widthM,
  }) {
    if (lengthM <= 0 || widthM <= 0) return 0;
    return 2 * (lengthM + widthM);
  }

  static BetonEstimate? calculate({
    required double houseLengthM,
    required double houseWidthM,
    double innerWallsM = 0,
    BetonSection section = defaultSection,
    required double betonPricePerM3,
    required double armaturaPricePerM,
  }) {
    final outer = perimeterM(lengthM: houseLengthM, widthM: houseWidthM);
    if (outer <= 0) return null;
    final inner = innerWallsM > 0 ? innerWallsM : 0.0;

    final innerSection = section.copyWith(
      padWidthM: section.padWidthM * innerPadShare,
    );

    final beton = outer * section.m3PerM + inner * innerSection.m3PerM;
    final armatura = (outer + inner) * armaturaPerM;

    return BetonEstimate(
      outerM: outer,
      innerM: inner,
      betonM3: beton,
      armaturaM: armatura,
      betonCost: (beton * betonPricePerM3).round(),
      armaturaCost: (armatura * armaturaPricePerM).round(),
    );
  }
}
