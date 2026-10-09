import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

void main() {
  test('Penthouse never asks for a rate, including old cached units', () {
    expect(const MasterSpecialty(id: 1, name: 'Penthaus gidro tom',
      code: 'penthaus_gidro_tom', unit: 'm²').asksRate, false);
  });

  test('Penthaus yo\'nalishi yangi matn bilan ko\'rinadi (ro\'yxat, profil, buyurtma)', () {
    const text = 'Tom gidro izolyatsiya terassa pent haus PVX TPO membrana';
    final s = MasterSpecialty.fromJson({
      'id': 2, 'name': 'Penthaus gidro tom', 'code': 'penthaus_gidro_tom', 'unit': 'm²',
    });
    expect(s.name, text);
    expect(s.code, 'penthaus_gidro_tom');
    expect(s.asksRate, false);
    expect(specialtyDisplayName('Penthaus gidro tom'), text);
    expect(specialtyDisplayName('Tom yopish'), 'Tom yopish');
    final profile = MasterProfileData.fromJson({'specialty_name': 'Penthaus gidro tom'});
    expect(profile.specialtyName, text);
  });
  test('Other roof methods retain their individual rates', () {
    final roof = MasterSpecialty.fromJson({
      'id': 2, 'name': 'Tom', 'code': 'tom', 'unit': 'm²',
      'variants': [
        {'id': 1, 'name': 'Terak + shifer'},
        {'id': 2, 'name': 'Gidroizolatsiya — penthaus tom yopish'},
      ],
    });
    expect(roof.asksRatePerVariant, true);
    expect(roof.variants.map((v) => v.name), ['Terak + shifer']);
  });
}
