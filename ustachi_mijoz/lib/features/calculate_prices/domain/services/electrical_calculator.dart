import 'dart:math' as math;

enum ElectricalLight { bulb, spot, duralight, rail }

class ElectricalRoom {
  const ElectricalRoom(
      {this.name = 'Xona', this.lights = const {ElectricalLight.bulb}});
  final String name;
  final Set<ElectricalLight> lights;
}

class ElectricalItem {
  const ElectricalItem(this.name, this.quantity, this.unit, this.price);
  final String name;
  final double quantity;
  final String unit;
  final int price;
  int get total => (quantity * price).round();
  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'unit_price': price,
        'total': total,
      };
}

class ElectricalEstimate {
  const ElectricalEstimate(this.items, this.roomLength, this.roomWidth);
  final List<ElectricalItem> items;
  final double roomLength;
  final double roomWidth;
  int get total => items.fold(0, (sum, item) => sum + item.total);
}

abstract final class ElectricalCalculator {
  static ElectricalEstimate calculate({
    required double length,
    required double width,
    required double poleDistance,
    required double panelDistance,
    required List<ElectricalRoom> rooms,
    bool copper = true,
    bool separate = false,
    bool premium = false,
    bool premiumConduit = false,
  }) {
    if (![length, width, poleDistance, panelDistance]
            .every((v) => v.isFinite) ||
        length <= 0 ||
        width <= 0 ||
        poleDistance < 0 ||
        panelDistance < 0 ||
        length > 100 ||
        width > 100 ||
        poleDistance > 1000 ||
        panelDistance > 1000 ||
        rooms.isEmpty ||
        rooms.length > 50 ||
        rooms.any((r) => r.lights.isEmpty)) {
      throw ArgumentError('Uy o‘lchami, masofalar va yoritishni tekshiring');
    }
    final count = rooms.length;
    final roomLength = length / math.sqrt(count);
    final roomWidth = width / math.sqrt(count);
    final scale = (roomLength + roomWidth) / 10;
    final perimeter = 2 * (roomLength + roomWidth);
    final socketM =
        (15 * scale * count + (length + width) / 2 * (separate ? count : 1))
            .ceilToDouble();
    double lightingM = 0;
    double duralightM = 0;
    int bulbs = 0, spots = 0, rails = 0, blocks = 0;
    for (final room in rooms) {
      final feed = 5 * scale;
      if (room.lights.contains(ElectricalLight.bulb)) {
        bulbs++;
        lightingM += feed;
      }
      if (room.lights.contains(ElectricalLight.spot)) {
        final n = (roomLength * roomWidth * 4 / 25).ceil();
        spots += n;
        final columns = math.sqrt(n).ceil();
        final rows = (n / columns).ceil();
        lightingM += feed +
            rows * roomLength * (columns - 1) / columns +
            roomWidth * (rows - 1) / rows;
      }
      if (room.lights.contains(ElectricalLight.duralight)) {
        duralightM += perimeter;
        blocks++;
        lightingM += feed + perimeter;
      }
      if (room.lights.contains(ElectricalLight.rail)) {
        rails++;
        lightingM += feed + 2;
      }
    }
    lightingM = lightingM.ceilToDouble();
    final items = <ElectricalItem>[];
    void add(String name, num quantity, String unit, int price) {
      if (quantity > 0) {
        items.add(ElectricalItem(name, quantity.toDouble(), unit, price));
      }
    }

    add('SIP 2×16 — ustundan uygacha', poleDistance, 'm', 7500);
    add('Traverz', 1, 'dona', premium ? 100000 : 80000);
    add('Elektr hisoblagich', 1, 'dona', 1000000);
    add('Asosiy shit', 1, 'dona', 100000);
    add('Hisoblagich chiqishidagi avtomat', 2, 'dona', premium ? 19000 : 13000);
    add('AVG NG 2×16 alyuminiy — hisoblagichdan shitgacha', panelDistance, 'm',
        5000);
    if (separate) {
      add('Xona avtomati', count, 'dona', premium ? 19000 : 13000);
      add('Xona avtomati uchun quti', count, 'dona', 45000);
    }
    add(
        copper
            ? 'Mis 2×2,5 — rozetka va umumiy liniya'
            : 'Alyuminiy 2×4 — rozetka va umumiy liniya',
        socketM,
        'm',
        copper ? 11500 : 4000);
    add(copper ? 'Mis 2×1,5 — yoritish' : 'Alyuminiy 2×2,5 — yoritish',
        lightingM, 'm', copper ? 7500 : 2500);
    add('Rozetka (bittalik)', count * 2, 'dona', premium ? 30000 : 11000);
    add('Viklyuchatel (bir tugmali)', count, 'dona', premium ? 25000 : 9000);
    add('Podrozetnik', count * 3, 'dona', 1500);
    add('Raspayka qutisi', count, 'dona', 3000);
    add('Izolenta', (count / 2).ceil(), 'dona', 10000);
    add('WAGO klemmasi', count * 4, 'dona', 5000);
    add('Gofra — faqat yoritish', lightingM, 'm', premiumConduit ? 5500 : 800);
    add('Patron', bulbs, 'dona', 5000);
    add('Oddiy lampochka', bulbs, 'dona', 12000);
    add('Nuqtali svetilnik', spots, 'dona', premium ? 80000 : 13000);
    add('Duralayt', duralightM.ceil(), 'm', premium ? 25000 : 9000);
    add('Duralayt blok pitaniya', blocks, 'dona', 15000);
    add('Rels (2 metr)', rails, 'dona', 50000);
    add('Rels svetilnigi', rails, 'dona', 65000);
    return ElectricalEstimate(List.unmodifiable(items), roomLength, roomWidth);
  }
}
