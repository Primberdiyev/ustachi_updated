
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_store.dart';
import 'package:ustachi/features/hisob/domain/settings_options.dart';
import 'package:ustachi/features/hisob/presentation/hisob_order_page.dart';
import 'package:ustachi/features/hisob/presentation/hisob_project_page.dart';
import 'package:ustachi/features/hisob/presentation/hisob_template_page.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_page.dart';
import 'package:ustachi/features/hisob/presentation/widgets/hisob_ui.dart';

class HisobListPage extends StatelessWidget {
  const HisobListPage({super.key, required this.store});

  final HisobStore store;

  void _open(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HisobProjectPage(projectId: id, store: store)),
    );
  }

  Future<void> _create(BuildContext context) async {
    final now = DateTime.now();
    final kind = await pickOption<HisobKind>(
      context,
      title: 'Nima chizamiz?',
      options: [
        for (final k in HisobKind.values)
          Option(k, k.label, hint: '${k.defaultWidthMm.round()} × ${k.defaultHeightMm.round()} mm dan boshlanadi'),
      ],
    );
    if (kind == null || !context.mounted) return;

    const base = ItemSettings.fresh;

    final design = await HisobTemplatePage.open(
      context,
      kind: kind,
      spec: seriesSpecOf(base.material),
      store: store,
    );
    if (design == null || !context.mounted) return;
    final saved = await ItemEditorPage.open(
      context,
      item: HisobItem(
        id: newHisobId(),
        kind: kind,
        design: design,
        settings: base,
      ),
      isNew: true,
      onSaveTemplate: store.saveTemplate,
    );
    if (saved == null || !context.mounted) return;
    final project = HisobProject(id: newHisobId(), createdAt: now, updatedAt: DateTime.now()).upsertItem(saved);
    store.save(project);
    _open(context, project.id);
  }

  Future<void> _delete(BuildContext context, HisobProject project) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hisobni o\'chirasizmi?'),
        content: Text(
          project.client.isEmpty
              ? 'Bu hisob butunlay o\'chadi.'
              : '«${project.client}» hisobi butunlay o\'chadi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Yo\'q')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('O\'chirish')),
        ],
      ),
    );
    if (ok == true) store.remove(project.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(
        title: Text('Hisoblar'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Yangi hisob'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final projects = store.projects;
          if (projects.isEmpty) {
            return ChizmaEmptyState(
              icon: Icons.window_outlined,
              title: 'Hali hisob yo\'q',
              message: 'Mijoz uchun yangi hisob oching: deraza va eshiklarni o\'lchami bilan chizing '
                  'va chizmani saqlab qo\'ying.',
              actionLabel: 'Yangi hisob',
              onAction: () => _create(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.sm, ChizmaSpace.lg, 120),
            children: [
              for (final p in projects) ...[
                _ProjectCard(
                  project: p,
                  onTap: () => _open(context, p.id),
                  onDelete: () => _delete(context, p),
                ),
                const SizedBox(height: ChizmaSpace.md),
              ],
            ],
          );
        },
      ),
    );
  }
}

String _ago(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'hozir';
  if (diff.inHours < 1) return '${diff.inMinutes} daqiqa oldin';
  if (diff.inDays < 1) return '${diff.inHours} soat oldin';
  if (diff.inDays < 7) return '${diff.inDays} kun oldin';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap, required this.onDelete});

  final HisobProject project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final pieces = project.pieceCount;

    return ChizmaSheet(
      onTap: onTap,
      child: Row(
        children: [
          const ChizmaIconTile(icon: Icons.window_outlined, size: 44, filled: true),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.client.isEmpty ? 'Nomsiz hisob' : project.client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.h4.copyWith(color: colors.neutral.textStrong),
                ),
                Text(
                  project.isEmpty ? 'Buyum yo\'q · ${_ago(project.updatedAt)}' : '$pieces dona · ${_ago(project.updatedAt)}',
                  style: context.text.body5.copyWith(color: colors.neutral.textMuted),
                ),
                if (project.order.deadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Muddat: ${orderDateText(project.order.deadline!)}',
                      style: context.text.label.copyWith(color: colors.categorizedColor.primary),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'O\'chirish',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: colors.neutral.textMuted),
          ),
        ],
      ),
    );
  }
}
