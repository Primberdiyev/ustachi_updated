import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/door_width_advice.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_generator.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_rom_design.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';

void main() {
  bool warns(int width, {ProposalShape shape = ProposalShape.eshik}) =>
      proposalIsWideSingleDoor(shape: shape, widthMm: width);

  test('96 sm eshik — ogohlantiriladi', () {
    expect(warns(960), isTrue);
  });

  test('chegara: 90 sm gacha yo\'q, 90,1 sm dan bor', () {
    expect(warns(900), isFalse);
    expect(warns(901), isTrue);
  });

  test('ikki qismli eshik chegarasidan boshlab ogohlantirish yo\'q', () {

    expect(proposalSingleLeafDoorUpToMm, 1000);
    expect(warns(999), isTrue);
    expect(warns(1000), isFalse);
    expect(warns(1200), isFalse);
  });

  test('faqat oddiy eshik shaklida (balkon blok, vitraj, deraza emas)', () {
    for (final shape in [
      ProposalShape.fEshik,
      ProposalShape.tEshik,
      ProposalShape.vitraj,
      ProposalShape.deraza,
      ProposalShape.arka,
    ]) {
      expect(warns(960, shape: shape), isFalse, reason: shape.name);
    }
  });

  group(
      'ikki qismli eshik oralig\'ida 900 mm dan keng tavaqa taklif qilinmaydi',
      () {

    List<List<int>> leavesFor(int w) => [
          for (final t in proposalTemplatesFor(ProposalType.door, w, 2100))
            if (!proposalHasOverwideDoorLeaf(t, w, 2100))
              proposalDoorLeafWidthsMm(
                  proposalRomDesign(t.buildSpec(w, 2100), w, 2100)),
        ];

    for (final w in [1000, 1100, 1200, 1300, 1350, 1399, 1400, 1450]) {
      test('$w mm: qolgan har bir tavaqa ≤ 900', () {
        final all = leavesFor(w);
        expect(all, isNotEmpty, reason: 'variant qolishi shart');
        for (final leaves in all) {
          expect(leaves.every((l) => l <= 900), isTrue, reason: '$leaves');
        }
      });
    }

    test('1400 mm da 700 + 700 varianti qoladi', () {
      expect(leavesFor(1400), contains(equals([700, 700])));
    });

    test('950 + 450 shablon haqiqatan chiqarib tashlanadi', () {
      final dropped = proposalTemplatesFor(ProposalType.door, 1400, 2100)
          .where((t) => proposalHasOverwideDoorLeaf(t, 1400, 2100));
      expect(dropped, isNotEmpty);
    });

    test('tor (bir tavaqali) oraliqqa tegmaydi — u yerda ogohlantirish bor',
        () {
      final t = proposalTemplatesFor(ProposalType.door, 960, 2100).first;
      expect(proposalHasOverwideDoorLeaf(t, 960, 2100), isFalse);
    });
  });

  group('mijoz "ha" desa — eshik 80 sm + qo\'zg\'almas qanot variantlari', () {
    ProposalRequest req(int w, {bool agree = true}) => ProposalRequest(
          type: ProposalType.door,
          widthMm: w,
          heightMm: 2100,
          shape: ProposalShape.eshik,
          fixedSideDoor: agree,
        );
    List<ProposalOption> fixedOptions(ProposalRequest r) => [
          for (final o in const ProposalGenerator().generate(r))
            if (o.title.contains('qo\'zg\'almas qanot')) o,
        ];

    test('96 sm: 6 variant, ro\'yxat boshida, eshik aniq 800 mm', () {
      final options = const ProposalGenerator().generate(req(960));
      final fixed = fixedOptions(req(960));
      expect(fixed.map((o) => o.title).toSet(), {
        'Eshik + qo\'zg\'almas qanot (o\'ngda)',
        'Eshik + qo\'zg\'almas qanot (chapda)',
        'Pastki panelli eshik + qo\'zg\'almas qanot (o\'ngda)',
        'Pastki panelli eshik + qo\'zg\'almas qanot (chapda)',
        'Pasti lambrili eshik + qo\'zg\'almas qanot (o\'ngda)',
        'Pasti lambrili eshik + qo\'zg\'almas qanot (chapda)',
      });

      expect(options.take(fixed.length).every((o) => o.pinFirst), isTrue);
      for (final o in fixed) {
        final d = proposalRomDesign(o.spec, 960, 2100);
        expect(proposalDoorLeafWidthsMm(d), [800], reason: o.title);
      }

      expect(options.any((o) => o.title == 'To\'liq oynali eshik'), isTrue);
    });

    test('qanot tutqich tomonida: eshik qanotdan uzoq chetga osiladi', () {
      for (final l in proposalDoorFixedSideLayouts(960, 2100)) {
        final t = l.toTemplate(ProposalType.door, 960, 2100);
        final doorSetup =
            t.zoneSetups.firstWhere((s) => s.openingIsDoor == true);
        final doorOnLeft = l.cols.first.role == ProposalColRole.door;

        expect(doorSetup.zoneCenter.dx < 0.5, doorOnLeft, reason: t.title);
      }
    });

    test('panelli variantda eshik va qanot paneli BIR XIL balandlikda (800 mm)',
        () {
      final l = proposalDoorFixedSideLayouts(960, 2100)
          .firstWhere((l) => l.doorPanelMm > 0);
      final spec =
          l.toTemplate(ProposalType.door, 960, 2100).buildSpec(960, 2100);
      final panelYs = {
        for (final ln in spec.lines)
          if ((ln.startY - ln.endY).abs() < 1e-9)
            ((1 - ln.startY) * 2100).round(),
      };
      expect(panelYs, {800});
    });

    test('lambrili variant: eshikda ham, qanotda ham lambri 800 mm', () {
      for (final l in proposalDoorFixedSideLayouts(960, 2100)
          .where((l) => l.lambriMm > 0)) {
        final t = l.toTemplate(ProposalType.door, 960, 2100);
        final spec = t.buildSpec(960, 2100);
        final ys = {
          for (final ln in spec.lines)
            if ((ln.startY - ln.endY).abs() < 1e-9)
              ((1 - ln.startY) * 2100).round(),
        };
        expect(ys, {800}, reason: t.title);

        final lambriZones = t.zoneSetups.where((s) => s.layoutCategory == 1);
        expect(lambriZones.length, 2, reason: t.title);

        final d = proposalRomDesign(spec, 960, 2100);
        expect(proposalDoorLeafWidthsMm(d), [800], reason: t.title);
      }
      expect(
        fixedOptions(req(960)).where((o) => o.title.contains('lambrili')),
        isNotEmpty,
      );
    });

    test(
        'belgi o\'lcham o\'zgartirilganda va buyurtma bilan yuborilganda saqlanadi',
        () {
      final o = fixedOptions(req(960)).first;
      expect(o.spec.plainDoorPosts, isTrue);

      final decoded =
          ProposalSpecCodec.decode(ProposalSpecCodec.encode(o.spec))!;
      expect(decoded.plainDoorPosts, isTrue);

      final edited = proposalEditSegment(
        current: o,
        request: req(960),
        horizontal: true,
        breaksMm: const [0, 800, 960],
        index: 0,
        newMm: 790,
      );
      expect(edited.option, isNotNull, reason: edited.error);
      expect(edited.option!.spec.plainDoorPosts, isTrue);
    });

    test('90–100 sm: rozilik bo\'lmasa qo\'shilmaydi', () {
      expect(fixedOptions(req(960, agree: false)), isEmpty);
    });

    group(
        'usta qoidasi: 90 sm gacha — bir tavaqa, 90–105 — bir tomoni qo\'zg\'almas, '
        '105 dan keng — ikki tavaqa', () {
      List<String> titles(int w) => [
            for (final o
                in const ProposalGenerator().generate(req(w, agree: false)))
              o.title,
          ];
      bool isFixed(String t) => t.contains('qo\'zg\'almas qanot');

      for (final w in [1000, 1020, 1050]) {
        test('$w mm: FAQAT bir tomoni qo\'zg\'almas', () {
          final t = titles(w);
          expect(t, isNotEmpty);
          expect(t.every(isFixed), isTrue, reason: '$t');
        });
      }

      test('105 sm dan keng — oldingidek ikki tavaqali', () {
        final t = titles(1051);
        expect(t.any(isFixed), isFalse, reason: '$t');
        expect(t.any((x) => x.startsWith('Juft')), isTrue, reason: '$t');
      });

      test('90 sm gacha — bir tavaqali, qo\'zg\'almas qanot yo\'q', () {
        final t = titles(900);
        expect(t.any(isFixed), isFalse, reason: '$t');
      });
    });

    test('qanot 10 sm dan tor bo\'lsa variant yasalmaydi', () {
      expect(proposalDoorFixedSideLayouts(899, 2100), isEmpty);
      expect(proposalDoorFixedSideLayouts(900, 2100), isNotEmpty); 
    });
  });

  test('matnda usta tavsiyasi bor', () {
    expect(proposalWideSingleDoorText, contains('qo\'zg\'almas qanot'));
  });
}
