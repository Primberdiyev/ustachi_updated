
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_composite.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/own_order_mapper.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';

MasterOrderEntity _marketplaceOrder({
  String id = '1',
  DateTime? createdAt,
}) =>
    MasterOrderEntity(
      id: id,
      number: '#$id',
      title: 'Mijoz buyurtmasi',
      clientName: 'Mijoz',
      address: 'Yunusobod',
      totalPrice: 1000000,
      stage: OrderStage.measured,
      createdAt: createdAt ?? DateTime(2026, 7, 20),
    );

OwnOrderEntity _ownOrder({
  int id = 7,
  OwnOrderStatus status = OwnOrderStatus.newOrder,
  DateTime? createdAt,
  DateTime? completedAt,
}) =>
    OwnOrderEntity(
      id: id,
      customerName: 'Aziz aka',
      customerPhone: '+998901234567',
      customerAddress: 'Chilonzor 9',
      status: status,
      createdAt: createdAt ?? DateTime(2026, 7, 25),
      completedAt: completedAt,
      items: const [
        OwnOrderItemEntity(
          title: '1500 × 1600 mm',
          qty: 2,
          materialLabel: 'Plastik',
        ),
      ],
    );

class FakeMarketplace implements OrdersRepository {
  List<MasterOrderEntity> ordersList = [];
  List<OrderRequestEntity> requestsList = [];
  Failure? ordersFailure;
  Failure? requestsFailure;
  String? advancedId;

  @override
  Future<Either<Failure, List<MasterOrderEntity>>> orders() async =>
      ordersFailure != null ? Left(ordersFailure!) : Right(ordersList);

  @override
  Future<Either<Failure, List<OrderRequestEntity>>> requests() async =>
      requestsFailure != null ? Left(requestsFailure!) : Right(requestsList);

  @override
  Future<Either<Failure, MasterOrderEntity>> historicalDetail(
          String orderId) async =>
      Left(ParsingFailure('not found'));

  @override
  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  }) async =>
      Right(null);

  @override
  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited = false,
    String reason = '',
  }) async =>
      Right(null);

  @override
  Future<Either<Failure, MasterOrderEntity>> completeStage(String orderId) async {
    advancedId = orderId;
    return Right(_marketplaceOrder(id: orderId));
  }
}

class FakeOwn implements OwnOrdersRepository {
  List<OwnOrderEntity> ownList = [];
  Failure? listFailure;
  OwnOrderStatus? setTo;
  int? setId;

  @override
  Future<Either<Failure, List<OwnOrderEntity>>> list({
    OwnOrderStatus? status,
  }) async =>
      listFailure != null ? Left(listFailure!) : Right(ownList);

  @override
  Future<Either<Failure, OwnOrderEntity>> detail(int id) async =>
      Right(ownList.firstWhere((order) => order.id == id));

  @override
  Future<Either<Failure, OwnOrderEntity>> create(OwnOrderPayload payload) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> update(
          int id, OwnOrderPayload payload) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> setStatus(
    int id,
    OwnOrderStatus status,
  ) async {
    setId = id;
    setTo = status;
    final source = ownList.firstWhere((order) => order.id == id);
    return Right(_ownOrder(
      id: id,
      status: status,
      createdAt: source.createdAt,
      completedAt: status.isClosed ? DateTime(2026, 7, 29) : null,
    ));
  }

  @override
  Future<Either<Failure, void>> remove(int id) async => Right(null);
}

