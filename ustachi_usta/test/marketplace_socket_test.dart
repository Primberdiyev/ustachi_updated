import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';

void main() {
  final socket = MarketplaceSocket.instance;

  setUp(() {
    while (socket.holders > 0) {
      socket.release();
    }
    socket.disconnect();
  });

  test('acquire/release muvozanatli — oxirgi ekran yopilsa ushlovchi qolmaydi',
      () {
    expect(socket.holders, 0);
    socket.acquire();
    expect(socket.holders, 1);
    socket.release();
    expect(socket.holders, 0);
    socket.disconnect(); 
  });

  test('ikki ekran ushlab tursa, bittasi yopilsa ulanish SAQLANADI', () {
    socket.acquire(); 
    socket.acquire(); 
    expect(socket.holders, 2);

    socket.release(); 
    expect(socket.holders, 1, reason: 'suhbatlar ro\'yxati hali ochiq');

    socket.release();
    expect(socket.holders, 0);
    socket.disconnect(); 
  });

  test('ortiqcha release manfiyga tushmaydi', () {
    socket.release();
    socket.release();
    expect(socket.holders, 0);
    socket.disconnect(); 
  });

  test('disconnect (logout/401) ulanishni yopadi, HISOBLAGICHGA tegmaydi', () {
    socket.acquire();
    socket.acquire();
    socket.disconnect();

    expect(socket.holders, 2);
    expect(socket.isConnected, isFalse);

    socket.release();
    socket.release();
    expect(socket.holders, 0);
    socket.disconnect(); 
  });

  test('DI sozlanmagan bo\'lsa ham connect YIQILMAYDI (real-time = qulaylik)',
      () {
    expect(socket.connect, returnsNormally);
    expect(socket.isConnected, isFalse, reason: 'token yo\'q — ulanmaydi');
  });

  group('SocketEvent parse', () {
    test('butun son id\'lar o\'qiladi', () {
      final e = SocketEvent.fromJson(const {
        'topic': 'chat_message',
        'thread_id': 12,
        'order_id': 5,
        'unread_count': 3,
      });
      expect(e.threadId, 12);
      expect(e.orderId, 5);
      expect(e.unreadCount, 3);
      expect(e.isChat, isTrue);
    });

    test('SATR bo\'lib kelgan id ham o\'qiladi (filtr ochilib ketmasin)', () {

      final e = SocketEvent.fromJson(const {
        'topic': 'chat_message',
        'thread_id': '12',
        'order_id': '5',
      });
      expect(e.threadId, 12);
      expect(e.orderId, 5);
    });

    test('yaroqsiz qiymat null beradi, yiqilmaydi', () {
      final e = SocketEvent.fromJson(const {
        'topic': 'chat_message',
        'thread_id': 'salom',
        'order_id': null,
      });
      expect(e.threadId, isNull);
      expect(e.orderId, isNull);
    });
  });
}
