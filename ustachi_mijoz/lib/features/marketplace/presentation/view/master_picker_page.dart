import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/specialty_filter_chips.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/master_rates_block.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_profile_page.dart';

class MasterPickerPage extends StatefulWidget {
  const MasterPickerPage({
    super.key,
    this.summary,
    this.alreadyInvited = const {},
    this.actionLabel,
    this.specialtyId,
    this.repairsOnly = false,
  });

  final String? summary;

  final Set<int> alreadyInvited;

  final String? actionLabel;

  final int? specialtyId;

  final bool repairsOnly;

  @override
  State<MasterPickerPage> createState() => _MasterPickerPageState();
}

class _MasterPickerPageState extends State<MasterPickerPage> {
  final _searchCtrl = TextEditingController();

  List<MasterCardEntity> _loadedMasters = const [];
  List<MasterCardEntity> get _masters =>
      _loadedMasters.where((m) => m.matchesSearch(_query)).toList();
  int _loadVersion = 0;
  final Set<int> _selected = <int>{};
  bool _loading = true;
  String? _error;
  String _query = '';

  int? _pickedSpecialtyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<MarketplaceRepository>().masters(
      specialtyId: widget.specialtyId ?? _pickedSpecialtyId,
      repairsOnly: widget.repairsOnly,
    );
    if (!mounted || version != _loadVersion) return;

    setState(() {
      _loading = false;
      if (result.isRight) {
        _loadedMasters = result.right;
      } else {
        _error = result.left.errorMessage;
      }
    });
  }

  void _onSearch(String value) {
    final query = value.trim();
    if (query == _query) return;
    setState(() => _query = query);
  }

  void _toggle(MasterCardEntity master) {
    if (widget.alreadyInvited.contains(master.id)) return;
    setState(() {
      if (!_selected.remove(master.id)) _selected.add(master.id);
    });
  }

  void _openProfile(MasterCardEntity master) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MasterProfilePage(masterId: master.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: const Text('Usta tanlash')),
      body: Column(
        children: [

          if (widget.summary != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: ChizmaSpace.lg,
                vertical: ChizmaSpace.md,
              ),
              color: colors.neutral.surface,
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 18, color: colors.categorizedColor.primary),
                  const SizedBox(width: ChizmaSpace.sm),
                  Expanded(
                    child: Text(
                      widget.summary!,
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textStrong),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ChizmaSpace.lg,
              ChizmaSpace.md,
              ChizmaSpace.lg,
              ChizmaSpace.sm,
            ),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: uz('Ism, yo\'nalish yoki telefon raqam'),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: colors.neutral.surface,
              ),
            ),
          ),

          if (widget.specialtyId == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ChizmaSpace.lg,
                0,
                ChizmaSpace.lg,
                ChizmaSpace.sm,
              ),
              child: SpecialtyFilterChips(
                selectedId: _pickedSpecialtyId,
                onSelected: (id) {
                  if (_pickedSpecialtyId == id) return;
                  setState(() => _pickedSpecialtyId = id);
                  _load();
                },
              ),
            ),
          Expanded(child: _body()),
        ],
      ),
      bottomNavigationBar: _SendBar(
        count: _selected.length,
        label: widget.actionLabel ?? 'Yuborish',
        onSend: _selected.isEmpty
            ? null
            : () => Navigator.of(context).pop<List<int>>(_selected.toList()),
      ),
    );
  }

  Widget _body() {
    final masters = _masters;
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return ChizmaEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Ro\'yxat yuklanmadi',
        message: _error!,
        actionLabel: 'Qayta urinish',
        onAction: _load,
      );
    }

    if (masters.isEmpty) {
      return ChizmaEmptyState(
        icon: Icons.person_search_outlined,
        title: _query.isEmpty ? 'Hozircha usta yo\'q' : 'Topilmadi',
        message: _query.isEmpty
            ? 'Ustalar ro\'yxatdan o\'tgach shu yerda ko\'rinadi. Hozircha '
                'e\'lonni hamma ustaga berishingiz mumkin.'
            : '"$_query" bo\'yicha usta topilmadi.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.sm,
          ChizmaSpace.lg,
          ChizmaSpace.xxl,
        ),
        itemCount: masters.length,
        separatorBuilder: (_, __) => const SizedBox(height: ChizmaSpace.sm),
        itemBuilder: (context, index) {
          final master = masters[index];
          return MasterPickCard(
            master: master,
            selected: _selected.contains(master.id),
            invited: widget.alreadyInvited.contains(master.id),
            onTap: () => _toggle(master),
            onProfile: () => _openProfile(master),
          );
        },
      ),
    );
  }
}

