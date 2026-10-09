
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/presentation/view/order_request_page.dart';

OrderRequestEntity _request({
  bool isInvited = false,
  bool inviteDeclined = false,
  bool offerSent = false,
}) =>
    OrderRequestEntity(
      id: '1',
      number: '#1',
      title: '2 qanotli oq deraza',
      clientName: 'Mijoz',
      address: 'Chilonzor 5',
      distanceKm: 0,
      calculatedPrice: 4280636,
      expiresAt: DateTime(2030),
      isInvited: isInvited,
      inviteDeclined: inviteDeclined,
      offerSent: offerSent,
    );

Future<void> _pump(
  WidgetTester tester,
  OrderRequestEntity request, {
  bool busy = false,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: OrderRequestActionBar(
            request: request,
            busy: busy,
            onSend: () {},
            onDecline: () {},
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  final tr = t.orders.request;

  group('Oddiy OCHIQ e\'lon', () {
    testWidgets('faqat "Taklifni yuborish" — RAD ETISH tugmasi YO\'Q',
        (tester) async {
      await _pump(tester, _request());

      expect(find.text(tr.send), findsOneWidget);
      expect(find.text(tr.decline), findsNothing,
          reason: 'usta xohlasa oladi, xohlamasa yo\'q');
    });

    testWidgets('tugma butun enni egallaydi va PASTDA turadi', (tester) async {
      await _pump(tester, _request());

      final button = find.widgetWithText(FilledButton, tr.send);
      expect(button, findsOneWidget);

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

      expect(tester.getSize(button).width, greaterThan(screen.width * 0.8));

      expect(tester.getCenter(button).dy, greaterThan(screen.height * 0.8));
    });

    testWidgets('band holatda bosilmaydi', (tester) async {
      await _pump(tester, _request(), busy: true);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('SHAXSIY taklif', () {
    testWidgets('rad etish QOLADI — mijoz javob kutmoqda', (tester) async {
      await _pump(tester, _request(isInvited: true));

      expect(find.text(tr.send), findsOneWidget);
      expect(find.text(tr.decline), findsOneWidget);
    });

    testWidgets('allaqachon rad etilgan bo\'lsa tugma qaytmaydi',
        (tester) async {
      await _pump(tester, _request(isInvited: true, inviteDeclined: true));

      expect(find.text(tr.decline), findsNothing);
      expect(find.text(tr.send), findsOneWidget,
          reason: 'fikridan qaytsa baribir taklif bera olsin');
    });
  });

  group('Taklif YUBORILGAN', () {
    testWidgets('faqat "qaytarib olish" ko\'rinadi', (tester) async {
      await _pump(tester, _request(offerSent: true));

      expect(find.text(tr.withdrawOffer), findsOneWidget);
      expect(find.text(tr.send), findsNothing);
      expect(find.text(tr.decline), findsNothing);
    });
  });
}
