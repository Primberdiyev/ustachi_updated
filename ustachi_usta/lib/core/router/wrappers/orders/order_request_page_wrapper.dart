import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_request_page.dart';

@RoutePage()
class OrderRequestPageWrapper extends StatelessWidget {
  const OrderRequestPageWrapper({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrdersBloc>(),
      child: OrderRequestPage(
        requestId: requestId,
        onClose: () => context.router.maybePop(),
      ),
    );
  }
}
