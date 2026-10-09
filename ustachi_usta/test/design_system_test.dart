
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/design_sytem/open_colors.dart';

double _luminance(Color c) => c.computeLuminance();

void main() {
  final light = OpenColors.light;
  final dark = OpenColors.dark;

  group('Tungi tema HAQIQATAN qorong\'u', () {
    test('sahifa foni va yuzalar teskarilangan', () {
      expect(dark.neutral.bg, isNot(light.neutral.bg));
      expect(dark.neutral.surface, isNot(light.neutral.surface));
      expect(dark.neutral.surface2, isNot(light.neutral.surface2));

      expect(_luminance(light.neutral.bg), greaterThan(0.7));
      expect(_luminance(dark.neutral.bg), lessThan(0.05));
    });

    test('matn ranglari teskarilangan', () {

      expect(_luminance(light.neutral.textStrong), lessThan(0.05));
      expect(_luminance(dark.neutral.textStrong), greaterThan(0.7));
      expect(dark.neutral.textBody, isNot(light.neutral.textBody));
      expect(dark.neutral.textMuted, isNot(light.neutral.textMuted));
    });

    test('categorizedColor ham qorong\'u variantda (asl bug shu edi)', () {

      expect(dark.categorizedColor.primary,
          isNot(light.categorizedColor.primary));
      expect(dark.categorizedColor.scaffoldColor,
          isNot(light.categorizedColor.scaffoldColor));
      expect(_luminance(dark.categorizedColor.scaffoldColor), lessThan(0.05));
    });

    test('eski black* aliaslari ham teskarilanadi', () {

      expect(_luminance(light.neutral.black1), lessThan(0.05));
      expect(_luminance(dark.neutral.black1), greaterThan(0.7));

      expect(_luminance(light.neutral.black8), greaterThan(0.7));
      expect(_luminance(dark.neutral.black8), lessThan(0.05));
    });
  });

  group('Yagona brend ko\'ki', () {
    test('blue1 aliasi primary bilan bir xil (uchta ko\'k yo\'q)', () {
      expect(light.neutral.blue1, light.categorizedColor.primary);
      expect(dark.neutral.blue1, dark.categorizedColor.primary);
    });

    test('primary va secondary bir xil rang', () {
      expect(light.categorizedColor.primary,
          light.categorizedColor.secondaryColor);
      expect(
          dark.categorizedColor.primary, dark.categorizedColor.secondaryColor);
    });

    test('ilgari binafsha bo\'lgan blue3/blue4 endi guruch (iliq)', () {

      for (final c in [light.neutral.blue3, light.neutral.blue4]) {
        expect(c.r, greaterThan(c.b),
            reason: 'blue3/blue4 iliq (guruch) bo\'lishi kerak');
      }
      expect(light.neutral.blue3, light.categorizedColor.accent);
    });
  });

  group('Token invariantlari', () {
    test('white — har ikkala temada SOF OQ (primary ustidagi siyoh)', () {
      const pureWhite = Color(0xFFFFFFFF);
      expect(light.neutral.white, pureWhite);
      expect(dark.neutral.white, pureWhite);
    });

    test('aksent status rangi EMAS — hammasi bir-biridan farqli', () {
      for (final c in [light.categorizedColor, dark.categorizedColor]) {
        final roles = {
          'accent': c.accent,
          'success': c.success,
          'warning': c.warning,
          'error': c.error,
          'info': c.info,
          'primary': c.primary,
        };
        expect(roles.values.toSet().length, roles.length,
            reason: 'har bir rol o\'z rangiga ega bo\'lishi kerak');
      }
    });

    test('matn/fon kontrasti WCAG AA (>= 4.5:1)', () {
      double ratio(Color fg, Color bg) {
        final a = _luminance(fg) + 0.05;
        final b = _luminance(bg) + 0.05;
        return a > b ? a / b : b / a;
      }

      for (final t in [light, dark]) {
        expect(ratio(t.neutral.textStrong, t.neutral.surface),
            greaterThanOrEqualTo(4.5));
        expect(ratio(t.neutral.textBody, t.neutral.surface),
            greaterThanOrEqualTo(4.5));
        expect(ratio(t.neutral.textMuted, t.neutral.surface),
            greaterThanOrEqualTo(4.5));
      }
    });
  });
}
