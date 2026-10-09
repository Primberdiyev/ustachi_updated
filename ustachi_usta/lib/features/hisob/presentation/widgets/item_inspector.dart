
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/settings_options.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_controller.dart';
import 'package:ustachi/features/hisob/presentation/widgets/hisob_ui.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class ItemInspector extends StatelessWidget {
  const ItemInspector({super.key, required this.controller});

  final ItemEditorController controller;

  @override
  Widget build(BuildContext context) {
    final cell = controller.selectedCell;
    if (cell == null) return SettingsPanel(controller: controller);
    return CellPanel(controller: controller, cell: cell);
  }
}

class CellPanel extends StatefulWidget {
  const CellPanel({super.key, required this.controller, required this.cell});

  final ItemEditorController controller;
  final hisob.Cell cell;

  @override
  State<CellPanel> createState() => _CellPanelState();
}

class _CellPanelState extends State<CellPanel> {
  ItemEditorController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final cell = widget.cell;
    final box = c.selectedBox;
    final insideWing = c.selectedInsideWing;
    final size = box == null ? '' : '${box.region.width.round()} × ${box.region.height.round()} mm';
    final title = switch (cell) {
      hisob.Wing(:final kind) => _wingName(kind),
      hisob.Zone(:final fill) => _fillName(fill),
      hisob.Split() => 'Bo\'linish',
    };

    return Padding(
      padding: const EdgeInsets.all(ChizmaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.h4.copyWith(color: colors.neutral.textStrong)),
                    if (size.isNotEmpty)
                      Text(size, style: context.text.body5.copyWith(color: colors.neutral.textMuted)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => c.select(null),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text('Yopish'),
              ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.md),
          if (insideWing && c.enclosingWing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => c.select(c.enclosingWing),
                  icon: const Icon(Icons.open_in_full_rounded, size: 18),
                  label: Text('Qanotni tahrirlash'),
                ),
              ),
            ),
          if (!insideWing && cell is! hisob.Split)
            _Group(
              label: 'Qanot',
              child: _ChipRow(
                children: [
                  ChizmaChip(
                    label: 'Yo\'q',
                    selected: cell is hisob.Zone,
                    onTap: () => c.setWing(null),
                  ),
                  for (final k in hisob.WingKind.values)

                    if (c.wingKindAllowed(k))
                      ChizmaChip(
                        label: _wingName(k),
                        selected: cell is hisob.Wing && cell.kind == k,
                        onTap: () => c.setWing(k),
                      ),
                ],
              ),
            ),

          if (cell is hisob.Zone) ...[
            _Group(
              label: 'To\'ldirma',
              child: _ChipRow(
                children: [
                  for (final f in hisob.Fill.values)
                    ChizmaChip(
                      label: _fillName(f),
                      selected: cell.fill == f,
                      onTap: () => c.setFill(f),
                    ),
                ],
              ),
            ),
          ],
          if (cell is hisob.Wing)
            _Group(
              label: 'Tutqich tomoni',
              child: _ChipRow(
                children: [
                  for (final side in _sidesFor(cell.kind))
                    ChizmaChip(
                      label: _sideName(side),
                      selected: cell.handleSide == side,
                      onTap: () => c.setHandleSide(side),
                    ),
                ],
              ),
            ),
          if (cell is hisob.Wing && cell.kind == hisob.WingKind.door)

            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tutqich bor', style: context.text.body4),
                subtitle: Text(
                  'Juft eshikning ikkinchi tavaqasi tutqichsiz (shpingalet bilan) bo\'ladi',
                  style: context.text.label.copyWith(color: colors.neutral.textMuted),
                ),
                value: cell.hasHandle,
                onChanged: c.setHandle,
              ),
            ),
          if (c.selectedHasSplitParent && box != null) ...[
            _Group(
              label: 'Bo\'lim o\'lchami',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_sizeAlongParent(box)} mm',
                      style: context.text.body3.copyWith(color: colors.neutral.textStrong),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final v = await askNumber(
                        context,
                        title: 'Bo\'lim o\'lchami',
                        initial: _sizeAlongParent(box).toDouble(),
                        suffix: 'mm',
                        min: 50,
                      );
                      if (v != null) c.resizeSelected(v);
                    },
                    child: Text('O\'zgartirish'),
                  ),
                ],
              ),
            ),

            if (c.selectedBalconyMullion != null)
              _ProfileSwitch(
                title: 'Balkon o\'rta',
                subtitle: 'Shu bo\'lim yonidagi impostlar balkon profilidan',
                value: c.selectedBalconyMullion!,
                onChanged: c.setBalconyMullion,
              ),
            Wrap(
              spacing: ChizmaSpace.sm,
              children: [

                TextButton.icon(
                  onPressed: c.equalize,
                  icon: const Icon(Icons.view_column_outlined, size: 18),
                  label: Text('Teng bo\'lish'),
                ),
                TextButton.icon(
                  onPressed: c.removeSplit,
                  icon: const Icon(Icons.layers_clear_outlined, size: 18),
                  label: Text('Impostlarni olib tashlash'),
                ),
              ],
            ),
          ],

          if (c.selectedChiftQuloq != null && chiftQuloqAvailable(c.settings.material))
            _ProfileSwitch(
              title: 'Chift quloq',
              subtitle: 'Shu bo\'limning (eshikning) ikki yonidagi ikkala impost — juft qo\'yiladi',
              value: c.selectedChiftQuloq!,
              onChanged: c.setChiftQuloq,
            ),
          if (c.selectedWingBalcony != null)
            _ProfileSwitch(
              title: 'Balkon qanot',
              subtitle: 'Eshikning hamma tavaqasi balkon profilidan (kengroq) — birga',
              value: c.selectedWingBalcony!,
              onChanged: c.setWingBalcony,
            ),
        ],
      ),
    );
  }

  int _sizeAlongParent(hisob.CellBox box) {
    final path = box.path;
    final parent = hisob.cellAt(c.design.root, path.sublist(0, path.length - 1));
    final axis = parent is hisob.Split ? parent.axis : hisob.Axis.vertical;
    return box.sizeAlong(axis).round();
  }
}

