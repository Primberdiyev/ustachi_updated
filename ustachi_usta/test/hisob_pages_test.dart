
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/presentation/hisob_list_page.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

late HisobStore _store;

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1284, 2778);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(home: HisobListPage(store: _store)),
    ),
  ));
  await tester.pumpAndSettle();
}

HisobItem _item({double w = 1500, double h = 1400, int qty = 1}) => HisobItem(
      id: newHisobId(),
      kind: HisobKind.window,
      design: hisob.FrameDesign(
        widthMm: w,
        heightMm: h,
        root: const hisob.Split(
          axis: hisob.Axis.vertical,
          positionsMm: [750],
          children: [hisob.Wing(hisob.WingKind.tiltTurn), hisob.Zone()],
        ),
      ),
      settings: ItemSettings(qty: qty),
    );

HisobProject _project({String client = 'Aliyev', List<HisobItem>? items}) => HisobProject(
      id: newHisobId(),
      client: client,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: items ?? [_item()],
    );

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Ustachi Pro',
      packageName: 'com.ustachi.pro',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageRepository.getInstance();
    await StorageRepository.clearStorage();
    _store = HisobStore();
  });

  testWidgets('hisob yo\'q: bo\'sh holat va "Yangi hisob"', (tester) async {
    await _pump(tester);
    expect(find.text('Hali hisob yo\'q'), findsOneWidget);
    expect(find.text('Yangi hisob'), findsWidgets);
  });

  testWidgets('hisoblar ro\'yxati: mijoz va dona, narx yo\'q', (tester) async {
    _store.save(_project(client: 'Aliyev, 3-xonadon', items: [_item(qty: 2)]));
    await _pump(tester);

    expect(find.text('Aliyev, 3-xonadon'), findsOneWidget);
    expect(find.textContaining('2 dona'), findsOneWidget);
    expect(find.textContaining('so\'m'), findsNothing);
  });

  testWidgets('buyurtma ma\'lumoti: kiritiladi va saqlanadi, pul maydoni yo\'q', (tester) async {
    final p = _project(client: '');
    _store.save(p);
    await _pump(tester);
    await tester.tap(find.text('Nomsiz hisob'));
    await tester.pumpAndSettle();

    expect(find.text('Buyurtma ma\'lumoti'), findsOneWidget);
    await tester.tap(find.text('Buyurtma ma\'lumoti'));
    await tester.pumpAndSettle();

    Future<void> fill(String label, String value) async {
      final field = find.widgetWithText(TextField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pump();
    }

    await fill('Mijoz ismi', 'Karimov Anvar');
    await fill('Telefon raqami', '+998 90 123 45 67');
    await fill('Manzil', 'Chilonzor 5-mavze, 12-uy');
    for (final gone in ['Kelishilgan narx, so\'m', 'Zaklad (oldindan olingan), so\'m', 'Qolgan to\'lov']) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
    expect(find.textContaining('so\'m'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final saved = _store.byId(p.id)!;
    expect(saved.client, 'Karimov Anvar');
    expect(saved.order.phone, '+998 90 123 45 67');
    expect(saved.order.address, 'Chilonzor 5-mavze, 12-uy');

    expect(find.text('Karimov Anvar'), findsWidgets);
    expect(find.text('Chilonzor 5-mavze, 12-uy'), findsOneWidget);
    expect(find.textContaining('so\'m'), findsNothing);
  });

  test('buyurtma ma\'lumoti saqlash/o\'qishda yo\'qolmaydi; eski hisobda bo\'sh', () {
    final p = _project().copyWith(
      order: HisobOrder(
        phone: '+998901234567',
        address: 'Toshkent',
        deadline: DateTime(2026, 10, 15),
      ),
    );
    final back = HisobProject.fromJson(p.toJson());
    expect(back.order.phone, '+998901234567');
    expect(back.order.address, 'Toshkent');
    expect(back.order.deadline, DateTime(2026, 10, 15));
    final old = HisobProject.fromJson(_project().toJson()..remove('order'));
    expect(old.order.isEmpty, isTrue);

    final legacy = HisobOrder.fromJson(const {'phone': '+998901234567', 'agreed': 5000000, 'deposit': 1500000});
    expect(legacy.phone, '+998901234567');
    expect(legacy.toJson().keys, ['phone']);
  });

  testWidgets('Yangi hisob: Deraza/Eshik so\'raladi va darrov muharrir ochiladi; saqlansa hisob paydo bo\'ladi', (tester) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Yangi hisob'));
    await tester.pumpAndSettle();
    expect(find.text('Nima chizamiz?'), findsOneWidget);
    await tester.tap(find.text('Deraza'));
    await tester.pumpAndSettle();

    expect(find.text('Deraza — shablon'), findsOneWidget);
    await tester.tap(find.ancestor(of: find.byType(FrameCanvas).first, matching: find.byType(ChizmaSheet)).first);
    await tester.pumpAndSettle();

    expect(find.byType(FrameCanvas), findsOneWidget);
    expect(_store.projects, isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final project = _store.projects.single;
    expect(project.items.length, 1);
    expect(find.textContaining('Deraza 1500 × 1400'), findsOneWidget);
    expect(find.byType(FrameCanvas), findsOneWidget, reason: 'buyum kartasida chizmaning o\'zi');
    expect(find.text('Taklif'), findsNothing);
    expect(find.textContaining('so\'m'), findsNothing);

    final restored = HisobStore()..restore();
    final item = restored.projects.single.items.single;
    expect(item.sizeLabel, '1500 × 1400');
    expect(item.toJson().keys, unorderedEquals(['id', 'kind', 'design', 'settings']));
  });

  testWidgets('Yangi hisob: tanlov yopilsa yoki saqlanmasa hisob yaratilmaydi', (tester) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Yangi hisob'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); 
    await tester.pumpAndSettle();
    expect(_store.projects, isEmpty);
    expect(find.text('Hali hisob yo\'q'), findsOneWidget);
  });

  testWidgets('hisob ichida: buyum chizmasi tahrirlanadi va saqlanadi; narx, detal, taklif yo\'q', (tester) async {
    final p = _project(client: 'Aliyev');
    _store.save(p);
    await _pump(tester);
    await tester.tap(find.text('Aliyev'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Deraza 1500 × 1400'), findsOneWidget);
    expect(find.text('1 dona'), findsOneWidget);
    for (final gone in ['Taklif', 'Detallar', 'Jami (foyda bilan)', 'Narxlar yuklanmagan']) {
      expect(find.text(gone), findsNothing, reason: gone);
    }

    await tester.tap(find.textContaining('Deraza 1500 × 1400'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soni'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '4');
    await tester.tap(find.widgetWithText(FilledButton, 'Tayyor'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    expect(_store.byId(p.id)!.items.single.settings.qty, 4);
    expect(find.text('4 dona'), findsOneWidget);
  });

  testWidgets('buyumni o\'chirish tasdiq so\'raydi', (tester) async {
    _store.save(_project(client: 'Aliyev'));
    await _pump(tester);
    await tester.tap(find.text('Aliyev'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O\'chirish'));
    await tester.pumpAndSettle();
    expect(find.text('Buyumni o\'chirasizmi?'), findsOneWidget);

    await tester.tap(find.text('O\'chirish').last);
    await tester.pumpAndSettle();
    expect(_store.projects.single.items, isEmpty);
  });

  testWidgets('hisobni o\'chirish ro\'yxatdan olib tashlaydi', (tester) async {
    _store.save(_project(client: 'Aliyev'));
    await _pump(tester);
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O\'chirish').last);
    await tester.pumpAndSettle();
    expect(_store.projects, isEmpty);
  });
}
