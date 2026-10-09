import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_groups.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';

class AllSpecialtiesPage extends StatefulWidget {
  const AllSpecialtiesPage({
    super.key,
    this.specialties = const [],
    this.title,
    this.searchHint,
  });

  final List<SpecialtyEntity> specialties;

  final String? title;
  final String? searchHint;

  bool get isGroupPage => title != null;

  @override
  State<AllSpecialtiesPage> createState() => _AllSpecialtiesPageState();
}

class _AllSpecialtiesPageState extends State<AllSpecialtiesPage> {
  final _searchCtrl = TextEditingController();

  late List<SpecialtyEntity> _all = widget.specialties;
  late bool _loading = widget.specialties.isEmpty;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (_loading) _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await sl<MarketplaceRepository>().specialties();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isRight) _all = result.right;
    });
  }

  List<SpecialtyEntity> get _visible {

    if (_query.isEmpty) {
      return widget.isGroupPage ? _all : SpecialtyGroups.collapse(_all);
    }
    final query = _query.toLowerCase();
    return _all
        .where((s) =>
            localizedSpecialtyName(context, s.code, s.name)
                .toLowerCase()
                .contains(query) ||
            s.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.home;
    final rows = _visible;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(widget.title ?? t.serviceType)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ChizmaSpace.lg,
              ChizmaSpace.md,
              ChizmaSpace.lg,
              ChizmaSpace.sm,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: uz(widget.searchHint ?? t.searchHint),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                    ? ChizmaEmptyState(
                        icon: Icons.search_off_rounded,
                        title: context.t.common.notFound,
                        message: _query.isEmpty
                            ? t.notFoundEmpty
                            : t.notFoundQuery(query: _query),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          ChizmaSpace.lg,
                          ChizmaSpace.sm,
                          ChizmaSpace.lg,
                          ChizmaSpace.xxl + context.viewPaddingBottom,
                        ),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: ChizmaSpace.xs),
                        itemBuilder: (_, index) => _SpecialtyRow(
                          specialty: rows[index],
                          onTap: () =>
                              SpecialtyGroups.open(context, rows[index], _all),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyRow extends StatelessWidget {
  const _SpecialtyRow({required this.specialty, required this.onTap});

  final SpecialtyEntity specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final image = SpecialtyVisuals.imageOf(specialty.code);

    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: ChizmaSpace.md,
        vertical: ChizmaSpace.sm,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ChizmaRadius.sm),
            child: Container(
              width: 44,
              height: 44,
              color: colors.neutral.white,
              padding: const EdgeInsets.all(3),
              alignment: Alignment.center,
              child: image != null
                  ? Image.asset(image, fit: BoxFit.contain, cacheWidth: 180)
                  : Icon(
                      SpecialtyVisuals.iconOf(specialty.code),
                      color: colors.categorizedColor.primary,
                    ),
            ),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Text(
              localizedSpecialtyName(context, specialty.code, specialty.name),
              style:
                  context.text.body4.copyWith(color: colors.neutral.textStrong),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.neutral.textMuted),
        ],
      ),
    );
  }
}
