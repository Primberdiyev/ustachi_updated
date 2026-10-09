library;

enum ProfileMaterial { plastic, aluminium, termo }

class SeriesSpec {
  const SeriesSpec({
    required this.material,
    required this.frameWidth,
    required this.mullionWidth,
    required this.sashWidth,
    required this.balconySashWidth,
    required this.overlap,
  });

  final ProfileMaterial material;

  final double frameWidth;

  final double mullionWidth;

  final double sashWidth;

  final double balconySashWidth;

  final double overlap;

  static const akfaPlastic = SeriesSpec(
    material: ProfileMaterial.plastic,
    frameWidth: 44,
    mullionWidth: 38,
    sashWidth: 56,
    balconySashWidth: 84,
    overlap: 8,
  );

  static const aldoks = SeriesSpec(
    material: ProfileMaterial.aluminium,
    frameWidth: 43,
    mullionWidth: 43,
    sashWidth: 60,
    balconySashWidth: 93,
    overlap: 7.5,
  );

  static const termo = SeriesSpec(
    material: ProfileMaterial.termo,
    frameWidth: 43,
    mullionWidth: 43,
    sashWidth: 60,
    balconySashWidth: 93,
    overlap: 7.5,
  );
}
