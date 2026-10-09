import 'package:test/test.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart';

void main() {
  const spec = SeriesSpec.akfaPlastic;
  const frame = FrameDesign(widthMm: 1500, heightMm: 1400, root: Zone());

  test('bo\'sh rom: bitta katak, yorug\'lik o\'rni rama enicha kichik', () {
    final boxes = layoutCells(frame, spec);
    expect(boxes, hasLength(1));
    expect(boxes.single.light.width, 1500 - 2 * spec.frameWidth);
    expect(boxes.single.light.height, 1400 - 2 * spec.frameWidth);
    expect(designError(frame, spec), isNull);
  });

  test('tik bo\'lish, qanot qo\'yish va o\'lchamni o\'zgartirish', () {
    var d = splitZone(frame, spec, const [], Axis.vertical, 2);
    expect((d.root as Split).positionsMm, [750]);

    d = setWing(d, const [0], WingKind.tiltTurn);
    final wing = (d.root as Split).children.first;
    expect(wing, isA<Wing>());
    expect(layoutCells(d, spec).where((b) => b.isWing).single.sash, isNotNull);

    d = resizeSection(d, spec, const [0], 600);
    expect((d.root as Split).positionsMm, [600]);

    d = resizeFrame(d, spec, 3000, 1400);
    expect((d.root as Split).positionsMm, [1200]);
  });

  test('noto\'g\'ri chizma rad etiladi', () {
    expect(() => resizeFrame(frame, spec, 60, 1400), throwsA(isA<DesignException>()));
    final split = splitZone(frame, spec, const [], Axis.vertical, 2);
    expect(() => resizeSection(split, spec, const [0], 1490), throwsA(isA<DesignException>()));
    final winged = setWing(frame, const [], WingKind.turn);
    expect(() => setWing(winged, const [0], WingKind.turn), throwsA(isA<DesignException>()));
    expect(() => setArch(frame, spec, 1400), throwsA(isA<DesignException>()));
  });

  test('chizma JSON orqali aynan qaytadi', () {
    var d = splitZone(frame, spec, const [], Axis.horizontal, 2);
    d = setWing(d, const [1], WingKind.door);
    d = setFill(d, const [0], Fill.panel);
    final back = designFromJson(designToJson(d));
    expect(designToJson(back), designToJson(d));
  });
}
