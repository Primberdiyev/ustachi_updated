
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';

import 'orders_composite_test.dart' show FakeMarketplace;

MasterOrderEntity _order(OrderStage stage) => MasterOrderEntity(
      id: '42',
      number: '#42',
      title: '2 qanotli oq deraza',
      summary: 'Yunusobod',
      clientName: 'Aziz',
      address: 'Toshkent',
      totalPrice: 1280000,
      stage: stage,
      createdAt: DateTime(2026, 8, 10),
    );

Future<void> _pump(WidgetTester tester, MasterOrderEntity order) async {
  tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
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
              child: OrderDetailView(order: order),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  group('Bosqich tugmasi', () {
    testWidgets('"Foto qo\'shish" tugmasi YO\'Q', (tester) async {
      await _pump(tester, _order(OrderStage.accepted));

      expect(find.text('Foto qo\'shish'), findsNothing);
      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
    });

    testWidgets('tanlangan zahoti tugma "O\'lchov olindi" deydi',
        (tester) async {

      await _pump(tester, _order(OrderStage.accepted));

      expect(find.widgetWithText(ElevatedButton, 'O\'lchov olindi'),
          findsOneWidget);
      expect(find.text('Bosqichni yakunlash'), findsNothing);
    });

    testWidgets('O\'LCHOVDAN keyin darhol yakunlash', (tester) async {

      await _pump(tester, _order(OrderStage.measured));
      expect(find.widgetWithText(ElevatedButton, 'Topshirish va yakunlash'),
          findsOneWidget);
      expect(find.text('Ishlab chiqarish boshlandi'), findsNothing);
    });

    testWidgets('ESKI zanjirdagi buyurtma ham bir bosishda yakunlanadi',
        (tester) async {
      for (final stage in [
        OrderStage.production,
        OrderStage.installation,
        OrderStage.handover,
      ]) {
        await _pump(tester, _order(stage));
        expect(find.widgetWithText(ElevatedButton, 'Topshirish va yakunlash'),
            findsOneWidget,
            reason: '$stage');
      }
    });
  });

  group('Tugma tizim paneli ortida QOLMAYDI', () {

    const navBar = 48.0;
    const screen = Size(390, 844);

    MasterOrderEntity longOrder() => MasterOrderEntity(
          id: '42',
          number: '#42',
          title: '2 qanotli oq deraza',
          summary: 'Yunusobod',
          clientName: 'Aziz',
          address: 'Toshkent',
          totalPrice: 1280000,
          stage: OrderStage.accepted,
          createdAt: DateTime(2026, 8, 10),
          drawings: const [
            (
              spec: FramePreviewSpec(
                aspectRatio: 0.94,
                lines: [FrameLine(0, 0.5, 1, 0.5)],
                widthMm: 1500,
                heightMm: 1600,
              ),
              frameArgb: null,
            ),
            (
              spec: FramePreviewSpec(
                aspectRatio: 1.2,
                lines: [FrameLine(0.5, 0, 0.5, 1)],
                widthMm: 1800,
                heightMm: 1500,
              ),
              frameArgb: null,
            ),
          ],
          spec: const {
            'profile': 'Alta Plast 58',
            'glass': '4-16-4',
            'hardware': 'Vorne',
            'color': 'Oq',
          },
        );

    Future<Rect> pumpPage(WidgetTester tester, MasterOrderEntity order) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = screen * 3;
      tester.view.padding = const FakeViewPadding(bottom: navBar * 3);
      tester.view.viewPadding = const FakeViewPadding(bottom: navBar * 3);
      addTearDown(tester.view.reset);

      final repository = FakeMarketplace()..ordersList = [order];
      final bloc = OrdersBloc(repository: repository);
      addTearDown(bloc.close);
      bloc.add(OrdersLoadRequested());
      await bloc.stream.firstWhere((state) => !state.loadStatus.isLoading);

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => TranslationProvider(
          child: MaterialApp(
            home: BlocProvider.value(
              value: bloc,
              child: OrderDetailPage(orderId: order.id),
            ),
          ),
        ),
      ));
      await tester.pump();

      return tester.getRect(
        find.widgetWithText(ElevatedButton, 'O\'lchov olindi'),
      );
    }

    testWidgets('aylantirmasdan TURIB ko\'rinadi', (tester) async {
      final rect = await pumpPage(tester, longOrder());

      expect(rect.top, greaterThanOrEqualTo(0.0));
      expect(rect.bottom, lessThanOrEqualTo(screen.height),
          reason: 'tugma ekran ichida');
    });

    testWidgets('tizim tugmalari ustida turadi', (tester) async {

      final rect = await pumpPage(tester, longOrder());

      expect(rect.bottom, lessThanOrEqualTo(screen.height - navBar));
    });

    testWidgets('ro\'yxat ichida IKKINCHI nusxa yo\'q', (tester) async {
      await pumpPage(tester, longOrder());

      expect(find.widgetWithText(ElevatedButton, 'O\'lchov olindi'),
          findsOneWidget);
    });
  });
}
