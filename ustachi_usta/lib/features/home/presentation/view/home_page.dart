import 'package:ustachi/features/profile/presentation/view/master_professional_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/features/profile/presentation/view/company/company_page.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/presentation/widgets/telegram_channel_card.dart';
import 'package:ustachi/features/home/presentation/widgets/availability_card.dart';
import 'package:ustachi/features/home/presentation/widgets/repair_card.dart';
import 'package:ustachi/features/home/presentation/widgets/dashboard_header.dart';
import 'package:ustachi/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_card.dart';
import 'package:ustachi/features/orders/presentation/widgets/order_request_card.dart';
import 'package:ustachi/features/orders/presentation/view/open_orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _acceptingOrders = true;
  bool _savingAvailability = false;

  bool _doesRepairs = false;
  bool _savingRepairs = false;

  bool _hasRom = false;

  late final _profileApi = MasterProfileApi(sl<Dio>());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<OrdersBloc>().add(const OrdersLoadRequested());
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final result = await _profileApi.readWithStatus();
    final profile = result.data;
    if (!mounted) return;

    setState(() {
      _acceptingOrders = profile?.acceptsOrders ?? true;
      _doesRepairs = profile?.doesRepairs ?? false;
      _hasRom = profile?.hasRom ?? false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<OrdersBloc>().add(const OrdersLoadRequested());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _setAccepting(bool value) async {
    if (_savingAvailability) return;
    final previous = _acceptingOrders;
    setState(() {
      _acceptingOrders = value;
      _savingAvailability = true;
    });

    final ok = await _profileApi.setAcceptsOrders(value);
    if (!mounted) return;
    setState(() {
      _savingAvailability = false;
      if (!ok) _acceptingOrders = previous;
    });
    if (!ok) {
      sl<SnackbarService>().showMessage(context.t.common.saveFailed);
    }
  }

  Future<void> _setRepairs(bool value) async {
    if (_savingRepairs) return;
    final previous = _doesRepairs;
    setState(() {
      _doesRepairs = value;
      _savingRepairs = true;
    });

    final ok = await _profileApi.setDoesRepairs(value);
    if (!mounted) return;
    setState(() {
      _savingRepairs = false;
      if (!ok) _doesRepairs = previous;
    });
    if (!ok) {
      sl<SnackbarService>().showMessage(context.t.common.saveFailed);
    }
  }

  void _openOpenOrders(BuildContext context) {
    final bloc = context.read<OrdersBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<OrdersBloc>.value(
          value: bloc,
          child: OpenOrdersPage(
            onOpenRequest: (pageContext, id) =>
                pageContext.router.push(OrderRequestPageRoute(requestId: id)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.dashboard;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final now = DateTime.now();

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<OrdersBloc>().add(const OrdersLoadRequested()),
          child: ChizmaPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: ChizmaSpace.lg),
                if (_hasRom)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AvailabilityCard(
                          value: _acceptingOrders,
                          onChanged: _setAccepting,
                          isSaving: _savingAvailability,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: ChizmaSpace.sm),
                      Expanded(
                        child: RepairCard(
                          value: _doesRepairs,
                          onChanged: _setRepairs,
                          isSaving: _savingRepairs,
                          compact: true,
                        ),
                      ),
                    ],
                  )
                else
                  AvailabilityCard(
                    value: _acceptingOrders,
                    onChanged: _setAccepting,
                    isSaving: _savingAvailability,
                  ),
                const SizedBox(height: ChizmaSpace.lg),
                if (_hasRom) ...[
                  _CalculateHero(
                    onTap: () =>
                        context.router.push(const CalculatePricesPageRoute()),
                  ),
                  const SizedBox(height: ChizmaSpace.md),
                ] else ...[
                  _OpenOrdersHero(
                    badgeCount: state.openRequests.length,
                    onTap: () => _openOpenOrders(context),
                  ),
                  const SizedBox(height: ChizmaSpace.md),
                ],
                QuickActionsGrid(
                  actions: [
                    QuickAction(
                      title: t.quickPortfolio,
                      hint: t.quickPortfolioHint,
                      icon: Icons.photo_library_outlined,
                      color: context.color.categorizedColor.accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<bool>(
                          builder: (_) => const MasterProfessionalPage(),
                        ),
                      ),
                    ),
                    if (_hasRom)
                      QuickAction(
                        title: t.quickCompany,
                        hint: t.quickCompanyHint,
                        asset: 'assets/images/korxona.png',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CompanyPage(),
                          ),
                        ),
                      ),
                    if (!_hasRom)
                      QuickAction(
                        title: t.quickRates,
                        hint: t.quickRatesHint,
                        icon: Icons.payments_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<bool>(
                            builder: (_) => const MasterProfessionalPage(),
                          ),
                        ),
                      ),
                    QuickAction(
                      title: t.quickOpenOrders,
                      hint: t.quickOpenOrdersHint,
                      asset: 'assets/images/buyurtmalar.png',
                      badgeCount: state.openRequests.length,
                      onTap: () => _openOpenOrders(context),
                    ),
                  ],
                ),
                const SizedBox(height: ChizmaSpace.xl),
                ChizmaSectionHeader(
                  title: t.newRequests,
                  actionLabel: state.openRequests.isEmpty ? null : t.all,
                  onAction: () => _openOpenOrders(context),
                ),
                const SizedBox(height: ChizmaSpace.md),
                if (state.openRequests.isEmpty)
                  _QuietCard(
                    title: t.emptyRequests,
                    message: t.emptyRequestsHint,
                  )
                else
                  for (final request in state.openRequests.take(2)) ...[
                    OrderRequestCard(
                      request: request,
                      now: now,
                      onTap: () => context.router.push(
                        OrderRequestPageRoute(requestId: request.id),
                      ),
                      onOffer: () => context.router.push(
                        OrderRequestPageRoute(requestId: request.id),
                      ),
                    ),
                    const SizedBox(height: ChizmaSpace.sm),
                  ],
                const SizedBox(height: ChizmaSpace.xl),
                if (state.activeOrders.isNotEmpty) ...[
                  ChizmaSectionHeader(
                    title: t.activeOrders,
                    actionLabel: t.all,
                    onAction: () =>
                        AutoTabsRouter.of(context).setActiveIndex(1),
                  ),
                  const SizedBox(height: ChizmaSpace.md),
                  for (final order in state.activeOrders.take(3)) ...[
                    OrderCard(
                      order: order,
                      now: now,
                      onTap: () => context.router.push(
                        OrderDetailPageRoute(orderId: order.id),
                      ),
                    ),
                    const SizedBox(height: ChizmaSpace.sm),
                  ],
                  const SizedBox(height: ChizmaSpace.lg),
                ],
                const TelegramChannelCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalculateHero extends StatelessWidget {
  const _CalculateHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.dashboard;
    final primary = colors.categorizedColor.primary;
    final onPrimary = colors.neutral.white;
    final radius = BorderRadius.circular(ChizmaRadius.lg);

    return Material(
      color: primary,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: onPrimary.withValues(alpha: 0.12),
        highlightColor: onPrimary.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.lg),
          decoration: BoxDecoration(borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(ChizmaRadius.md),
                    ),
                    child: Icon(Icons.window_outlined,
                        size: 28, color: onPrimary),
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.quickCalculate,
                          style: context.text.h3.copyWith(color: onPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.quickCalculateHint,
                          style: context.text.body5.copyWith(
                            color: onPrimary.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 22, color: onPrimary.withValues(alpha: 0.9)),
                ],
              ),
              const SizedBox(height: ChizmaSpace.md),
              Divider(height: 1, color: onPrimary.withValues(alpha: 0.22)),
              const SizedBox(height: ChizmaSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Step(number: '1', label: t.calcStep1)),
                  Expanded(child: _Step(number: '2', label: t.calcStep2)),
                  Expanded(child: _Step(number: '3', label: t.calcStep3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.color.neutral.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: context.text.label.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: context.text.label
                .copyWith(color: onPrimary.withValues(alpha: 0.85)),
          ),
        ),
      ],
    );
  }
}

class _QuietCard extends StatelessWidget {
  const _QuietCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.text.body4.copyWith(
              color: colors.neutral.textStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ],
      ),
    );
  }
}

class _OpenOrdersHero extends StatelessWidget {
  const _OpenOrdersHero({required this.onTap, required this.badgeCount});

  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.dashboard;
    final primary = colors.categorizedColor.primary;
    final onPrimary = colors.neutral.white;
    final radius = BorderRadius.circular(ChizmaRadius.lg);

    return Material(
      color: primary,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: onPrimary.withValues(alpha: 0.12),
        highlightColor: onPrimary.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(ChizmaRadius.md),
                ),
                child: Icon(Icons.travel_explore_rounded,
                    size: 28, color: onPrimary),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.quickOrdersHeroTitle,
                      style: context.text.h3.copyWith(color: onPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.quickOrdersHeroHint,
                      style: context.text.body5.copyWith(
                        color: onPrimary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.categorizedColor.accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: context.text.label.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.arrow_forward_rounded,
                  size: 22, color: onPrimary.withValues(alpha: 0.9)),
            ],
          ),
        ),
      ),
    );
  }
}
