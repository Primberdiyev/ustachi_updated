import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/marketplace/data/models/master_card_model.dart';
import 'package:ustachi/features/marketplace/data/models/master_profile_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

void main() {
  const tomNote = {
    'code': 'tom',
    'name': 'Tom yopish ustasi',
    'text': "Sasna + shifer — 1 m² uchun 30 000 so'm",
  };

  test('profil izohni o\'qiydi', () {
    final p = MasterProfileModel.fromJson({
      'id': 5,
      'notes': [tomNote],
    });
    expect(p.notes, hasLength(1));
    expect(p.notes.first.code, 'tom');
    expect(p.notes.first.text, contains('30 000'));
  });

  test('kartada ham izoh bor', () {
    final c = MasterCardModel.fromJson({
      'id': 5,
      'full_name': 'Tomchi',
      'notes': [tomNote],
    });
    expect(c.notes.single.name, 'Tom yopish ustasi');
  });

  test('eski server (notes yo\'q) va bo\'sh matn — bo\'sh ro\'yxat', () {
    expect(MasterProfileModel.fromJson({'id': 5}).notes, isEmpty);
    expect(
      MasterNoteEntity.listFrom([
        {'code': 'tom', 'name': 'Tom', 'text': '   '},
      ]),
      isEmpty,
    );
  });
}
