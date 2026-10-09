import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class MainTabSpec {
  const MainTabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

String _compact(String label, {int max = 9}) => label.characters.length <= max
    ? label
    : label.characters.take(max).toString().trimRight();

List<MainTabSpec> mainTabSpecs(BuildContext context) {
  final t = context.t;
  final ordersLabel =
      context.breakpoint.isCompact ? _compact(t.orders.title) : t.orders.title;

  return [
    MainTabSpec(
      label: t.dashboard.title,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    MainTabSpec(
      label: ordersLabel,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    MainTabSpec(
      label: t.home.chatting,
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    MainTabSpec(
      label: t.home.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];
}
