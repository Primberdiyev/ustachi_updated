// MIJOZ RAQAMI USTADA (real muammo, 2026-10-07).
//
// Mijoz taklifni qabul qilgach ikkalasi bog'lanishi kerak edi, lekin usta
// ilovasida mijozning telefoni UMUMAN ko'rinmasdi: server uni yuborardi,
// ilova esa o'qimasdi ham.
//
// Qulflanadigan shartnoma:
//   * tanlangan buyurtmada mijoz raqami o'qiladi va sahifada chiqadi;
//   * qo'ng'iroq tugmasi ko'rinadi;
//   * raqam bo'lmasa (hali tanlanmagan — server raqamni yashiradi) sahifa
//     avvalgidek ishlaydi, tugma chiqmaydi.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart' as api;
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_api.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';

class _FakeApi implements MarketplaceRepository {
  _FakeApi(this.order);

  final api.OrderEntity order;

  @override
  Future<Either<Failure, List<api.OrderEntity>>> list({
    String? status,
    String? scope,
  }) async =>
      Right([order]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('testda chaqirilmaydi: ${invocation.memberName}');
}

api.OrderEntity _apiOrder({String phone = '+998901234567'}) => api.OrderEntity(
      id: 42,
      title: 'Balkon romi',
      status: api.OrderStatus.assigned,
      stage: api.OrderStage.accepted,
      proposal: const {},
      calculatedPrice: 1500000,
      specialtyCode: 'rom',
      specialtyName: 'Rom ustasi',
      address: 'Chilonzor 12',
      client: api.PersonEntity(
        id: 5,
        fullName: 'Aziz aka',
        phoneNumber: phone,
      ),
    );

MasterOrderEntity _order({String phone = '+998901234567'}) => MasterOrderEntity(
      id: '42',
      number: '#42',
      title: 'Balkon romi',
      clientName: 'Aziz aka',
      clientPhone: phone,
      address: 'Chilonzor 12',
      totalPrice: 1500000,
      stage: OrderStage.accepted,
      createdAt: DateTime(2026, 10, 1),
    );

Future<void> _pump(WidgetTester tester, MasterOrderEntity order) async {
  tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: BlocProvider(
          create: (_) => OrdersBloc(repository: OrdersRepositoryInMemory()),
          child: Scaffold(
            body: SingleChildScrollView(
              child: OrderDetailView(order: order, showStageAction: false),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  test('tanlangan buyurtmada mijoz raqami O\'QILADI', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_apiOrder()));

    final order = (await repo.orders()).right.single;

    expect(order.clientPhone, '+998901234567');
  });

  test('server raqamni bermasa — bo\'sh, lekin yiqilmaydi', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_apiOrder(phone: '')));

    final order = (await repo.orders()).right.single;

    expect(order.clientPhone, isEmpty);
  });

  testWidgets('sahifada raqam va QO\'NG\'IROQ tugmasi chiqadi', (tester) async {
    await _pump(tester, _order());

    expect(find.text('+998901234567'), findsOneWidget);
    expect(find.byIcon(Icons.call_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('raqamsiz buyurtmada tugma YO\'Q', (tester) async {
    await _pump(tester, _order(phone: ''));

    expect(find.byIcon(Icons.call_rounded), findsNothing);
    expect(find.text('Aziz aka'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
