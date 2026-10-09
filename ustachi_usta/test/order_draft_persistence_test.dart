
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';

OrderDraftItem _item(
  String id, {
  int width = 1500,
  int height = 1400,
  int qty = 1,
}) =>
    OrderDraftItem(
      localId: id,
      drawing: WindowDrawingSnapshot(
        widthMm: width,
        heightMm: height,
        spec: const FramePreviewSpec(
          aspectRatio: 1.07,
          lines: [FrameLine(0, 0.5, 1, 0.5)],
          widthMm: 1500,
          heightMm: 1400,
        ),

        preview: (_) => const SizedBox(key: Key('muharrir-chizmasi')),
      ),
      qty: qty,
      materialLabel: 'Plastik',
    );

OrderDraftStore _newSession() => OrderDraftStore()..restore();

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

  group('Qo\'ng\'iroqdan keyin qoralama QAYTADI', () {
    test('qo\'shilgan romlar yangi sessiyada joyida', () async {
      final store = OrderDraftStore();
      store.add(_item('draft-1'));
      store.add(_item('draft-2', width: 1800, height: 1500));
      await store.pendingWrites;

      final restored = _newSession();

      expect(restored.value.items, hasLength(2));
      expect(restored.value.items.map((i) => i.localId),
          ['draft-1', 'draft-2']);
    });

    test('soni va o\'lchamlar AYNAN qaytadi', () async {

      final store = OrderDraftStore()..add(_item('draft-1', qty: 3));
      await store.pendingWrites;

      final item = _newSession().value.items.single;

      expect(item.qty, 3);
      expect(item.drawing.sizeLabel, '1500 × 1400 mm');
      expect(item.materialLabel, 'Plastik');
    });

    test('eski qoralamadagi narx maydonlari e\'tiborsiz qoldiriladi', () async {
      await StorageRepository.putString(
        'order_draft_v1',
        '{"v": 2, "counter": 1, "items": [{"id": "draft-1", "w": 1500, "h": 1400, '
            '"spec": {"ar": 1.07, "lines": []}, "qty": 2, "material": "Plastik", '
            '"bom": {"lines": [], "cost": 497100, "total": 1250000}}]}',
      );

      final item = _newSession().value.items.single;

      expect(item.qty, 2);
      expect(item.drawing.sizeLabel, '1500 × 1400 mm');
    });

    test('miqdor o\'zgarishi ham saqlanadi', () async {
      final store = OrderDraftStore()..add(_item('draft-1'));
      store.setQty('draft-1', 7);
      await store.pendingWrites;

      expect(_newSession().value.items.single.qty, 7);
    });

    test('o\'chirilgan rom qaytib kelmaydi', () async {
      final store = OrderDraftStore()
        ..add(_item('draft-1'))
        ..add(_item('draft-2'));
      store.remove('draft-1');
      await store.pendingWrites;

      expect(_newSession().value.items.single.localId, 'draft-2');
    });
  });

  group('Chizma', () {
    testWidgets('closure YO\'Q, lekin chizma baribir chiziladi',
        (tester) async {

      final store = OrderDraftStore()..add(_item('draft-1'));
      await store.pendingWrites;

      final drawing = _newSession().value.items.single.drawing;
      expect(drawing.preview, isNull);
      expect(drawing.spec.widthMm, 1500);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => drawing.render(context)),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('muharrir-chizmasi')), findsNothing);
    });
  });

  group('Tozalash va chidamlilik', () {
    test('clear() DISKDAN ham o\'chiradi', () async {

      final store = OrderDraftStore()..add(_item('draft-1'));
      await store.pendingWrites;

      store.clear();
      await store.pendingWrites;

      expect(_newSession().value.isEmpty, isTrue);
    });

    test('BUZUQ yozuv ilovani yiqitmaydi', () async {
      await StorageRepository.putString('order_draft_v1', '{buzuq');

      final store = _newSession();

      expect(store.value.isEmpty, isTrue);
    });

    test('ESKI shakldagi yozuv jimgina tashlanadi', () async {
      await StorageRepository.putString(
        'order_draft_v1',
        '{"v": 0, "items": [{"id": "x"}]}',
      );

      expect(_newSession().value.isEmpty, isTrue);
    });

    test('tiklangandan keyin ID TAKRORLANMAYDI', () async {

      final store = OrderDraftStore();
      store.add(_item(store.nextId()));
      store.add(_item(store.nextId()));
      await store.pendingWrites;

      final restored = _newSession();
      final next = restored.nextId();

      expect(restored.value.items.map((i) => i.localId).contains(next),
          isFalse);
      expect(next, 'draft-3');
    });

    test('syncId ham saqlanadi — dublikat buyurtma yaralmaydi', () async {

      final store = OrderDraftStore()..add(_item('draft-1'));
      final id = store.syncId;
      await store.pendingWrites;

      expect(_newSession().syncId, id);
    });

    test('clear()dan keyin syncId YANGI bo\'ladi', () async {
      final store = OrderDraftStore()..add(_item('draft-1'));
      final first = store.syncId;
      store.clear();
      await store.pendingWrites;

      expect(store.syncId, isNot(first));
    });
  });
}
