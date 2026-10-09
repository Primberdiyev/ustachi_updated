
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/settings_options.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

HisobItem _window({int material = 0, double w = 1500, double h = 1400, int qty = 1}) =>
    HisobItem(
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
      settings: ItemSettings(material: material, qty: qty),
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
  });

  group('modellar', () {
    test('hisob saqlanib qaytganda bir xil (buyum, rang, buyurtma)', () {
      final item = _window(qty: 3);
      final project = HisobProject(
        id: 'p1',
        client: 'Aliyev, 3-xonadon',
        createdAt: DateTime(2026, 9, 26),
        updatedAt: DateTime(2026, 9, 27),
        items: [item.copyWith(settings: item.settings.copyWith(colorName: 'Antrazit', colorArgb: 0xFF383E42))],
        order: HisobOrder(phone: '+998 90 123 45 67', address: 'Chilonzor', deadline: DateTime(2026, 10, 20)),
      );
      final back = HisobProject.fromJson(jsonDecode(jsonEncode(project.toJson())) as Map<String, dynamic>);

      expect(jsonEncode(back.toJson()), jsonEncode(project.toJson()));
      expect(back.items.single.settings.qty, 3);
      expect(back.items.single.settings.colorArgb, 0xFF383E42);
      expect(back.order.address, 'Chilonzor');
      expect(back.client, 'Aliyev, 3-xonadon');
    });

    test('saqlangan hisobda faqat chizma va ko\'rinish sozlamalari bor', () {
      final json = _window().toJson();
      expect((json['settings'] as Map).keys, unorderedEquals(['material', 'balcony', 'qty']));
      expect(json.keys, unorderedEquals(['id', 'kind', 'design', 'settings']));
    });

    test('eski yozuvdagi ortiqcha maydonlar e\'tiborsiz qoldiriladi', () {
      final s = ItemSettings.fromJson(const {
        'material': 1,
        'brandId': 3,
        'seriesId': 12,
        'seriesName': 'Aldoks',
        'colorKey': 'LAMINATION',
        'glassName': 'Oq + Oq',
        'sill': 25,
        'qty': 2,
      });
      expect((s.material, s.qty, s.isColored), (1, 2, false));
    });

    test('yangi eshik — tutqichli eshik tavaqasi, deraza — bo\'sh katak', () {
      expect(HisobKind.window.blankDesign().root, isA<hisob.Zone>());
      final door = HisobKind.door.blankDesign();
      expect(door.root, isA<hisob.Wing>());
      expect((door.root as hisob.Wing).kind, hisob.WingKind.door);
      expect((door.widthMm, door.heightMm), (900, 2100));
    });

    test('buyum qo\'shish/almashtirish/o\'chirish', () {
      final a = _window();
      final b = _window(w: 1200);
      var p = HisobProject(id: 'p', createdAt: DateTime(2026), updatedAt: DateTime(2026));
      p = p.upsertItem(a).upsertItem(b);
      expect(p.items.length, 2);
      p = p.upsertItem(a.copyWith(settings: a.settings.copyWith(qty: 4)));
      expect(p.items.length, 2);
      expect(p.pieceCount, 5);
      p = p.removeItem(a.id);
      expect(p.items.single.id, b.id);
    });
  });

  group('saqlash', () {
    test('save → yangi store restore() o\'qiydi; eng yangisi birinchi', () {
      final store = HisobStore();
      store.save(HisobProject(id: 'eski', createdAt: DateTime(2026, 1), updatedAt: DateTime(2026, 1), items: [_window()]));
      store.save(HisobProject(id: 'yangi', createdAt: DateTime(2026, 2), updatedAt: DateTime(2026, 2)));

      final other = HisobStore()..restore();
      expect(other.projects.map((p) => p.id), ['yangi', 'eski']);
      expect(other.byId('eski')!.items.length, 1);
    });

    test('buzuq hisob qolganlarini yiqitmaydi', () async {
      final good = HisobProject(id: 'good', createdAt: DateTime(2026), updatedAt: DateTime(2026));
      await StorageRepository.putString(
        StoreKeys.hisobProjects,
        jsonEncode([
          good.toJson(),
          {'id': 'buzuq', 'items': 'bu ro\'yxat emas'},
        ]),
      );
      final store = HisobStore()..restore();
      expect(store.projects.map((p) => p.id), ['good']);
    });

    test('butunlay buzuq matn — bo\'sh ro\'yxat', () async {
      await StorageRepository.putString(StoreKeys.hisobProjects, '{{{');
      expect(HisobStore().projects, isEmpty);
      final store = HisobStore()..restore();
      expect(store.projects, isEmpty);
    });

    test('o\'chirish va tozalash (logout)', () async {
      final store = HisobStore();
      store.save(HisobProject(id: 'a', createdAt: DateTime(2026), updatedAt: DateTime(2026)));
      store.save(HisobProject(id: 'b', createdAt: DateTime(2026), updatedAt: DateTime(2026)));
      store.remove('a');
      expect(store.projects.map((p) => p.id), ['b']);
      await store.clear();
      expect(store.projects, isEmpty);
      expect((HisobStore()..restore()).projects, isEmpty);
    });

    test('o\'zgarganda tinglovchilar xabardor qilinadi', () {
      final store = HisobStore();
      var calls = 0;
      store.addListener(() => calls++);
      store.save(HisobProject(id: 'a', createdAt: DateTime(2026), updatedAt: DateTime(2026)));
      store.remove('a');
      expect(calls, 2);
    });
  });

  group('sozlash ro\'yxatlari', () {
    test('materiallar: termo — Tez kunda', () {
      expect(materialOptions.map((m) => m.label), ['Plastik', 'Alyuminiy', 'Termo']);
      expect(materialOptions.where((m) => m.comingSoon).map((m) => m.label), ['Termo']);
    });

    test('material profil geometriyasini belgilaydi', () {
      expect(seriesSpecOf(0).material, hisob.ProfileMaterial.plastic);
      expect(seriesSpecOf(1).material, hisob.ProfileMaterial.aluminium);
      expect(seriesSpecOf(2).material, hisob.ProfileMaterial.termo);
    });

    test('ranglar: oq birinchi va rangsiz, qolganlari takrorlanmaydi', () {
      expect(frameColorOptions.first.argb, isNull);
      expect(frameColorOptions.skip(1).every((c) => c.argb != null), isTrue);
      expect(frameColorOptions.map((c) => c.name).toSet().length, frameColorOptions.length);
      expect(colorDisplay(const ItemSettings()), 'Oq');
      expect(colorDisplay(const ItemSettings(colorName: 'Antrazit', colorArgb: 0xFF383E42)), 'Antrazit');
    });
  });
}
