
library;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/presentation/widgets/frame_canvas.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class ImpostTray extends StatelessWidget {
  const ImpostTray({
    super.key,
    required this.onClose,
    this.showChiftQuloq = false,
    this.kind = ImpostKind.plain,
    this.onKind,
    this.onEqualize,
  });

  final VoidCallback onClose;

  final VoidCallback? onEqualize;

  final ImpostKind kind;
  final ValueChanged<ImpostKind>? onKind;

  final bool showChiftQuloq;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      margin: const EdgeInsets.fromLTRB(ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.sm),
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.md, vertical: ChizmaSpace.sm),
      decoration: BoxDecoration(
        color: colors.categorizedColor.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: colors.categorizedColor.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              const Flexible(child: ImpostStick(tool: ImpostTool(hisob.Axis.vertical))),
              const SizedBox(width: ChizmaSpace.sm),
              const Flexible(child: ImpostStick(tool: ImpostTool(hisob.Axis.horizontal))),
              const SizedBox(width: ChizmaSpace.sm),

              const Flexible(child: ImpostStick(tool: ImpostTool(hisob.Axis.vertical, pair: true))),

              if (showChiftQuloq) ...[
                const SizedBox(width: ChizmaSpace.sm),
                const Flexible(
                  child: ImpostStick(tool: ImpostTool(hisob.Axis.vertical, pair: true, chiftQuloq: true)),
                ),
              ],
              const SizedBox(width: ChizmaSpace.sm),
              IconButton(
                tooltip: 'Yopish',
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tayoqchani bosib turib, oynaning kerakli joyiga suring. Juft va Chift quloq — eshik o\'rni, orasi 140 sm',
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.xs,
            children: [
              ChizmaChip(
                label: 'Oddiy impost',
                selected: kind == ImpostKind.plain,
                onTap: () => onKind?.call(ImpostKind.plain),
              ),
              ChizmaChip(
                label: 'Balkon o\'rta',
                selected: kind == ImpostKind.balcony,
                onTap: () => onKind?.call(ImpostKind.balcony),
              ),

              if (onEqualize != null)
                OutlinedButton.icon(
                  onPressed: onEqualize,
                  icon: const Icon(Icons.view_column_outlined, size: 18),
                  label: Text('Teng bo\'lish'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImpostStick extends StatelessWidget {
  const ImpostStick({super.key, required this.tool});

  final ImpostTool tool;

  hisob.Axis get axis => tool.axis;

  bool get chiftQuloq => tool.chiftQuloq;

  static const double _long = 44;
  static const double _thick = 7;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final vertical = axis == hisob.Axis.vertical;
    final color = colors.categorizedColor.primary;
    Widget one(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        );

    Widget single(double scale) {
      final w = (vertical ? _thick : _long) * scale;
      final h = (vertical ? _long : _thick) * scale;
      if (!chiftQuloq) return one(w, h);
      final gap = 3.0 * scale;
      return vertical
          ? Row(mainAxisSize: MainAxisSize.min, children: [one(w * 0.7, h), SizedBox(width: gap), one(w * 0.7, h)])
          : Column(mainAxisSize: MainAxisSize.min, children: [one(w, h * 0.7), SizedBox(height: gap), one(w, h * 0.7)]);
    }

    const pairGap = 18.0;
    Widget bar(double scale) => tool.pair
        ? Row(mainAxisSize: MainAxisSize.min, children: [single(scale), SizedBox(width: pairGap * scale), single(scale)])
        : single(scale);

    final feedbackW = (tool.pair ? _thick * 2 + pairGap : (vertical ? _thick : _long)) * 1.3;
    final feedbackH = (vertical ? _long : _thick) * 1.3;

    return Draggable<ImpostTool>(
      data: tool,
      dragAnchorStrategy: pointerDragAnchorStrategy,

      feedback: Transform.translate(
        offset: Offset(-feedbackW / 2, -impostDragLift - feedbackH / 2),
        child: Material(type: MaterialType.transparency, child: bar(1.3)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: _tile(context, bar(1), vertical)),
      child: _tile(context, bar(1), vertical),
    );
  }

  Widget _tile(BuildContext context, Widget bar, bool vertical) {
    final colors = context.color;
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        borderRadius: BorderRadius.circular(ChizmaRadius.md),
        border: Border.all(color: colors.neutral.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _long, child: Center(child: bar)),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tool.chiftQuloq ? 'Chift quloq' : (tool.pair ? 'Juft' : (vertical ? 'Tik' : 'Yotiq')),
                style: context.text.label.copyWith(color: colors.neutral.textBody),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
