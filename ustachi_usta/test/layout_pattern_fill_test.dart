
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_schematic_painter.dart';

const _w = 300.0, _h = 675.0; 
const _blue = Color(0xFF3B82F6);
const _profile = Color(0xFFB58A5A); 

Future<ui.Image> _render(int pattern) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  WindowSchematicPainter(
    widthMm: 800,
    heightMm: 1800,
    panes: [
      SchematicPane(
        rect: const Rect.fromLTRB(0, 0, 1, 1),
        openingCategory: 2, 
        isDoor: true,
        compartments: [
          (rect: const Rect.fromLTRB(0, 0, 1, 0.55), pattern: 0), 
          (rect: const Rect.fromLTRB(0, 0.55, 1, 1), pattern: pattern), 
        ],
      ),
    ],
    profileColor: _profile, 
    glassColor: _blue.withValues(alpha: 0.7),
    outlineColor: const Color(0xB3000000),
    showHardware: false,
  ).paint(canvas, const Size(_w, _h));
  return rec.endRecording().toImage(_w.toInt(), _h.toInt());
}

const _rx0 = 70, _rx1 = 230, _ry0 = 420, _ry1 = 600;

Future<(int, int, int)> _bgPixel(ui.Image img) async {
  final data = (await img.toByteData())!;
  var best = (0, 0, 0), bestSum = -1;
  for (var y = _ry0; y < _ry1; y += 2) {
    for (var x = _rx0; x < _rx1; x += 2) {
      final o = (y * _w.toInt() + x) * 4;
      final r = data.getUint8(o), g = data.getUint8(o + 1), b = data.getUint8(o + 2);
      if (r + g + b > bestSum) {
        bestSum = r + g + b;
        best = (r, g, b);
      }
    }
  }
  return best;
}

Future<bool> _hasDarkLines(ui.Image img) async {
  final data = (await img.toByteData())!;
  for (var y = _ry0; y < _ry1; y++) {
    for (var x = _rx0; x < _rx1; x++) {
      final o = (y * _w.toInt() + x) * 4;
      final r = data.getUint8(o), g = data.getUint8(o + 1), b = data.getUint8(o + 2);
      if (r < 140 && g < 140 && b < 140) return true; 
    }
  }
  return false;
}

void main() {

  final pr = (_profile.r * 255).round(),
      pg = (_profile.g * 255).round(),
      pb = (_profile.b * 255).round();
  bool isProfile(int r, int g, int b) =>
      (r - pr).abs() < 24 && (g - pg).abs() < 24 && (b - pb).abs() < 24;

  test('verticalBars(1): PROFIL rangi fon (ko\'k/oq EMAS) + qora chiziqlar',
      () async {
    final img = await _render(1);
    final (r, g, b) = await _bgPixel(img);
    expect(isProfile(r, g, b), isTrue,
        reason: 'fon profil rangi bo\'lishi kerak — $r,$g,$b');
    expect(await _hasDarkLines(img), isTrue, reason: 'qora chiziqlar kerak');
  });

  test('horizontalBars(2): PROFIL rangi fon', () async {
    final (r, g, b) = await _bgPixel(await _render(2));
    expect(isProfile(r, g, b), isTrue, reason: '$r,$g,$b');
  });

  test('emptyPanel(3): PROFIL rangi fon, chiziqsiz', () async {
    final img = await _render(3);
    final (r, g, b) = await _bgPixel(img);
    expect(isProfile(r, g, b), isTrue, reason: '$r,$g,$b');
  });

  test('glassPanel(4): OYNA rangi (ko\'k)', () async {
    final (r, g, b) = await _bgPixel(await _render(4));

    expect(b > r + 20, isTrue, reason: 'oyna (ko\'k) rangi kerak — $r,$g,$b');
  });

  test('tepa oyna (pattern 0) — ko\'k qoladi (to\'ldirmasiz)', () async {
    final img = await _render(1); 
    final data = (await img.toByteData())!;
    const y = 170, x = 150; 
    final o = (y * _w.toInt() + x) * 4;
    final r = data.getUint8(o), b = data.getUint8(o + 2);
    expect(b > r + 20, isTrue, reason: 'tepa oyna ko\'k qolishi kerak');
  });
}
