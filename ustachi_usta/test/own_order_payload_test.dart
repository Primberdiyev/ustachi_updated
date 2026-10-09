
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_drawing_snapshot.dart';
import 'package:ustachi/features/orders/data/models/own_order_model.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';

WindowDrawingSnapshot _drawing({int w = 1500, int h = 1600}) =>
    WindowDrawingSnapshot(
      widthMm: w,
      heightMm: h,
      spec: FramePreviewSpec(
        aspectRatio: w / h,
        lines: const [FrameLine(0, 0.5, 1, 0.5)],
        widthMm: w,
        heightMm: h,
      ),
      preview: (_) => const SizedBox.shrink(),
    );

OrderDraftItem _item({String id = 'draft-1', int qty = 1}) =>
    OrderDraftItem(
      localId: id,
      drawing: _drawing(),
      qty: qty,
      materialLabel: 'Plastik',
    );

void main() {
  group('Qoralamadan yig\'ish', () {
    test('faqat chizma va o\'lcham ketadi — pul maydonlari yuborilmaydi', () {
      final json = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item(qty: 3)]),
        customerName: 'Aziz aka',
      ).toJson();

      for (final key in ['cost', 'benefit', 'total_price', 'last_cost', 'discount', 'prepaid']) {
        expect(json.containsKey(key), isFalse, reason: key);
      }

      final item = json['items'][0] as Map<String, dynamic>;
      expect(item['qty'], 3);
      expect(item['width_mm'], 1500);
      expect(item['height_mm'], 1600);
      expect(item['material_label'], 'Plastik');
      for (final key in ['unit_cost', 'unit_benefit', 'benefit_percent', 'bom', 'brand_label']) {
        expect(item.containsKey(key), isFalse, reason: key);
      }
    });

    test('chizma ProposalSpecCodec bilan ketadi — hujjat bo\'lib qoladi', () {
      final item = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item()]),
        customerName: 'Aziz aka',
      ).toJson()['items'][0] as Map<String, dynamic>;

      final drawing = item['drawing'] as Map<String, dynamic>;
      expect(drawing['w'], 1500);
      expect(drawing['h'], 1600);
      expect((drawing['lines'] as List), hasLength(1));
    });

    test('tartib (position) qatorlar ketma-ketligiga mos', () {
      final json = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [
          _item(id: 'draft-1'),
          _item(id: 'draft-2'),
        ]),
        customerName: 'Aziz aka',
      ).toJson();

      final items = json['items'] as List;
      expect(items[0]['position'], 0);
      expect(items[1]['position'], 1);
    });

    test('muddat Django DateField formatida', () {
      final json = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item()]),
        customerName: 'Aziz aka',
        deadline: DateTime(2026, 8, 5),
      ).toJson();

      expect(json['deadline'], '2026-08-05');
    });

    test('muddat yo\'q bo\'lsa kalit umuman ketmaydi', () {
      final json = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item()]),
        customerName: 'Aziz aka',
      ).toJson();

      expect(json.containsKey('deadline'), isFalse);
    });

    test('sync_client_id bo\'sh bo\'lsa yuborilmaydi', () {
      final without = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item()]),
        customerName: 'Aziz aka',
      ).toJson();
      final with_ = OwnOrderPayload.fromDraft(
        draft: OrderDraft(items: [_item()]),
        customerName: 'Aziz aka',
        syncClientId: 'ord-42',
      ).toJson();

      expect(without.containsKey('sync_client_id'), isFalse);
      expect(with_['sync_client_id'], 'ord-42');
    });

  });

  group('Server javobini o\'qish', () {
    Map<String, dynamic> body({Object? status = 'in_progress'}) => {
          'id': 7,
          'sync_client_id': 'ord-42',
          'customer_name': 'Aziz aka',
          'customer_phone': '+998901234567',
          'customer_address': 'Chilonzor 9',
          'deadline': '2026-08-05',
          'note': '2-qavat',
          'status': status,
          'completed_at': null,
          'created_at': '2026-07-28T10:00:00Z',
          'items': [
            {
              'id': 11,
              'position': 0,
              'title': '1500 × 1600 mm',
              'material_label': 'Plastik',
              'qty': 2,
              'width_mm': 1500,
              'height_mm': 1600,
              'drawing': {'ar': 0.94, 'lines': []},
            },
          ],
        };

    test('to\'liq javob o\'qiladi', () {
      final order = OwnOrderModel.fromJson(body());

      expect(order.id, 7);
      expect(order.customerName, 'Aziz aka');
      expect(order.status, OwnOrderStatus.inProgress);
      expect(order.items, hasLength(1));
      expect(order.items.first.widthMm, 1500);
      expect(order.items.first.drawing, isNotEmpty);
      expect(order.productCount, 2);
    });

    test('notanish holat NEW ga tushadi — ekran yiqilmaydi', () {
      final order = OwnOrderModel.fromJson(body(status: 'kutilmagan'));
      expect(order.status, OwnOrderStatus.newOrder);
    });

    test('bo\'sh/buzuq javob yiqitmaydi', () {
      final order = OwnOrderModel.fromJson({'id': 1});

      expect(order.id, 1);
      expect(order.customerName, isEmpty);
      expect(order.items, isEmpty);
    });

    test('ro\'yxat parseri Map bo\'lmagan elementni tashlab ketadi', () {
      final orders = OwnOrderModel.listFrom([body(), 'axlat', null]);
      expect(orders, hasLength(1));
    });

    test('holat wire qiymatlari server bilan bir xil', () {
      expect(OwnOrderStatus.newOrder.wire, 'new');
      expect(OwnOrderStatus.inProgress.wire, 'in_progress');
      expect(OwnOrderStatus.done.wire, 'done');
      expect(OwnOrderStatus.debt.wire, 'debt');
      expect(OwnOrderStatus.cancelled.wire, 'cancelled');
      expect(OwnOrderStatus.draft.wire, 'draft');
    });

    test('yopilgan holatlar', () {
      expect(OwnOrderStatus.done.isClosed, isTrue);
      expect(OwnOrderStatus.cancelled.isClosed, isTrue);
      expect(OwnOrderStatus.debt.isClosed, isFalse);
    });
  });
}
