
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/marketplace/data/models/order_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

const _new = 'Tom gidro izolyatsiya terassa pent haus PVX TPO membrana';

void main() {
  test('serverdagi "Penthaus gidro tom" yangi matn bilan ko\'rinadi, kodi o\'zgarmaydi', () {
    final s = SpecialtyEntity.fromJson(const {
      'id': 2,
      'code': 'penthaus_gidro_tom',
      'name': 'Penthaus gidro tom',
      'unit': 'm²',
    });
    expect(s.name, _new);
    expect(s.code, 'penthaus_gidro_tom');
  });

  test('boshqa yo\'nalishlar nomi o\'zgarmaydi; admin nomni o\'zgartirsa — serverdagisi', () {
    expect(specialtyDisplayName('Tom yopish'), 'Tom yopish');
    expect(specialtyDisplayName('Beton ishlari'), 'Beton ishlari');
    expect(specialtyDisplayName('Penthaus tomi'), 'Penthaus tomi');
    expect(specialtyDisplayName('Penthaus gidro tom'), _new);
  });

  test('buyurtmadagi yo\'nalish nomi ham yangi matnda', () {
    final o = OrderModel.fromJson(const {
      'id': 1,
      'specialty_name': 'Penthaus gidro tom',
    });
    expect(o.specialtyName, _new);
  });
}
