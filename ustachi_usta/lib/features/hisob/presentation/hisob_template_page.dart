
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/domain/hisob_templates.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

const showBuiltInTemplates = false;

hisob.FrameDesign emptyTemplateOf(HisobKind kind) =>
    hisob.FrameDesign(widthMm: kind.defaultWidthMm, heightMm: kind.defaultHeightMm);

class HisobTemplatePage extends StatelessWidget {
  const HisobTemplatePage({super.key, required this.kind, required this.spec, this.store});

  final HisobKind kind;

  final hisob.SeriesSpec spec;

  final HisobStore? store;

  static Future<hisob.FrameDesign?> open(
    BuildContext context, {
    required HisobKind kind,
    required hisob.SeriesSpec spec,
    HisobStore? store,
  }) =>
      Navigator.of(context).push<hisob.FrameDesign>(
        MaterialPageRoute(builder: (_) => HisobTemplatePage(kind: kind, spec: spec, store: store)),
      );

  Future<void> _delete(BuildContext context, hisob.FrameDesign design) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Shablonni o\'chirasizmi?'),
        content: Text('Bu shablon ro\'yxatdan o\'chadi. Hisoblarga ta\'sir qilmaydi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Yo\'q')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('O\'chirish')),
        ],
      ),
    );
    if (ok == true) store?.removeTemplate(kind, design);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    SliverPadding title(String text) => SliverPadding(
          padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.lg, ChizmaSpace.lg, ChizmaSpace.sm),
          sliver: SliverToBoxAdapter(child: ChizmaEyebrow(text)),
        );

    SliverPadding grid(List<hisob.FrameDesign> designs, {bool own = false}) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg),
          sliver: SliverGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: ChizmaSpace.sm,
            crossAxisSpacing: ChizmaSpace.sm,
            childAspectRatio: 0.78,
            children: [
              for (final d in designs)
                _TemplateTile(
                  design: d,
                  spec: spec,
                  onTap: () => Navigator.of(context).pop(d),
                  onDelete: own ? () => _delete(context, d) : null,
                ),
            ],
          ),
        );

    Widget body() {
      final own = store?.templatesOf(kind) ?? const <hisob.FrameDesign>[];
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.md, ChizmaSpace.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Bo\'sh katakdan boshlab o\'zingiz chizing. Chizganingizni «Shablondek saqlash» bilan '
                'shu yerga qo\'shasiz — keyin bir bosishda qayta ishlatasiz.',
                style: context.text.body5.copyWith(color: colors.neutral.textMuted),
              ),
            ),
          ),
          title('Bo\'sh'),

          grid([emptyTemplateOf(kind)]),

          if (shapeTemplatesFor(kind) case final shapes when shapes.isNotEmpty) ...[
            title('G va T shakl (${shapes.length})'),
            grid(shapes),
          ],
          if (own.isNotEmpty) ...[
            title('Mening shablonlarim (${own.length})'),
            grid(own, own: true),
          ],
          if (showBuiltInTemplates)
            for (final g in templateGroupsFor(kind).where((g) => g.title != doorGroupTitles.last)) ...[
              title('${g.title} (${g.designs.length})'),
              grid(g.designs),
            ],
          const SliverToBoxAdapter(child: SizedBox(height: ChizmaSpace.xxl)),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text('${kind.label} — shablon')),
      body: store == null ? body() : ListenableBuilder(listenable: store!, builder: (_, __) => body()),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.design, required this.spec, required this.onTap, this.onDelete});

  final hisob.FrameDesign design;
  final hisob.SeriesSpec spec;
  final VoidCallback onTap;

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final tile = ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.sm),
      child: Column(
        children: [

          Expanded(
            child: IgnorePointer(child: FrameCanvas(design: design, spec: spec, showDimensions: false)),
          ),
          const SizedBox(height: 4),
          Text(
            '${design.widthMm.round()}×${design.heightMm.round()}',
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
        ],
      ),
    );
    if (onDelete == null) return tile;
    return Stack(
      children: [
        Positioned.fill(child: tile),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            tooltip: 'Shablonni o\'chirish',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: onDelete,
            icon: Icon(Icons.close_rounded, color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}
