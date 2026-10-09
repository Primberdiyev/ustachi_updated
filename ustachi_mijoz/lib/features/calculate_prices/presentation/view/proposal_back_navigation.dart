
library;

import 'package:flutter/widgets.dart';
import 'package:ustachi/core/router/app_router.dart';

const proposalDetailRouteName = 'ProposalDetailPage';
const proposalBasketRouteName = 'CreateOrderPage';

const calculatorPickerRouteName = 'CalculatorPickerPage';
const areaCalculatorRouteName = 'AreaCalculatorPage';
const variantCalculatorRouteName = 'VariantCalculatorPage';
const masonryCalculatorRouteName = 'MasonryCalculatorPage';
const roofCalculatorRouteName = 'RoofCalculatorPage';
const betonCalculatorRouteName = 'BetonCalculatorPage';
const electricalCalculatorRouteName = 'ElectricalCalculatorPage';

const heatingCalculatorRouteName = 'HeatingCalculatorPage';

const repairOrderRouteName = 'RepairOrderPage';

bool proposalBackStopsAt(String? routeName) =>
    routeName != ProposalWizardPageRoute.name &&
    routeName != ProposalResultsPageRoute.name;

bool isProposalFlowRoute(String? routeName) =>
    routeName == ProposalWizardPageRoute.name ||
    routeName == ProposalResultsPageRoute.name ||
    routeName == proposalDetailRouteName ||
    routeName == proposalBasketRouteName ||
    routeName == calculatorPickerRouteName ||
    routeName == areaCalculatorRouteName ||
    routeName == variantCalculatorRouteName ||
    routeName == masonryCalculatorRouteName ||
    routeName == roofCalculatorRouteName ||
    routeName == betonCalculatorRouteName ||
    routeName == heatingCalculatorRouteName ||
    routeName == electricalCalculatorRouteName ||
    routeName == repairOrderRouteName;

void popFromProposals(BuildContext context, {required bool hasBasket}) {
  final navigator = Navigator.of(context);
  if (!navigator.canPop()) return;

  if (!hasBasket) {
    navigator.pop();
    return;
  }

  navigator.popUntil((route) => proposalBackStopsAt(route.settings.name));
}

void clearProposalFlow(NavigatorState navigator) {
  navigator.popUntil(
    (route) => route.isFirst || !isProposalFlowRoute(route.settings.name),
  );
}
