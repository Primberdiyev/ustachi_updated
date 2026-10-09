import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';

class DrawingStage extends StatelessWidget {
  const DrawingStage({
    super.key,
    required this.height,
    required this.child,
    this.topLeft = const [],
    this.topRight,
    this.borderRadius = BorderRadius.zero,
  });

  final double height;
  final Widget child;
  final List<Widget> topLeft;
  final Widget? topRight;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [Color(0xFF1D2733), Color(0xFF151D26)]
                      : const [Color(0xFFF6F9FC), Color(0xFFE6EEF6)],
                ),
              ),
            ),
            CustomPaint(painter: _DotGridPainter(dark: dark)),
            Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.xl, 36, ChizmaSpace.md, ChizmaSpace.sm),
              child: child,
            ),
            if (topLeft.isNotEmpty)
              Positioned(
                left: ChizmaSpace.md,
                top: ChizmaSpace.md,
                child: Row(
                  children: [
                    for (var i = 0; i < topLeft.length; i++) ...[
                      if (i > 0) const SizedBox(width: ChizmaSpace.xs),
                      topLeft[i],
                    ],
                  ],
                ),
              ),
            if (topRight != null) Positioned(right: ChizmaSpace.md, top: ChizmaSpace.md, child: topRight!),
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF9FB3C8).withValues(alpha: dark ? 0.12 : 0.28);
    const step = 16.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => oldDelegate.dark != dark;
}
