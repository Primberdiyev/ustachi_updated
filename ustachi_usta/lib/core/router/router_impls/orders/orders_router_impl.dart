import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/orders/presentation/router/orders_router.dart';

class OrdersRouterImpl implements OrdersRouter {
  @override
  void openOrderDetail(BuildContext context, {required String orderId}) =>
      context.router.push(OrderDetailPageRoute(orderId: orderId));

  @override
  void openRequestOffer(BuildContext context, {required String requestId}) =>
      context.router.push(OrderRequestPageRoute(requestId: requestId));
}
