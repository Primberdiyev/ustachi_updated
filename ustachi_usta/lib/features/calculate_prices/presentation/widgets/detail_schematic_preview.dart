import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/arch_overlay_painter.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/default_window_frame_painter.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/schematic_hardware_images.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_schematic_painter.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

const _defaultGlassColor = Color(0xFF83D5ED);

class DetailSchematicPreview extends StatelessWidget {
  const DetailSchematicPreview({
    super.key,
    required this.spec,
    this.frameTint,
    this.glassTint,
  });

  final FramePreviewSpec spec;

  final Color? frameTint;

  final Color? glassTint;

  @override
  Widget build(BuildContext context) {
    final wMm = (spec.widthMm ?? (1500 * spec.aspectRatio).round()).toDouble();
    final hMm = (spec.heightMm ?? 1500).toDouble();

    final frameColor = frameTint ?? context.color.neutral.white;
    final edgeColor =
        frameTint != null ? const Color(0xFF3A3A3A) : Colors.black;
    final glassColor = glassTint == null
        ? _defaultGlassColor
        : glassTint!.withValues(alpha: 0.7);
    final accentLineColor = context.color.neutral.blue1;

    final zone = WindowZone.fromFramePreviewSpecWithDefaults(spec);
    final panes = schematicPanesOf(zone);
    final layoutPatternRects = zone.layoutPatternRects();

    final isArch = spec.archHeightFactor > 0;

    final stretch =
        !isArch && wMm / hMm > 1.5 ? (wMm / hMm / 1.5).clamp(1.0, 1.6) : 1.0;

    return AspectRatio(
      aspectRatio: (wMm / (hMm * stretch)).clamp(0.05, 20.0),
      child: SchematicHardwareImagesLoader(
        builder: (context, images) {
          final Widget baseLayer;
          if (!isArch) {
            baseLayer = CustomPaint(
              painter: WindowSchematicPainter(
                widthMm: wMm,
                heightMm: hMm,
                heightStretch: stretch,
                minFramePx: 6.0,
                hingeImage: images.hinge,
                handleImage: images.handle,
                handleRightImage: images.handleRight,
                windowHandleImage: images.windowHandle,
                panes: panes,
                regions: spec.regions,
                profileColor: frameColor,
                glassColor: glassColor,
                outlineColor: edgeColor.withValues(alpha: 0.75),
                openingLineColor: accentLineColor,
              ),
              child: const SizedBox.expand(),
            );
          } else {
            final openingPanes = [
              for (final p in panes)
                if (p.openingCategory > 0) p,
            ];
            baseLayer = CustomPaint(
              painter: DefaultWindowFramePainter(
                dividerLines: spec.lines,
                regions: spec.regions,
                frameColor: frameColor,
                innerFrameColor: frameColor,
                glassColor: glassColor,
                dividerColor: frameColor,
                edgeColor: edgeColor,
                showFrame: spec.showFrame,
                showGlass: spec.showGlass,
                layoutPatternRects: layoutPatternRects,
                layoutPatternColor: const Color(0xFF555555),
                frameBandScale: spec.frameBandScale,
              ),
              foregroundPainter: openingPanes.isEmpty
                  ? null
                  : WindowSchematicPainter(
                      widthMm: wMm,
                      heightMm: hMm,
                      minFramePx: 6.0,
                      transparent: true,
                      hingeImage: images.hinge,
                      handleImage: images.handle,
                      handleRightImage: images.handleRight,
                      windowHandleImage: images.windowHandle,
                      panes: openingPanes,
                      profileColor: frameColor,
                      glassColor: glassColor,
                      outlineColor: edgeColor.withValues(alpha: 0.75),
                      openingLineColor: accentLineColor,
                    ),
              child: const SizedBox.expand(),
            );
          }

          if (!isArch) return baseLayer;

          final arch = spec.archHeightFactor;
          final hasTransom = spec.lines.any((l) =>
              (l.startY - l.endY).abs() < 0.001 &&
              (l.startY - arch).abs() < 0.001);
          final archMullionXs = [
            for (final l in spec.lines)
              if ((l.startX - l.endX).abs() < 0.001 &&
                  (l.startY < l.endY ? l.startY : l.endY) < arch - 0.001)
                l.startX,
          ];

          return ClipPath(
            clipper: ArchClipper(arch),
            child: Stack(
              fit: StackFit.expand,
              children: [
                baseLayer,
                IgnorePointer(
                  child: CustomPaint(
                    painter: ArchOverlayPainter(
                      archHeightFactor: arch,
                      hasTransom: hasTransom,
                      mullionXs: archMullionXs,
                      isPlainArch: !hasTransom,
                      frameColor: frameColor,
                      glassColor: glassColor,
                      edgeColor: edgeColor,
                      showFrame: spec.showFrame,
                      showGlass: spec.showGlass,
                      frameBandScale: spec.frameBandScale,
                      capOpening: panes.any(
                          (p) => p.openingCategory > 0 && p.rect.top <= 0.001),
                      widthMm: wMm,
                      heightMm: hMm,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
