
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/services/radiator_catalog.dart';

void main() {
  test('50 × 140: 87,2 dollar × 12 000 = 1 046 400 so\'m', () {
    final p = RadiatorCatalog.anchor;

    expect(p.size, '50×140');
    expect(p.priceUsd, 87.2);
    expect(p.priceSom(RadiatorCatalog.defaultUsdRate), 1046400);
  });

  test('kurs: 1 dollar = 12 000 so\'m (usta qarori)', () {
    expect(RadiatorCatalog.defaultUsdRate, 12000);
  });

  test('jadvalda 36 ta o\'lcham bor: 30/40/50/60 × 40…200', () {
    expect(RadiatorCatalog.all, hasLength(36));

    for (final height in [30, 40, 50, 60]) {
      for (final length in [40, 60, 80, 100, 120, 140, 160, 180, 200]) {
        expect(
          RadiatorCatalog.bySize('$height×$length'),
          isNotNull,
          reason: '$height×$length jadvalda yo\'q',
        );
      }
    }
  });

  test('narx o\'lcham kattalashgani sayin oshadi', () {
    final small = RadiatorCatalog.bySize('30×40')!;
    final big = RadiatorCatalog.bySize('60×200')!;

    expect(small.priceUsd, lessThan(big.priceUsd));
    expect(small.priceUsd, 31.4);
    expect(big.priceUsd, 132.1);
  });

  test('bo\'yi 50 sm: har 10 sm 150 Vt (mutaxassis 2026-09-22)', () {
    expect(RadiatorCatalog.wattsPer10cm, 150);

    expect(RadiatorCatalog.anchor.watts, 2100);

    expect(RadiatorCatalog.bySize('50×60')!.watts, 900);

    expect(RadiatorCatalog.bySize('50×200')!.watts, 3000);
  });

  test('boshqa balandlik — bo\'yiga nisbatan', () {

    expect(RadiatorCatalog.bySize('30×140')!.watts, 1260);

    expect(RadiatorCatalog.bySize('60×140')!.watts, 2520);
  });
}
