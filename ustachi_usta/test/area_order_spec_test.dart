
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart'
    as api;
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_api.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';

class _FakeApi implements MarketplaceRepository {
  _FakeApi(this.order);

  final api.OrderEntity order;

  @override
  Future<Either<Failure, List<api.OrderEntity>>> feed() async =>
      Right([order]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('testda chaqirilmaydi: ${invocation.memberName}');
}

api.OrderEntity _order(Map<String, dynamic> proposal, {String? code}) =>
    api.OrderEntity(
      id: 5,
      title: 'Asfalt ustasi — 150 m²',
      status: api.OrderStatus.published,
      proposal: proposal,
      calculatedPrice: 11250000,
      specialtyCode: code ?? 'asfalt',
      specialtyName: 'Asfalt ustasi',
      address: 'Chilonzor 12',
      regionName: 'Toshkent',
    );

Future<Map<String, String>> _spec(api.OrderEntity order) async {
  final repo = OrdersRepositoryApi(_FakeApi(order));
  final result = await repo.requests();
  return result.right.single.spec;
}

void main() {
  test('MAYDON buyurtmasi — maydon, stavka va manzil', () async {
    final spec = await _spec(_order({
      'calculator': 'area',
      'area_m2': 150.0,
      'unit': 'm²',
      'unit_price': 75000,
      'total_price': 11250000,
    }));

    expect(spec[specArea], '150 m²');
    expect(spec[specUnitPrice], '75000');
    expect(spec[specAddress], contains('Chilonzor 12'));
  });

  test('ROM qatorlari asfaltda UMUMAN chiqmaydi', () async {

    final spec = await _spec(_order({
      'calculator': 'area',
      'area_m2': 80.0,
      'unit_price': 100000,
    }));

    expect(spec.containsKey(specGlass), isFalse);
    expect(spec.containsKey(specMaterial), isFalse);
    expect(spec.containsKey(specSize), isFalse);
    expect(spec.containsKey(specBrand), isFalse);
  });

  test('kasrli maydon ortiqcha nolsiz chiqadi', () async {
    final spec = await _spec(_order({
      'calculator': 'area',
      'area_m2': 12.5,
      'unit_price': 100000,
    }));
    expect(spec[specArea], '12.5 m²');
  });

  test('sonlar SATR bo\'lib kelsa ham o\'qiladi', () async {
    final spec = await _spec(_order({
      'calculator': 'area',
      'area_m2': '150.00',
      'unit_price': '75000',
    }));
    expect(spec[specArea], '150 m²');
    expect(spec[specUnitPrice], '75000');
  });

  test('VARIANTLI buyurtma — daraja, maydon va stavka', () async {

    final spec = await _spec(_order({
      'calculator': 'variant',
      'variant': 'Odatiy',
      'variant_note': '1 qanotli laminatsiya',
      'area_m2': 4.0,
      'unit_price': 500000,
      'total_price': 2000000,
    }, code: 'eshik'));

    expect(spec[specVariant], 'Odatiy (1 qanotli laminatsiya)');
    expect(spec[specArea], '4 m²');
    expect(spec[specUnitPrice], '500000');
    expect(spec.containsKey(specGlass), isFalse, reason: 'rom qatorlari yo\'q');
  });

  test('izohsiz variant — faqat nomi', () async {
    final spec = await _spec(_order({
      'calculator': 'variant',
      'variant': 'Premium',
      'area_m2': 4.0,
      'unit_price': 1500000,
    }, code: 'eshik'));

    expect(spec[specVariant], 'Premium');
  });

  test('ROM buyurtmasi AVVALGIDEK — regressiya yo\'q', () async {
    final spec = await _spec(_order(
      {
        'width_mm': 1500,
        'height_mm': 1400,
        'shape_title': 'Deraza',
        'brand_name': 'Aldox',
        'material': 0,
        'layer_type': 1,
      },
      code: 'rom',
    ));

    expect(spec[specSize], '1500×1400');
    expect(spec[specBrand], 'Aldox');
    expect(spec[specGlass], specValueDoubleGlass);
    expect(spec.containsKey(specArea), isFalse);
  });
}
