import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/router_impls/master/masters_route_impl.dart';
import 'package:ustachi/features/masters/presentation/view/masters_page.dart';

@RoutePage()
class MastersPageWrapper extends StatelessWidget {
  const MastersPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MastersPage(
      route: MastersRouteImpl(),
    );
  }
}
