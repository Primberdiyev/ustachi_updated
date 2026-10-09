
import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/presentation/specialty_icons.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

final _now = DateTime(2026, 8, 13, 12);

OrderRequestEntity _request({
  int calculatedPrice = 0,
  String? specialtyCode = 'tom',
  String? specialtyName = 'Tom yopish ustasi',
}) =>
    OrderRequestEntity(
      id: '7',
      number: '#7',
      title: 'Tom yopish ustasi',
      clientName: 'Aziz',
      address: 'Toshkent',
      distanceKm: 0,
      calculatedPrice: calculatedPrice,
      specialtyCode: specialtyCode,
      specialtyName: specialtyName,
      expiresAt: _now.add(const Duration(hours: 5)),
    );

MasterProfileData _profile(List<Map<String, dynamic>> specialties) =>
    MasterProfileData.fromJson({
      'specialty': specialties.isEmpty ? null : specialties.first['id'],
      'specialty_name': specialties.isEmpty ? '' : specialties.first['name'],
      'specialty_list': specialties,
      'experience_years': 5,
    });

void main() {
  group('Profil — ko\'p yo\'nalish', () {
    test('ro\'yxat o\'qiladi va ROM aniqlanadi', () {
      final profile = _profile(const [
        {'id': 2, 'code': 'tom', 'name': 'Tom yopish ustasi'},
        {'id': 1, 'code': 'rom', 'name': 'Rom ustasi'},
      ]);

      expect(profile.specialties.map((s) => s.code), ['tom', 'rom']);
      expect(profile.hasRom, isTrue);

      expect(profile.specialtyId, 2);
    });

    test('ROMSIZ ustada narx hisoblash yo\'q', () {
      final profile = _profile(const [
        {'id': 2, 'code': 'tom', 'name': 'Tom yopish ustasi'},
        {'id': 3, 'code': 'gisht', 'name': 'G\'isht teruvchi'},
      ]);

      expect(profile.hasRom, isFalse);
    });

    test('ESKI server ro\'yxatni bermasa — rom deb qaraladi', () {

      final profile = MasterProfileData.fromJson(const {
        'specialty': 1,
        'specialty_name': 'Rom ustasi',
        'experience_years': 5,
      });

      expect(profile.specialties, isEmpty);
      expect(profile.hasRom, isTrue);
    });

    test('profilsiz holatda hasRom FALSE', () {
      const profile = MasterProfileData();
      expect(profile.hasRom, isFalse);
    });
  });

  group('Yo\'nalish ikonkasi', () {
    test('kod bo\'yicha tanlanadi', () {
      expect(specialtyIcon('rom'), Icons.window_outlined);
      expect(specialtyIcon('tom'), Icons.roofing_outlined);
      expect(specialtyIcon('mardikor'), Icons.engineering_outlined);

      expect(specialtyIcon('zina'), Icons.stairs_outlined);
      expect(specialtyIcon('parda'), Icons.blinds_outlined);
      expect(specialtyIcon('landshaft'), Icons.yard_outlined);

      expect(specialtyIcon('kamera'), Icons.videocam_outlined);
    });

    test('kod yo\'q — eski buyurtma, oyna ikonkasi', () {
      expect(specialtyIcon(null), Icons.window_outlined);
      expect(specialtyIcon(''), Icons.window_outlined);
    });

    test('notanish kod — umumiy asbob (ilova yiqilmaydi)', () {
      expect(specialtyIcon('kelajakdagi_soha'), Icons.handyman_outlined);
    });
  });

  group('Narxsiz e\'lon kartasi', () {
    Future<void> pump(WidgetTester tester, OrderRequestEntity request) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OrderRequestCard(request: request, now: _now),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('"0 so\'m" o\'rniga kelishuv izohi', (tester) async {
      await pump(tester, _request());

      expect(find.text(t.orders.request.priceInChat), findsOneWidget);

      expect(find.byType(ChizmaPrice), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rom e\'lonida narx avvalgidek turadi', (tester) async {
      await pump(
        tester,
        _request(
          calculatedPrice: 1280000,
          specialtyCode: 'rom',
          specialtyName: 'Rom ustasi',
        ),
      );

      final price = tester.widget<ChizmaPrice>(find.byType(ChizmaPrice));
      expect(price.amount, ChizmaMoney.format(1280000));
      expect(find.text(t.orders.request.priceInChat), findsNothing);
    });
  });
}
