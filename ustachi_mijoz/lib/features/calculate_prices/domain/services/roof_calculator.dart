
library;

enum RoofShape {
  single(
    'Bir qiyali',
    'Bitta tomonga qiya — ayvon, garaj, omborxona.',
    slopeFactor: 1.15,
    variantSuffix: 'bir qiyali',
    fallsBackToBase: false,
  ),
  gable(
    'Ikki qiyali',
    'Eng ko\'p uchraydigan tom — ikki tomonga qiya.',
    slopeFactor: 1.15,
    variantSuffix: '',
    fallsBackToBase: true,
  ),
  hip(
    'To\'rt qiyali',
    'To\'rt tomonga qiya (valma) — frontonsiz.',
    slopeFactor: 1.15,
    variantSuffix: 'to\'rt qiyali',

    fallsBackToBase: true,
  );

  const RoofShape(
    this.title,
    this.desc, {
    required this.slopeFactor,
    required this.variantSuffix,
    required this.fallsBackToBase,
  });

  final String title;
  final String desc;

  final double slopeFactor;

  final String variantSuffix;

  final bool fallsBackToBase;

  String variantNameFor(RoofMaterial material) =>
      variantSuffix.isEmpty ? material.title : '${material.title} · $variantSuffix';
}

enum RoofRafter {
  terak('Terak to\'sin', 'terak'),
  sasna('Sasna to\'sin', 'sasna'),
  plita('Tayyor temir-beton plita', 'temir-beton plita'),
  metall('Metall karkas', 'metall karkas');

  const RoofRafter(this.title, this.shortName);

  final String title;

  final String shortName;
}

enum RoofCover {
  shifer('Shifer'),
  tunuka('Tunuka'),
  cherepitsa('Cherepitsa'),
  profnastil('Profnastil'),
  ruberoid('Ruberoid');

  const RoofCover(this.title);
  final String title;
}

enum RoofMaterial {
  terakShifer(
    'Terak + shifer',
    'Eng arzon variant. Terak to\'sin ustiga shifer.',
    RoofRafter.terak,
    RoofCover.shifer,
  ),
  terakTunuka(
    'Terak + tunuka',
    'Terak to\'sin ustiga tunuka (metall list).',
    RoofRafter.terak,
    RoofCover.tunuka,
  ),
  sasnaShifer(
    'Sasna + shifer',
    'Sasna (qarag\'ay) to\'sin ustiga shifer — terakdan mustahkamroq.',
    RoofRafter.sasna,
    RoofCover.shifer,
  ),
  sasnaTunuka(
    'Sasna + tunuka',
    'Sasna to\'sin ustiga tunuka.',
    RoofRafter.sasna,
    RoofCover.tunuka,
  ),
  sasnaCherepitsa(
    'Sasna + cherepitsa',
    'Sasna to\'sin ustiga cherepitsa — eng chiroyli va uzoq turadi.',
    RoofRafter.sasna,
    RoofCover.cherepitsa,
  ),
  tayyorPlita(
    'Tayyor plita',

    'Temir-beton plita, ustida tunuka tom bilan.',
    RoofRafter.plita,
    RoofCover.tunuka,

    priceNote: 'Narx ichida plitani keltirish, kran va o\'rnatish '
        'xizmati YO\'Q — ularni usta alohida aytadi.',
  ),
  profnastil(
    'Profnastil',
    'Metall karkas ustiga profnastil.',
    RoofRafter.metall,
    RoofCover.profnastil,
  );

  const RoofMaterial(
    this.title,
    this.desc,
    this.rafter,
    this.cover, {
    this.priceNote = '',
  });

  final String title;
  final String desc;
  final RoofRafter rafter;
  final RoofCover cover;

  final String priceNote;

  String get rawMaterials =>
      '${cover.title.toLowerCase()} va ${rafter.shortName}';

  String get variantName => title;

  bool get isFlat => cover == RoofCover.ruberoid;
}

class RoofEstimate {
  const RoofEstimate({
    required this.houseAreaM2,
    required this.footprintM2,
    required this.areaM2,
    required this.pricePerM2,
    required this.materialCost,
  });

  final double houseAreaM2;

  final double footprintM2;

  final double areaM2;

  final double pricePerM2;

  final int materialCost;
}

abstract final class RoofCalculator {

  static const overhangM = 0.5;

  static double slopeFactor(RoofShape shape, RoofMaterial? material) =>
      material != null && material.isFlat ? 1.0 : shape.slopeFactor;

  static double areaM2({
    required double lengthM,
    required double widthM,
    required RoofShape shape,
    RoofMaterial? material,
  }) {
    if (lengthM <= 0 || widthM <= 0) return 0;
    return footprintM2(lengthM: lengthM, widthM: widthM) *
        slopeFactor(shape, material);
  }

  static double footprintM2({
    required double lengthM,
    required double widthM,
  }) {
    if (lengthM <= 0 || widthM <= 0) return 0;
    return (lengthM + 2 * overhangM) * (widthM + 2 * overhangM);
  }

  static double houseAreaM2({
    required double lengthM,
    required double widthM,
  }) {
    if (lengthM <= 0 || widthM <= 0) return 0;
    return lengthM * widthM;
  }

  static RoofEstimate? calculate({
    required double lengthM,
    required double widthM,
    required RoofShape shape,
    RoofMaterial? material,
    required double pricePerM2,
  }) {
    final house = houseAreaM2(lengthM: lengthM, widthM: widthM);
    if (house <= 0) return null;
    return RoofEstimate(
      houseAreaM2: house,
      footprintM2: footprintM2(lengthM: lengthM, widthM: widthM),
      areaM2: areaM2(
          lengthM: lengthM, widthM: widthM, shape: shape, material: material),
      pricePerM2: pricePerM2,
      materialCost: (house * pricePerM2).round(),
    );
  }
}
