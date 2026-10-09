import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/presentation/view/notifications_page.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    if (bloc.state.getUserDataStatus.isInitial) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => bloc.add(GetUserDataEvent()));
    }
    final t = context.t.dashboard;
    final colors = context.color;

    final name = context.select<ProfileBloc, String>(
      (bloc) => bloc.state.userModel?.fullName ?? '',
    );
    final unread = context.select<OrdersBloc, int>(
      (bloc) => bloc.state.orders
          .fold<int>(0, (sum, order) => sum + order.unreadMessages),
    );

    return Row(
      children: [
        _Avatar(name: name),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greeting(t),
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: 1),
              Text(
                name.isEmpty ? t.master : name,
                style: context.text.h4
                    .copyWith(color: colors.neutral.textStrong),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _IconAction(
          icon: Icons.mail_outline_rounded,
          badge: unread,
          onTap: () => AutoTabsRouter.of(context).setActiveIndex(2),
        ),
        NotificationBell(
          openOrderDetail: false,
          onClosed: () =>
              context.read<OrdersBloc>().add(const OrdersLoadRequested()),
        ),
      ],
    );
  }

  String _greeting(TranslationsDashboardUz t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.greetingMorning;
    if (hour < 18) return t.greetingDay;
    return t.greetingEvening;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;

    final initials = _initials(name);

    return Container(
      height: 42,
      width: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: colors.neutral.border),
      ),
      child: initials.isEmpty
          ? Icon(Icons.person_outline_rounded, size: 20, color: primary)
          : Text(
              initials,
              style: context.text.body4.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ChizmaRadius.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.neutral.surface2,
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
            ),
            child: Icon(icon, size: 19, color: colors.categorizedColor.primary),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17),
                height: 17,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors.categorizedColor.error,
                  borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                  border: Border.all(color: colors.neutral.bg, width: 1.5),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: context.text.numericMuted.copyWith(
                    fontSize: 9,
                    color: colors.neutral.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
