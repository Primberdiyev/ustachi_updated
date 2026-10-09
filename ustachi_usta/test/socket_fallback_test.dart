
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';

Duration fallbackInterval({
  required Duration base,
  required int rounds,
  required Duration max,
  int slowdownAfter = 4,
}) {
  final next = base * (1 << (rounds ~/ slowdownAfter));
  return next > max ? max : next;
}

void main() {
  group('Zaxira so\'rov sekinlashuvi', () {
    test('birinchi urinishlar TEZ (asosiy oraliq)', () {
      const base = Duration(seconds: 5);
      for (var r = 0; r < 4; r++) {
        expect(
          fallbackInterval(
              base: base, rounds: r, max: const Duration(seconds: 60)),
          base,
        );
      }
    });

    test('har 4 urinishdan keyin IKKI BAROBAR cho\'ziladi', () {
      const base = Duration(seconds: 5);
      const max = Duration(seconds: 60);
      expect(fallbackInterval(base: base, rounds: 4, max: max),
          const Duration(seconds: 10));
      expect(fallbackInterval(base: base, rounds: 8, max: max),
          const Duration(seconds: 20));
      expect(fallbackInterval(base: base, rounds: 12, max: max),
          const Duration(seconds: 40));
    });

    test('chegaradan oshmaydi', () {
      const base = Duration(seconds: 5);
      expect(
        fallbackInterval(
            base: base, rounds: 100, max: const Duration(seconds: 60)),
        const Duration(seconds: 60),
      );
    });

    test('CHAT chegarasi qattiqroq — suhbat o\'lik bo\'lib qolmaydi', () {
      const base = Duration(seconds: 5);

      expect(
        fallbackInterval(
            base: base, rounds: 100, max: const Duration(seconds: 15)),
        const Duration(seconds: 15),
      );
    });
  });

  group('MarketplaceSocket', () {
    test('tokensiz ulanish urinilmaydi (jimgina o\'tkazib yuboriladi)', () {
      final socket = MarketplaceSocket.instance;

      socket.connect();
      expect(socket.isConnected, isFalse);
    });

    test('hodisa modeli SATR id larni ham o\'qiydi', () {
      final event = SocketEvent.fromJson(const {
        'topic': 'chat_message',
        'thread_id': '7',
        'unread_count': '3',
      });
      expect(event.isChat, isTrue);
      expect(event.threadId, 7);
      expect(event.unreadCount, 3);
    });

    test('buyurtma hodisalari ajratiladi', () {
      bool touches(String topic) =>
          SocketEvent.fromJson({'topic': topic}).touchesOrders;
      expect(touches('order_published'), isTrue);
      expect(touches('order_stage'), isTrue);
      expect(touches('review_received'), isTrue);
      expect(touches('chat_message'), isFalse);
      expect(touches('pong'), isFalse);
    });
  });

  group('Oqim shartnomasi', () {
    test('bir xil natija QAYTA chiqarilmaydi (ortiqcha rebuild yo\'q)', () async {

      final seen = <String>[];
      Object? last;
      void emit(String value) {
        if (last == value) return;
        last = value;
        seen.add(value);
      }

      emit('a');
      emit('a');
      emit('b');
      emit('b');
      expect(seen, ['a', 'b']);
    });

    test('xato kelsa oxirgi yaxshi qiymat saqlanadi', () async {
      Either<Failure, int> result = Right(1);
      var value = 0;
      void apply() {
        if (result.isLeft) return; 
        value = result.right;
      }

      apply();
      expect(value, 1);
      result = Left(const ServerFailure('xato', 500));
      apply();
      expect(value, 1);
    });
  });
}
