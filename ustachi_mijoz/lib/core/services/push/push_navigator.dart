import 'package:flutter/material.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/push/push_message.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';

class PushNavigator {
  const PushNavigator(this._router);

  final AppRouter _router;

  void open(PushMessage message) {

    if (message.isChat) {
      _router.navigate(const MainPageRoute(children: [ChattingPageRoute()]));
      return;
    }

    final orderId = message.orderId;
    if (orderId == null) return;

    final context = _router.navigatorKey.currentContext;
    if (context == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: orderId),
      ),
    );
  }
}
