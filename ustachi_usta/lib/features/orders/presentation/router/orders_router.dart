import 'package:flutter/material.dart';

abstract class OrdersRouter {
  void openOrderDetail(BuildContext context, {required String orderId});

  void openRequestOffer(BuildContext context, {required String requestId});
}
