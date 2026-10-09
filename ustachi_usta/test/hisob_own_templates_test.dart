
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/domain/hisob_templates.dart';
import 'package:ustachi/features/hisob/presentation/hisob_template_page.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

const _own = hisob.FrameDesign(
  widthMm: 1800,
  heightMm: 1500,
  root: hisob.Split(
    axis: hisob.Axis.vertical,
    positionsMm: [600, 1200],
    children: [hisob.Wing(hisob.WingKind.turn), hisob.Zone(), hisob.Wing(hisob.WingKind.tiltTurn)],
  ),
);

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
        appName: 'Ustachi Pro', packageName: 'com.ustachi.pro', version: '1.0.0', buildNumber: '1', buildSignature: '');
    SharedPreferences.setMockInitialValues({});
    await StorageRepository.getInstance();
    await StorageRepository.clearStorage();
  });

  Future<void> pump(WidgetTester tester, HisobKind kind, HisobStore store) async {
    tester.view.physicalSize = const Size(430 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(home: HisobTemplatePage(kind: kind, spec: hisob.SeriesSpec.akfaPlastic, store: store)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  test('saqlash: deraza va eshik alohida, qayta ochilganda turadi, yangisi birinchi', () {
    final store = HisobStore();
    store.saveTemplate(HisobKind.window, HisobKind.window.blankDesign());
    store.saveTemplate(HisobKind.window, _own);
    expect(store.templatesOf(HisobKind.window).first.widthMm, 1800);
    expect(store.templatesOf(HisobKind.door), isEmpty);

    final reopened = HisobStore()..restore();
    final saved = reopened.templatesOf(HisobKind.window);
    expect(saved, hasLength(2));
    expect(hisob.designToJson(saved.first), hisob.designToJson(_own));

    reopened.removeTemplate(HisobKind.window, saved.first);
    expect((HisobStore()..restore()).templatesOf(HisobKind.window), hasLength(1));
  });

  test('akkauntdan chiqishda hisoblar o\'chadi, shablonlar qoladi', () async {
    final store = HisobStore()..saveTemplate(HisobKind.door, HisobKind.door.blankDesign());
    await store.clear();
    expect(store.templatesOf(HisobKind.door), hasLength(1));
    expect((HisobStore()..restore()).templatesOf(HisobKind.door), hasLength(1));
  });

  testWidgets('eshik: bo\'sh katak yonida G va T shakllar tayyor, tanlasa ochiladi', (tester) async {
    await pump(tester, HisobKind.door, HisobStore());
    expect(find.text('G VA T SHAKL (6)'), findsOneWidget);
    expect(find.byType(FrameCanvas), findsNWidgets(7));
    final shapes = shapeTemplatesFor(HisobKind.door);
    expect(shapes, hasLength(6));
    for (final d in shapes) {
      expect(
        hisob.layoutCells(d, hisob.SeriesSpec.akfaPlastic).any((b) => b.cell is hisob.Zone && (b.cell as hisob.Zone).fill == hisob.Fill.cutout),
        isTrue,
      );
    }
    expect(shapeTemplatesFor(HisobKind.window), isEmpty);
  });

  for (final kind in HisobKind.values) {
    testWidgets('${kind.label}: bitta bo\'sh katak — eski tayyor shablonlar berkitilgan', (tester) async {
      await pump(tester, kind, HisobStore());
      expect(showBuiltInTemplates, isFalse);
      expect(find.byType(FrameCanvas), findsNWidgets(1 + shapeTemplatesFor(kind).length));
      expect(find.textContaining('Mening shablonlarim'), findsNothing);

      final blank = emptyTemplateOf(kind);
      expect(blank.root, isA<hisob.Zone>());
      expect((blank.widthMm, blank.heightMm), (kind.defaultWidthMm, kind.defaultHeightMm));
      expect(tester.widget<FrameCanvas>(find.byType(FrameCanvas).first).design.root, isA<hisob.Zone>());
    });
  }

  testWidgets('saqlangan shablon sahifada chiqadi, tanlanadi va o\'chiriladi', (tester) async {
    final store = HisobStore()..saveTemplate(HisobKind.window, _own);
    await pump(tester, HisobKind.window, store);
    expect(find.textContaining('MENING SHABLONLARIM (1)'), findsOneWidget);
    expect(find.byType(FrameCanvas), findsNWidgets(2));
    expect(find.text('1800×1500'), findsOneWidget);

    await tester.tap(find.byTooltip('Shablonni o\'chirish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O\'chirish'));
    await tester.pumpAndSettle();
    expect(store.templatesOf(HisobKind.window), isEmpty);
    expect(find.byType(FrameCanvas), findsOneWidget);
  });
}
