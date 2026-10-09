
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart';

const _kafel = MasterSpecialty(
  id: 8,
  name: 'Kafel-plitka ustasi',
  code: 'kafel',
  unit: 'm²',
  unitQuestion: 'Kafel yotqizishning bir kvadrat metri qancha?',
  variants: [
    MasterSpecialtyVariant(id: 1, name: 'Pol kafeli', size: '40×40 sm'),
    MasterSpecialtyVariant(id: 2, name: 'Devor kafeli', size: '30×60 sm'),
    MasterSpecialtyVariant(id: 3, name: 'Sokl kafeli', size: '60×120 sm'),
  ],
);

const _gisht = MasterSpecialty(
  id: 3,
  name: 'G\'isht teruvchi',
  code: 'gisht',
  unit: 'dona',
  unitQuestion: 'Bitta g\'ishtni qanchadan terasiz?',
);

Widget _wrap(Widget child) => TranslationProvider(
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );

void main() {
  group('Model', () {
    test('turlari bor soha — narx TUR bo\'yicha so\'raladi', () {
      expect(_kafel.asksRate, isTrue);
      expect(_kafel.asksRatePerVariant, isTrue);
    });

    test('turlari yo\'q soha — avvalgidek bitta narx', () {
      expect(_gisht.asksRate, isTrue);
      expect(_gisht.asksRatePerVariant, isFalse);
    });

    test('birligi yo\'q soha — narx umuman so\'ralmaydi', () {
      const rom = MasterSpecialty(id: 1, name: 'Rom ustasi', code: 'rom');
      expect(rom.asksRate, isFalse);
      expect(rom.asksRatePerVariant, isFalse);
    });

    test('serverdagi variantlar o\'qiladi', () {
      final parsed = MasterSpecialty.fromJson({
        'id': 8,
        'name': 'Kafel',
        'code': 'kafel',
        'unit': 'm²',
        'variants': [
          {'id': 1, 'name': 'Pol kafeli', 'size': '40×40 sm'},
          {'id': 3, 'name': 'Sokl kafeli', 'size': '60×120 sm'},
        ],
      });

      expect(parsed.variants.map((v) => v.name).toList(),
          ['Pol kafeli', 'Sokl kafeli']);
      expect(parsed.variants.first.size, '40×40 sm');
      expect(parsed.asksRatePerVariant, isTrue);
    });

    test('narxlar TUR va YO\'NALISH bo\'yicha ajratiladi', () {
      final profile = MasterProfileData.fromJson({
        'rates': [
          {'specialty': 3, 'price': 1500},
          {'specialty': 8, 'variant': 1, 'variant_name': 'Pol', 'price': 60000},
          {'specialty': 8, 'variant': 3, 'variant_name': 'Sokl', 'price': 150000},
        ],
      });

      expect(profile.rateBySpecialty, {3: 1500},
          reason: 'variantsizlari alohida');
      expect(profile.rateByVariant, {1: 60000, 3: 150000});
    });
  });

  group('Forma', () {
    testWidgets('HAR TURGA alohida maydon chiqadi', (tester) async {
      final controllers = <int, TextEditingController>{};
      addTearDown(() {
        for (final c in controllers.values) {
          c.dispose();
        }
      });

      await tester.pumpWidget(_wrap(
        SpecialtyVariantRateFields(
          specialty: _kafel,
          controllerFor: (id) =>
              controllers.putIfAbsent(id, TextEditingController.new),
          enabled: true,
        ),
      ));

      expect(find.text('Pol kafeli'), findsOneWidget);
      expect(find.text('Devor kafeli'), findsOneWidget);
      expect(find.text('Sokl kafeli'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('o\'lchami ko\'rsatiladi', (tester) async {
      final controllers = <int, TextEditingController>{};
      addTearDown(() {
        for (final c in controllers.values) {
          c.dispose();
        }
      });

      await tester.pumpWidget(_wrap(
        SpecialtyVariantRateFields(
          specialty: _kafel,
          controllerFor: (id) =>
              controllers.putIfAbsent(id, TextEditingController.new),
          enabled: true,
        ),
      ));

      expect(find.text('40×40 sm'), findsOneWidget);
      expect(find.text('60×120 sm'), findsOneWidget);
    });

    testWidgets('turlari YO\'Q sohada bitta maydon (regressiya yo\'q)',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_wrap(
        SpecialtyRateField(
          specialty: _gisht,
          controller: controller,
          enabled: true,
        ),
      ));

      expect(find.text(_gisht.unitQuestion), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
