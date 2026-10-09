library;

enum RomAxis {
  vertical,

  horizontal,
}

enum RomFill {
  glass,
  panel,
  lambri,
  lambriHorizontal;

  bool get isLambri => this == lambri || this == lambriHorizontal;
}

enum RomWingFunction {
  turn,

  tilt,

  tiltTurn,

  door,
}

sealed class RomCell {
  const RomCell();
}

final class RomZone extends RomCell {
  const RomZone([this.fill = RomFill.glass]);

  final RomFill fill;
}

final class RomSplit extends RomCell {
  const RomSplit({
    required this.axis,
    required this.positionsMm,
    required this.children,
    this.fromCell = false,
  });

  final RomAxis axis;
  final List<double> positionsMm;
  final List<RomCell> children;

  final bool fromCell;
}

enum RomHandleSide { left, right, top, bottom }

final class RomWing extends RomCell {
  const RomWing(
    this.function, [
    this.content = const RomZone(),
    this.handleSide = RomHandleSide.right,
    this.hasHandle = true,
  ]);

  final RomWingFunction function;
  final RomCell content;
  final RomHandleSide handleSide;

  final bool hasHandle;
}

class RomFrameDesign {
  const RomFrameDesign({
    required this.widthMm,
    required this.heightMm,
    this.root = const RomZone(),
    this.archRiseMm = 0,
  });

  final double widthMm;
  final double heightMm;
  final RomCell root;

  final double archRiseMm;
}

class RomDesignException implements Exception {
  const RomDesignException(this.message);

  final String message;

  @override
  String toString() => message;
}
