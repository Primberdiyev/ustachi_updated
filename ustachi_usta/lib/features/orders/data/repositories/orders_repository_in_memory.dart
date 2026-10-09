import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OrdersRepositoryInMemory implements OrdersRepository {
  OrdersRepositoryInMemory({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _seed();
  }

  final DateTime Function() _clock;

  final List<OrderRequestEntity> _requests = [];
  final List<MasterOrderEntity> _orders = [];

  static const _latency = Duration(milliseconds: 350);

  void _seed() {
    final now = _clock();

    _requests.addAll([
      OrderRequestEntity(
        id: 'req-2418',
        number: '#2418',
        title: 'Oyna almashtirish · 4 rom',
        summary: 'Yunusobod 12-kv · 60 mm',
        clientName: 'Dilnoza Karimova',
        address: 'Yunusobod 12-kvartal, 34-uy',
        distanceKm: 6.4,
        calculatedPrice: 4850000,
        expiresAt: now.add(const Duration(hours: 6)),
        windows: ['1400×1600', '2100×1600'],
        spec: {
          'Profil': '60 mm · oq',
          'Shisha paketi': '4-16-4 energiya',
          'Furnitura': 'Vorne · burama-ochma',
          'Jami maydon': '5.6 m²',
        },
      ),
      OrderRequestEntity(
        id: 'req-2419',
        number: '#2419',
        title: 'Balkon romi · burchakli',
        summary: 'Chilonzor 9-kv · 3200×2700 mm',
        clientName: 'Jasur Abdullayev',
        address: 'Chilonzor 9-kvartal, 12-uy',
        distanceKm: 11.2,
        calculatedPrice: 8320000,
        expiresAt: now.add(const Duration(hours: 2)),
        windows: ['3200×2700'],
        spec: {
          'Profil': '70 mm · oq',
          'Shisha paketi': '4-10-4',
          'Furnitura': 'Vorne · surma',
          'Jami maydon': '8.6 m²',
        },
      ),
    ]);

    _orders.addAll([
      MasterOrderEntity(
        id: 'ord-2394',
        number: '#2394',
        title: 'Oyna almashtirish',
        summary: 'Yunusobod · 4 rom',
        clientName: 'Dilnoza Karimova',
        address: 'Yunusobod 12-kv, 34-uy',
        totalPrice: 5270000,
        prepaid: 2600000,
        stage: OrderStage.production,
        createdAt: now.subtract(const Duration(days: 9)),
        dueDate: now.add(const Duration(days: 2)),
        unreadMessages: 1,
        spec: {
          'Profil': '60 mm · oq',
          'Shisha': '4-16-4 energiya',
          'Furnitura': 'Vorne · burama-ochma',
        },
        stageDates: {
          OrderStage.accepted: now.subtract(const Duration(days: 9)),
          OrderStage.measured: now.subtract(const Duration(days: 7)),
        },
      ),
      MasterOrderEntity(
        id: 'ord-2388',
        number: '#2388',
        title: 'Balkon romi',
        summary: 'Chilonzor · burchakli',
        clientName: 'Aziz Tursunov',
        address: 'Chilonzor 9-kv, 4-uy',
        totalPrice: 9140000,
        prepaid: 4500000,
        stage: OrderStage.installation,
        createdAt: now.subtract(const Duration(days: 16)),
        dueDate: now.subtract(const Duration(days: 2)),
        spec: {
          'Profil': '70 mm · oq',
          'Shisha': '4-10-4',
        },
        stageDates: {
          OrderStage.accepted: now.subtract(const Duration(days: 16)),
          OrderStage.measured: now.subtract(const Duration(days: 14)),
          OrderStage.production: now.subtract(const Duration(days: 5)),
        },
      ),
      MasterOrderEntity(
        id: 'ord-2401',
        number: '#2401',
        title: 'Eshik va rom',
        summary: 'Mirobod · 2 rom + 1 eshik',
        clientName: 'Nodira Saidova',
        address: 'Mirobod, Amir Temur 41',
        totalPrice: 3620000,
        prepaid: 1800000,
        stage: OrderStage.measured,
        createdAt: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 8)),
        spec: {
          'Profil': '60 mm · oq',
          'Shisha': '4-16-4 energiya',
        },
        stageDates: {
          OrderStage.accepted: now.subtract(const Duration(days: 3)),
        },
      ),
      MasterOrderEntity(
        id: 'ord-2377',
        number: '#2377',
        title: 'Vitraj rom',
        summary: 'Sergeli · 6 rom',
        clientName: 'Kamola Rasulova',
        address: 'Sergeli 4, 18-uy',
        totalPrice: 12400000,
        prepaid: 12400000,
        stage: OrderStage.handover,
        createdAt: now.subtract(const Duration(days: 34)),
        dueDate: now.subtract(const Duration(days: 4)),
        completedAt: now.subtract(const Duration(days: 3)),
        rating: 5,
        spec: {
          'Profil': '70 mm · oq',
          'Shisha': 'Triplex',
        },
        stageDates: {
          OrderStage.accepted: now.subtract(const Duration(days: 34)),
          OrderStage.measured: now.subtract(const Duration(days: 30)),
          OrderStage.production: now.subtract(const Duration(days: 12)),
          OrderStage.installation: now.subtract(const Duration(days: 5)),
          OrderStage.handover: now.subtract(const Duration(days: 3)),
        },
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<OrderRequestEntity>>> requests() async {
    await Future<void>.delayed(_latency);
    final now = _clock();
    return Right(
      _requests.where((request) => !request.isExpired(now)).toList(),
    );
  }

  @override
  Future<Either<Failure, List<MasterOrderEntity>>> orders() async {
    await Future<void>.delayed(_latency);
    return Right(List.unmodifiable(_orders));
  }

  @override
  Future<Either<Failure, MasterOrderEntity>> historicalDetail(
      String orderId) async {
    final order = _orders.where((item) => item.id == orderId).firstOrNull;
    return order == null
        ? Left(ParsingFailure(t.orders.detail.notFound))
        : Right(order);
  }

  @override
  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  }) async {
    await Future<void>.delayed(_latency);

    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) {
      return Left(ParsingFailure(t.orders.request.expired));
    }

    _requests[index] = _requests[index].copyWith(offerSent: true);
    return Right(null);
  }

  @override
  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited = false,
    String reason = '',
  }) async {
    await Future<void>.delayed(_latency);
    _requests.removeWhere((request) => request.id == requestId);
    return Right(null);
  }

  @override
  Future<Either<Failure, MasterOrderEntity>> completeStage(
    String orderId,
  ) async {
    await Future<void>.delayed(_latency);

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return Left(ParsingFailure(t.orders.detail.notFound));
    }

    final order = _orders[index];
    final now = _clock();
    final stageDates = Map<OrderStage, DateTime>.from(order.stageDates)
      ..[order.stage] = now;

    final updated = order.copyWith(
      stage: order.stage.next ?? order.stage,
      completedAt: order.stage.isLast ? now : null,
      stageDates: stageDates,
    );

    _orders[index] = updated;
    return Right(updated);
  }
}
