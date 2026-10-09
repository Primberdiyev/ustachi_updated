import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/features/auth/presentation/view/telegram_exchange_page.dart';

@RoutePage()
class TelegramExchangePageWrapper extends StatelessWidget {
  const TelegramExchangePageWrapper({super.key});

  @override
  Widget build(BuildContext context) => TelegramExchangePage(
        code: RouteData.of(context).params.getString('code'),
      );
}
