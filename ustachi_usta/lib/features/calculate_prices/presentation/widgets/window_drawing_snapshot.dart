import 'package:flutter/widgets.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/detail_schematic_preview.dart';

@immutable
class WindowDrawingSnapshot {
  const WindowDrawingSnapshot({
    required this.widthMm,
    required this.heightMm,
    required this.spec,
    required this.preview,
  });

  final int widthMm;
  final int heightMm;

  final FramePreviewSpec spec;

  final Widget Function(BuildContext context)? preview;

  Widget render(BuildContext context) =>
      preview?.call(context) ?? DetailSchematicPreview(spec: spec);

  String get sizeLabel => '$widthMm × $heightMm mm';
}
