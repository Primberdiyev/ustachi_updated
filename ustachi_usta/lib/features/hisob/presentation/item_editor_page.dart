
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/presentation/item_editor_controller.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi/features/hisob/presentation/widgets/hisob_ui.dart';
import 'package:ustachi/features/hisob/presentation/widgets/impost_tray.dart';
import 'package:ustachi/features/hisob/presentation/widgets/item_inspector.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class ItemEditorPage extends StatefulWidget {
  const ItemEditorPage({
    super.key,
    required this.item,
    this.isNew = false,
    this.onSaveTemplate,
  });

  final void Function(HisobKind kind, hisob.FrameDesign design)? onSaveTemplate;

  final HisobItem item;

  final bool isNew;

  static Future<HisobItem?> open(
    BuildContext context, {
    required HisobItem item,
    bool isNew = false,
    void Function(HisobKind kind, hisob.FrameDesign design)? onSaveTemplate,
  }) {
    return Navigator.of(context).push<HisobItem>(
      MaterialPageRoute(
        builder: (_) => ItemEditorPage(
          item: item,
          isNew: isNew,
          onSaveTemplate: onSaveTemplate,
        ),
      ),
    );
  }

  @override
  State<ItemEditorPage> createState() => _ItemEditorPageState();
}

class _ItemEditorPageState extends State<ItemEditorPage> {
  late final ItemEditorController _c;
  late final String _initialJson;

  bool _tray = false;

  ImpostKind _kind = ImpostKind.plain;