void main() {
  late FakeMarketplace marketplace;
  late FakeOwn own;
  late OrdersRepositoryComposite composite;

  setUp(() {
    marketplace = FakeMarketplace();
    own = FakeOwn();
    composite = OrdersRepositoryComposite(marketplace: marketplace, own: own);
  });

  group('Ro\'yxat', () {
    test('ikki manba qo\'shiladi va YANGISI boshida turadi', () async {
      marketplace.ordersList = [
        _marketplaceOrder(id: '1', createdAt: DateTime(2026, 7, 20)),
      ];
      own.ownList = [_ownOrder(id: 7, createdAt: DateTime(2026, 7, 25))];

      final result = await composite.orders();

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(2));
      expect(result.right.first.id, 'own:7', reason: 'eng yangisi tepada');
      expect(result.right.last.id, '1');
    });

    test('MARKETPLACE yiqilsa o\'z buyurtmalari KO\'RINAVERADI', () async {
      marketplace.ordersFailure = const ServerFailure('500', 500);
      own.ownList = [_ownOrder()];

      final result = await composite.orders();

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
      expect(result.right.single.isOwn, isTrue);
    });

    test('O\'Z manbasi yiqilsa marketplace KO\'RINAVERADI', () async {
      own.listFailure = const ServerFailure('500', 500);
      marketplace.ordersList = [_marketplaceOrder()];

      final result = await composite.orders();

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
      expect(result.right.single.isOwn, isFalse);
    });

    test('IKKALASI yiqilsa xato qaytadi', () async {
      marketplace.ordersFailure = const ServerFailure('500', 500);
      own.listFailure = const ServerFailure('500', 500);

      final result = await composite.orders();

      expect(result.isLeft, isTrue);
    });

    test('e\'lonlar faqat marketplace\'dan olinadi', () async {
      marketplace.requestsFailure = const ServerFailure('500', 500);

      final result = await composite.requests();

      expect(result.isLeft, isTrue);
    });
  });

  group('O\'z buyurtmasi → ro\'yxat kartasi', () {
    test('mijoz va sanoq ko\'chadi, narx yo\'q', () async {
      own.ownList = [_ownOrder()];

      final order = (await composite.orders()).right.single;

      expect(order.clientName, 'Aziz aka');
      expect(order.totalPrice, 0);
      expect(order.remainingPayment, 0);
      expect(order.productCount, 2);
      expect(order.title, '1500 × 1600 mm');
    });

    test('holat → segment: yangi/jarayonda FAOL', () async {
      own.ownList = [
        _ownOrder(id: 1, status: OwnOrderStatus.newOrder),
        _ownOrder(id: 2, status: OwnOrderStatus.inProgress),
      ];

      final orders = (await composite.orders()).right;

      expect(orders.every((order) => !order.isCompleted), isTrue);
    });

    test('yakunlangan va bekor qilingan → ARXIV', () async {
      own.ownList = [
        _ownOrder(id: 1, status: OwnOrderStatus.done),
        _ownOrder(id: 2, status: OwnOrderStatus.cancelled),
      ];

      final orders = (await composite.orders()).right;

      expect(orders.every((order) => order.isCompleted), isTrue);
    });

    test('QARZDOR yakunlanmagan — ro\'yxatdan yo\'qolmaydi', () async {
      own.ownList = [_ownOrder(status: OwnOrderStatus.debt)];

      final order = (await composite.orders()).right.single;

      expect(order.isCompleted, isFalse,
          reason: 'pul olinmagan buyurtma faol qoladi');
      expect(order.ownStatus, OwnOrderStatus.debt);
    });
  });

  group('Holatni surish', () {
    test('marketplace ID\'si marketplace\'ga ketadi', () async {
      await composite.completeStage('42');

      expect(marketplace.advancedId, '42');
      expect(own.setTo, isNull);
    });

    test('o\'z buyurtmasida HOLAT suriladi', () async {
      own.ownList = [_ownOrder(id: 7, status: OwnOrderStatus.newOrder)];

      final result = await composite.completeStage('own:7');

      expect(own.setId, 7);
      expect(own.setTo, OwnOrderStatus.inProgress);
      expect(result.right.ownStatus, OwnOrderStatus.inProgress);
      expect(marketplace.advancedId, isNull);
    });

    test('yakunlangan buyurtma yana surilmaydi', () async {
      own.ownList = [_ownOrder(id: 7, status: OwnOrderStatus.done)];

      final result = await composite.completeStage('own:7');

      expect(result.isLeft, isTrue);
      expect(own.setTo, isNull);
    });

    test('qarzdordan yakunlanganga o\'tadi', () async {
      own.ownList = [_ownOrder(id: 7, status: OwnOrderStatus.debt)];

      await composite.completeStage('own:7');

      expect(own.setTo, OwnOrderStatus.done);
    });
  });

  group('ID xaritasi', () {
    test('prefiks qo\'shiladi va yechiladi', () {
      expect(OwnOrderMapper.idOf(7), 'own:7');
      expect(OwnOrderMapper.serverIdOf('own:7'), 7);
      expect(OwnOrderMapper.isOwnId('own:7'), isTrue);
    });

    test('marketplace ID\'si O\'Z buyurtmasi deb o\'qilmaydi', () {
      expect(OwnOrderMapper.serverIdOf('7'), isNull);
      expect(OwnOrderMapper.isOwnId('7'), isFalse);
    });
  });

  group('Bloc — qisman xato', () {
    test('e\'lonlar yiqilsa BUYURTMALAR baribir ko\'rinadi', () async {
      marketplace.requestsFailure = const ServerFailure('500', 500);
      marketplace.ordersList = [_marketplaceOrder()];
      final bloc = OrdersBloc(repository: composite);
      addTearDown(bloc.close);

      bloc.add(const OrdersLoadRequested());
      final state = await bloc.stream
          .firstWhere((state) => !state.loadStatus.isLoading);

      expect(state.loadStatus.isSuccess, isTrue,
          reason: 'bitta manba yiqilgani butun ekranni o\'chirmasin');
      expect(state.orders, hasLength(1));
      expect(state.requests, isEmpty);
      expect(state.failure, isNotNull, reason: 'sabab qo\'lda qoladi');
    });

    test('buyurtmalar yiqilsa E\'LONLAR baribir ko\'rinadi', () async {
      marketplace.ordersFailure = const ServerFailure('500', 500);
      own.listFailure = const ServerFailure('500', 500);
      final bloc = OrdersBloc(repository: composite);
      addTearDown(bloc.close);

      bloc.add(const OrdersLoadRequested());
      final state = await bloc.stream
          .firstWhere((state) => !state.loadStatus.isLoading);

      expect(state.loadStatus.isSuccess, isTrue);
      expect(state.failure, isNotNull);
    });

    test('IKKALASI yiqilsa xato holati', () async {
      marketplace.ordersFailure = const ServerFailure('500', 500);
      marketplace.requestsFailure = const ServerFailure('500', 500);
      own.listFailure = const ServerFailure('500', 500);
      final bloc = OrdersBloc(repository: composite);
      addTearDown(bloc.close);

      bloc.add(const OrdersLoadRequested());
      final state = await bloc.stream
          .firstWhere((state) => !state.loadStatus.isLoading);

      expect(state.loadStatus.isFailure, isTrue);
    });
  });

}
