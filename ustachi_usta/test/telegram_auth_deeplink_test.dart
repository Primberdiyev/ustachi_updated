import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/router/app_router.dart';

void main() {
  test('Telegram auth App Link routes code to exchange page', () {
    final matches = AppRouter().matcher.match(
          '/app/auth/master-telegram/one-time-test-code/',
        );

    expect(matches, isNotNull);
    expect(matches!.last.name, TelegramExchangePageRoute.name);
    expect(matches.last.params.getString('code'), 'one-time-test-code');
  });
}
