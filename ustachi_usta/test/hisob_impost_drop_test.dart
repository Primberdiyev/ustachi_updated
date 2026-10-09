import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

void main() {
  const spec = hisob.SeriesSpec.akfaPlastic;
  final blank = HisobKind.window.blankDesign(); 

  hisob.FrameDesign drop(hisob.FrameDesign d, hisob.Axis axis, double x, double y) {
    final plan = planImpost(d, spec, axis, x, y)!;
    return applyImpostDrop(d, plan, spec: spec);
  }

  test('bo\'sh romga tik tayoqcha 603 mm ga — impost 600 da (10 mm ga yaxlitlanadi)', () {
    final plan = planImpost(blank, spec, hisob.Axis.vertical, 603, 700)!;
    expect(plan.ok, isTrue);
    expect(plan.positionsMm, [600]);
    expect(plan.segmentsMm, [600, 900]);
    final d = applyImpostDrop(blank, plan, spec: spec);
    expect(lineMarks(d, hisob.Axis.vertical), [0, 600, 1500]);
  });

  test('ikkinchi tik tayoqcha shu qatorga qo\'shiladi (ichma-ich emas): 3 bo\'lak', () {
    final d = drop(drop(blank, hisob.Axis.vertical, 500, 700), hisob.Axis.vertical, 1000, 700);
    final root = d.root as hisob.Split;
    expect(root.positionsMm, [500, 1000]);
    expect(root.children.length, 3);
    expect(root.children.every((c) => c is hisob.Zone), isTrue);
  });

  test('yotiq tayoqcha o\'ng bo\'limga — faqat shu bo\'lim ustma-ust bo\'linadi', () {
    final d = drop(drop(blank, hisob.Axis.vertical, 500, 700), hisob.Axis.horizontal, 1000, 400);
    final root = d.root as hisob.Split;
    expect(root.children[0], isA<hisob.Zone>());
    final right = root.children[1] as hisob.Split;
    expect(right.axis, hisob.Axis.horizontal);
    expect(right.positionsMm, [400]);
    expect(lineMarks(d, hisob.Axis.horizontal, side: ChainSide.end), [0, 400, 1400]);
  });

  test('qanot ichidagi oyna ham bo\'linadi (impost qanot ichida)', () {
    final wing = hisob.FrameDesign(
      widthMm: 1500,
      heightMm: 1400,
      root: const hisob.Wing(hisob.WingKind.turn),
    );
    final d = drop(wing, hisob.Axis.horizontal, 750, 700);
    final w = d.root as hisob.Wing;
    expect(w.content, isA<hisob.Split>());
    expect((w.content as hisob.Split).positionsMm, [700]);
  });

  test('chetga juda yaqin — eng kichik bo\'lak (100 mm) ga suriladi', () {
    final plan = planImpost(blank, spec, hisob.Axis.vertical, 20, 700)!;
    expect(plan.positionsMm, [100]);
  });

  test('rom tashqarisi — null', () {
    expect(planImpost(blank, spec, hisob.Axis.vertical, -50, 700), isNull);
    expect(planImpost(blank, spec, hisob.Axis.vertical, 700, 1600), isNull);
  });

  test('chift quloq tayoqchasi: yangi katak belgili; oddiy qatorga qo\'shilmaydi', () {
    final plan = planImpost(blank, spec, hisob.Axis.vertical, 600, 700, chiftQuloq: true)!;
    final d = applyImpostDrop(blank, plan, spec: spec);
    expect((d.root as hisob.Split).chiftQuloq, isTrue);

    final plain = drop(blank, hisob.Axis.vertical, 500, 700);
    final p2 = planImpost(plain, spec, hisob.Axis.vertical, 1000, 700, chiftQuloq: true)!;
    final mixed = applyImpostDrop(plain, p2, spec: spec);
    final root = mixed.root as hisob.Split;
    expect(root.positionsMm, [500, 1000]);
    expect((root.isChift(0), root.isChift(1)), (false, true));
    expect(lineMarks(mixed, hisob.Axis.vertical), [0, 500, 1000, 1500]);
  });

  test('chift quloq tayoqchasi: bir juft chift quloq, orasi 1400; qatorda eski impostlar oddiy qoladi', () {
    final wide = hisob.FrameDesign(widthMm: 5400, heightMm: 2800, root: const hisob.Zone());
    const alu = hisob.SeriesSpec.aldoks;
    final p = planImpost(wide, alu, hisob.Axis.vertical, 2700, 1400, pair: true, chiftQuloq: true)!;
    expect(p.positionsMm, [2000, 3400]);
    final d = applyImpostDrop(wide, p, spec: alu);
    final placed = d.root as hisob.Split;
    expect(placed.positionsMm, [2000, 3400]);
    expect((placed.isChift(0), placed.isChift(1)), (true, true));

    final d0 = applyImpostDrop(wide, planImpost(wide, alu, hisob.Axis.vertical, 1000, 1400)!, spec: alu);
    final p1 = planImpost(d0, alu, hisob.Axis.vertical, 2700, 1400, pair: true, chiftQuloq: true)!;
    final d1 = applyImpostDrop(d0, p1, spec: alu);
    final root = d1.root as hisob.Split;
    expect(root.positionsMm, [1000, 2000, 3400]);
    expect([for (var i = 0; i < 3; i++) root.isChift(i)], [false, true, true]);

    final d2 = applyImpostDrop(d1, planImpost(d1, alu, hisob.Axis.vertical, 500, 1400)!, spec: alu);
    final r2 = d2.root as hisob.Split;
    expect(r2.positionsMm, [500, 1000, 2000, 3400]);
    expect([for (var i = 0; i < 4; i++) r2.isChift(i)], [false, false, true, true]);
  });

  group('juft tayoqcha', () {
    final vitrage = hisob.FrameDesign(widthMm: 5000, heightMm: 2800, root: const hisob.Zone());

    test('o\'rtaga qo\'yilsa: ikki impost barmoqning ikki yonida, orasi 1400', () {
      final plan = planImpost(vitrage, spec, hisob.Axis.vertical, 2500, 1400, pair: true)!;
      expect(plan.ok, isTrue);
      expect(plan.positionsMm, [1800, 3200]);
      expect(plan.segmentsMm, [1800, 1400, 1800]);
      final d = applyImpostDrop(vitrage, plan, spec: spec);
      final root = d.root as hisob.Split;
      expect(root.positionsMm, [1800, 3200]);
      expect(root.children.length, 3);
    });

    test('chetga yaqin qo\'yilsa ichkariga suriladi — oraliq baribir 1400', () {
      final left = planImpost(vitrage, spec, hisob.Axis.vertical, 200, 1400, pair: true)!;
      expect(left.positionsMm, [100, 1500]);
      final right = planImpost(vitrage, spec, hisob.Axis.vertical, 4900, 1400, pair: true)!;
      expect(right.positionsMm, [3500, 4900]);
    });

    test('tor bo\'limga ham tushadi: 1500 → 500/500/500, 1300 → 440/430/430', () {
      final plan = planImpost(blank, spec, hisob.Axis.vertical, 750, 700, pair: true)!; 
      expect(plan.ok, isTrue);
      expect(plan.segmentsMm, [500, 500, 500]);
      expect(() => applyImpostDrop(blank, plan, spec: spec), returnsNormally);

      const narrow = hisob.FrameDesign(widthMm: 1300, heightMm: 1400);
      final p = planImpost(narrow, spec, hisob.Axis.vertical, 650, 700, pair: true)!;
      expect(p.ok, isTrue);
      expect(p.segmentsMm, [440, 430, 430]);

      final split = drop(vitrage, hisob.Axis.vertical, 1300, 1400);
      final inSection = planImpost(split, spec, hisob.Axis.vertical, 600, 1400, pair: true)!;
      expect(inSection.ok, isTrue);
      expect((applyImpostDrop(split, inSection, spec: spec).root as hisob.Split).children.length, 4);
    });

    test('keng bo\'limda oraliq 1400 ligicha qoladi; chegarada (1600) ham', () {
      expect(pairGapFor(1600), 1400);
      expect(pairGapFor(1590), 530);
      expect(pairGapFor(5000), 1400);
    });

    test('chift quloq bilan: ikkala impost chift quloq', () {
      final plan = planImpost(vitrage, spec, hisob.Axis.vertical, 2500, 1400, pair: true, chiftQuloq: true)!;
      final d = applyImpostDrop(vitrage, plan, spec: spec);
      expect((d.root as hisob.Split).chiftQuloq, isTrue);
    });
  });

  test('yotiq tayoqcha chift quloq bo\'lmaydi — doim oddiy impost', () {
    final plan = planImpost(blank, spec, hisob.Axis.horizontal, 750, 500, chiftQuloq: true)!;
    expect(plan.chiftQuloq, isFalse);
    final d = applyImpostDrop(blank, plan, spec: spec);
    expect((d.root as hisob.Split).chiftQuloq, isFalse);
  });

  test('alyuminiy bo\'lmasa chift quloq yo\'q; material almashsa oddiy impostga qaytadi', () {
    expect(chiftQuloqAvailable(1), isTrue);
    expect(chiftQuloqAvailable(0), isFalse);
    final plan = planImpost(blank, spec, hisob.Axis.vertical, 600, 700, chiftQuloq: true)!;
    final d = withoutChiftQuloq(applyImpostDrop(blank, plan, spec: spec));
    expect((d.root as hisob.Split).chiftQuloq, isFalse);
    expect(identical(withoutChiftQuloq(blank), blank), isTrue);
  });

  test('ichki katakdagi yangi impost joyi to\'g\'ri (katak boshidan o\'lchanadi)', () {

    final d = drop(drop(drop(blank, hisob.Axis.vertical, 500, 700), hisob.Axis.horizontal, 1000, 400),
        hisob.Axis.vertical, 1200, 900);

    final right = (d.root as hisob.Split).children[1] as hisob.Split;
    final low = right.children[1] as hisob.Split;
    expect(low.axis, hisob.Axis.vertical);
    expect(low.positionsMm, [700]); 
    expect(lineMarks(d, hisob.Axis.vertical), [0, 500, 1200, 1500]);
  });
}
