import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/router_impls/orders/orders_router_impl.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/orders_page.dart';

@RoutePage()
class OrdersPageWrapper extends StatelessWidget {
  const OrdersPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrdersBloc>(),
      child: OrdersPage(router: OrdersRouterImpl()),
    );
  }
}
