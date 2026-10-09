import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/home/presentation/view/all_specialties_page.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_flow.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_groups.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/specialty_catalog.dart';

class ServicesWidget extends StatefulWidget {
  const ServicesWidget({super.key});

  @override
  State<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {

  static const int _visibleTiles = 7;

  SpecialtyCatalog get _catalog => sl<SpecialtyCatalog>();

  late bool _waiting = _catalog.isEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {

    await _catalog.ensureFresh();
    if (mounted && _waiting) setState(() => _waiting = false);
  }

  List<SpecialtyEntity> _featured(List<SpecialtyEntity> all) {
    final withImage = all.where((s) => SpecialtyVisuals.hasImage(s.code));
    final rest = all.where((s) =>
        !SpecialtyVisuals.hasImage(s.code) && !SpecialtyGroups.isGroup(s));
    final ordered = [...withImage, ...rest];
    if (all.any(SpecialtyGroups.isGroup)) {
      ordered.insert(
          ordered.length < _texnikaSlot ? ordered.length : _texnikaSlot,
          SpecialtyGroups.texnika);
    }
    return ordered.take(_visibleTiles).toList();
  }

  static const int _texnikaSlot = 3;

  Future<void> _open(SpecialtyEntity specialty) =>
      SpecialtyGroups.open(context, specialty, _catalog.value);

  void _showAll() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AllSpecialtiesPage(specialties: _catalog.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<List<SpecialtyEntity>>(
      valueListenable: _catalog,
      builder: (context, all, _) => _build(context, all),
    );
  }

  Widget _build(BuildContext context, List<SpecialtyEntity> all) {
    if (all.isEmpty && _waiting) {
      return const _TilesSkeleton();
    }
    if (all.isEmpty) {

      return _ServiceTile(
        label: localizedSpecialtyName(
          context,
          SpecialtyEntity.romCode,
          'Alyumin va PVX eshik va rom',
        ),
        code: SpecialtyEntity.romCode,

        onTap: () => openSpecialtyFlow(
          context,
          const SpecialtyEntity(
            id: 0,
            code: SpecialtyEntity.romCode,
            name: 'Alyumin va PVX eshik va rom ustasi',
            calculator: SpecialtyCalculator.rom,
          ),
        ),
      );
    }

    final grouped = SpecialtyGroups.collapse(all);
    final featured = _featured(grouped);
    final hasMore = grouped.length > featured.length;
    final count = featured.length + (hasMore ? 1 : 0);

    final perRow = (count + 1) ~/ 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - (perRow - 1) * ChizmaSpace.sm) / perRow;
        final labelWidth = tileWidth - _ServiceTile.horizontalInset;
        return _rows(
          perRow: perRow,
          tiles: [
            for (final specialty in featured)
              _ServiceTile(

                label: localizedSpecialtyName(
                  context,
                  specialty.code,
                  specialty.workName,
                ),
                code: specialty.code,
                labelWidth: labelWidth,
                onTap: () => _open(specialty),
              ),
            if (hasMore)
              _ServiceTile(
                label: context.t.home.all,
                code: '',
                labelWidth: labelWidth,
                icon: Icons.grid_view_rounded,
                onTap: _showAll,
              ),
          ],
        );
      },
    );
  }

  Widget _rows({required int perRow, required List<Widget> tiles}) {
    return Column(
      children: [
        for (var start = 0; start < tiles.length; start += perRow) ...[
          if (start > 0) const SizedBox(height: ChizmaSpace.sm),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < perRow; col++) ...[
                  if (col > 0) const SizedBox(width: ChizmaSpace.sm),
                  Expanded(
                    child: start + col < tiles.length
                        ? tiles[start + col]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TilesSkeleton extends StatelessWidget {
  const _TilesSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    Widget box() => Expanded(
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: colors.neutral.surface,
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
              border: Border.all(color: colors.neutral.border),
            ),
          ),
        );
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                if (col > 0) const SizedBox(width: ChizmaSpace.sm),
                box(),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.label,
    required this.code,
    required this.onTap,
    this.labelWidth,
    this.icon,
  });

  final String label;
  final String code;
  final VoidCallback onTap;

  final double? labelWidth;

  static const double horizontalInset = ChizmaSpace.xs * 2 + 2;

  final IconData? icon;

  static const double _imageSize = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.md);
    final image = SpecialtyVisuals.imageOf(code);

    return Material(
      color: colors.neutral.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: ChizmaBorder.safePadding(
            const EdgeInsets.symmetric(
              horizontal: ChizmaSpace.xs,
              vertical: ChizmaSpace.md,
            ),
            1,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.neutral.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                child: Container(
                  width: _imageSize,
                  height: _imageSize,
                  color: colors.neutral.white,
                  padding: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  child: image != null
                      ? Image.asset(
                          image,
                          fit: BoxFit.contain,

                          cacheWidth: 200,
                          errorBuilder: (_, __, ___) => Icon(
                            SpecialtyVisuals.iconOf(code),
                            size: _imageSize * 0.6,
                            color: colors.categorizedColor.primary,
                          ),
                        )
                      : Icon(
                          icon ?? SpecialtyVisuals.iconOf(code),
                          size: _imageSize * 0.6,
                          color: colors.categorizedColor.primary,
                        ),
                ),
              ),
              const SizedBox(height: ChizmaSpace.sm),

              _TwoLineLabel(
                label,
                maxWidth: labelWidth,
                style:
                    context.text.label.copyWith(color: colors.neutral.textBody),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoLineLabel extends StatelessWidget {
  const _TwoLineLabel(this.text, {required this.style, this.maxWidth});

  final String text;
  final TextStyle style;
  final double? maxWidth;

  static const double _minSize = 9;

  @override
  Widget build(BuildContext context) {

    final shown = uz(text);
    var size = style.fontSize ?? 12;
    final width = maxWidth;
    if (width != null && width > 0) {
      while (size > _minSize &&
          _exceeds(shown, style.copyWith(fontSize: size), width)) {
        size -= 0.5;
      }
    }
    return Text(
      shown,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style.copyWith(fontSize: size, height: 1.15),
    );
  }

  static bool _exceeds(String text, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style.copyWith(height: 1.15)),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    final exceeds = painter.didExceedMaxLines;
    painter.dispose();
    return exceeds;
  }
}
