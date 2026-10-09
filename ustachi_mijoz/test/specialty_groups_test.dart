import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_groups.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

void main() {
  SpecialtyEntity s(int id, String code, {String group = ''}) =>
      SpecialtyEntity(id: id, code: code, name: code, group: group);

  final catalog = [
    s(1, 'rom'),
    s(2, 'texnika_ekskavator_zanjirli', group: 'texnika'),
    s(3, 'tom'),
    s(4, 'texnika_avtokran', group: 'texnika'),
    s(5, 'gisht'),
  ];

  test('texnikalar bitta "Polvon texnika" yozuviga jamlanadi', () {
    final collapsed = SpecialtyGroups.collapse(catalog);
    expect(collapsed.map((e) => e.code), ['rom', 'texnika', 'tom', 'gisht']);
    expect(SpecialtyGroups.isGroup(collapsed[1]), isTrue);
    expect(collapsed[1].name, 'Polvon texnika');
  });

  test('guruh ichida faqat texnikalar', () {
    expect(SpecialtyGroups.texnikaOf(catalog).map((e) => e.code),
        ['texnika_ekskavator_zanjirli', 'texnika_avtokran']);
  });

  test('texnikasiz katalog o\'zgarmaydi', () {
    final plain = [s(1, 'rom'), s(3, 'tom')];
    expect(SpecialtyGroups.collapse(plain), plain);
  });

  test('serverdan kelgan "group" o\'qiladi va keshga yoziladi', () {
    final e = SpecialtyEntity.fromJson({
      'id': 40,
      'code': 'texnika_samosval',
      'name': 'Samosval',
      'group': 'texnika'
    });
    expect(e.isTexnika, isTrue);
    expect(SpecialtyEntity.fromJson(e.toJson()).isTexnika, isTrue);
    expect(
        SpecialtyEntity.fromJson({'id': 1, 'code': 'rom', 'name': 'Rom'})
            .isTexnika,
        isFalse);
  });
}
