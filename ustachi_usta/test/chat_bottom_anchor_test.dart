
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String messageAt(List<String> messages, int index) =>
    messages[messages.length - 1 - index];

void main() {
  group('Teskari ro\'yxat indeksi', () {
    const messages = ['birinchi', 'ikkinchi', 'uchinchi'];

    test('0-indeks — ENG OXIRGI xabar (pastda turadi)', () {
      expect(messageAt(messages, 0), 'uchinchi');
    });

    test('oxirgi indeks — eng birinchi xabar (tepada)', () {
      expect(messageAt(messages, messages.length - 1), 'birinchi');
    });

    test('tartib teskari o\'qilganda ASL ketma-ketlik tiklanadi', () {
      final rendered = [
        for (var i = messages.length - 1; i >= 0; i--) messageAt(messages, i),
      ];
      expect(rendered, messages);
    });
  });

  group('Ko\'rinish', () {
    testWidgets('reverse: true — kam xabar PASTDA turadi, tepada emas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              reverse: true,
              itemCount: 2,
              itemBuilder: (_, i) => SizedBox(
                height: 40,
                child: Text(i == 0 ? 'oxirgi' : 'birinchi'),
              ),
            ),
          ),
        ),
      );

      final screenHeight = tester.getSize(find.byType(Scaffold)).height;
      final lastY = tester.getCenter(find.text('oxirgi')).dy;
      final firstY = tester.getCenter(find.text('birinchi')).dy;

      expect(lastY, greaterThan(screenHeight / 2));
      expect(firstY, greaterThan(screenHeight / 2));

      expect(lastY, greaterThan(firstY));
    });
  });
}
