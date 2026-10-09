import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart';

typedef FrameDimensionEditor = Future<FramePreviewSpec?> Function(FrameDimensionTarget target);

class FrameDrawingViewer extends StatefulWidget {
  const FrameDrawingViewer({
    super.key,
    required this.spec,
    required this.title,
    this.heroTag,
    this.frameTint,
    this.showSill = false,
    this.onEditDimension,
  });

  final FramePreviewSpec spec;
  final String title;
  final Object? heroTag;
  final Color? frameTint;
  final bool showSill;
  final FrameDimensionEditor? onEditDimension;

  static Future<void> open(
    BuildContext context, {
    required FramePreviewSpec spec,
    required String title,
    Object? heroTag,
    Color? frameTint,
    bool showSill = false,
    FrameDimensionEditor? onEditDimension,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => FrameDrawingViewer(
            spec: spec,
            title: title,
            heroTag: heroTag,
            frameTint: frameTint,
            showSill: showSill,
            onEditDimension: onEditDimension,
          ),
        ),
      );

  @override
  State<FrameDrawingViewer> createState() => _FrameDrawingViewerState();
}

class _FrameDrawingViewerState extends State<FrameDrawingViewer> {
  late FramePreviewSpec _spec = widget.spec;
  final _zoom = TransformationController();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  Future<void> _edit(FrameDimensionTarget target) async {
    final next = await widget.onEditDimension?.call(target);
    if (next == null || !mounted) return;
    setState(() {

      if (next.widthMm != _spec.widthMm || next.heightMm != _spec.heightMm) _zoom.value = Matrix4.identity();
      _spec = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final editable = widget.onEditDimension != null;
    final drawing = FrameDrawing(
      spec: _spec,
      frameTint: widget.frameTint,
      showDimensions: true,
      showSill: widget.showSill,
      onDimensionTap: editable ? _edit : null,
    );
    return Scaffold(
      backgroundColor: colors.neutral.surface,
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DrawingStage(
                height: double.infinity,
                child: InteractiveViewer(
                  transformationController: _zoom,
                  minScale: 1,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: widget.heroTag == null ? drawing : Hero(tag: widget.heroTag!, child: drawing),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ChizmaSpace.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pinch_outlined, size: 18, color: colors.neutral.textMuted),
                  const SizedBox(width: ChizmaSpace.xs),
                  Flexible(
                    child: Text(
                      editable
                          ? 'Ikki barmoq bilan kattalashtiring · ko\'k o\'lchamni bosib o\'zgartiring'
                          : 'Ikki barmoq bilan kattalashtiring · o\'lchamlar mm da',
                      textAlign: TextAlign.center,
                      style: context.text.label.copyWith(color: colors.neutral.textMuted),
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
