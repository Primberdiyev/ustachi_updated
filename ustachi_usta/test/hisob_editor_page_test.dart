
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_page.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

HisobItem? _saved;

final _templates = <(HisobKind, hisob.FrameDesign)>[];

Future<void> _open(
  WidgetTester tester, {
  HisobKind kind = HisobKind.window,
  bool isNew = true,
  ItemSettings settings = const ItemSettings(),
  double widthPx = 1284,
}) async {
  tester.view.physicalSize = Size(widthPx, 2778);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  _saved = null;
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  _saved = await ItemEditorPage.open(
                    context,
                    item: HisobItem(
                      id: 'i1',
                      kind: kind,
                      design: kind.blankDesign(),
                      settings: settings,
                    ),
                    isNew: isNew,
                    onSaveTemplate: (k, d) => _templates.add((k, d)),
                  );
                },
                child: const Text('ochish'),
              ),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('ochish'));
  await tester.pumpAndSettle();
}

Future<void> _tapCanvas(WidgetTester tester, double fx, double fy) async {
  final finder = find.byType(FrameCanvas);
  final origin = tester.getTopLeft(finder);
  final size = tester.getSize(finder);
  await tester.tapAt(origin + Offset(size.width * fx, size.height * fy));
  await tester.pumpAndSettle();
}

Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(InkWell, label).first;
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

bool c0(WidgetTester tester) {
  final chip = tester.widget<ChizmaChip>(find.widgetWithText(ChizmaChip, 'PVH lambri'));
  return chip.selected;
}

