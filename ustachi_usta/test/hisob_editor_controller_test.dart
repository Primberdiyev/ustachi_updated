
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_templates.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_controller.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

ItemEditorController _fresh([HisobKind kind = HisobKind.window]) => ItemEditorController(
      HisobItem(id: 'i1', kind: kind, design: kind.blankDesign()),
    );

void main() {

  group('eshikda polgacha tushgan qanot — eshik tavaqasi', () {
    hisob.Cell leaf() => const hisob.Split(
          axis: hisob.Axis.horizontal,
          positionsMm: [1200],
          children: [hisob.Zone(), hisob.Zone(hisob.Fill.lambriVertical)],
        );
    hisob.FrameDesign door() => hisob.FrameDesign(
          widthMm: 1200,
          heightMm: 2400,
          root: hisob.Split(axis: hisob.Axis.horizontal, positionsMm: const [400], children: [
            const hisob.Wing(hisob.WingKind.tilt),
            hisob.Split(axis: hisob.Axis.vertical, positionsMm: const [800], children: [
              hisob.Wing(hisob.WingKind.turn, leaf(), true, hisob.WingSide.right),
              hisob.Wing(hisob.WingKind.turn, leaf(), true, hisob.WingSide.left),
            ]),
          ]),
        );
    ItemEditorController open(HisobKind kind) => ItemEditorController(
          HisobItem(
            id: 'd',
            kind: kind,
            design: door(),
            settings: const ItemSettings(material: 1),
          ),
        );
    List<hisob.Wing> leaves(ItemEditorController c) =>
        [for (final x in ((c.design.root as hisob.Split).children[1] as hisob.Split).children) x as hisob.Wing];

    test('saqlangan eshik ochilganda: ikkala tavaqa eshik, ikkinchisi tutqichsiz; framuga — fortochka', () {
      final c = open(HisobKind.door);
      expect(leaves(c).map((w) => w.kind), [hisob.WingKind.door, hisob.WingKind.door]);
      expect(leaves(c).map((w) => w.hasHandle), [true, false]);
      expect(((c.design.root as hisob.Split).children[0] as hisob.Wing).kind, hisob.WingKind.tilt);
    });

    test('deraza buyumida o\'zgarmaydi — polgacha qanot deraza qanoti bo\'lib qoladi', () {
      expect(leaves(open(HisobKind.window)).map((w) => w.kind), [hisob.WingKind.turn, hisob.WingKind.turn]);
    });

    test('bo\'sh katakka "Oddiy ochiladigan" qo\'yilsa — eshik tavaqasi; polgacha tushmagan qanot — deraza', () {
      final c = ItemEditorController(
        const HisobItem(
          id: 'b',
          kind: HisobKind.door,
          design: hisob.FrameDesign(widthMm: 900, heightMm: 2100),
          settings: ItemSettings(material: 1),
        ),
      )
        ..select(const [])
        ..setWing(hisob.WingKind.turn);
      expect((c.design.root as hisob.Wing).kind, hisob.WingKind.door);

      final side = ItemEditorController(
        const HisobItem(
          id: 's',
          kind: HisobKind.door,
          design: hisob.FrameDesign(
            widthMm: 2000,
            heightMm: 2300,
            root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [800], children: [
              hisob.Wing(hisob.WingKind.door),
              hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [1500], children: [
                hisob.Wing(hisob.WingKind.turn),
                hisob.Zone(hisob.Fill.lambriVertical),
              ]),
            ]),
          ),
          settings: ItemSettings(material: 1),
        ),
      );
      final right = (side.design.root as hisob.Split).children[1] as hisob.Split;
      expect((right.children[0] as hisob.Wing).kind, hisob.WingKind.turn);
    });
  });

  group('arka va yotiq impost bir chiziqda', () {
    ItemEditorController open(hisob.FrameDesign d) => ItemEditorController(
          HisobItem(
            id: 'k',
            kind: HisobKind.window,
            design: d,
            settings: const ItemSettings(material: 1),
          ),
        );
    const withImpost = hisob.FrameDesign(
      widthMm: 1300,
      heightMm: 1800,
      root: hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [600], children: [hisob.Zone(), hisob.Zone()]),
    );

    test('impost bor, arka 619 kiritilsa — arka impost chizig\'iga (600) tushadi', () {
      final c = open(withImpost)..setArch(619);
      expect(c.design.archRiseMm, 600);

      c.setArch(400);
      expect(c.design.archRiseMm, 400);
    });

    test('arka bor, yotiq tayoqcha yaqiniga qo\'yilsa — aynan arka chizig\'iga tushadi', () {
      const arched = hisob.FrameDesign(widthMm: 1300, heightMm: 1800, archRiseMm: 619);
      final c = open(arched)..dropImpost(const ImpostTool(hisob.Axis.horizontal), 650, 600);
      expect(c.message, isNull);
      expect((c.design.root as hisob.Split).positionsMm, [619]);

      final far = open(arched)..dropImpost(const ImpostTool(hisob.Axis.horizontal), 650, 1200);
      expect((far.design.root as hisob.Split).positionsMm, [1200]);
    });

    test('arka chizig\'idagi impost surilsa — arka ham birga suriladi', () {
      final c = open(withImpost)..setArch(600);
      c.setSegment(hisob.Axis.horizontal, 0, 500);
      expect((c.design.root as hisob.Split).positionsMm, [500]);
      expect(c.design.archRiseMm, 500);
    });
  });

  group('teng bo\'lish', () {
    const uneven = hisob.FrameDesign(
      widthMm: 1500,
      heightMm: 1800,
      root: hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [500], children: [
        hisob.Zone(),
        hisob.Split(
          axis: hisob.Axis.vertical,
          positionsMm: [370, 1020],
          children: [hisob.Wing(hisob.WingKind.turn), hisob.Zone(), hisob.Zone()],
        ),
      ]),
    );
    ItemEditorController open() => ItemEditorController(
          const HisobItem(
            id: 'e',
            kind: HisobKind.window,
            design: uneven,
            settings: ItemSettings(material: 1),
          ),
        );
    hisob.Split lower(ItemEditorController c) => (c.design.root as hisob.Split).children[1] as hisob.Split;

    test('bo\'lim tanlanmagan: tik impostlar tenglashadi (500/500/500), framuga joyida', () {
      final c = open();
      expect(c.canEqualize, isTrue);
      c.equalize();
      expect(c.message, isNull);
      expect(lower(c).positionsMm, [500, 1000]);
      expect((c.design.root as hisob.Split).positionsMm, [500]); 
      expect(lower(c).children[0], isA<hisob.Wing>()); 
      c.undo();
      expect(lower(c).positionsMm, [370, 1020]);
    });

    test('bo\'lim tanlangan: faqat shu qator; framuga tanlansa — bo\'yi teng (900/900)', () {
      final c = open()..select([1, 1]);
      c.equalize();
      expect(lower(c).positionsMm, [500, 1000]);

      final t = open()..select([0]);
      t.equalize();
      expect((t.design.root as hisob.Split).positionsMm, [900]);
      expect(lower(t).positionsMm, [370, 1020]);
    });

    test('impost yo\'q — xabar, chizma o\'zgarmaydi', () {
      final c = _fresh();
      expect(c.canEqualize, isFalse);
      c.equalize();
      expect(c.message, isNotNull);
      expect(c.canUndo, isFalse);
    });
  });

  test('bo\'sh deraza — tanlov yo\'q, bekor qilinadigan narsa yo\'q', () {
    final c = _fresh();
    expect(c.selected, isNull);
    expect(c.canUndo, isFalse);
    expect(c.boxes.length, 1);
  });

  test('tanlash va bo\'lish: 3 teng bo\'lak', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 3);

    final split = c.design.root as hisob.Split;
    expect(split.children.length, 3);
    expect(c.canUndo, isTrue);

    expect(c.selected, isNotNull);
  });

  group('chift quloq doim juft', () {
    const vitrage = hisob.FrameDesign(
      widthMm: 5400,
      heightMm: 2800,
      root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [2000, 3400], children: [
        hisob.Zone(),
        hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [550], children: [
          hisob.Zone(),
          hisob.Split(axis: hisob.Axis.vertical, positionsMm: [700], children: [
            hisob.Wing(hisob.WingKind.door),
            hisob.Wing(hisob.WingKind.door, hisob.Zone(), false, hisob.WingSide.left),
          ]),
        ]),
        hisob.Zone(),
      ]),
    );
    ItemEditorController open() => ItemEditorController(
          const HisobItem(
            id: 'v',
            kind: HisobKind.window,
            design: vitrage,
            settings: ItemSettings(material: 1),
          ),
        );
    List<double> chift(ItemEditorController c) => [
          for (final _ in (c.design.root as hisob.Split).chiftImposts) c.design.heightMm,
        ];

    test('eshik tavaqasidan yoqilsa — eshikning IKKI yonidagi impost (tavaqalar orasidagi emas)', () {
      final c = open()..select([1, 1, 0]); 
      expect(c.selectedChiftQuloq, isFalse);
      c.setChiftQuloq(true);
      expect(c.selectedChiftQuloq, isTrue);
      final root = c.design.root as hisob.Split;
      expect(root.chiftImposts, {0, 1});

      final pieces = chift(c);
      expect(pieces.length, 2);
      expect(pieces[0], pieces[1]);
      final inner = ((root.children[1] as hisob.Split).children[1]) as hisob.Split;
      expect(inner.hasChift, isFalse);
    });

    test('o\'ng tavaqadan, framugadan yoki tavaqa ichidagi oynadan — o\'sha juftning o\'zi', () {
      for (final path in [
        [1, 1, 1],
        [1, 0],
        [1, 1, 0, 0],
      ]) {
        final c = open()
          ..select(path)
          ..setChiftQuloq(true);
        expect((c.design.root as hisob.Split).chiftImposts, {0, 1}, reason: '$path');
        expect(chift(c).length, 2, reason: '$path');
      }
    });

    test('balkon qanot: bir tavaqadan yoqilsa ikkalasi balkon, o\'chirilsa ikkalasi oddiy', () {
      List<bool> leaves(ItemEditorController c) {
        final door = (((c.design.root as hisob.Split).children[1] as hisob.Split).children[1]) as hisob.Split;
        return [for (final w in door.children) (w as hisob.Wing).balcony];
      }

      final c = open()..select([1, 1, 1]); 
      expect(c.selectedWingBalcony, isFalse);
      c.setWingBalcony(true);
      expect(leaves(c), [true, true]);

      c
        ..select([1, 1, 0, 0])
        ..setWingBalcony(false);
      expect(leaves(c), [false, false]);
    });

    test('balkon qanot yoqilsa oddiy ochiladigan tavaqalar ESHIK bo\'ladi, ikkinchisi passiv', () {
      const turnVitrage = hisob.FrameDesign(
        widthMm: 5400,
        heightMm: 2800,
        root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [2000, 3400], children: [
          hisob.Zone(),
          hisob.Split(axis: hisob.Axis.horizontal, positionsMm: [550], children: [
            hisob.Zone(),
            hisob.Split(axis: hisob.Axis.vertical, positionsMm: [700], children: [
              hisob.Wing(hisob.WingKind.turn),
              hisob.Wing(hisob.WingKind.turn, hisob.Zone(), true, hisob.WingSide.left),
            ]),
          ]),
          hisob.Zone(),
        ]),
      );
      final c = ItemEditorController(
        const HisobItem(
          id: 't',
          kind: HisobKind.window,
          design: turnVitrage,
          settings: ItemSettings(material: 1),
        ),
      )
        ..select([1, 1, 0])
        ..setWingBalcony(true);
      final door = (((c.design.root as hisob.Split).children[1] as hisob.Split).children[1]) as hisob.Split;
      final leaves = [for (final w in door.children) w as hisob.Wing];
      expect(leaves.map((w) => w.kind), everyElement(hisob.WingKind.door));
      expect(leaves.map((w) => w.balcony), everyElement(isTrue));
      expect(leaves.map((w) => w.hasHandle), [true, false]);
    });

    test('o\'chirilsa ikkalasi birga o\'chadi', () {
      final c = open()
        ..select([1, 1, 0])
        ..setChiftQuloq(true)
        ..setChiftQuloq(false);
      expect(chift(c), isEmpty);
    });

    test('ikki yonida impost bo\'lmasa (chetdagi bo\'lim) — kalit yo\'q', () {
      final c = open()..select([0]);
      expect(c.selectedChiftQuloq, isNull);
    });

    ItemEditorController blank() => ItemEditorController(
          const HisobItem(
            id: 'b',
            kind: HisobKind.window,
            design: hisob.FrameDesign(widthMm: 5400, heightMm: 2800),
            settings: ItemSettings(material: 1),
          ),
        );

    test('impostlar BITTA-BITTA tayoqcha bilan qo\'yilgan: o\'rtadagi bo\'limdan yoqilsa — ikkalasi chift quloq', () {
      final c = blank()
        ..dropImpost(const ImpostTool(hisob.Axis.vertical), 2000, 1400)
        ..dropImpost(const ImpostTool(hisob.Axis.vertical), 3400, 1400);
      expect(chift(c), isEmpty, reason: 'tayoqcha o\'zi chift quloq qo\'ymaydi');
      c
        ..select([1])
        ..setChiftQuloq(true);
      expect(chift(c).length, 2);
      c.setChiftQuloq(false);
      expect(chift(c), isEmpty);
    });

    test('impostlar JUFT tayoqcha bilan qo\'yilgan: xuddi shunday', () {
      final c = blank()..dropImpost(const ImpostTool(hisob.Axis.vertical, pair: true), 2700, 1400);
      expect(chift(c), isEmpty);
      c
        ..select([1])
        ..setChiftQuloq(true);
      expect(chift(c).length, 2);
    });
  });

  test('eshikda ikki tomonlama qanot qo\'yilmaydi; derazada qo\'yiladi', () {
    final door = _fresh(HisobKind.door)..select([]);
    expect(door.wingKindAllowed(hisob.WingKind.tiltTurn), isFalse);
    expect(door.wingKindAllowed(hisob.WingKind.door), isTrue);
    final before = door.design.root;
    door.setWing(hisob.WingKind.tiltTurn);
    expect(identical(door.design.root, before), isTrue);
    expect(door.message, contains('faqat derazada'));

    final window = _fresh()
      ..select([])
      ..setWing(hisob.WingKind.tiltTurn);
    expect((window.design.root as hisob.Wing).kind, hisob.WingKind.tiltTurn);
  });

  test('eshik shablonlarida ikki tomonlama qanot yo\'q', () {
    bool has(hisob.Cell c) => switch (c) {
          hisob.Wing(:final kind, :final content) => kind == hisob.WingKind.tiltTurn || has(content),
          hisob.Split(:final children) => children.any(has),
          hisob.Zone() => false,
        };
    for (final g in templateGroupsFor(HisobKind.door)) {
      for (final (n, d) in g.designs.indexed) {
        expect(has(d.root), isFalse, reason: '${g.title} #${n + 1}');
      }
    }
  });

  test('ikki qanot yonma-yon: tutqichlar o\'rtaga qaraydi, petlyalar chetda', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([0])
      ..setWing(hisob.WingKind.turn)
      ..select([1])
      ..setWing(hisob.WingKind.turn);
    final root = c.design.root as hisob.Split;
    expect((root.children[0] as hisob.Wing).handleSide, hisob.WingSide.right);
    expect((root.children[1] as hisob.Wing).handleSide, hisob.WingSide.left);
  });

  test('juft eshik: avval o\'ng tavaqa qo\'yilsa ham tutqichlar o\'rtada', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([1])
      ..setWing(hisob.WingKind.door)
      ..select([0])
      ..setWing(hisob.WingKind.door);
    final root = c.design.root as hisob.Split;
    expect((root.children[0] as hisob.Wing).handleSide, hisob.WingSide.right);
    expect((root.children[1] as hisob.Wing).handleSide, hisob.WingSide.left);
  });

  test('qanot qo\'yish va turini almashtirish', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([0])
      ..setWing(hisob.WingKind.tiltTurn);
    expect(((c.design.root as hisob.Split).children[0] as hisob.Wing).kind, hisob.WingKind.tiltTurn);

    c.setWing(hisob.WingKind.tilt);
    expect(((c.design.root as hisob.Split).children[0] as hisob.Wing).kind, hisob.WingKind.tilt);

    c.setWing(null);
    expect((c.design.root as hisob.Split).children[0], isA<hisob.Zone>());
  });

  test('bekor qilish har bir tahrirni ketma-ket qaytaradi', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([1])
      ..setFill(hisob.Fill.panel);
    expect(((c.design.root as hisob.Split).children[1] as hisob.Zone).fill, hisob.Fill.panel);

    c.undo();
    expect(((c.design.root as hisob.Split).children[1] as hisob.Zone).fill, hisob.Fill.glass);
    c.undo();
    expect(c.design.root, isA<hisob.Zone>());
    expect(c.canUndo, isFalse);
  });

  test('rad etilgan tahrir chizmani o\'zgartirmaydi va sababini aytadi', () {
    final c = _fresh()
      ..select([])
      ..setWing(hisob.WingKind.turn)
      ..select([0])
      ..setWing(hisob.WingKind.turn); 

    expect(c.message, isNotNull);
    expect(c.design.root, isA<hisob.Wing>());
    expect(c.selectedInsideWing, isTrue);
    expect(c.canUndo, isTrue); 
    c.undo();
    expect(c.canUndo, isFalse);
  });

  test('impostni olib tashlash: tanlov otaga o\'tadi', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 3)
      ..select([2]);
    expect(c.selectedHasSplitParent, isTrue);

    c.removeSplit();

    expect(c.design.root, isA<hisob.Zone>());
    expect(c.selected, isEmpty);
  });

  test('bo\'lim o\'lchamini o\'zgartirish', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([0])
      ..resizeSelected(600);
    expect((c.design.root as hisob.Split).positionsMm, [600]);
    expect(c.selectedBox!.region.width, 600);
  });

  test('rom o\'lchami va kamar', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..resizeFrame(2000, 1400)
      ..setArch(300);
    expect((c.design.root as hisob.Split).positionsMm, [1000]);
    expect(c.design.archRiseMm, 300);
    expect(c.design.widthMm, 2000);
  });

  test('eshik: tavaqa tanlanadi, tutqichsiz qilinadi', () {
    final c = _fresh(HisobKind.door)
      ..select([])
      ..setHandle(false);
    expect((c.design.root as hisob.Wing).hasHandle, isFalse);
    expect(c.selectedCell, isA<hisob.Wing>());
  });

  test('sozlama almashganda chizma yangi seriyaga sig\'masa rad etiladi', () {
    final c = _fresh();
    c.resizeFrame(60, 60);
    expect(c.message, isNotNull);
    expect(c.design.widthMm, 1500);
  });

  test('tinglovchilar har o\'zgarishda xabardor qilinadi', () {
    final c = _fresh();
    var calls = 0;
    c.addListener(() => calls++);
    c.select([]);
    c.split(hisob.Axis.horizontal, 2);
    c.undo();
    expect(calls, 3);
  });

  test('sozlamani o\'zgartirish', () {
    final c = _fresh();
    expect(c.updateSettings(c.settings.copyWith(qty: 3, colorName: 'Antrazit', colorArgb: 0xFF383E42)), isTrue);
    expect((c.settings.qty, c.settings.colorArgb), (3, 0xFF383E42));
    expect(c.updateSettings(c.settings.copyWith(clearColor: true)), isTrue);
    expect(c.settings.isColored, isFalse);
  });

  test('qanot ichidagi oynadan qanotning o\'ziga o\'tish yo\'li', () {
    final c = _fresh()
      ..select([])
      ..split(hisob.Axis.vertical, 2)
      ..select([1])
      ..setWing(hisob.WingKind.turn)
      ..select([1, 0]); 

    expect(c.selectedInsideWing, isTrue);
    expect(c.enclosingWing, [1]);

    c.select(c.enclosingWing);
    expect(c.selectedCell, isA<hisob.Wing>());
    expect(c.enclosingWing, isNull); 
  });

  test('qanotsiz bo\'limda enclosingWing yo\'q', () {
    final c = _fresh()..select([]);
    expect(c.enclosingWing, isNull);
  });
}
