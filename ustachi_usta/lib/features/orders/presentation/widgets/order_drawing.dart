import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/drawing_stage.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';

class OrderDrawing extends StatelessWidget {
  const OrderDrawing({super.key, required this.spec, this.frameArgb});

  final FramePreviewSpec spec;
  final int? frameArgb;

  static const double stageHeight = 280;

  Color? get _tint => frameArgb == null ? null : Color(frameArgb!);

  String? get _sizeLabel => spec.widthMm != null && spec.heightMm != null
      ? '${spec.widthMm} × ${spec.heightMm} mm'
      : null;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _DrawingViewerPage(
          spec: spec,
          frameTint: _tint,
          title: _sizeLabel ?? context.t.orders.request.clientSpec,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final size = _sizeLabel;
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Stack(
        children: [
          DrawingStage(
            height: stageHeight,
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            topLeft: [if (size != null) _StageLabel(size)],
            child: FrameDrawing(
              spec: spec,
              frameTint: _tint,
              showDimensions: true,
            ),
          ),
          Positioned(
            right: ChizmaSpace.sm,
            bottom: ChizmaSpace.sm,
            child: _RoundIcon(
              icon: Icons.zoom_out_map_rounded,
              color: colors.neutral.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingViewerPage extends StatelessWidget {
  const _DrawingViewerPage({
    required this.spec,
    required this.title,
    this.frameTint,
  });

  final FramePreviewSpec spec;
  final String title;
  final Color? frameTint;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Scaffold(
      backgroundColor: colors.neutral.surface,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DrawingStage(
                height: double.infinity,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: FrameDrawing(
                    spec: spec,
                    frameTint: frameTint,
                    showDimensions: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ChizmaSpace.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pinch_outlined,
                      size: 18, color: colors.neutral.textMuted),
                  const SizedBox(width: ChizmaSpace.xs),
                  Flexible(
                    child: Text(
                      context.t.orders.detail.drawingsHint,
                      textAlign: TextAlign.center,
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: colors.neutral.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      ),
      child: Text(
        text,
        style: context.text.label.copyWith(
          color: colors.neutral.textStrong,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: context.color.neutral.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      );
}
