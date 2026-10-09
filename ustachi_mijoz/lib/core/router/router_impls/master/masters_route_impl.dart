import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/masters/presentation/router/masters_route.dart';

class MastersRouteImpl implements MastersRoute {
  @override
  void navigateToMasterDetail(BuildContext context) =>
      context.router.push(MasterDetailPageRoute());
}
