
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

void main() {
  WindowZone nested() => WindowZone.split(
        direction: SplitDirection.vertical,
        children: [
          WindowZone.leaf(),
          WindowZone.split(
            direction: SplitDirection.vertical,
            children: [WindowZone.leaf(), WindowZone.leaf()],
            ratios: [0.5, 0.5],
          ),
        ],
        ratios: [0.5, 0.5],
      );

  test('nested vertikal — chekka (index 2) ustunni resize CRASH bermaydi', () {
    final z = nested();
    expect(z.widthSegments(3000), [1500, 750, 750]);

    late WindowZone updated;
    expect(() => updated = z.updateVerticalRatioAt(2, 500 / 3000), returnsNormally);
    expect(updated.widthSegments(3000), [1500, 1000, 500]);
  });

  test("nested vertikal — o'rta (index 1) ustunni resize", () {
    final z = nested();
    final u = z.updateVerticalRatioAt(1, 1000 / 3000);
    expect(u.widthSegments(3000), [1500, 1000, 500]);
  });

  test('nested vertikal — chap (index 0, root bola) ustunni resize', () {
    final z = nested();
    final u = z.updateVerticalRatioAt(0, 1000 / 3000);

    expect(u.widthSegments(3000), [1000, 1000, 1000]);
  });

  test('flat vertikal (3 ustun) — resize ishlaydi', () {
    final z = WindowZone.fromAbsoluteWidths([1000, 1000, 1000]);
    final u = z.updateVerticalRatioAt(2, 500 / 3000);
    expect(u.widthSegments(3000), [1000, 1500, 500]);
  });

  test('ketma-ket ustun tahriri oldingi ustunlarni o\'zgartirmaydi', () {
    final z = WindowZone.fromAbsoluteWidths([1000, 1000, 1000, 1000]);

    final first = z.updateVerticalRatioAt(0, 1400 / 4000);
    final second = first.updateVerticalRatioAt(1, 700 / 4000);

    expect(second.widthSegments(4000), [1400, 700, 1000, 900]);
  });
}
