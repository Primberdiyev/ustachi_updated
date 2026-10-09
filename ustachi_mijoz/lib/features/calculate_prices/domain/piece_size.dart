
class PieceSize {
  const PieceSize({required this.heightMm, required this.widthMm});

  final int heightMm;
  final int widthMm;

  double get areaM2 => heightMm * widthMm / 1000000;

  Map<String, Object> toJson() => {
        'height_mm': heightMm,
        'width_mm': widthMm,
        'area_m2': areaM2,
      };

  static double totalArea(Iterable<PieceSize> pieces) =>
      pieces.fold(0, (sum, p) => sum + p.areaM2);

  static int totalPrice(Iterable<PieceSize> pieces, double pricePerM2) =>
      (totalArea(pieces) * pricePerM2).round();
}

enum SizeUnit {

  mm('mm'),

  m('m');

  const SizeUnit(this.label);
  final String label;

  int? parseMm(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    final result = switch (this) {
      mm => int.tryParse(text),
      m => switch (double.tryParse(text)) {
          final v? => (v * 1000).round(),
          null => null,
        },
    };
    return (result != null && result > 0) ? result : null;
  }
}
