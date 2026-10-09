import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_results_page.dart';

@RoutePage()
class ProposalResultsPageWrapper extends StatelessWidget {
  const ProposalResultsPageWrapper({super.key, required this.request});

  final ProposalRequest request;

  @override
  Widget build(BuildContext context) =>
      ProposalResultsPage(request: request);
}
