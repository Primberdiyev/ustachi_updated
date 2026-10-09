
library;

class RadiatorPanel {
  const RadiatorPanel(this.heightCm, this.lengthCm, this.priceUsd);

  final int heightCm;

  final int lengthCm;

  final double priceUsd;

  String get size => '$heightCm×$lengthCm';

  int get faceCm2 => heightCm * lengthCm;

  int get watts => (lengthCm /
          10 *
          RadiatorCatalog.wattsPer10cm *
          heightCm /
          RadiatorCatalog.baseHeightCm)
      .round();

  int priceSom(double usdRate) => (priceUsd * usdRate).round();
}

abstract final class RadiatorCatalog {

  static const defaultUsdRate = 12000.0;

  static const anchor = RadiatorPanel(50, 140, 87.2);

  static const baseHeightCm = 50;

  static const wattsPer10cm = 150;

  static const all = <RadiatorPanel>[
    RadiatorPanel(30, 40, 31.4),
    RadiatorPanel(30, 60, 37.7),
    RadiatorPanel(30, 80, 44),
    RadiatorPanel(30, 100, 49.4),
    RadiatorPanel(30, 120, 55.7),
    RadiatorPanel(30, 140, 62),
    RadiatorPanel(30, 160, 68.3),
    RadiatorPanel(30, 180, 74.6),
    RadiatorPanel(30, 200, 81.8),
    RadiatorPanel(40, 40, 37.7),
    RadiatorPanel(40, 60, 44),
    RadiatorPanel(40, 80, 51.2),
    RadiatorPanel(40, 100, 58.4),
    RadiatorPanel(40, 120, 66.5),
    RadiatorPanel(40, 140, 73.7),
    RadiatorPanel(40, 160, 82.7),
    RadiatorPanel(40, 180, 91.8),
    RadiatorPanel(40, 200, 98.9),
    RadiatorPanel(50, 40, 40.4),
    RadiatorPanel(50, 60, 48.5),
    RadiatorPanel(50, 80, 57.5),
    RadiatorPanel(50, 100, 66.5),
    RadiatorPanel(50, 120, 76.4),
    anchor, 
    RadiatorPanel(50, 160, 97.1),
    RadiatorPanel(50, 180, 107),
    RadiatorPanel(50, 200, 117.8),
    RadiatorPanel(60, 40, 45.8),
    RadiatorPanel(60, 60, 54.8),
    RadiatorPanel(60, 80, 63.8),
    RadiatorPanel(60, 100, 75.5),
    RadiatorPanel(60, 120, 85.4),
    RadiatorPanel(60, 140, 97.1),
    RadiatorPanel(60, 160, 108.9),
    RadiatorPanel(60, 180, 113.3),
    RadiatorPanel(60, 200, 132.1),
  ];

  static RadiatorPanel? bySize(String size) {
    for (final p in all) {
      if (p.size == size) return p;
    }
    return null;
  }
}
