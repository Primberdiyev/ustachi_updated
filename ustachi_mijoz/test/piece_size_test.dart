import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/piece_size.dart';

void main() {
  test('bitta eshik: 2100 × 900 mm = 1,89 m²', () {
    const door = PieceSize(heightMm: 2100, widthMm: 900);
    expect(door.areaM2, closeTo(1.89, 1e-9));
  });

  test('bir necha eshik — maydonlar qo\'shiladi, narx jami maydondan', () {
    const doors = [
      PieceSize(heightMm: 2100, widthMm: 900), 
      PieceSize(heightMm: 2000, widthMm: 800), 
    ];
    expect(PieceSize.totalArea(doors), closeTo(3.49, 1e-9));

    expect(PieceSize.totalPrice(doors, 500000), 1745000);
  });

  test('kafel: pol 4,5 × 3,2 m va devor 2,7 × 3,2 m', () {
    final floor = PieceSize(
      heightMm: SizeUnit.m.parseMm('4,5')!,
      widthMm: SizeUnit.m.parseMm('3.2')!,
    );
    final wall = PieceSize(
      heightMm: SizeUnit.m.parseMm('2,7')!,
      widthMm: SizeUnit.m.parseMm('3,2')!,
    );
    expect(floor.areaM2, closeTo(14.4, 1e-9));
    expect(wall.areaM2, closeTo(8.64, 1e-9));

    expect(PieceSize.totalPrice([floor, wall], 45000), 1036800);
  });

  test('mm faqat butun son, m kasr bilan; bo\'sh va 0 qabul qilinmaydi', () {
    expect(SizeUnit.mm.parseMm('2100'), 2100);
    expect(SizeUnit.mm.parseMm('2,1'), isNull);
    expect(SizeUnit.m.parseMm('3'), 3000);
    expect(SizeUnit.m.parseMm('0,25'), 250);
    expect(SizeUnit.m.parseMm(''), isNull);
    expect(SizeUnit.m.parseMm('0'), isNull);
    expect(SizeUnit.mm.parseMm('0'), isNull);
  });

  test('ustaga har bo\'lakning o\'lchami boradi', () {
    const door = PieceSize(heightMm: 2100, widthMm: 900);
    expect(door.toJson(), {
      'height_mm': 2100,
      'width_mm': 900,
      'area_m2': closeTo(1.89, 1e-9),
    });
  });
}
