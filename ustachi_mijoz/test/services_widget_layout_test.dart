
import 'package:ustachi/features/home/presentation/view/all_specialties_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/home/presentation/widgets/services_widget.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/domain/specialty_catalog.dart';

import 'support/fake_marketplace_repository.dart';

const _catalog = <SpecialtyEntity>[
  SpecialtyEntity(
      id: 1, code: 'rom', name: 'Alyumin va PVX eshik va rom ustasi'),
  SpecialtyEntity(id: 2, code: 'tom', name: 'Tom yopish ustasi'),
  SpecialtyEntity(id: 3, code: 'gisht', name: 'G\'isht teruvchi'),
  SpecialtyEntity(id: 4, code: 'beton', name: 'Beton ishlari ustasi'),
  SpecialtyEntity(id: 5, code: 'elektrik', name: 'Elektrik'),
  SpecialtyEntity(id: 6, code: 'santexnik', name: 'Santexnik'),
  SpecialtyEntity(id: 7, code: 'mebel', name: 'Mebel ustasi'),
  SpecialtyEntity(id: 8, code: 'darvoza', name: 'Darvoza ustasi'),
  SpecialtyEntity(id: 9, code: 'suvoq', name: 'Suvoqchi'),
  SpecialtyEntity(id: 10, code: 'mardikor', name: 'Mardikor'),
];

class _CatalogRepo extends FakeMarketplaceRepository {
  _CatalogRepo([this.rows = _catalog]);

  final List<SpecialtyEntity> rows;
  int calls = 0;

  @override
  Future<Either<Failure, List<SpecialtyEntity>>> specialties() async {
    calls++;
    return Right<Failure, List<SpecialtyEntity>>(rows);
  }
}

Widget _wrap(Widget child) => TranslationProvider(
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
          ),
        ),
      ),
    );

Future<void> _pumpCatalog(WidgetTester tester, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(const ServicesWidget()));
  await tester.pump(); 
}

void _useCatalog(List<SpecialtyEntity> rows) {
  if (sl.isRegistered<MarketplaceRepository>()) {
    sl.unregister<MarketplaceRepository>();
  }
  if (sl.isRegistered<SpecialtyCatalog>()) {
    sl.unregister<SpecialtyCatalog>();
  }
  final repo = _CatalogRepo(rows);
  sl.registerSingleton<MarketplaceRepository>(repo);
  sl.registerSingleton<SpecialtyCatalog>(SpecialtyCatalog(repo));
}

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.uz);
    if (sl.isRegistered<MarketplaceRepository>()) {
      sl.unregister<MarketplaceRepository>();
    }
    final repo = _CatalogRepo();
    sl.registerSingleton<MarketplaceRepository>(repo);

    if (sl.isRegistered<SpecialtyCatalog>()) {
      sl.unregister<SpecialtyCatalog>();
    }
    sl.registerSingleton<SpecialtyCatalog>(SpecialtyCatalog(repo));
  });

  tearDown(() {
    if (sl.isRegistered<MarketplaceRepository>()) {
      sl.unregister<MarketplaceRepository>();
    }
    if (sl.isRegistered<SpecialtyCatalog>()) {
      sl.unregister<SpecialtyCatalog>();
    }
  });

  for (final width in <double>[320, 360, 390, 428]) {
    testWidgets('$width px ekranda 2 qator toshmaydi', (tester) async {
      await _pumpCatalog(tester, width: width);
      expect(tester.takeException(), isNull,
          reason: '$width px da toshish (overflow) bo\'lmasligi kerak');
    });
  }

  testWidgets('plitalar AYNAN ikki qatorda', (tester) async {
    await _pumpCatalog(tester);

    final tiles = find.byType(InkWell);
    expect(tester.widgetList(tiles).length, 8, reason: '7 soha + "Barchasi"');

    final rowTops = <double>{
      for (var i = 0; i < 8; i++) tester.getTopLeft(tiles.at(i)).dy,
    };
    expect(rowTops.length, 2, reason: 'aynan IKKI qator bo\'lishi kerak');
  });

  testWidgets('katalog SERVERDAN keladi (qattiq ro\'yxat emas)',
      (tester) async {
    await _pumpCatalog(tester);

    final repo = sl<MarketplaceRepository>() as _CatalogRepo;
    expect(repo.calls, 1);

    expect(find.text('Alyumin va PVX eshik va rom'), findsOneWidget);
    expect(find.text('Tom yopish'), findsOneWidget);
  });

  testWidgets('sig\'magan sohalar "Barchasi" SAHIFASIDA chiqadi',
      (tester) async {

    await _pumpCatalog(tester);

    expect(find.text('Mardikor'), findsNothing);
    expect(find.text('Hammasi'), findsOneWidget);

    await tester.tap(find.text('Hammasi'));
    await tester.pumpAndSettle();

    expect(find.byType(AllSpecialtiesPage), findsOneWidget);
    expect(find.text('Xizmat turlari'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Mardikor'), findsOneWidget);
    expect(find.text('Suvoqchi'), findsOneWidget);
  });

  testWidgets('sahifada QIDIRUV ishlaydi', (tester) async {
    await _pumpCatalog(tester);
    await tester.tap(find.text('Hammasi'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pump();

    expect(find.text('Tom yopish ustasi'), findsOneWidget);
    expect(find.text('Mardikor'), findsNothing);
  });

  testWidgets('sahifa katalogni QAYTA so\'ramaydi', (tester) async {

    await _pumpCatalog(tester);
    final repo = sl<MarketplaceRepository>() as _CatalogRepo;
    final before = repo.calls;

    await tester.tap(find.text('Hammasi'));
    await tester.pumpAndSettle();

    expect(repo.calls, before);
  });

  testWidgets('katalog kam bo\'lsa "Barchasi" plitasi chiqmaydi',
      (tester) async {
    _useCatalog(_catalog.take(4).toList());
    await _pumpCatalog(tester);

    expect(find.text('Hammasi'), findsNothing);
    expect(tester.widgetList(find.byType(InkWell)).length, 4);
  });

  testWidgets('katalog kelmasa ROM yo\'li baribir ochiq qoladi',
      (tester) async {

    _useCatalog(const []);
    await _pumpCatalog(tester);

    expect(find.text('Alyumin va PVX eshik va rom'), findsOneWidget);
  });
}
