import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_wizard_page.dart';

@RoutePage()
class ProposalWizardPageWrapper extends StatelessWidget {
  const ProposalWizardPageWrapper({super.key});

  @override
  Widget build(BuildContext context) => const ProposalWizardPage();
}
