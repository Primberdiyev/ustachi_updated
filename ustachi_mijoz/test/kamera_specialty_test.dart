import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/script/latin_to_cyrillic.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

void main() {
  const name = "Kuzatuv kamerasi o'rnatish va ta'mirlash";

  test('kamera yo\'nalishi o\'z belgisi bilan chiqadi (umumiy "asbob" emas)', () {
    expect(SpecialtyVisuals.iconOf('kamera'), Icons.videocam_outlined);
    expect(SpecialtyVisuals.hasImage('kamera'), isFalse);
  });

  test('narx hisoblash yo\'q — server javobida ham, eski serverda ham', () {
    final fromServer = SpecialtyEntity.fromJson(const {
      'id': 26,
      'code': 'kamera',
      'name': name,
      'unit': '',
      'calculator': '',
    });
    expect(fromServer.name, name);
    expect(fromServer.calculator, SpecialtyCalculator.none);
    expect(fromServer.hasCalculator, isFalse);

    final legacy = SpecialtyEntity.fromJson(const {'id': 26, 'code': 'kamera', 'name': name});
    expect(legacy.hasCalculator, isFalse);
  });

  test('kirillda ham o\'zbekcha chiqadi', () {
    expect(latinToCyrillic(name), 'Кузатув камераси ўрнатиш ва таъмирлаш');
  });
}