  @override
  void initState() {
    super.initState();
    _c = ItemEditorController(widget.item);
    _initialJson = _fingerprint(_c.item);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static String _fingerprint(HisobItem item) => item.toJson().toString();

  bool get _dirty => widget.isNew || _fingerprint(_c.item) != _initialJson;

  Future<void> _editSize(bool width) async {
    final d = _c.design;
    final v = await askNumber(
      context,
      title: width ? 'Rom eni' : 'Rom bo\'yi',
      initial: width ? d.widthMm : d.heightMm,
      suffix: 'mm',
      min: 200,
      max: 9000,
    );
    if (v == null) return;
    _c.resizeFrame(width ? v : d.widthMm, width ? d.heightMm : v);
  }

  Future<void> _editArch() async {
    final v = await askArchRise(context, _c.design);
    if (v != null) _c.setArch(v);
  }

  Future<void> _editArchStart() async {
    final d = _c.design;
    final v = await askNumber(
      context,
      title: 'Arka qayerdan boshlanadi (pastdan)',
      initial: d.heightMm - d.archRiseMm,
      suffix: 'mm',
      min: 100,
      max: d.heightMm - 50,
    );
    if (v != null) _c.setArch(d.heightMm - v);
  }

  Future<void> _editSegment(hisob.Axis axis, int index, ChainSide? side) async {
    final marks = lineMarks(_c.design, axis, side: side);
    if (index + 1 >= marks.length) return;
    final horizontal = axis == hisob.Axis.horizontal;
    final v = await askNumber(
      context,
      title: horizontal ? 'Bo\'lak bo\'yi' : 'Bo\'lak eni',
      initial: marks[index + 1] - marks[index],
      suffix: 'mm',
      min: minSegmentMm,
      max: marks.last - minSegmentMm,
    );
    if (v == null) return;
    _c.setSegment(axis, index, v, side: side);
  }

  String? _designError() =>
      hisob.designError(_c.design, _c.spec, balconyDoor: _c.settings.balconyDoor);

  Future<void> _confirmLeave() async {
    if (!_dirty) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Saqlanmagan o\'zgarishlar'),
        content: Text('Chiqsangiz, shu buyumdagi o\'zgarishlar yo\'qoladi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Qolish')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Chiqish')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final designError = _designError();
          final blocked = designError != null;
          return Scaffold(
            backgroundColor: colors.neutral.bg,
            appBar: AppBar(
              title: Text('${_c.item.kind.label} · ${_c.item.sizeLabel}'),
              actions: [
                if (widget.onSaveTemplate != null)

                  _SaveTemplateButton(

                    onPressed: blocked
                        ? null
                        : () {
                            widget.onSaveTemplate!(_c.item.kind, _c.design);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text('Shablonlaringizga saqlandi')));
                          },
                  ),
                IconButton(
                  tooltip: 'Bekor qilish',
                  onPressed: _c.canUndo ? _c.undo : null,
                  icon: const Icon(Icons.undo_rounded),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(

                  flex: _tray ? 16 : 9,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.sm, ChizmaSpace.lg, ChizmaSpace.sm),
                    decoration: BoxDecoration(
                      color: colors.neutral.surface,
                      borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                      border: Border.all(color: colors.neutral.border),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FrameCanvas(
                            design: _c.design,
                            spec: _c.spec,
                            frameColor: frameColorOf(_c.settings.colorArgb),
                            balconyDoor: _c.settings.balconyDoor,
                            selected: _c.selected,
                            onTapCell: _c.select,
                            onTapWidth: () => _editSize(true),
                            onTapHeight: () => _editSize(false),
                            onTapSegment: _editSegment,
                            onTapArch: (startPoint) => startPoint ? _editArchStart() : _editArch(),
                            onDropImpost: (tool, x, y) => _c.dropImpost(tool, x, y, kind: _kind),
                          ),
                        ),

                        Positioned(
                          left: ChizmaSpace.sm,
                          top: ChizmaSpace.sm,
                          child: _SplitToggle(
                            active: _tray,
                            onTap: () => setState(() => _tray = !_tray),
                          ),
                        ),

                        Positioned(
                          right: ChizmaSpace.sm,
                          top: ChizmaSpace.sm,
                          child: _SplitToggle(
                            active: _c.design.archRiseMm > 0,
                            icon: Icons.architecture_rounded,
                            label: 'Arka',
                            onTap: _editArch,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tray)
                  ImpostTray(
                    onClose: () => setState(() => _tray = false),
                    showChiftQuloq: chiftQuloqAvailable(_c.settings.material),
                    kind: _kind,
                    onKind: (v) => setState(() => _kind = v),
                    onEqualize: _c.equalize,
                  ),
                if (_c.message != null) _MessageStrip(text: _c.message!, onClose: _c.clearMessage),

                Expanded(
                  flex: 8,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.neutral.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(ChizmaRadius.lg)),
                      border: Border(top: BorderSide(color: colors.neutral.border)),
                    ),
                    child: SingleChildScrollView(
                      child: ItemInspector(controller: _c),
                    ),
                  ),
                ),
                _SaveBar(
                  error: designError,
                  onSave: blocked ? null : () => Navigator.of(context).pop(_c.item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SaveTemplateButton extends StatelessWidget {
  const _SaveTemplateButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final color = onPressed == null ? colors.neutral.textMuted : colors.categorizedColor.primary;
    return Tooltip(
      message: 'Shablondek saqlash',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_add_outlined, color: color),
              const SizedBox(width: 4),
              Text(
                'Shablondek\nsaqlash',
                style: context.text.label.copyWith(color: color, height: 1.1, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitToggle extends StatelessWidget {
  const _SplitToggle({
    required this.active,
    required this.onTap,
    this.icon = Icons.border_inner_rounded,
    this.label = 'Bo\'lish',
  });

  final bool active;
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return Material(
      color: active ? primary : colors.neutral.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        side: BorderSide(color: active ? primary : colors.neutral.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.text.body5.copyWith(
                  color: active ? Colors.white : primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageStrip extends StatelessWidget {
  const _MessageStrip({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg),
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.md, vertical: ChizmaSpace.sm),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Colors.redAccent),
          const SizedBox(width: ChizmaSpace.sm),
          Expanded(child: Text(text, style: context.text.body5.copyWith(color: Colors.redAccent))),
          InkWell(onTap: onClose, child: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent)),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({this.error, required this.onSave});

  final String? error;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Material(
      color: colors.neutral.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          child: Row(
            children: [
              Expanded(
                child: error == null
                    ? const SizedBox.shrink()
                    : Text(
                        error!,
                        style: context.text.body5.copyWith(color: Colors.redAccent),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              FilledButton(onPressed: onSave, child: Text('Saqlash')),
            ],
          ),
        ),
      ),
    );
  }
}
