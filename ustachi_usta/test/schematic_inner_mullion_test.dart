
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_schematic_painter.dart';

const _w = 400.0, _h = 900.0; 

Future<ui.Image> _render(List<SchematicPane> panes) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  WindowSchematicPainter(
    widthMm: 800,
    heightMm: 1800,
    panes: panes,
    profileColor: const Color(0xFFFFFFFF), 
    glassColor: const Color(0xFF0000FF), 
    showHardware: false, 
  ).paint(canvas, const Size(_w, _h));
  return rec.endRecording().toImage(_w.toInt(), _h.toInt());
}

Future<int> _whiteInStrip(ui.Image img, int yPx, int band) async {
  final data = (await img.toByteData())!;
  int white = 0;
  for (var y = yPx - band; y <= yPx + band; y++) {
    for (var x = 0; x < _w.toInt(); x++) {
      final o = (y * _w.toInt() + x) * 4;
      final r = data.getUint8(o), g = data.getUint8(o + 1), b = data.getUint8(o + 2);
      if (r > 200 && g > 200 && b > 200) white++;
    }
  }
  return white;
}

void main() {
  const doorRect = Rect.fromLTRB(0, 0, 1, 1);

  test('sash ichidagi gorizontal impost bo\'lmalar orasida chiziladi', () async {

    final withMullion = SchematicPane(
      rect: doorRect,
      openingCategory: 2, 
      isDoor: true,
      compartments: const [
        (rect: Rect.fromLTRB(0, 0, 1, 0.5), pattern: 0),
        (rect: Rect.fromLTRB(0, 0.5, 1, 1), pattern: 0),
      ],
    );
    final without = SchematicPane(
      rect: doorRect,
      openingCategory: 2,
      isDoor: true,
    );

    final imgWith = await _render([withMullion]);
    final imgWithout = await _render([without]);

    const yPx = 450, band = 6;
    final wWith = await _whiteInStrip(imgWith, yPx, band);
    final wWithout = await _whiteInStrip(imgWithout, yPx, band);

    expect(wWith, greaterThan(wWithout + 1500),
        reason: 'bo\'lmalararo impost profil-rang bo\'lishi kerak');

    expect(wWith, greaterThan(2000));
  });

  test('impostsiz sash bo\'luvchi joyi shisha bo\'lib qoladi (nazorat)', () async {
    final img = await _render([
      SchematicPane(rect: doorRect, openingCategory: 2, isDoor: true),
    ]);

    final data = (await img.toByteData())!;
    const x = 200, y = 450;
    final o = (y * _w.toInt() + x) * 4;
    final r = data.getUint8(o), g = data.getUint8(o + 1), b = data.getUint8(o + 2);

    expect(b, greaterThan(120));
    expect(r < 200 || g < 200, isTrue);
  });
}
