
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart';

void main() {
  group('Katalog — o\'lchov birligi', () {
    test('birlik va savol o\'qiladi', () {
      final gisht = MasterSpecialty.fromJson(const {
        'id': 3,
        'code': 'gisht',
        'name': 'G\'isht teruvchi',
        'unit': 'dona',
        'unit_question': 'Bitta g\'ishtni qanchadan terasiz?',
      });

      expect(gisht.unit, 'dona');
      expect(gisht.unitQuestion, contains('g\'ishtni'));
      expect(gisht.asksRate, isTrue);
    });

    test('birligi yo\'q sohada narx SO\'RALMAYDI', () {

      final rom = MasterSpecialty.fromJson(const {
        'id': 1,
        'code': 'rom',
        'name': 'Rom ustasi',
        'unit': '',
      });

      expect(rom.asksRate, isFalse);
      expect(rom.isRom, isTrue);
    });

    test('ESKI server birlik bermasa — yiqilmaydi', () {
      final row = MasterSpecialty.fromJson(const {'id': 2, 'name': 'Tom'});

      expect(row.unit, '');
      expect(row.asksRate, isFalse);
    });
  });

  group('Profil javobi', () {
    MasterProfileData profile(List<Map<String, dynamic>> rates) =>
        MasterProfileData.fromJson({
          'specialty': 3,
          'specialty_list': const [
            {'id': 3, 'code': 'gisht', 'name': 'G\'isht', 'unit': 'dona'},
            {'id': 18, 'code': 'zina', 'name': 'Zina', 'unit': 'metr'},
          ],
          'rates': rates,
          'experience_years': 5,
        });

    test('narxlar birligi bilan o\'qiladi', () {
      final data = profile(const [
        {
          'specialty': 3,
          'code': 'gisht',
          'name': 'G\'isht',
          'unit': 'dona',
          'price': 1500,
        },
      ]);

      expect(data.specialtyRates, hasLength(1));
      expect(data.specialtyRates.first.unit, 'dona');
      expect(data.specialtyRates.first.price, 1500);
    });

    test('rateBySpecialty — maydonlarni to\'ldirish uchun xarita', () {
      final data = profile(const [
        {'specialty': 3, 'price': 1500},
        {'specialty': 18, 'price': 350000},
      ]);

      expect(data.rateBySpecialty, {3: 1500, 18: 350000});
    });

    test('ESKI serverda narx yo\'q — bo\'sh ro\'yxat', () {
      final data = MasterProfileData.fromJson(const {
        'specialty': 3,
        'experience_years': 5,
      });

      expect(data.specialtyRates, isEmpty);
      expect(data.rateBySpecialty, isEmpty);
    });

  });

  group('Narx maydoni (ekran)', () {
    Future<void> pump(
      WidgetTester tester,
      MasterSpecialty specialty, {
      String value = '',
    }) async {
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
              body: SpecialtyRateField(
                specialty: specialty,
                controller: TextEditingController(text: value),
                enabled: true,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    const gisht = MasterSpecialty(
      id: 3,
      name: 'G\'isht teruvchi',
      code: 'gisht',
      unit: 'dona',
      unitQuestion: 'Bitta g\'ishtni qanchadan terasiz?',
    );

    testWidgets('SOHA TILIDAGI savol va birlik ko\'rinadi', (tester) async {
      await pump(tester, gisht);

      expect(find.text('Bitta g\'ishtni qanchadan terasiz?'), findsOneWidget);
      expect(find.text('/ dona'), findsOneWidget);
      expect(find.text('so\'m'), findsOneWidget);
    });

    testWidgets('saqlangan narx maydonda turadi', (tester) async {
      await pump(tester, gisht, value: '1500');

      expect(find.text('1500'), findsOneWidget);
    });

    testWidgets('savol berilmasa ham tushunarli matn chiqadi',
        (tester) async {

      await pump(
        tester,
        const MasterSpecialty(
          id: 18, name: 'Zina ustasi', code: 'zina', unit: 'metr'),
      );

      expect(find.textContaining('bir metr'), findsOneWidget);
      expect(find.text('/ metr'), findsOneWidget);
    });

    testWidgets('faqat RAQAM kiritiladi', (tester) async {
      await pump(tester, gisht);

      await tester.enterText(find.byType(TextFormField), '1a5b0x0');
      await tester.pump();

      expect(find.text('1500'), findsOneWidget);
    });
  });
}
