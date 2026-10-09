import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/features/masters/presentation/view/master_detail_page.dart';

@RoutePage()
class MasterDetailPageWrapper extends StatelessWidget {
  const MasterDetailPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterDetailPage();
  }
}
