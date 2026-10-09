
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';

FramePreviewSpec _sample() => const FramePreviewSpec(
      aspectRatio: 1.5,
      widthMm: 1500,
      heightMm: 1000,
      lines: [
        FrameLine(0.5, 0, 0.5, 1),
        FrameLine(0, 0.4, 1, 0.4),
      ],
      defaultOpeningCategory: 1,
      defaultZoneSetups: [
        DefaultZoneSetup(zoneCenter: Offset(0.25, 0.7), openingCategory: 2),
        DefaultZoneSetup(
          zoneCenter: Offset(0.75, 0.7),
          openingCategory: 1,
          openingIsDoor: true,
          openingHasHandle: false,
          layoutCategory: 3,
        ),
      ],
    );

void main() {
  test('aylanish shaklni SAQLAYDI', () {
    final decoded = ProposalSpecCodec.decode(
      ProposalSpecCodec.encode(_sample()),
    )!;

    expect(decoded.aspectRatio, 1.5);
    expect(decoded.widthMm, 1500);
    expect(decoded.heightMm, 1000);
    expect(decoded.lines, hasLength(2));
    expect(decoded.lines.first.startX, 0.5);
    expect(decoded.lines.first.endY, 1);
    expect(decoded.defaultOpeningCategory, 1);

    expect(decoded.defaultZoneSetups, hasLength(2));
    final door = decoded.defaultZoneSetups[1];
    expect(door.zoneCenter, const Offset(0.75, 0.7));
    expect(door.openingIsDoor, isTrue);
    expect(door.openingHasHandle, isFalse);
    expect(door.layoutCategory, 3);
  });

  test('arka (kamar) saqlanadi', () {
    const arch = FramePreviewSpec(
      aspectRatio: 0.67,
      archHeightFactor: 0.33,
      lines: [],
    );
    final decoded = ProposalSpecCodec.decode(ProposalSpecCodec.encode(arch))!;
    expect(decoded.archHeightFactor, closeTo(0.33, 0.0001));
  });

  test('JSON orqali ham buzilmaydi (server saqlab qaytaradi)', () {
    final wire = jsonDecode(jsonEncode(ProposalSpecCodec.encode(_sample())));
    final decoded = ProposalSpecCodec.decode(wire)!;
    expect(decoded.lines, hasLength(2));
    expect(decoded.defaultZoneSetups, hasLength(2));
  });

  test('YENGIL: oddiy chizma 1 KB dan kichik', () {
    final bytes = utf8.encode(jsonEncode(ProposalSpecCodec.encode(_sample())));
    expect(bytes.length, lessThan(1024),
        reason: 'rasm o\'rniga raqam yuborishning butun ma\'nosi shu');
  });

  group('eski/buzuq ma\'lumot — ekran YIQILMASIN', () {
    test('spec umuman yo\'q (eski buyurtma) → null', () {
      expect(ProposalSpecCodec.decode(null), isNull);
      expect(ProposalSpecCodec.decode('salom'), isNull);
    });

    test('nisbat yo\'q → null', () {
      expect(ProposalSpecCodec.decode(const {'lines': []}), isNull);
    });

    test('buzuq chiziq TASHLAB YUBORILADI, qolgani chiziladi', () {
      final decoded = ProposalSpecCodec.decode(const {
        'ar': 1.0,
        'lines': [
          [0.0, 0.0, 1.0, 1.0],
          [0.0, 0.0], 
          'buzuq',
        ],
      })!;
      expect(decoded.lines, hasLength(1));
    });

    test('chiziqsiz spec ham yaroqli (bo\'sh rom)', () {
      final decoded = ProposalSpecCodec.decode(const {'ar': 1.2})!;
      expect(decoded.lines, isEmpty);
      expect(decoded.aspectRatio, 1.2);
    });
  });
}
