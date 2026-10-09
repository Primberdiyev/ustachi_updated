import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';

void main() {
  late OrdersBloc bloc;

  setUp(() {
    bloc = OrdersBloc(repository: OrdersRepositoryInMemory());
  });

  tearDown(() async {
    await bloc.close();
  });

  Future<void> load() async {
    bloc.add(const OrdersLoadRequested());
    await bloc.stream.firstWhere((state) => state.loadStatus.isSuccess);
  }

  group('OrderStage', () {
    test('ROMDA IKKI bosqich: qabul va o\'lchov', () {
      expect(OrderStage.stagesFor(isRom: true),
          [OrderStage.accepted, OrderStage.measured]);
      expect(OrderStage.accepted.step, 1);
      expect(OrderStage.measured.step, 2);
    });

    test("boshqa yo'nalishda o'lchov bosqichi yo'q", () {
      expect(OrderStage.stagesFor(isRom: false), [OrderStage.accepted]);
    });

    test('eski zanjir bosqichlari ESKI deb belgilanadi', () {
      expect(OrderStage.production.isLegacy, isTrue);
      expect(OrderStage.installation.isLegacy, isTrue);
      expect(OrderStage.handover.isLegacy, isTrue);
      expect(OrderStage.measured.isLegacy, isFalse);
    });
  });

  group('yuklash', () {
    test('so\'rovlar va buyurtmalar bitta o\'qishda keladi', () async {
      await load();

      expect(bloc.state.requests, isNotEmpty);
      expect(bloc.state.orders, isNotEmpty);
      expect(bloc.state.failure, isNull);
    });

    test('segment hisoblari bir-birini takrorlamaydi', () async {
      await load();
      final state = bloc.state;

      expect(state.countFor(OrdersSegment.fresh), state.requests.length);
      expect(
        state.countFor(OrdersSegment.inProgress) +
            state.countFor(OrdersSegment.completed),
        state.orders.length,
      );
    });

    test('yakunlangan buyurtma faol ro\'yxatga tushmaydi', () async {
      await load();

      expect(
        bloc.state.activeOrders.any((order) => order.isCompleted),
        isFalse,
      );
      expect(
        bloc.state.completedOrders.every((order) => order.isCompleted),
        isTrue,
      );
    });
  });

  group('taklif berish', () {
    test('taklif yuborilgan e\'lon OCHIQ ro\'yxatda qoladi, buyurtma YARATILMAYDI',
        () async {
      await load();

      final request = bloc.state.requests.first;
      final requestCountBefore = bloc.state.requests.length;
      final orderCountBefore = bloc.state.orders.length;
      expect(request.offerSent, isFalse);

      bloc.add(OrderOfferSent(requestId: request.id));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      final state = bloc.state;

      expect(state.requests.length, requestCountBefore);
      expect(
        state.requests.firstWhere((item) => item.id == request.id).offerSent,
        isTrue,
      );

      expect(state.orders.length, orderCountBefore);
      expect(state.segment, OrdersSegment.fresh);
    });

    test('taklif yuborilganlar ro\'yxatning ikkinchi yarmida (amal birinchi)',
        () async {
      await load();

      final request = bloc.state.requests.first;
      bloc.add(OrderOfferSent(requestId: request.id));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      final state = bloc.state;

      expect(state.openRequests.any((item) => item.id == request.id), isFalse);
      expect(state.awaitingRequests.map((item) => item.id), contains(request.id));
      expect(
        state.openRequests.length + state.awaitingRequests.length,
        state.requests.length,
      );
    });

    test('rad etilgan so\'rov ro\'yxatdan o\'chadi', () async {
      await load();

      final request = bloc.state.requests.first;
      final before = bloc.state.requests.length;

      bloc.add(OrderRequestDeclined(request.id));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      expect(bloc.state.requests.length, before - 1);
      expect(
        bloc.state.requests.any((item) => item.id == request.id),
        isFalse,
      );
    });
  });

  group('bosqichni yakunlash', () {
    test('bosqich keyingisiga o\'tadi va sana yoziladi', () async {
      await load();

      final order =
          bloc.state.activeOrders.firstWhere((item) => !item.stage.isLast);
      final stageBefore = order.stage;

      bloc.add(OrderStageCompleted(order.id));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      final updated =
          bloc.state.orders.firstWhere((item) => item.id == order.id);

      expect(updated.stage, stageBefore.next);
      expect(updated.stageDates.containsKey(stageBefore), isTrue);
      expect(updated.isCompleted, isFalse);
    });

    test('oxirgi bosqich buyurtmani yakunlaydi', () async {
      await load();

      var order =
          bloc.state.activeOrders.firstWhere((item) => !item.stage.isLast);

      while (!order.stage.isLast) {
        bloc.add(OrderStageCompleted(order.id));
        await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);
        order = bloc.state.orders.firstWhere((item) => item.id == order.id);
      }

      bloc.add(OrderStageCompleted(order.id));
      await bloc.stream.firstWhere((state) => state.actionStatus.isSuccess);

      final finished =
          bloc.state.orders.firstWhere((item) => item.id == order.id);

      expect(finished.isCompleted, isTrue);
      expect(finished.completedAt, isNotNull);

      expect(bloc.state.activeOrders.contains(finished), isFalse);
      expect(bloc.state.completedOrders.contains(finished), isTrue);
    });
  });

  group('kechikish', () {
    test('muddati o\'tgan va tugamagan ish kechikkan hisoblanadi', () async {
      await load();

      final now = DateTime.now();
      final late = bloc.state.orders.where((order) => order.isLate(now));

      expect(late, isNotEmpty, reason: 'seed ichida kechikkan ish bor');
      for (final order in late) {
        expect(order.isCompleted, isFalse);
        expect(order.lateDays(now), greaterThan(0));
      }
    });

    test('yakunlangan buyurtma hech qachon kechikkan emas', () async {
      await load();

      final now = DateTime.now();
      for (final order in bloc.state.completedOrders) {
        expect(order.isLate(now), isFalse);
        expect(order.lateDays(now), 0);
      }
    });
  });
}
