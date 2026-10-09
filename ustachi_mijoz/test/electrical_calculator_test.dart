import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/services/electrical_calculator.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

void main() {
  ElectricalEstimate estimate(
          {bool copper = true,
          bool separate = false,
          bool premium = false,
          Set<ElectricalLight> lights = const {ElectricalLight.bulb},
          int rooms = 4,
          double length = 10}) =>
      ElectricalCalculator.calculate(
        length: length,
        width: 10,
        poleDistance: 20,
        panelDistance: 5,
        rooms: List.generate(rooms, (_) => ElectricalRoom(lights: lights)),
        copper: copper,
        separate: separate,
        premium: premium,
      );
  ElectricalItem item(ElectricalEstimate e, String prefix) =>
      e.items.firstWhere((i) => i.name.startsWith(prefix));
  test('Owner reference: 4 rooms, ordinary copper, complete material total',
      () {
    final e = estimate();
    expect(item(e, 'Mis 2×2,5').quantity, 70);
    expect(item(e, 'Mis 2×1,5').quantity, 20);
    expect(item(e, 'Gofra').quantity, 20);
    expect(item(e, 'Mis 2×2,5').total + item(e, 'Mis 2×1,5').total, 955000);
    expect(e.total, 2674000);
    expect(item(e, 'Hisoblagich chiqishidagi').quantity, 2);
    expect(e.items.any((i) => i.name == 'Xona avtomati'), false);
  });
  test('Aluminium keeps entry cables and uses owner reference of 330000', () {
    final e = estimate(copper: false);
    expect(item(e, 'Alyuminiy 2×4').total + item(e, 'Alyuminiy 2×2,5').total,
        330000);
    expect(item(e, 'SIP').total, 150000);
    expect(item(e, 'AVG').total, 25000);
    expect(e.total, 2049000);
  });
  test('Radial adds room breakers and boxes without multiplying main breakers',
      () {
    final e = estimate(separate: true);
    expect(item(e, 'Hisoblagich chiqishidagi').quantity, 2);
    expect(item(e, 'Xona avtomati').quantity, 4);
    expect(item(e, 'Xona avtomati uchun').total, 180000);
    expect(item(e, 'Mis 2×2,5').quantity, 100);
    expect(e.total, 3251000);
  });
  test('Combined lighting counts fixtures, extra wire and matching conduit',
      () {
    final e = estimate(lights: ElectricalLight.values.toSet());
    expect(item(e, 'Nuqtali').quantity, 16);
    expect(item(e, 'Duralayt').quantity, 80);
    expect(item(e, 'Duralayt blok').quantity, 4);
    expect(item(e, 'Rels (').quantity, 4);
    expect(item(e, 'Rels svet').quantity, 4);
    expect(item(e, 'Gofra').quantity, item(e, 'Mis 2×1,5').quantity);
    expect(item(e, 'Gofra').quantity, greaterThan(20));
  });
  test('Premium endpoints and odd room tape rounding', () {
    final e = estimate(premium: true, rooms: 5);
    expect(item(e, 'Rozetka').price, 30000);
    expect(item(e, 'Viklyuchatel').price, 25000);
    expect(item(e, 'Izolenta').quantity, 3);
  });
  test('Invalid geometry and empty lighting are rejected', () {
    expect(() => estimate(length: double.nan), throwsArgumentError);
    expect(() => estimate(length: 0), throwsArgumentError);
    expect(() => estimate(rooms: 0), throwsArgumentError);
    expect(() => estimate(lights: {}), throwsArgumentError);
  });
  test(
      'Catalogue supports server and legacy fallback, respects disabled server',
      () {
    expect(SpecialtyEntity.fromJson({'code': 'elektrik'}).hasCalculator, true);
    expect(
        SpecialtyEntity.fromJson(
            {'code': 'elektrik', 'calculator': 'electrical'}).calculator,
        SpecialtyCalculator.electrical);
    expect(
        SpecialtyEntity.fromJson({'code': 'elektrik', 'calculator': ''})
            .hasCalculator,
        false);
  });
}
