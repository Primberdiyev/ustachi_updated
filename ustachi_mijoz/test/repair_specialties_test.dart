import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_flow.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/repair/domain/repair_problem.dart';
import 'package:ustachi/features/repair/presentation/view/repair_order_page.dart';

/// TA'MIR HAR SOHADA (foydalanuvchi qarori 2026-10-09, "B" varianti): soha
/// ichida "Yangi ish / Ta'mir" tanlovi; ta'mirda o'lcham so'ralmaydi.
void main() {
  const plumberJson = {
    'id': 7,
    'code': 'santexnik',
    'name': 'Santexnik',
    'unit': '',
    'calculator': 'heating',
    'has_repair': true,
    'repair_problems': [
      {'code': 'kran', 'title': 'Kran yoki smesitel', 'hint': 'Oqyapti yoki almashtirish kerak'},
      {'code': 'tiqilish', 'title': 'Kanalizatsiya tiqilgan', 'hint': ''},
    ],
  };

  test('server belgisi va muammolar o\'qiladi; keshga yozilib qayta o\'qiladi', () {
    final plumber = SpecialtyEntity.fromJson(plumberJson);
    expect(plumber.hasRepair, isTrue);
    expect(plumber.repairProblems.map((p) => p.code), ['kran', 'tiqilish']);
    expect(SpecialtyEntity.fromJson(plumber.toJson()), plumber);

    final old = SpecialtyEntity.fromJson(const {'id': 7, 'code': 'santexnik', 'name': 'Santexnik'});
    expect(old.hasRepair, isFalse);
    expect(old.repairProblems, isEmpty);
  });

  test('bandlar: sohada serverdagilar + "Boshqa"; eshik-romda ilovadagi ro\'yxat', () {
    final plumber = repairOptionsFor(SpecialtyEntity.fromJson(plumberJson));
    expect(plumber.map((o) => o.code), ['kran', 'tiqilish', 'boshqa']);

    const rom = SpecialtyEntity(id: 1, code: SpecialtyEntity.romCode, name: 'Rom');
    final romOptions = repairOptionsFor(rom);
    expect(romOptions.length, RepairProblem.values.length);
    expect(romOptions.where((o) => o.isOther).length, 1);
    expect(romOptions.first.code, 'tutqich');
  });

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(TranslationProvider(
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (_, __) => MaterialApp(theme: ThemeData(fontFamily: 'SfProDisplay'), home: home),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('santexnik bosilganda tanlov chiqadi; "Ta\'mir" — o\'lchovsiz muammolar ro\'yxati', (tester) async {
    final plumber = SpecialtyEntity.fromJson(plumberJson);
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(onPressed: () => openSpecialtyFlow(context, plumber), child: const Text('ochish')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ochish'));
    await tester.pumpAndSettle();

    expect(find.text('Sizga nima kerak?'), findsOneWidget);
    expect(find.text('Yangi ish'), findsOneWidget);
    await tester.tap(find.text('Ta\'mir'));
    await tester.pumpAndSettle();

    expect(find.byType(RepairOrderPage), findsOneWidget);
    expect(find.text('Kran yoki smesitel'), findsOneWidget);
    expect(find.text('Boshqa muammo'), findsOneWidget);
    // Eshik-rom bandlari bu yerda yo'q.
    expect(find.text('Tutqich (ruchka)'), findsNothing);

    // Hech narsa belgilanmagan — davom etib bo'lmaydi.
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    await tester.tap(find.text('Kran yoki smesitel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keyingisi'));
    await tester.pumpAndSettle();

    // Ikkinchi qadam: rom soni va materiali so'ralmaydi, qavat va izoh bor.
    expect(find.text('Nechta rom yoki eshik?'), findsNothing);
    expect(find.text('Usta chaqirish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eshik-rom ta\'mirida soni va materiali avvalgidek so\'raladi', (tester) async {
    const rom = SpecialtyEntity(id: 1, code: SpecialtyEntity.romCode, name: 'Rom', hasRepair: true);
    await pumpApp(tester, const RepairOrderPage(specialty: rom));
    await tester.tap(find.text('Tutqich (ruchka)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keyingisi'));
    await tester.pumpAndSettle();
    expect(find.text('Nechta rom yoki eshik?'), findsOneWidget);
  });
}
