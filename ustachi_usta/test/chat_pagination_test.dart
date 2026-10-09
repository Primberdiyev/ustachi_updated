
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/data/datasources/marketplace_socket.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_page.dart';

class Ask {
  const Ask({this.limit, this.before, this.after});
  final int? limit;
  final int? before;
  final int? after;

  @override
  String toString() => 'limit=$limit before=$before after=$after';
}

ChatMessageEntity msg(int id) =>
    ChatMessageEntity(id: id, text: 'xabar-$id', isMine: false);

class _Repo implements MarketplaceRepository {
  _Repo({required this.history});

  List<ChatMessageEntity> history;
  final asks = <Ask>[];

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  }) async {
    asks.add(Ask(limit: limit, before: before, after: after));
    final page = limit ?? 50;

    if (after != null) {
      return Right(history.where((m) => m.id > after).take(page).toList());
    }
    if (before != null) {
      final older = history.where((m) => m.id < before).toList();
      return Right(older.sublist(older.length > page ? older.length - page : 0));
    }
    if (limit != null) {
      return Right(history.sublist(
          history.length > page ? history.length - page : 0));
    }
    return Right(history);
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(
    int threadId, {
    Duration interval = const Duration(seconds: 5),
    bool immediate = true,
    int Function()? after,
  }) =>
      const Stream<List<ChatMessageEntity>>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child) => TranslationProvider(
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(home: child),
      ),
    );

Future<void> _withChat(
  WidgetTester tester, {
  required int total,
  required Future<void> Function(_Repo repo) body,
}) async {
  MarketplaceSocket.instance.disconnect();
  final repo = _Repo(history: [for (var i = 1; i <= total; i++) msg(i)]);
  sl.registerSingleton<MarketplaceRepository>(repo);
  addTearDown(() => sl.unregister<MarketplaceRepository>());

  await tester.pumpWidget(_wrap(const ChatPage(threadId: 1)));
  await tester.pumpAndSettle();

  await body(repo);

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 20));
}

ScrollPosition _position(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    )
    .position;

Future<void> _scrollToTop(WidgetTester tester) async {
  _position(tester).jumpTo(_position(tester).maxScrollExtent);
  await tester.pumpAndSettle();
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  _position(tester).jumpTo(0);
  await tester.pumpAndSettle();
}

void main() {
  group('Chat ochilganda', () {
    testWidgets('faqat OXIRGI sahifa so\'raladi', (tester) async {
      await _withChat(tester, total: 200, body: (repo) async {
        expect(repo.asks.first.limit, 50);
        expect(repo.asks.first.before, isNull);
        expect(repo.asks.first.after, isNull);
      });
    });

    testWidgets('BUTUN tarix so\'ralmaydi', (tester) async {

      await _withChat(tester, total: 200, body: (repo) async {
        expect(
          repo.asks.where(
            (a) => a.limit == null && a.before == null && a.after == null,
          ),
          isEmpty,
        );
      });
    });

    testWidgets('eng YANGI xabarlar ko\'rinadi', (tester) async {
      await _withChat(tester, total: 200, body: (_) async {
        expect(find.text('xabar-200'), findsOneWidget);
        expect(find.text('xabar-1'), findsNothing);
      });
    });
  });

  group('Tepaga surilganda', () {
    testWidgets('ESKI sahifa `before` bilan so\'raladi', (tester) async {
      await _withChat(tester, total: 200, body: (repo) async {
        repo.asks.clear();

        await _scrollToTop(tester);

        expect(repo.asks, isNotEmpty);
        expect(repo.asks.first.before, 151, reason: 'ro\'yxatdagi ENG ESKISI');
        expect(repo.asks.first.limit, 50);
      });
    });

    testWidgets('eski xabarlar ro\'yxat BOSHIGA qo\'shiladi', (tester) async {

      await _withChat(tester, total: 60, body: (_) async {
        expect(find.text('xabar-1'), findsNothing, reason: 'hali yuklanmagan');

        await _scrollToTop(tester); 
        await _scrollToTop(tester); 

        expect(find.text('xabar-1'), findsOneWidget, reason: 'eng eskisi');

        await _scrollToBottom(tester);
        expect(find.text('xabar-60'), findsOneWidget);
      });
    });

    testWidgets('SUHBAT BOSHIDA boshqa so\'ralmaydi', (tester) async {

      await _withChat(tester, total: 60, body: (repo) async {
        await _scrollToTop(tester);
        final afterFirst = repo.asks.length;

        await _scrollToTop(tester);
        await _scrollToTop(tester);

        expect(repo.asks.length, afterFirst,
            reason: 'to\'liq bo\'lmagan sahifadan keyin so\'rov to\'xtaydi');
      });
    });

    testWidgets('sahifa yuklanayotganda IKKINCHI so\'rov ketmaydi',
        (tester) async {
      await _withChat(tester, total: 200, body: (repo) async {
        repo.asks.clear();

        await _scrollToTop(tester);
        await _scrollToTop(tester);

        expect(repo.asks.length, lessThanOrEqualTo(2));
      });
    });
  });
}
