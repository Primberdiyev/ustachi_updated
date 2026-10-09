
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/open_orders_page.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';

Future<OrdersBloc> _pump(WidgetTester tester) async {

  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final bloc = OrdersBloc(repository: OrdersRepositoryInMemory());
  addTearDown(bloc.close);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: BlocProvider<OrdersBloc>.value(
          value: bloc,
          child: OpenOrdersPage(onOpenRequest: (_, __) {}),
        ),
      ),
    ),
  ));

  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  return bloc;
}

void main() {
  testWidgets('sarlavha, ikki bo\'lim va e\'lon kartalari', (tester) async {
    final bloc = await _pump(tester);
    final tr = t.orders;

    expect(find.text(tr.open.pageTitle), findsOneWidget);

    expect(find.text(tr.open.tabWaiting), findsWidgets);
    expect(find.text(tr.open.tabSent), findsWidgets);

    expect(bloc.state.requests, isNotEmpty);
    expect(find.byType(OrderRequestCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TAKLIF BERILGAN bo\'limi javob berilganlarni ko\'rsatadi',
      (tester) async {
    final bloc = await _pump(tester);
    final tr = t.orders;

    expect(bloc.state.awaitingRequests, isEmpty);
    final first = bloc.state.requests.first;

    bloc.add(OrderOfferSent(requestId: first.id));

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(bloc.state.awaitingRequests.length, 1);

    await tester.tap(find.text(tr.open.tabSent).last);
    await tester.pump();
    expect(find.text(tr.open.offerSent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bo\'sh bo\'limda tushuntirish matni chiqadi', (tester) async {
    final bloc = await _pump(tester);
    final tr = t.orders;

    expect(bloc.state.awaitingRequests, isEmpty);
    await tester.tap(find.text(tr.open.tabSent).last);
    await tester.pump();

    expect(find.text(tr.open.emptySentTitle), findsOneWidget);
    expect(find.byType(OrderRequestCard), findsNothing);
  });
}
