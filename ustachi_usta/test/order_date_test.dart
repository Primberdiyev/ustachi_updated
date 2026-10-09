
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/order_date.dart';

void main() {

  final now = DateTime(2026, 8, 4, 15, 30);

  group('orderDateLabel', () {
    test('bugun — "Bugun, 14:20"', () {
      expect(orderDateLabel(DateTime(2026, 8, 4, 14, 20), now: now),
          'Bugun, 14:20');
    });

    test('kecha — "Kecha, 09:05"', () {
      expect(orderDateLabel(DateTime(2026, 8, 3, 9, 5), now: now),
          'Kecha, 09:05');
    });

    test('shu yil — kun-oy va vaqt', () {
      expect(orderDateLabel(DateTime(2026, 7, 21, 18, 0), now: now),
          '21-iyl, 18:00');
    });

    test('o\'tgan yil — YIL ham yoziladi, vaqt esa keraksiz', () {
      expect(orderDateLabel(DateTime(2025, 12, 31, 23, 59), now: now),
          '31-dek 2025');
    });

    test('null — bo\'sh satr (qator umuman chizilmaydi)', () {
      expect(orderDateLabel(null), '');
    });
  });

  group('orderDateShort', () {
    test('tor joyda vaqtsiz', () {
      expect(orderDateShort(DateTime(2026, 8, 4, 14, 20), now: now), 'Bugun');
      expect(orderDateShort(DateTime(2026, 8, 3, 14, 20), now: now), 'Kecha');
      expect(orderDateShort(DateTime(2026, 7, 21), now: now), '21-iyl');
      expect(orderDateShort(DateTime(2025, 7, 21), now: now), '21-iyl 2025');
    });
  });

  group('orderTimeAgo', () {
    test('daqiqa va soat — e\'lon yangiligini bildiradi', () {
      expect(orderTimeAgo(now.subtract(const Duration(seconds: 20)), now: now),
          'Hozirgina');
      expect(orderTimeAgo(now.subtract(const Duration(minutes: 12)), now: now),
          '12 daqiqa oldin');
      expect(orderTimeAgo(now.subtract(const Duration(hours: 5)), now: now),
          '5 soat oldin');
    });

    test('bir kundan oshsa ANIQ SANAGA o\'tadi', () {

      final old = DateTime(2026, 7, 20, 10, 0);
      expect(orderTimeAgo(old, now: now), orderDateLabel(old, now: now));
    });

    test('kelajakdagi sana yozuvni buzmaydi', () {
      final future = now.add(const Duration(hours: 3));
      expect(orderTimeAgo(future, now: now), orderDateLabel(future, now: now));
    });
  });
}