Future<void> _dragStick(WidgetTester tester, String label, double fx, double fy) async {
  if (find.text(label).evaluate().isEmpty) {
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();
  }
  final canvas = find.byType(FrameCanvas);
  final target = tester.getTopLeft(canvas) + Offset(tester.getSize(canvas).width * fx, tester.getSize(canvas).height * fy);
  final gesture = await tester.startGesture(tester.getCenter(find.text(label)));
  await tester.pump();
  await gesture.moveTo(target + const Offset(0, impostDragLift - 40));
  await tester.pump();
  await gesture.moveTo(target + const Offset(0, impostDragLift));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

Offset _heightLabel(WidgetTester tester, double widthMm, double heightMm) {
  final finder = find.byType(FrameCanvas);
  final origin = tester.getTopLeft(finder);
  final size = tester.getSize(finder);
  const band = 30.0;
  final availW = size.width - band - band;
  final availH = size.height - band - 4;
  final scale = [availW / widthMm, availH / heightMm].reduce((a, b) => a < b ? a : b);
  final drawW = widthMm * scale;
  final drawH = heightMm * scale;
  final originX = band + (availW - drawW) / 2;
  final originY = band + (availH - drawH) / 2;
  return origin + Offset(originX - 12, originY + drawH / 2);
}

void main() {

  testWidgets('eshik: bo\'yi yozuvini bosib o\'lchamni o\'zgartirsa bo\'ladi', (tester) async {
    await _open(tester, kind: HisobKind.door);
    await tester.tapAt(_heightLabel(tester, 900, 2100));
    await tester.pumpAndSettle();
    expect(find.text('Rom bo\'yi'), findsOneWidget);
  });

  testWidgets('ochilganda: bo\'sh chizma va sozlamalar ko\'rinadi, narx va detal yo\'q', (tester) async {
    await _open(tester);

    expect(find.byType(FrameCanvas), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    expect(find.text('Plastik'), findsOneWidget);
    expect(find.text('Rang'), findsOneWidget);
    expect(find.text('Soni'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Saqlash'), findsOneWidget);
    for (final gone in ['Brend', 'Seriya', 'Oyna', 'Tokcha', 'Detallar']) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
    expect(find.textContaining('so\'m'), findsNothing);
  });

  testWidgets('rang: tayyor ro\'yxatdan tanlanadi va chizma bilan saqlanadi', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Rang'));
    await tester.pumpAndSettle();
    expect(find.text('Profil rangi'), findsOneWidget);
    await tester.tap(find.text('Antrazit'));
    await tester.pumpAndSettle();
    expect(find.text('Antrazit'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(_saved!.settings.colorName, 'Antrazit');
    expect(_saved!.settings.colorArgb, 0xFF383E42);
  });

  testWidgets('bo\'limni bosish: panel almashadi (sozlamalar → bo\'lim)', (tester) async {
    await _open(tester);
    expect(find.text('TO\'LDIRMA'), findsNothing);

    await _tapCanvas(tester, .5, .55);

    expect(find.text('Teng bo\'lish'), findsNothing, reason: 'usta talabi bilan olib tashlangan');
    expect(find.text('TO\'LDIRMA'), findsOneWidget);
    expect(find.text('QANOT'), findsOneWidget);
    expect(find.text('Material'), findsNothing);

    await tester.tap(find.text('Yopish'));
    await tester.pumpAndSettle();
    expect(find.text('Material'), findsOneWidget);
  });

  testWidgets('tayoqcha: "Bo\'lish" → tik tayoqchani o\'rtaga surish → impost', (tester) async {
    await _open(tester);
    expect(find.text('Tik'), findsNothing, reason: 'tayoqchalar tugma bosilgandagina chiqadi');
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();
    expect(find.text('Tik'), findsOneWidget);
    expect(find.text('Yotiq'), findsOneWidget);
    expect(find.text('Juft'), findsOneWidget);

    final canvas = find.byType(FrameCanvas);
    final target = tester.getTopLeft(canvas) + Offset(tester.getSize(canvas).width * .5, tester.getSize(canvas).height * .5);
    final start = tester.getCenter(find.text('Tik'));
    final gesture = await tester.startGesture(start);
    await tester.pump();

    await gesture.moveTo(target + const Offset(0, impostDragLift) - const Offset(0, 40));
    await tester.pump();
    await gesture.moveTo(target + const Offset(0, impostDragLift));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    final root = _saved!.design.root as hisob.Split;
    expect(root.axis, hisob.Axis.vertical);
    expect(root.positionsMm.single, closeTo(750, 60));
  });

  testWidgets('bo\'lish, chap bo\'limga qanot qo\'yish va saqlash', (tester) async {
    await _open(tester);
    await _dragStick(tester, 'Tik', .5, .5);

    await _tapCanvas(tester, .38, .55);
    await _tapChip(tester, 'Ikki tomonlama');

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final item = _saved!;
    final split = item.design.root as hisob.Split;
    expect(split.children.length, 2);
    expect((split.children[0] as hisob.Wing).kind, hisob.WingKind.tiltTurn);
    expect(split.children[1], isA<hisob.Zone>());
  });

  testWidgets('qanot ichidagi bo\'limga qanot qo\'yib bo\'lmaydi — variant ko\'rinmaydi', (tester) async {
    await _open(tester);
    await _tapCanvas(tester, .5, .55);
    await _tapChip(tester, 'Oddiy ochiladigan');

    await _tapCanvas(tester, .5, .55);

    expect(find.text('Oddiy ochiladigan'), findsNothing);
    expect(find.text('TO\'LDIRMA'), findsOneWidget);
  });

  testWidgets('qanot ichidagi oyna tanlansa — "Qanotni tahrirlash" qanotga o\'tkazadi', (tester) async {
    await _open(tester);
    await _tapCanvas(tester, .5, .55);
    await _tapChip(tester, 'Ikki tomonlama');

    await _tapCanvas(tester, .5, .55);
    expect(find.text('Ikki tomonlama'), findsNothing);
    await tester.tap(find.text('Qanotni tahrirlash'));
    await tester.pumpAndSettle();

    expect(find.text('Ikki tomonlama'), findsNWidgets(2)); 
    expect(find.text('Oddiy ochiladigan'), findsOneWidget);
    expect(find.text('Qanotni tahrirlash'), findsNothing);
  });

  testWidgets('bekor qilish tugmasi tahrirdan keyin yoqiladi', (tester) async {
    await _open(tester);
    IconButton undo() => tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.undo_rounded));
    expect(undo().onPressed, isNull);

    await _dragStick(tester, 'Tik', .5, .5);
    expect(undo().onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.undo_rounded));
    await tester.pumpAndSettle();
    expect(undo().onPressed, isNull);
  });

  testWidgets('material almashtirish oynasi: termo — Tez kunda', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Material'));
    await tester.pumpAndSettle();

    expect(find.text('Alyuminiy'), findsOneWidget);
    expect(find.text('Termo'), findsOneWidget);
    expect(find.text('Tez kunda'), findsOneWidget);
  });

  testWidgets('alyuminiyga o\'tish: material almashadi', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alyuminiy'));
    await tester.pumpAndSettle();

    expect(find.text('Alyuminiy'), findsOneWidget);
    expect(find.text('Plastik'), findsNothing);
  });

  testWidgets('yangi buyum saqlanmasdan chiqilsa — tasdiq so\'raydi', (tester) async {
    await _open(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Saqlanmagan o\'zgarishlar'), findsOneWidget);

    await tester.tap(find.text('Qolish'));
    await tester.pumpAndSettle();
    expect(find.byType(FrameCanvas), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chiqish'));
    await tester.pumpAndSettle();
    expect(find.byType(FrameCanvas), findsNothing);
    expect(_saved, isNull);
  });

  Future<void> tapSwitch(WidgetTester tester, String title) async {
    final tile = find.widgetWithText(SwitchListTile, title);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('eshik: tavaqani bosib "Balkon qanot" yoqiladi va chizma bilan saqlanadi', (tester) async {
    await _open(tester, kind: HisobKind.door, settings: const ItemSettings(material: 1));
    await _tapCanvas(tester, .5, .5);
    await tapSwitch(tester, 'Balkon qanot');
    expect(find.text('Balkon kosa'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect((_saved!.design.root as hisob.Wing).balcony, isTrue);
  });

  testWidgets('plastik eshik: "Balkon qanot" doim yoqilgan, o\'chmaydi', (tester) async {
    await _open(tester, kind: HisobKind.door);
    await _tapCanvas(tester, .5, .5);
    final tile = find.widgetWithText(SwitchListTile, 'Balkon qanot');
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
    await tapSwitch(tester, 'Balkon qanot');
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
  });

  testWidgets('impost yonidagi bo\'lim: "Balkon o\'rta" kaliti; qanotsiz bo\'limda "Balkon qanot" yo\'q', (tester) async {
    await _open(tester);
    await _dragStick(tester, 'Tik', .5, .5);
    await _tapCanvas(tester, .38, .55);
    expect(find.widgetWithText(SwitchListTile, 'Balkon qanot'), findsNothing);
    await tapSwitch(tester, 'Balkon o\'rta');
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect((_saved!.design.root as hisob.Split).balcony, isTrue);
  });

  testWidgets('tor ekranda "Shablondek saqlash" yozuvi sig\'adi (xatosiz chiziladi)', (tester) async {
    await _open(tester, kind: HisobKind.door, widthPx: 1080);
    expect(tester.takeException(), isNull);
    expect(find.text('Shablondek\nsaqlash'), findsOneWidget);
    expect(find.byTooltip('Bekor qilish'), findsOneWidget);
  });

  testWidgets('"Shablondek saqlash": chizilgan rom shablon bo\'lib saqlanadi', (tester) async {
    _templates.clear();
    await _open(tester);
    await _dragStick(tester, 'Tik', .5, .5);

    expect(find.text('Shablondek\nsaqlash'), findsOneWidget);
    await tester.tap(find.byTooltip('Shablondek saqlash'));
    await tester.pump();
    expect(find.text('Shablonlaringizga saqlandi'), findsOneWidget);
    expect(_templates, hasLength(1));
    final (kind, design) = _templates.single;
    expect(kind, HisobKind.window);
    expect(design.root, isA<hisob.Split>());
  });

  for (final kind in HisobKind.values) {
    testWidgets('${kind.label}: "Arka" tugmasi yoysimon tepa qo\'yadi va hisoblanadi', (tester) async {
      await _open(tester, kind: kind);
      await tester.tap(find.text('Arka'));
      await tester.pumpAndSettle();

      final half = kind == HisobKind.window ? 700 : 450;
      expect(find.widgetWithText(TextField, '$half'), findsOneWidget);
      await tester.tap(find.text('Tayyor'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hisoblanmaydi'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
      await tester.pumpAndSettle();
      expect(_saved!.design.archRiseMm, half);
    });
  }

  testWidgets('eshik: qanot turlari ichida "Ikki tomonlama" yo\'q; derazada bor', (tester) async {
    await _open(tester, kind: HisobKind.door);
    await _tapCanvas(tester, .5, .5);

    await tester.tap(find.text('Qanotni tahrirlash'));
    await tester.pumpAndSettle();
    expect(find.text('Oddiy ochiladigan'), findsOneWidget);
    expect(find.text('Ikki tomonlama'), findsNothing);
  });

  testWidgets('deraza: qanot turlari ichida "Ikki tomonlama" bor', (tester) async {
    await _open(tester);
    await _tapCanvas(tester, .5, .55);
    expect(find.text('Ikki tomonlama'), findsOneWidget);
  });

  testWidgets('tayoqchalar: plastikda Chift quloq tayoqchasi yo\'q, alyuminiyda bor', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();
    expect(find.text('Juft'), findsOneWidget);
    expect(find.text('Chift quloq'), findsNothing);
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alyuminiy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();
    expect(find.text('Chift quloq'), findsOneWidget);
  });

  testWidgets('tayoqchalar paneli: "Balkon o\'rta" tanlansa tayoqcha balkon impost qo\'yadi', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Bo\'lish'));
    await tester.pumpAndSettle();
    expect(find.text('Oddiy impost'), findsOneWidget);
    await tester.tap(find.text('Balkon o\'rta'));
    await tester.pumpAndSettle();
    await _dragStick(tester, 'Yotiq', .5, .5);
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    final root = _saved!.design.root as hisob.Split;
    expect((root.axis, root.balcony, root.chiftQuloq), (hisob.Axis.horizontal, true, false));
  });
}
