import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/hisob/presentation/hisob_template_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_templates.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

void main() {
  Iterable<hisob.Cell> walk(hisob.Cell c) sync* {
    yield c;
    switch (c) {
      case hisob.Split(:final children):
        for (final x in children) {
          yield* walk(x);
        }
      case hisob.Wing(:final content):
        yield* walk(content);
      case hisob.Zone():
        break;
    }
  }

  List<hisob.FrameDesign> allOf(HisobKind kind) => [for (final g in templateGroupsFor(kind)) ...g.designs];
  List<hisob.FrameDesign> groupOf(HisobKind kind, String title) =>
      templateGroupsFor(kind).firstWhere((g) => g.title == title).designs;

  test('shablonlar soni va guruhlari: deraza 41, eshik 40 — hech biri tushib qolmagan', () {
    final window = templateGroupsFor(HisobKind.window);
    final door = templateGroupsFor(HisobKind.door);
    expect({for (final g in window) g.title: g.designs.length},
        {'Kichik deraza': 7, 'O\'rta deraza': 8, 'Vitraj': 10, 'Kamarli (arka)': 16});
    expect({for (final g in door) g.title: g.designs.length}, {
      'Bir tavaqali eshik': 6,
      'Juft eshik': 8,
      'Yon oynali eshik': 6,
      'Vitrajli juft eshik': 14,
      'G va T shakl': 6,
    });
    expect(window.map((g) => g.title), windowGroupTitles);
    expect(door.map((g) => g.title), doorGroupTitles);
  });

  test('guruh qoidasi: tavaqalar soni va yon oyna; framuga yon oyna emas', () {
    const door = hisob.Wing(hisob.WingKind.door);
    hisob.FrameDesign d(hisob.Cell root, {double w = 1200}) =>
        hisob.FrameDesign(widthMm: w, heightMm: 2300, root: root);
    hisob.Split v(List<double> at, List<hisob.Cell> c) =>
        hisob.Split(axis: hisob.Axis.vertical, positionsMm: at, children: c);
    hisob.Split h(List<double> at, List<hisob.Cell> c) =>
        hisob.Split(axis: hisob.Axis.horizontal, positionsMm: at, children: c);
    expect(doorGroupOf(d(door)), 'Bir tavaqali eshik');
    expect(doorGroupOf(d(h([300], [const hisob.Zone(), door]))), 'Bir tavaqali eshik');
    expect(doorGroupOf(d(h([300], [const hisob.Zone(), v([600], [door, door])]))), 'Juft eshik');
    expect(doorGroupOf(d(v([600], [door, const hisob.Zone()]))), 'Yon oynali eshik');
    expect(doorGroupOf(d(v([400, 800], [const hisob.Zone(), door, door]))), 'Vitrajli juft eshik');
    expect(windowGroupOf(d(const hisob.Zone(), w: 1200)), 'Kichik deraza');
    expect(windowGroupOf(d(const hisob.Zone(), w: 1500)), 'O\'rta deraza');
    expect(windowGroupOf(d(const hisob.Zone(), w: 2000)), 'Vitraj');
  });

  for (final kind in HisobKind.values) {
    test('${kind.label}: har shablon plastik va alyuminiyda chiziladi', () {
      for (final group in templateGroupsFor(kind)) {
        for (final (i, d) in group.designs.indexed) {
          for (final spec in [hisob.SeriesSpec.akfaPlastic, hisob.SeriesSpec.aldoks]) {
            expect(hisob.designError(d, spec), isNull,
                reason: '${group.title} #${i + 1} (${d.widthMm}×${d.heightMm})');
          }
          expect(d.widthMm, greaterThan(0));
          expect(d.heightMm, greaterThan(0));
        }
      }
    });
  }

  test('eshik shablonlarida eshik tavaqasi bor', () {
    final designs = allOf(HisobKind.door);
    final withDoor = designs.where((d) => walk(d.root).any((c) => c is hisob.Wing && c.kind == hisob.WingKind.door));

    expect(withDoor.length, designs.length, reason: 'hamma eshik shablonida eshik tavaqasi bor');
  });

  test('eshik tavaqasi ichidagi oyna va lambri — BITTA ochilish (usta 2026-09-30)', () {

    final problems = <String>[];
    for (final (n, d) in allOf(HisobKind.door).indexed) {
      final doors = <Rect>[];
      void walk(hisob.Cell c, Rect r) {
        switch (c) {
          case hisob.Wing(:final kind, :final content):
            if (kind == hisob.WingKind.door) {
              doors.add(r);
            } else {
              walk(content, r);
            }
          case hisob.Split(:final axis, :final positionsMm, :final children):
            final v = axis == hisob.Axis.vertical;
            final start = v ? r.left : r.top;
            final edges = [start, for (final p in positionsMm) start + p, v ? r.right : r.bottom];
            for (var i = 0; i < children.length; i++) {
              walk(children[i], v ? Rect.fromLTRB(edges[i], r.top, edges[i + 1], r.bottom)
                  : Rect.fromLTRB(r.left, edges[i], r.right, edges[i + 1]));
            }
          case hisob.Zone():
            break;
        }
      }

      walk(d.root, Rect.fromLTWH(0, 0, d.widthMm, d.heightMm));
      for (final a in doors) {
        for (final b in doors) {
          final stacked = (a.bottom - b.top).abs() < 0.5 && a.left < b.right - 0.5 && b.left < a.right - 0.5;
          if (stacked) problems.add('#${n + 1}');
        }
      }
    }
    expect(problems, isEmpty);
  });

  test('1200×2000 juft eshik: ikki tavaqa, har biri ichida oyna tepada, lambri pastda', () {
    final match = allOf(HisobKind.door).where((d) => d.widthMm == 1200 && d.heightMm == 2000);
    expect(match, isNotEmpty);
    for (final d in match) {
      Iterable<hisob.Wing> doorsOf(hisob.Cell c) sync* {
        switch (c) {
          case hisob.Wing(:final kind) when kind == hisob.WingKind.door:
            yield c;
          case hisob.Split(:final children):
            for (final x in children) {
              yield* doorsOf(x);
            }
          default:
            break;
        }
      }

      for (final w in doorsOf(d.root)) {

        if (w.content is hisob.Split) {
          expect((w.content as hisob.Split).axis, hisob.Axis.horizontal);
          expect(walk(w.content).whereType<hisob.Wing>(), isEmpty);
        }
      }
    }
  });

  test('juft tavaqa: petlyalar chetda, tutqich o\'rtada (usta 2026-09-30)', () {
    var pairs = 0;
    void check(hisob.Cell c) {
      switch (c) {
        case hisob.Split(:final axis, :final children):
          if (axis == hisob.Axis.vertical) {
            for (var i = 0; i + 1 < children.length; i++) {
              final a = children[i];
              final b = children[i + 1];
              if (a is hisob.Wing && b is hisob.Wing) {
                pairs++;
                expect(a.handleSide, hisob.WingSide.right);
                expect(b.handleSide, hisob.WingSide.left);
              }
            }
          }
          children.forEach(check);
        case hisob.Wing(:final content):
          check(content);
        case hisob.Zone():
          break;
      }
    }

    for (final g in [...templateGroupsFor(HisobKind.door), ...templateGroupsFor(HisobKind.window)]) {
      for (final d in g.designs) {
        check(d.root);
      }
    }
    expect(pairs, greaterThan(0), reason: 'juft eshik shablonlari bor');
  });

  test('kesikli eshiklar: 6 ta, har birida kesik va eshik', () {
    final designs = groupOf(HisobKind.door, 'G va T shakl');
    expect(designs.length, 6);
    for (final d in designs) {
      expect(walk(d.root).any((c) => c is hisob.Zone && c.fill == hisob.Fill.cutout), isTrue);
      expect(walk(d.root).any((c) => c is hisob.Wing && c.kind == hisob.WingKind.door), isTrue);
      expect(hisob.designError(d, hisob.SeriesSpec.akfaPlastic), isNull);
      expect(hisob.designError(d, hisob.SeriesSpec.aldoks), isNull);
    }
  });

  test('arka shablonlarida kamar balandligi bor', () {
    final arch = groupOf(HisobKind.window, 'Kamarli (arka)');
    expect(arch.every((d) => d.archRiseMm > 0 && d.archRiseMm < d.heightMm), isTrue);
  });

  for (final kind in HisobKind.values) {
    testWidgets('${kind.label}: shablonlar sahifasi oxirigacha xatosiz chiziladi', (tester) async {
      tester.view.physicalSize = const Size(430 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (_, __) => TranslationProvider(
          child: MaterialApp(home: HisobTemplatePage(kind: kind, spec: hisob.SeriesSpec.akfaPlastic)),
        ),
      ));
      await tester.pumpAndSettle();

      for (var i = 0; i < 40; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  test('o\'girish: 2000×2300 eshik — tik 600/1400, yon bo\'limlarda 1500 da yotiq impost', () {
    const spec = FramePreviewSpec(
      aspectRatio: 2000 / 2300,
      widthMm: 2000,
      heightMm: 2300,
      lines: [
        FrameLine(600 / 2000, 0, 600 / 2000, 1),
        FrameLine(1400 / 2000, 0, 1400 / 2000, 1),
        FrameLine(0, 1500 / 2300, 600 / 2000, 1500 / 2300),
        FrameLine(1400 / 2000, 1500 / 2300, 1, 1500 / 2300),
      ],
    );
    final d = designFromSpec(spec, HisobKind.door);
    final root = d.root as hisob.Split;
    expect(root.axis, hisob.Axis.vertical);
    expect(root.positionsMm, [600, 1400]);
    expect((root.children[0] as hisob.Split).positionsMm, [1500]);
    expect(root.children[1], isA<hisob.Zone>());

    expect((root.children[2] as hisob.Split).positionsMm, [1500]);
  });
}
