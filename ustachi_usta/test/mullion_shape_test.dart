
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

void main() {
  group('WindowZone dividerShapes', () {
    WindowZone grid() => WindowZone.split(
          direction: SplitDirection.horizontal,
          children: [
            WindowZone.leaf(),
            WindowZone.split(
              direction: SplitDirection.vertical,
              children: [WindowZone.leaf(), WindowZone.leaf()],
              ratios: [0.5, 0.5],
              dividerShapes: [MullionShape.y],
            ),
          ],
          ratios: [1 / 3, 2 / 3],
          dividerShapes: [MullionShape.t],
        );

    test('toFrameLinesTyped tartibi va shakllar', () {
      final z = grid();
      final typed = z.toFrameLinesTyped();
      expect(typed.length, 2);
      expect(typed[0].shape, MullionShape.t); 
      expect(typed[1].shape, MullionShape.y); 
    });

    test('mullionStatsByShape invariantlari (Σ = eski API)', () {
      final z = grid();
      final stats = z.mullionStatsByShape(3000, 1500);
      final mmSum = stats.values.fold(0.0, (a, b) => a + b.mm);
      final cntSum = stats.values.fold(0, (a, b) => a + b.count);
      final tjSum = stats.values.fold(0, (a, b) => a + b.tJunctions);
      expect(mmSum, closeTo(z.totalMullionLengthMm(3000, 1500), 1e-6));
      expect(cntSum, z.toFrameLines().length);
      expect(tjSum, z.mullionTJunctionCount());

      expect(stats[MullionShape.y]!.mm, closeTo(1000, 1e-6));
      expect(stats[MullionShape.y]!.tJunctions, 1);
    });

    test('resize va opening-apply shakllarni SAQLAYDI', () {
      var z = grid();
      z = z.updateVerticalRatioAt(0, 0.4);
      z = z.applyOpeningTypeAt(const Offset(0.2, 0.8), WindowOpeningType.openLeft);
      final typed = z.toFrameLinesTyped();
      expect(typed[0].shape, MullionShape.t);
      expect(typed[1].shape, MullionShape.y);
    });

    test('setDividerShapeAt flat indeks bo\'yicha to\'g\'ri chiziqqa tushadi', () {
      final z = grid().setDividerShapeAt(0, MullionShape.sh);
      expect(z.toFrameLinesTyped()[0].shape, MullionShape.sh);
      expect(z.toFrameLinesTyped()[1].shape, MullionShape.y); 
    });

    test('parser: shablon vertikal chiziqlari = witraj, gorizontal = T', () {

      final z = WindowZone.fromFramePreviewSpec(const FramePreviewSpec(
        aspectRatio: 1.0,
        lines: [
          FrameLine(0, 0.3, 1, 0.3),
          FrameLine(1 / 3, 0.3, 1 / 3, 1),
          FrameLine(2 / 3, 0.3, 2 / 3, 1),
        ],
      ));
      final shapes = z.toFrameLinesTyped().map((e) => e.shape).toList();

      expect(shapes.where((s) => s == MullionShape.witraj).length, 2);
      expect(shapes.where((s) => s == MullionShape.t).length, 1);
    });

    test('dividerIndexNear eng yaqin chiziqni topadi', () {
      final z = grid();

      expect(z.dividerIndexNear(const Offset(0.2, 0.34)), 0);

      expect(z.dividerIndexNear(const Offset(0.51, 0.7)), 1);
      expect(z.dividerIndexNear(const Offset(0.1, 0.1)), isNull);
    });
  });
}
