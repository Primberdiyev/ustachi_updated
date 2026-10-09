import 'dart:async';
import 'package:ustachi/core/design_sytem/widgets/list_loading_placeholder.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/locations_repository.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/specialty_filter_chips.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_profile_page.dart';
import 'package:ustachi/features/masters/domain/models/master_card_item_model.dart';
import 'package:ustachi/features/masters/presentation/router/masters_route.dart';
import 'package:ustachi/features/masters/presentation/widgets/master_card_item.dart';

class MastersPage extends StatefulWidget {
  const MastersPage({
    super.key,
    required this.route,
  });
  final MastersRoute route;

  @override
  State<MastersPage> createState() => _MastersPageState();
}

class _MastersPageState extends State<MastersPage> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int? _nextPage;
  bool _loadingMore = false;
  String? _moreError;

  List<MasterCardEntity> _loadedMasters = const [];
  List<MasterCardEntity> get _masters =>
      _loadedMasters.where((m) => m.matchesSearch(_query)).toList();
  int _loadVersion = 0;
  bool _loading = true;
  String? _error;
  String _query = '';

  int? _specialtyId;

  LocationEntity? _region;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onQueryChanged);
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_query.isEmpty &&
        _scrollCtrl.hasClients &&
        _scrollCtrl.position.extentAfter < 300 &&
        _moreError == null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final page = _nextPage;
    if (page == null || _loading || _loadingMore) return;
    final version = _loadVersion;
    setState(() {
      _loadingMore = true;
      _moreError = null;
    });
    try {
      final result = await sl<MarketplaceRepository>()
          .mastersPage(
            page: page,
            specialtyId: _specialtyId,
            regionId: _region?.id,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted || version != _loadVersion) return;
      if (result.isLeft) {
        setState(() => _moreError = result.left.errorMessage);
      } else {
        final response = result.right;
        if (response.nextPage != null && response.nextPage! <= page) {
          throw const FormatException('Invalid next page');
        }
        setState(() {
          final byId = {for (final master in _loadedMasters) master.id: master};
          for (final master in response.items) {
            byId[master.id] = master;
          }
          _loadedMasters = byId.values.toList();
          _nextPage = response.items.isEmpty ? null : response.nextPage;
        });
      }
    } catch (error) {
      if (!mounted || version != _loadVersion) return;
      setState(() => _moreError = error is TimeoutException
          ? context.t.common.loadingTimeout
          : context.t.common.wentWrong);
    } finally {
      if (mounted && version == _loadVersion) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _onQueryChanged() => _onSearch(_searchCtrl.text);

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final results = await Future.wait([
      sl<LocationsRepository>().regions(),
      sl<MarketplaceRepository>().specialties(),
    ]);
    if (!mounted) return;
    final regionsResult = results[0] as Either<Failure, List<LocationEntity>>;
    final specialtiesResult =
        results[1] as Either<Failure, List<SpecialtyEntity>>;
    final regions =
        regionsResult.isRight ? regionsResult.right : const <LocationEntity>[];
    final specialties = specialtiesResult.isRight
        ? specialtiesResult.right
        : const <SpecialtyEntity>[];
    if (regions.isEmpty && specialties.isEmpty) {
      sl<SnackbarService>().showMessage('Sozlamalar yuklanmadi.');
      return;
    }

    final picked = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.color.neutral.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(ChizmaRadius.lg)),
      ),
      builder: (_) => _FilterSheet(
        specialties: specialties,
        regions: regions,
        specialtyId: _specialtyId,
        region: _region,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _specialtyId = picked.specialtyId;
      _region = picked.region;
    });
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _error = null;
      _loadedMasters = const [];
      _nextPage = null;
      _loadingMore = false;
      _moreError = null;
    });

    try {
      final result = await sl<MarketplaceRepository>()
          .mastersPage(
            refresh: refresh,
            specialtyId: _specialtyId,
            regionId: _region?.id,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted || version != _loadVersion) return;
      setState(() {
        if (result.isRight) {
          _loadedMasters = result.right.items;
          _nextPage = result.right.items.isEmpty ? null : result.right.nextPage;
        } else {
          _error = result.left.errorMessage;
        }
      });
    } catch (error) {
      if (!mounted || version != _loadVersion) return;
      setState(() => _error = error is TimeoutException
          ? context.t.common.loadingTimeout
          : context.t.common.wentWrong);
    } finally {
      if (mounted && version == _loadVersion) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearch(String value) {
    setState(() => _query = value.trim());
  }

  void _openMaster(MasterCardEntity master) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MasterProfilePage(masterId: master.id),
      ),
    );
  }

  MasterCardItemModel _toCard(MasterCardEntity master) {
    final t = context.t.masters;
    final jobName = localizedMasterSpecialties(
        context, master.specialties, master.specialty);
    final rate = master.rateFor(_specialtyId);
    return MasterCardItemModel(
      name: master.fullName.isEmpty ? t.noName : master.fullName,
      job: jobName,
      experience: master.experienceYears == null
          ? t.noExperience
          : t.experienceYears(count: master.experienceYears!),
      location: master.location.isEmpty ? t.noAddress : master.location,
      price: rate != null
          ? '${formatSom(rate.price.toDouble())} ${context.t.calculatePage.som}/${rate.unit}'
          : (master.completedOrders > 0
              ? t.completedOrders(count: master.completedOrders)
              : t.newMaster),
      rating: master.rating,
      imageUrl: master.photo ?? '',
      phone: master.phoneNumber,
      onTap: (_) => _openMaster(master),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masters = _masters;
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(15.w, ChizmaSpace.md, 15.w, 0),
            sliver: SliverToBoxAdapter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t.masters.masterList, style: context.text.h2),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _SearchField(
                        controller: _searchCtrl,
                        onSubmitted: _onSearch,
                        onClear: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      ),
                    ),
                    const SizedBox(width: ChizmaSpace.sm),
                    _FilterButton(
                      active: _region != null || _specialtyId != null,
                      onTap: _openFilters,
                    ),
                  ],
                ),
                if (_region != null) ...[
                  SizedBox(height: 8.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: InputChip(
                      label: Text(_region!.name),
                      avatar: const Icon(Icons.location_on_outlined, size: 16),
                      onDeleted: () {
                        setState(() => _region = null);
                        _load();
                      },
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                SpecialtyFilterChips(
                  selectedId: _specialtyId,
                  onSelected: (id) {
                    if (_specialtyId == id) return;
                    setState(() => _specialtyId = id);
                    _load();
                  },
                ),
                SizedBox(height: 12.h),
                if (!_loading && _query.isNotEmpty && _nextPage != null) ...[
                  Text(context.t.masters.searchLoadedOnly,
                      style: context.text.body5
                          .copyWith(color: context.color.neutral.textMuted)),
                  const SizedBox(height: ChizmaSpace.sm),
                ],
                if (_loading)
                  const ListLoadingPlaceholder(showAvatar: true)
                else if (_error != null)
                  _Message(
                    icon: Icons.wifi_off_rounded,
                    title: context.t.masters.loadFailed,
                    subtitle: _error!,
                    actionLabel: context.t.common.retry,
                    onAction: _load,
                  )
                else if (masters.isEmpty)
                  _Message(
                    icon: Icons.person_search_outlined,
                    title: _query.isEmpty &&
                            _specialtyId == null &&
                            _region == null
                        ? context.t.masters.noMastersYet
                        : context.t.common.notFound,
                    subtitle: _query.isNotEmpty
                        ? (_nextPage != null
                            ? context.t.masters.searchLoadedOnly
                            : context.t.masters.searchNotFound(query: _query))
                        : _region != null
                            ? context.t.masters
                                .regionNotFound(region: _region!.name)
                            : _specialtyId != null
                                ? context.t.masters.specialtyNotFound
                                : context.t.masters.defaultEmpty,
                  )
              ],
            )),
          ),
          if (!_loading && _error == null && masters.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, ChizmaSpace.xl),
              sliver: SliverList.builder(
                itemCount: masters.length,
                itemBuilder: (context, index) =>
                    MasterCardItem(model: _toCard(masters[index])),
              ),
            ),
          if (!_loading && _error == null && _nextPage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(ChizmaSpace.lg),
                child: Column(children: [
                  if (_moreError != null) ...[
                    Text(_moreError!, textAlign: TextAlign.center),
                    const SizedBox(height: ChizmaSpace.sm),
                  ],
                  if (_loadingMore)
                    LinearProgressIndicator(
                        semanticsLabel: context.t.common.loading)
                  else
                    OutlinedButton.icon(
                      onPressed: _loadMore,
                      icon: Icon(_moreError == null
                          ? Icons.expand_more
                          : Icons.refresh),
                      label: Text(_moreError == null
                          ? context.t.masters.loadMore
                          : context.t.common.retry),
                    ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(

        hintText: uz(context.t.masters.searchHint),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
                tooltip: uz(context.t.masters.clear),
              ),
        filled: true,
        fillColor: colors.neutral.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          borderSide: BorderSide(color: colors.neutral.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          borderSide: BorderSide(color: colors.neutral.border),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.xxl),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.neutral.textMuted),
          const SizedBox(height: ChizmaSpace.md),
          Text(
            title,
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ChizmaSpace.xs),
          Text(
            subtitle,
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: ChizmaSpace.md),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return Material(
      color: active ? primary.withValues(alpha: 0.10) : colors.neutral.surface,
      borderRadius: BorderRadius.circular(ChizmaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ChizmaRadius.md),
            border: Border.all(
              color: active ? primary : colors.neutral.border,
            ),
          ),
          child: Badge(
            isLabelVisible: active,
            smallSize: 8,
            backgroundColor: primary,
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: active ? primary : colors.neutral.textBody,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({this.specialtyId, this.region});

  final int? specialtyId;
  final LocationEntity? region;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.specialties,
    required this.regions,
    required this.specialtyId,
    required this.region,
  });

  final List<SpecialtyEntity> specialties;
  final List<LocationEntity> regions;
  final int? specialtyId;
  final LocationEntity? region;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _specialtyId = widget.specialtyId;
  late LocationEntity? _region = widget.region;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(
            ChizmaSpace.lg,
            ChizmaSpace.md,
            ChizmaSpace.lg,
            ChizmaSpace.sm,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: context.text.body4.copyWith(
                color: colors.neutral.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

    Widget choice({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) =>
        ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          labelStyle: context.text.body5.copyWith(
            color: selected
                ? colors.categorizedColor.onPrimary
                : colors.neutral.textBody,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          selectedColor: colors.categorizedColor.primary,
          backgroundColor: colors.neutral.surface,
          side: BorderSide(
            color: selected
                ? colors.categorizedColor.primary
                : colors.neutral.border,
          ),
          showCheckmark: false,
        );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: ChizmaSpace.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.neutral.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ChizmaSpace.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.masters.filterTitle,
                      style: context.text.h4
                          .copyWith(color: colors.neutral.textStrong),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: (_specialtyId == null && _region == null)
                        ? null
                        : () => setState(() {
                              _specialtyId = null;
                              _region = null;
                            }),
                    child: Text(context.t.masters.clear),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  if (widget.specialties.isNotEmpty) ...[
                    sectionTitle(context.t.masters.professionType),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChizmaSpace.lg),
                      child: Wrap(
                        spacing: ChizmaSpace.xs,
                        runSpacing: ChizmaSpace.xs,
                        children: [
                          choice(
                            label: context.t.masters.all,
                            selected: _specialtyId == null,
                            onTap: () => setState(() => _specialtyId = null),
                          ),
                          for (final specialty in widget.specialties)
                            choice(
                              label: localizedSpecialtyName(
                                  context, specialty.code, specialty.name),
                              selected: _specialtyId == specialty.id,
                              onTap: () =>
                                  setState(() => _specialtyId = specialty.id),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.regions.isNotEmpty) ...[
                    sectionTitle(context.t.masters.region),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChizmaSpace.lg),
                      child: Wrap(
                        spacing: ChizmaSpace.xs,
                        runSpacing: ChizmaSpace.xs,
                        children: [
                          choice(
                            label: context.t.masters.allRegions,
                            selected: _region == null,
                            onTap: () => setState(() => _region = null),
                          ),
                          for (final region in widget.regions)
                            choice(
                              label: region.name,
                              selected: _region?.id == region.id,
                              onTap: () => setState(() => _region = region),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: ChizmaSpace.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ChizmaSpace.lg,
                ChizmaSpace.sm,
                ChizmaSpace.lg,
                ChizmaSpace.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    _FilterResult(specialtyId: _specialtyId, region: _region),
                  ),
                  child: Text(context.t.masters.apply),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
