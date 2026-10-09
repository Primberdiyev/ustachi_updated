
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_schematic_painter.dart';

void main() {
  const size = Size(300, 300);
  const fullPane = Rect.fromLTRB(0, 0, 1, 1);

  test('fixed pane → shisha proyomi draw-area ichida (rom qadar chekingan)', () {
    final r = schematicDecorationGlassRects(
      size: size,
      panes: const [SchematicPane(rect: fullPane, openingCategory: 0)],
      widthMm: 1500,
      heightMm: 1500,
    );
    expect(r.length, 1);
    final g = r.first.glass;

    expect(g.left, greaterThan(0));
    expect(g.top, greaterThan(0));
    expect(g.right, lessThan(300));
    expect(g.bottom, lessThan(300));

    expect(g.width, greaterThan(300 * 0.8));
  });

  test('casement → sash ICHKI qirrasi (fixed proyomдан bir chiziq ichkarida)', () {
    final f = schematicDecorationGlassRects(
      size: size,
      panes: const [SchematicPane(rect: fullPane, openingCategory: 0)],
      widthMm: 1500,
      heightMm: 1500,
    ).first.glass;
    final c = schematicDecorationGlassRects(
      size: size,
      panes: const [SchematicPane(rect: fullPane, openingCategory: 1)],
      widthMm: 1500,
      heightMm: 1500,
    ).first.glass;

    expect(c.left, greaterThan(f.left));
    expect(c.top, greaterThan(f.top));
    expect(c.right, lessThan(f.right));
    expect(c.bottom, lessThan(f.bottom));
    expect(c.width, lessThan(f.width));
  });

  test('regions/panes bo\'sh → bo\'sh (chaqiruvchi eski geometriyaga qaytadi)', () {
    expect(
        schematicDecorationGlassRects(
            size: size, panes: const [], widthMm: 1500, heightMm: 1500),
        isEmpty);
    expect(
        schematicDecorationGlassRects(
            size: Size.zero,
            panes: const [SchematicPane(rect: fullPane)],
            widthMm: 1500,
            heightMm: 1500),
        isEmpty);
  });
}
