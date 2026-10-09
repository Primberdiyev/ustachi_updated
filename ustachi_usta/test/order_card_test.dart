
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_card.dart';
import 'support/l10n_harness.dart';

final _now = DateTime(2026, 9, 8);

MasterOrderEntity _order({
  OrderStage stage = OrderStage.measured,
  int unread = 0,
  String? specialtyCode,
  DateTime? completed,
  int? rating,
}) =>
    MasterOrderEntity(
      id: '1',
      number: '#1042',
      title: 'Balkon romi',
      clientName: 'Aziz aka',
      address: 'Yunusobod 12',
      summary: 'Yunusobod 12',
      totalPrice: 4250000,
      stage: stage,
      createdAt: DateTime(2026, 9, 1, 14, 20),
      completedAt: completed,
      rating: rating,
      unreadMessages: unread,
      specialtyCode: specialtyCode,
    );

Future<void> _pump(WidgetTester tester, MasterOrderEntity order) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: OrderCard(order: order, now: _now),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bosqich belgisi ko\'rinadi', (tester) async {
    await _pump(tester, _order());

    expect(find.byIcon(Icons.straighten_rounded), findsOneWidget);
  });

  testWidgets('SANA vaqtsiz yoziladi', (tester) async {
    await _pump(tester, _order());

    expect(find.text('1-sen'), findsOneWidget);
    expect(find.textContaining('14:20'), findsNothing);
  });

  group('o\'qilmagan xabarlar nishoni', () {
    testWidgets('xabar bo\'lsa chiqadi', (tester) async {
      await _pump(tester, _order(unread: 3));
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    });

    testWidgets('xabar yo\'q bo\'lsa chiqmaydi', (tester) async {
      await _pump(tester, _order());
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    });

    testWidgets('99 dan oshsa qisqartiriladi', (tester) async {
      await _pump(tester, _order(unread: 128));
      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('bosqich sanog\'i sohaga qarab', () {
    testWidgets('ROM — ikki bosqich', (tester) async {
      await _pump(tester, _order());
      expect(find.text('2-bosqich / 2'), findsOneWidget);
    });

    testWidgets('boshqa soha — bitta bosqich', (tester) async {

      await _pump(
        tester,
        _order(stage: OrderStage.accepted, specialtyCode: 'darvoza'),
      );
      expect(find.text('1-bosqich / 1'), findsOneWidget);
    });
  });

  testWidgets('YAKUNLANGAN buyurtmada bosqich o\'rniga baho', (tester) async {
    await _pump(
      tester,
      _order(
        stage: OrderStage.handover,
        completed: DateTime(2026, 9, 5),
        rating: 4,
      ),
    );
    expect(find.textContaining('bosqich'), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
  });
}
