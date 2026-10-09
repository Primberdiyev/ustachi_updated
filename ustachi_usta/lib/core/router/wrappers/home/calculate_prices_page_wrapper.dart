import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/presentation/hisob_list_page.dart';

@RoutePage()
class CalculatePricesPageWrapper extends StatelessWidget {
  const CalculatePricesPageWrapper({super.key});

  @override
  Widget build(BuildContext context) => HisobListPage(store: sl<HisobStore>());
}
