
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/services/roof_calculator.dart';

const terakShiferPrice = 375000.0;
const terakShiferSinglePrice = 261000.0;

void main() {
  test('6 × 4 uy, terak + shifer: 24 × 375 000 = 9 000 000 so\'m', () {
    final e = RoofCalculator.calculate(
      lengthM: 6,
      widthM: 4,
      shape: RoofShape.gable,
      material: RoofMaterial.terakShifer,
      pricePerM2: terakShiferPrice,
    )!;

    expect(e.houseAreaM2, 24);
    expect(e.materialCost, 9000000);
  });

  test('narx TOM yuzasiga emas, UY maydoniga', () {
    final e = RoofCalculator.calculate(
      lengthM: 10,
      widthM: 8,
      shape: RoofShape.gable,
      pricePerM2: terakShiferPrice,
    )!;

    expect(e.houseAreaM2, 80);
    expect(e.materialCost, (80 * terakShiferPrice).round());

    expect(e.areaM2, greaterThan(e.houseAreaM2));
  });

  test('uy kattalashsa 1 m² narxi o\'zgarmaydi (usta javobi)', () {
    int costOf(double l, double w) => RoofCalculator.calculate(
          lengthM: l,
          widthM: w,
          shape: RoofShape.gable,
          pricePerM2: terakShiferPrice,
        )!.materialCost;

    expect(costOf(12, 8), costOf(6, 4) * 4);
  });

  test('bir qiyali, 6 × 4 uy: 24 × 261 000 = 6 264 000 so\'m', () {

    final e = RoofCalculator.calculate(
      lengthM: 6,
      widthM: 4,
      shape: RoofShape.single,
      material: RoofMaterial.terakShifer,
      pricePerM2: terakShiferSinglePrice,
    )!;

    expect(e.materialCost, 6264000);
  });

  test('usta ilovasidagi xom ashyo yozuvi: "shifer va terak"', () {

    expect(RoofMaterial.terakShifer.rawMaterials, 'shifer va terak');
    expect(RoofMaterial.sasnaCherepitsa.rawMaterials, 'cherepitsa va sasna');
    expect(RoofMaterial.tayyorPlita.rawMaterials, 'tunuka va temir-beton plita');
    expect(RoofMaterial.profnastil.rawMaterials, 'profnastil va metall karkas');
  });

  test('adminkadagi narx qatori nomi: material + shakl', () {
    const m = RoofMaterial.terakShifer;

    expect(RoofShape.gable.variantNameFor(m), 'Terak + shifer');
    expect(RoofShape.single.variantNameFor(m), 'Terak + shifer · bir qiyali');
    expect(RoofShape.hip.variantNameFor(m), 'Terak + shifer · to\'rt qiyali');
  });

  test('to\'rt qiyali asosiy narxga qaytadi, bir qiyali esa YO\'Q', () {

    expect(RoofShape.hip.fallsBackToBase, isTrue);
    expect(RoofShape.gable.fallsBackToBase, isTrue);

    expect(RoofShape.single.fallsBackToBase, isFalse);
  });

  test('tom yuzasi (ko\'rsatish uchun): 10 × 8 uy → 113,85 m²', () {
    expect(RoofCalculator.footprintM2(lengthM: 10, widthM: 8), 99);
    expect(
      RoofCalculator.areaM2(lengthM: 10, widthM: 8, shape: RoofShape.gable),
      closeTo(113.85, 1e-9),
    );
  });

  test('chiqish har tomonga 0,5 m', () {
    expect(RoofCalculator.overhangM, 0.5);
    expect(RoofCalculator.footprintM2(lengthM: 6, widthM: 4), 35);
  });

  test('tayyor plita TEKIS EMAS — ustida tunuka tom bor', () {

    expect(RoofMaterial.tayyorPlita.isFlat, isFalse);
    expect(RoofMaterial.tayyorPlita.cover, RoofCover.tunuka);

    final e = RoofCalculator.calculate(
      lengthM: 6,
      widthM: 4,
      shape: RoofShape.hip,
      material: RoofMaterial.tayyorPlita,
      pricePerM2: terakShiferPrice,
    )!;
    expect(e.areaM2, greaterThan(e.footprintM2));
  });

  test('o\'lcham yo\'q — hisob ham yo\'q', () {
    expect(
      RoofCalculator.calculate(
          lengthM: 0, widthM: 8, shape: RoofShape.gable, pricePerM2: 100),
      isNull,
    );
  });

  test('narx kiritilmagan bo\'lsa ham maydon hisoblanadi', () {
    final e = RoofCalculator.calculate(
      lengthM: 6,
      widthM: 4,
      shape: RoofShape.hip,
      pricePerM2: 0,
    )!;
    expect(e.houseAreaM2, 24);
    expect(e.materialCost, 0);
  });
}
