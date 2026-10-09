
library;

enum Fill {
  glass,
  panel,

  lambriVertical,

  lambriHorizontal,

  cutout;

  bool get isLambri => this == lambriVertical || this == lambriHorizontal;
}

enum Axis {

  vertical,

  horizontal,
}

enum WingKind {

  turn,

  tilt,

  tiltTurn,

  door,
}

sealed class Cell {
  const Cell();
}

final class Zone extends Cell {
  const Zone([this.fill = Fill.glass]);

  final Fill fill;
}

final class Split extends Cell {
  const Split({
    required this.axis,
    required this.positionsMm,
    required this.children,
    this.chiftQuloq = false,
    this.chiftImposts = const {},
    this.balcony = false,
  });

  final Axis axis;

  final List<double> positionsMm;

  final List<Cell> children;

  final bool chiftQuloq;

  final Set<int> chiftImposts;

  bool isChift(int i) => chiftQuloq || chiftImposts.contains(i);

  bool get hasChift => chiftQuloq || chiftImposts.isNotEmpty;

  final bool balcony;

  Split copyWith({
    List<double>? positionsMm,
    List<Cell>? children,
    bool? chiftQuloq,
    Set<int>? chiftImposts,
    bool? balcony,
  }) =>
      Split(
        axis: axis,
        positionsMm: positionsMm ?? this.positionsMm,
        children: children ?? this.children,
        chiftQuloq: chiftQuloq ?? this.chiftQuloq,
        chiftImposts: chiftImposts ?? this.chiftImposts,
        balcony: balcony ?? this.balcony,
      );
}

enum WingSide { left, right, top, bottom }

final class Wing extends Cell {
  const Wing(
    this.kind, [
    this.content = const Zone(),
    this.hasHandle = true,
    this.handleSide = WingSide.right,
    this.balcony = false,
  ]);

  final WingKind kind;

  final bool balcony;

  Wing copyWith({WingKind? kind, Cell? content, bool? hasHandle, WingSide? handleSide, bool? balcony}) => Wing(
        kind ?? this.kind,
        content ?? this.content,
        hasHandle ?? this.hasHandle,
        handleSide ?? this.handleSide,
        balcony ?? this.balcony,
      );

  final Cell content;

  final bool hasHandle;

  final WingSide handleSide;
}

class FrameDesign {
  const FrameDesign({
    required this.widthMm,
    required this.heightMm,
    this.root = const Zone(),
    this.archRiseMm = 0,
  });

  final double widthMm;
  final double heightMm;
  final Cell root;

  final double archRiseMm;
}

class DesignException implements Exception {
  const DesignException(this.message);

  final String message;

  @override
  String toString() => message;
}