class MasterPickCard extends StatelessWidget {
  const MasterPickCard({
    super.key,
    required this.master,
    required this.selected,
    required this.onTap,
    required this.onProfile,
    this.invited = false,
  });

  final MasterCardEntity master;
  final bool selected;
  final bool invited;
  final VoidCallback onTap;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final radius = BorderRadius.circular(ChizmaRadius.lg);
    final active = selected || invited;
    final width = active ? 2.0 : 1.0;

    return Material(
      color:
          selected ? primary.withValues(alpha: 0.06) : colors.neutral.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: invited ? null : onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: active ? primary : colors.neutral.border,
              width: width,
            ),
          ),

          padding: ChizmaBorder.safePadding(
            const EdgeInsets.all(ChizmaSpace.md),
            width,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(master: master),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            master.fullName.isEmpty
                                ? 'Ism ko\'rsatilmagan'
                                : master.fullName,
                            style: context.text.body4.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (master.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded,
                              size: 15, color: primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizedMasterSpecialties(
                          context, master.specialties, master.specialty),
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                    if (master.hasPhone) ...[
                      const SizedBox(height: 3),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_outlined, size: 13, color: primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              master.phoneNumber,
                              style: context.text.label.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (master.rates.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      MasterRatesBlock(rates: master.rates, compact: true),
                    ],
                    if (master.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      MasterNotesBlock(notes: master.notes, compact: true),
                    ],
                    const SizedBox(height: ChizmaSpace.sm),
                    _Stats(master: master),
                    if (!master.acceptsOrders) ...[
                      const SizedBox(height: ChizmaSpace.sm),

                      const ChizmaStatusPill(
                        'Hozir band',
                        status: ChizmaStatus.warning,
                      ),
                    ],
                    const SizedBox(height: ChizmaSpace.sm),
                    GestureDetector(
                      onTap: onProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ishlarini ko\'rish',
                            style: context.text.body5.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 17, color: primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              _Check(selected: selected, invited: invited),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.master});

  final MasterCardEntity master;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final photo = master.photo;
    final letter = master.fullName.trim().isEmpty
        ? '?'
        : master.fullName.trim()[0].toUpperCase();

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: colors.neutral.border),
      ),
      child: photo == null || photo.isEmpty
          ? Text(
              letter,
              style: context.text.h4.copyWith(color: colors.neutral.textMuted),
            )
          : CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              errorWidget: (_, __, ___) => Text(
                letter,
                style:
                    context.text.h4.copyWith(color: colors.neutral.textMuted),
              ),
            ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.master});

  final MasterCardEntity master;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final parts = <Widget>[];

    if (master.rating != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: 15, color: colors.categorizedColor.accent),
          const SizedBox(width: 2),
          Text(
            master.rating!.toStringAsFixed(1),
            style: context.text.label.copyWith(
              color: colors.neutral.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ));
    }
    parts.add(Text(
      master.completedOrders > 0
          ? '${master.completedOrders} ta ish'
          : 'Yangi usta',
      style: context.text.label.copyWith(color: colors.neutral.textMuted),
    ));
    if (master.experienceYears != null) {
      parts.add(Text(
        '${master.experienceYears} yil tajriba',
        style: context.text.label.copyWith(color: colors.neutral.textMuted),
      ));
    }

    return Wrap(
      spacing: ChizmaSpace.md,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts,
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected, required this.invited});

  final bool selected;
  final bool invited;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final on = selected || invited;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: on ? primary : colors.neutral.borderStrong,
          width: 1.5,
        ),
      ),
      child: on
          ? Icon(
              invited ? Icons.done_all_rounded : Icons.check_rounded,
              size: 15,
              color: colors.neutral.white,
            )
          : null,
    );
  }
}

class _SendBar extends StatelessWidget {
  const _SendBar({
    required this.count,
    required this.label,
    required this.onSend,
  });

  final int count;
  final String label;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.md,
          ChizmaSpace.lg,
          ChizmaSpace.md,
        ),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          border: Border(top: BorderSide(color: colors.neutral.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                count == 0 ? 'Ustani tanlang' : '$count ta usta tanlandi',
                style: context.text.body5.copyWith(
                  color: count == 0
                      ? colors.neutral.textMuted
                      : colors.neutral.textStrong,
                  fontWeight: count == 0 ? null : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: ChizmaSpace.md),
            ElevatedButton(onPressed: onSend, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