class _ProfileSwitch extends StatelessWidget {
  const _ProfileSwitch({required this.title, required this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(title, style: context.text.body4),
          subtitle: Text(subtitle, style: context.text.label.copyWith(color: context.color.neutral.textMuted)),
          value: value,
          onChanged: onChanged,
        ),
      );
}

List<hisob.WingSide> _sidesFor(hisob.WingKind kind) => kind == hisob.WingKind.tilt
    ? const [hisob.WingSide.top, hisob.WingSide.bottom]
    : const [hisob.WingSide.left, hisob.WingSide.right];

String _sideName(hisob.WingSide s) => switch (s) {
      hisob.WingSide.left => "Chap",
      hisob.WingSide.right => "O'ng",
      hisob.WingSide.top => 'Yuqori',
      hisob.WingSide.bottom => 'Past',
    };

String _wingName(hisob.WingKind k) => switch (k) {
      hisob.WingKind.turn => 'Oddiy ochiladigan',
      hisob.WingKind.tilt => 'Fortochka',
      hisob.WingKind.tiltTurn => 'Ikki tomonlama',
      hisob.WingKind.door => 'Eshik',
    };

String _fillName(hisob.Fill f) => switch (f) {
      hisob.Fill.glass => 'Oyna',
      hisob.Fill.panel => 'Panel',
      hisob.Fill.lambriVertical => 'Lambri (tik)',
      hisob.Fill.lambriHorizontal => 'Lambri (yotiq)',

      hisob.Fill.cutout => 'Bo\'sh (kesik)',
    };

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: ChizmaSpace.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChizmaEyebrow(label),
          const SizedBox(height: ChizmaSpace.xs + 2),
          child,
        ],
      ),
    );
  }
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key, required this.controller});

  final ItemEditorController controller;

  ItemSettings get s => controller.settings;

  void _apply(BuildContext context, ItemSettings next) {
    if (!controller.updateSettings(next)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(controller.message ?? '')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Padding(
      padding: const EdgeInsets.all(ChizmaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bo\'limni bosing — bo\'lish, qanot va to\'ldirmani shu yerda tanlaysiz',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
          const SizedBox(height: ChizmaSpace.md),
          ChizmaRowGroup(
            rows: [
              SettingRow(
                icon: Icons.layers_outlined,
                label: 'Material',
                value: materialLabel(s.material),
                onTap: () async {
                  final v = await pickOption<int>(
                    context,
                    title: 'Material',
                    selected: s.material,
                    options: [
                      for (final m in materialOptions) Option(m.index, m.label, enabled: !m.comingSoon),
                    ],
                  );
                  if (v != null && v != s.material && context.mounted) _apply(context, s.copyWith(material: v));
                },
              ),
              SettingRow(
                icon: Icons.palette_outlined,
                label: 'Rang',
                value: colorDisplay(s),
                swatch: s.colorArgb != null ? Color(s.colorArgb!) : Colors.white,
                onTap: () async {
                  final current = frameColorOptions.where((c) => c.argb == s.colorArgb).firstOrNull;
                  final pick = await pickOption<FrameColorOption>(
                    context,
                    title: 'Profil rangi',
                    selected: current,
                    options: [
                      for (final c in frameColorOptions)
                        Option(c, c.name, swatch: c.argb != null ? Color(c.argb!) : Colors.white),
                    ],
                  );
                  if (pick == null || !context.mounted) return;
                  _apply(
                    context,
                    pick.argb == null
                        ? s.copyWith(clearColor: true)
                        : s.copyWith(colorName: pick.name, colorArgb: pick.argb),
                  );
                },
              ),
              SettingRow(
                icon: Icons.filter_none_rounded,
                label: 'Soni',
                value: '${s.qty} dona',
                onTap: () async {
                  final v = await askNumber(context, title: 'Nechta dona', initial: s.qty.toDouble(), min: 1, max: 999);
                  if (v != null && context.mounted) _apply(context, s.copyWith(qty: v.round()));
                },
              ),
              SettingRow(
                icon: Icons.architecture_rounded,
                label: 'Arka balandligi',
                value: controller.design.archRiseMm > 0 ? '${controller.design.archRiseMm.round()} mm' : 'Yo\'q',
                onTap: () async {
                  final v = await askArchRise(context, controller.design);
                  if (v != null) controller.setArch(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
