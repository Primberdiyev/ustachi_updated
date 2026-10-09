
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/services/beton_calculator.dart';

const betonPrice = 390000.0; 
const armaturaPrice = 7500.0; 

BetonEstimate estimateFor({
  double length = 6,
  double width = 4,
  double inner = 0,
  BetonSection section = BetonCalculator.defaultSection,
}) =>
    BetonCalculator.calculate(
      houseLengthM: length,
      houseWidthM: width,
      innerWallsM: inner,
      section: section,
      betonPricePerM3: betonPrice,
      armaturaPricePerM: armaturaPrice,
    )!;

void main() {
  test('6 × 4 uy: 12 kub beton va 100 metr armatura (mutaxassis namunasi)',
      () {
    final e = estimateFor();

    expect(e.outerM, 20, reason: 'perimetr 2 × (6 + 4)');
    expect(e.betonM3, closeTo(12, 1e-9));
    expect(e.armaturaM, closeTo(100, 1e-9));
  });

  test('6 × 4 uy tannarxi: beton 4 680 000 + armatura 750 000', () {
    final e = estimateFor();

    expect(e.betonCost, 4680000); 
    expect(e.armaturaCost, 750000); 
    expect(e.total, 5430000);
  });

  test('odatiy o\'lcham: poydevor 40 × 60 sm', () {
    expect(BetonCalculator.defaultWidthM, 0.40);
    expect(BetonCalculator.defaultHeightM, 0.60);

    expect(BetonCalculator.defaultSection.wallM3, closeTo(0.24, 1e-9));
    expect(BetonCalculator.defaultSection.padM3, closeTo(0.36, 1e-9));
    expect(BetonCalculator.defaultSection.m3PerM, closeTo(0.6, 1e-9));
  });

  test('mijoz o\'lchamni o\'zgartirsa kub ham o\'zgaradi', () {

    final e = estimateFor(
      section: BetonCalculator.defaultSection.copyWith(widthM: 0.50),
    );

    expect(e.betonM3, closeTo(20 * 0.66, 1e-9));

    final deeper = estimateFor(
      section: BetonCalculator.defaultSection.copyWith(heightM: 0.80),
    );
    expect(deeper.betonM3, greaterThan(e.betonM3 - 1e-9 + 0));
    expect(deeper.betonM3, closeTo(20 * (0.4 * 0.8 + 0.36), 1e-9));
  });

  test('hisob PERIMETRGA bog\'liq, maydonga emas', () {

    final e = estimateFor(length: 12, width: 14);

    expect(e.outerM, 52);
    expect(e.betonM3, closeTo(31.2, 1e-9));
    expect(e.armaturaM, closeTo(260, 1e-9));
  });

  test('ichki devorda padushka KICHIKROQ (usta: "ozroq miqdorda")', () {
    final e = estimateFor(inner: 4);

    expect(e.lengthM, 24);

    expect(e.betonM3, closeTo(12 + 4 * (0.24 + 0.18), 1e-9));

    expect(e.armaturaM, closeTo(120, 1e-9));
  });

  group('devor (zabor) poydevori', () {
    BetonEstimate fence(double length, [BetonSection section = BetonCalculator.fenceSection]) =>
        BetonCalculator.calculateFence(
          lengthM: length,
          section: section,
          betonPricePerM3: betonPrice,
          armaturaPricePerM: armaturaPrice,
        )!;

    test('odatiy o\'lcham 30 × 50 sm, padushkasiz: 1 metrga 0,15 m³', () {
      expect(BetonCalculator.fenceSection.widthM, 0.30);
      expect(BetonCalculator.fenceSection.heightM, 0.50);
      expect(BetonCalculator.fenceSection.padM3, 0);
      expect(BetonCalculator.fenceSection.m3PerM, closeTo(0.15, 1e-9));
    });

    test('20 metr zabor: 3 kub beton, 100 m armatura, 1 920 000 so\'m', () {
      final e = fence(20);
      expect(e.lengthM, 20);
      expect(e.innerM, 0);
      expect(e.betonM3, closeTo(3, 1e-9));
      expect(e.armaturaM, closeTo(100, 1e-9));
      expect(e.betonCost, 1170000); 
      expect(e.armaturaCost, 750000); 
      expect(e.total, 1920000);
    });

    test('hisob UZUNLIKKA to\'g\'ri proporsional (perimetr emas)', () {
      expect(fence(40).betonM3, closeTo(2 * fence(20).betonM3, 1e-9));
      expect(fence(40).armaturaM, closeTo(200, 1e-9));
    });

    test('mijoz padushka qo\'shsa (60 × 30 sm) — kub ko\'payadi', () {
      final withPad = BetonCalculator.fenceSection.copyWith(
        padWidthM: BetonCalculator.fencePadWidthM,
        padHeightM: BetonCalculator.fencePadHeightM,
      );
      final e = fence(20, withPad);

      expect(e.betonM3, closeTo(20 * 0.33, 1e-9));
      expect(e.armaturaM, closeTo(100, 1e-9), reason: 'armatura o\'zgarmaydi');
    });

    test('mijoz o\'lchamni o\'zgartirsa (40 × 60 sm) — kub ham o\'zgaradi', () {
      final e = fence(20, BetonCalculator.fenceSection.copyWith(widthM: 0.40, heightM: 0.60));
      expect(e.betonM3, closeTo(20 * 0.24, 1e-9));
    });

    test('uzunlik yo\'q — hisob ham yo\'q', () {
      expect(
        BetonCalculator.calculateFence(
          lengthM: 0,
          betonPricePerM3: betonPrice,
          armaturaPricePerM: armaturaPrice,
        ),
        isNull,
      );
    });
  });

  test('o\'lcham yo\'q — hisob ham yo\'q', () {
    expect(
      BetonCalculator.calculate(
        houseLengthM: 0,
        houseWidthM: 4,
        betonPricePerM3: betonPrice,
        armaturaPricePerM: armaturaPrice,
      ),
      isNull,
    );
  });
}
