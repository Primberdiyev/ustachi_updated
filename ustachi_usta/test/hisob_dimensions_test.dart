import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/uikit/registan_uikit.dart' as uikit;
import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_templates.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

void main() {

  const spec = hisob.SeriesSpec.akfaPlastic;
  const door = hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2800,
    root: hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [500], children: [
      hisob.Zone(),
      hisob.Split(axis: hisob.Axis.vertical, positionsMm: [600, 1400], children: [
        hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1500], children: [hisob.Zone(), hisob.Zone(hisob.Fill.panel)]),
        hisob.Wing(hisob.WingKind.door),
        hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1500], children: [hisob.Zone(), hisob.Zone(hisob.Fill.panel)]),
      ]),
    ]),
  );

  test('zanjir belgilari: bo\'y 500 | 1500 | 800, en 600 | 800 | 600', () {
    expect(lineMarks(door, hisob.Axis.horizontal), [0, 500, 2000, 2800]);
    expect(lineMarks(door, hisob.Axis.vertical), [0, 600, 1400, 2000]);
    expect(lineMarks(HisobKind.window.blankDesign(), hisob.Axis.horizontal), [0, 1400]);
  });

  test('framugani 400 qilish: chiziq siljiydi, yon oynalardagi 1500 impost joyida (2000 da) qoladi', () {
    final d = setSegment(door, hisob.Axis.horizontal, 0, 400, spec);
    expect(lineMarks(d, hisob.Axis.horizontal), [0, 400, 2000, 2800]);
    final lower = (d.root as hisob.Split).children[1] as hisob.Split;
    expect(((lower.children[0]) as hisob.Split).positionsMm, [1600]);
  });

  test('oxirgi bo\'lak (lambri) 700: uning ustidagi impost siljiydi, ikkala yon oynada ham', () {
    final d = setSegment(door, hisob.Axis.horizontal, 2, 700, spec);
    expect(lineMarks(d, hisob.Axis.horizontal), [0, 500, 2100, 2800]);
  });

  test('eshik eni 1000: o\'ngdagi impost siljiydi, rom o\'lchami o\'zgarmaydi', () {
    final d = setSegment(door, hisob.Axis.vertical, 1, 1000, spec);
    expect(lineMarks(d, hisob.Axis.vertical), [0, 600, 1600, 2000]);
    expect((d.widthMm, d.heightMm), (2000, 2800));
  });

  test('sig\'maydigan o\'lcham rad etiladi, sababi aytiladi', () {
    expect(
      () => setSegment(door, hisob.Axis.horizontal, 0, 1950, spec),
      throwsA(isA<hisob.DesignException>()),
    );
    expect(
      () => setSegment(HisobKind.window.blankDesign(), hisob.Axis.horizontal, 0, 700, spec),
      throwsA(isA<hisob.DesignException>()),
    );
  });

  const wide = hisob.FrameDesign(
    widthMm: 5000,
    heightMm: 1400,
    root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [714, 1428, 2142, 2856, 3570, 4284], children: [
      hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [700], children: [hisob.Zone(), hisob.Zone()]),
      hisob.Zone(),
      hisob.Zone(),
      hisob.Zone(),
      hisob.Zone(),
      hisob.Zone(),
      hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1000], children: [hisob.Zone(), hisob.Zone()]),
    ]),
  );

  test('chap va o\'ng chet zanjirlari alohida: chap 700|700, o\'ng 1000|400', () {
    expect(lineMarks(wide, hisob.Axis.horizontal, side: ChainSide.start), [0, 700, 1400]);
    expect(lineMarks(wide, hisob.Axis.horizontal, side: ChainSide.end), [0, 1000, 1400]);

    expect(lineMarks(door, hisob.Axis.horizontal, side: ChainSide.start), [0, 500, 2000, 2800]);
  });

  test('chapni o\'ngdek qilish: chapdagi impost 1000 ga, o\'ngdagi joyida', () {
    final d = setSegment(wide, hisob.Axis.horizontal, 0, 1000, spec, side: ChainSide.start);
    expect(lineMarks(d, hisob.Axis.horizontal, side: ChainSide.start), [0, 1000, 1400]);
    expect(lineMarks(d, hisob.Axis.horizontal, side: ChainSide.end), [0, 1000, 1400]);
    final o = setSegment(wide, hisob.Axis.horizontal, 1, 300, spec, side: ChainSide.end);
    expect(lineMarks(o, hisob.Axis.horizontal, side: ChainSide.start), [0, 700, 1400]);
    expect(lineMarks(o, hisob.Axis.horizontal, side: ChainSide.end), [0, 1100, 1400]);
  });

  test('chap chetda: framuga (butun eni) ostidagi yon oyna impostini surish framugani qo\'zg\'atmaydi', () {
    const d0 = hisob.FrameDesign(
      widthMm: 2000,
      heightMm: 2800,
      root: hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [500], children: [
        hisob.Zone(),
        hisob.Split(axis: hisob.Axis.vertical, positionsMm: [600, 1400], children: [
          hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1500], children: [hisob.Zone(), hisob.Zone()]),
          hisob.Wing(hisob.WingKind.door),
          hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1200], children: [hisob.Zone(), hisob.Zone()]),
        ]),
      ]),
    );
    expect(lineMarks(d0, hisob.Axis.horizontal, side: ChainSide.start), [0, 500, 2000, 2800]);
    expect(lineMarks(d0, hisob.Axis.horizontal, side: ChainSide.end), [0, 500, 1700, 2800]);
    final d = setSegment(d0, hisob.Axis.horizontal, 0, 400, spec, side: ChainSide.start);

    expect(lineMarks(d, hisob.Axis.horizontal, side: ChainSide.start), [0, 400, 2000, 2800]);
    expect(lineMarks(d, hisob.Axis.horizontal, side: ChainSide.end), [0, 400, 1700, 2800]);
  });

  test('hamma shablonda har bo\'lakni o\'zgartirsa bo\'ladi (5 % ga)', () {
    var edits = 0;
    for (final kind in HisobKind.values) {
      for (final g in templateGroupsFor(kind)) {
        for (final (n, d) in g.designs.indexed) {
          for (final axis in hisob.Axis.values) {
            final marks = lineMarks(d, axis);
            if (marks.length < 3) continue;
            for (var i = 0; i + 1 < marks.length; i++) {
              final len = marks[i + 1] - marks[i];

              final next = (len * 0.95).roundToDouble();
              if (next < minSegmentMm) continue;
              final out = setSegment(d, axis, i, next, spec);
              final after = lineMarks(out, axis);
              expect((after[i + 1] - after[i]).round(), next.round(), reason: '${g.title} #${n + 1} $axis $i');
              edits++;
            }
          }
        }
      }
    }
    expect(edits, greaterThan(100));
  });

  testWidgets('chizmadagi raqamni bosish — shu bo\'lak aytiladi', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final taps = <(hisob.Axis, int)>[];
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(
          theme: ThemeData(extensions: [
            uikit.OpenColors.light,
            uikit.OpenTypographies.fromColors(uikit.LightNeutralColor(), uikit.LightUncategorizedColor()),
          ]),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: FrameCanvas(design: door, spec: spec, onTapSegment: (a, i, _) => taps.add((a, i))),
            ),
          ),
        ),
      ),
    ));

    const band = 30.0;
    const availW = 400 - band * 2, availH = 600 - band * 2;
    final scale = [availW / 2000, availH / 2800].reduce((a, b) => a < b ? a : b);
    final ox = band + (availW - 2000 * scale) / 2;
    final oy = band + (availH - 2800 * scale) / 2;
    await tester.tapAt(Offset(ox + 2000 * scale + 12, oy + 250 * scale)); 
    await tester.tapAt(Offset(ox + 1000 * scale, oy + 2800 * scale + 12)); 
    expect(taps, [(hisob.Axis.horizontal, 0), (hisob.Axis.vertical, 1)]);
  });

  testWidgets('chap chetda o\'z zanjiri: chapdagi raqamni bosish — chap chet', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final taps = <(hisob.Axis, int, ChainSide?)>[];
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(
          theme: ThemeData(extensions: [
            uikit.OpenColors.light,
            uikit.OpenTypographies.fromColors(uikit.LightNeutralColor(), uikit.LightUncategorizedColor()),
          ]),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: FrameCanvas(design: wide, spec: spec, onTapSegment: (a, i, s) => taps.add((a, i, s))),
            ),
          ),
        ),
      ),
    ));

    const band = 30.0;
    const availW = 400 - band * 3, availH = 600 - band * 2;
    final scale = [availW / 5000, availH / 1400].reduce((a, b) => a < b ? a : b);
    final ox = band * 2 + (availW - 5000 * scale) / 2;
    final oy = band + (availH - 1400 * scale) / 2;
    await tester.tapAt(Offset(ox - 12, oy + 1050 * scale)); 
    await tester.tapAt(Offset(ox + 5000 * scale + 12, oy + 500 * scale)); 
    expect(taps, [
      (hisob.Axis.horizontal, 1, ChainSide.start),
      (hisob.Axis.horizontal, 0, ChainSide.end),
    ]);
  });
}
