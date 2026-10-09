
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/domain/settings_options.dart';
import 'package:ustachi/features/hisob/presentation/hisob_order_page.dart';
import 'package:ustachi/features/hisob/presentation/hisob_template_page.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_page.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi/features/hisob/presentation/widgets/hisob_ui.dart';

class HisobProjectPage extends StatelessWidget {
  const HisobProjectPage({super.key, required this.projectId, required this.store});

  final String projectId;
  final HisobStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final project = store.byId(projectId);
        if (project == null) {

          return const Scaffold(body: SizedBox.shrink());
        }
        return PopScope(

          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) return;
            final p = store.byId(projectId);
            if (p != null && p.isEmpty && p.client.isEmpty && p.order.isEmpty) store.remove(projectId);
          },
          child: _ProjectView(project: project, store: store),
        );
      },
    );
  }
}

class _ProjectView extends StatelessWidget {
  const _ProjectView({required this.project, required this.store});

  final HisobProject project;
  final HisobStore store;

  Future<void> _addItem(BuildContext context) async {
    final kind = await pickOption<HisobKind>(
      context,
      title: 'Nima chizamiz?',
      options: [
        for (final k in HisobKind.values) Option(k, k.label, hint: '${k.defaultWidthMm.round()} × ${k.defaultHeightMm.round()} mm dan boshlanadi'),
      ],
    );
    if (kind == null || !context.mounted) return;

    final base = project.items.isEmpty ? ItemSettings.fresh : project.items.last.settings;

    final design = await HisobTemplatePage.open(
      context,
      kind: kind,
      spec: seriesSpecOf(base.material),
      store: store,
    );
    if (design == null || !context.mounted) return;
    final item = HisobItem(
      id: newHisobId(),
      kind: kind,
      design: design,
      settings: base.copyWith(qty: 1),
    );
    final saved = await ItemEditorPage.open(
      context,
      item: item,
      isNew: true,
      onSaveTemplate: store.saveTemplate,
    );
    if (saved != null) store.save(project.upsertItem(saved));
  }

  Future<void> _edit(BuildContext context, HisobItem item) async {
    final saved = await ItemEditorPage.open(
      context,
      item: item,
      onSaveTemplate: store.saveTemplate,
    );
    if (saved != null) store.save(project.upsertItem(saved));
  }

  void _duplicate(HisobItem item) {
    store.save(project.upsertItem(HisobItem(id: newHisobId(), kind: item.kind, design: item.design, settings: item.settings)));
  }

  Future<void> _delete(BuildContext context, HisobItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Buyumni o\'chirasizmi?'),
        content: Text('${item.kind.label} ${item.sizeLabel} hisobdan olib tashlanadi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Yo\'q')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('O\'chirish')),
        ],
      ),
    );
    if (ok == true) store.save(project.removeItem(item.id));
  }

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: project.client);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mijoz'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ism yoki manzil'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Bekor')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: Text('Tayyor')),
        ],
      ),
    );
    if (name != null) store.save(project.copyWith(client: name.trim()));
  }

  Future<void> _editOrder(BuildContext context) async {
    final result = await HisobOrderPage.open(context, client: project.client, order: project.order);
    if (result != null) store.save(project.copyWith(client: result.client, order: result.order));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(
        title: InkWell(
          onTap: () => _rename(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  project.client.isEmpty ? 'Mijoz nomi' : project.client,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, size: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Buyum qo\'shish'),
      ),
      body: project.isEmpty
              ? ChizmaEmptyState(
                  icon: Icons.window_outlined,
                  title: 'Hali buyum yo\'q',
                  message: 'Deraza yoki eshik qo\'shing — o\'lchami bilan chizib, saqlab qo\'yasiz.',
                  actionLabel: 'Buyum qo\'shish',
                  onAction: () => _addItem(context),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.sm, ChizmaSpace.lg, 160),
                  children: [

                    _OrderCard(
                      client: project.client,
                      order: project.order,
                      onTap: () => _editOrder(context),
                    ),
                    const SizedBox(height: ChizmaSpace.md),
                    for (final item in project.items) ...[
                      _ItemCard(
                        item: item,
                        onTap: () => _edit(context, item),
                        onDuplicate: () => _duplicate(item),
                        onDelete: () => _delete(context, item),
                      ),
                      const SizedBox(height: ChizmaSpace.md),
                    ],
                  ],
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.client, required this.order, required this.onTap});

  final String client;
  final HisobOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final muted = context.text.body5.copyWith(color: colors.neutral.textMuted);
    final strong = context.text.body4.copyWith(color: colors.neutral.textStrong, fontWeight: FontWeight.w700);

    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: colors.neutral.textMuted),
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(child: Text(label, style: muted)),
              Flexible(child: Text(value, style: strong, textAlign: TextAlign.end)),
            ],
          ),
        );

    final overdue = order.deadline != null && order.deadline!.isBefore(DateUtils.dateOnly(DateTime.now()));

    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 20, color: colors.categorizedColor.primary),
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(
                child: Text(
                  'Buyurtma ma\'lumoti',
                  style: context.text.h4.copyWith(color: colors.neutral.textStrong),
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: colors.neutral.textMuted),
            ],
          ),
          if (order.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Mijoz ismi, telefon, manzil va bitkazish sanasini yozib qo\'ying',
                style: muted,
              ),
            )
          else ...[
            if (client.isNotEmpty) row(Icons.person_outline_rounded, 'Mijoz', client),
            if (order.phone.isNotEmpty) row(Icons.phone_outlined, 'Telefon', order.phone),
            if (order.address.isNotEmpty) row(Icons.location_on_outlined, 'Manzil', order.address),
            if (order.deadline != null)
              row(
                Icons.event_outlined,
                'Bitkazish sanasi',
                '${orderDateText(order.deadline!)}${overdue ? ' — muddati o\'tgan' : ''}',
              ),
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });

  final HisobItem item;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final s = item.settings;
    final spec = seriesSpecOf(s.material);
    final subtitle = [materialLabel(s.material), colorDisplay(s)].join(' · ');

    return ChizmaSheet(
      onTap: onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colors.neutral.surface2,
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
            ),
            child: FrameCanvas(
              design: item.design,
              spec: spec,
              showDimensions: false,
              frameColor: frameColorOf(s.colorArgb),
            ),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.kind.label} ${item.sizeLabel}',
                  style: context.text.h4.copyWith(color: colors.neutral.textStrong),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.body5.copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.qty} dona',
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'copy' ? onDuplicate() : onDelete(),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'copy', child: Text('Nusxa olish')),
              PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
            ],
          ),
        ],
      ),
    );
  }
}
