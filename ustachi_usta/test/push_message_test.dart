
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/services/push/push_message.dart';

void main() {
  group('PushMessage.fromData', () {
    test('SATR ko\'rinishidagi raqamlar to\'g\'ri o\'qiladi', () {
      final message = PushMessage.fromData(
        {'topic': 'order_published', 'order_id': '12'},
        title: 'Yangi buyurtma',
        body: '2 qanotli oq deraza',
      );

      expect(message.topic, 'order_published');
      expect(message.orderId, 12);
      expect(message.isNewOrder, isTrue);
      expect(message.title, 'Yangi buyurtma');
      expect(message.body, '2 qanotli oq deraza');
    });

    test('int ko\'rinishida kelsa ham ishlaydi', () {
      final message = PushMessage.fromData({'topic': 'chat_message', 'thread_id': 7});
      expect(message.threadId, 7);
      expect(message.isChat, isTrue);
    });

    test('yaroqsiz/bo\'sh qiymatlar YIQITMAYDI', () {
      final message = PushMessage.fromData({'topic': 'order_stage', 'order_id': 'x'});
      expect(message.orderId, isNull);
      expect(message.threadId, isNull);
      expect(message.isChat, isFalse);
      expect(message.isNewOrder, isFalse);
    });

    test('mavzu yo\'q bo\'lsa bo\'sh satr (hech narsa ochilmaydi)', () {
      final message = PushMessage.fromData(const {});
      expect(message.topic, '');
      expect(message.orderId, isNull);
    });
  });
}
