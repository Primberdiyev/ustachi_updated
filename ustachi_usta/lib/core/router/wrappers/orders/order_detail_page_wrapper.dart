import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_page.dart';

@RoutePage()
class OrderDetailPageWrapper extends StatelessWidget {
  const OrderDetailPageWrapper({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrdersBloc>(),
      child: OrderDetailPage(orderId: orderId),
    );
  }
}
