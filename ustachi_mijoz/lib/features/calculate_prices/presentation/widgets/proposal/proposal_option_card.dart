import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';

String formatSom(double v) {
  final n = v.round();
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

String proposalDrawingHeroTag(ProposalOption o) =>
    'frame-${o.title}-${o.spec.widthMm}x${o.spec.heightMm}-${identityHashCode(o.spec)}';

class ProposalOptionCard extends StatelessWidget {
  const ProposalOptionCard({
    super.key,
    required this.option,
    this.frameColor,
    this.onDetails,
    this.onTap,
    this.titleOverride,
    this.showSill = false,
  });

  final ProposalOption option;

  final bool showSill;

  final Color? frameColor;

  final VoidCallback? onDetails;

  final VoidCallback? onTap;

  final String? titleOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final subtitle = titleOverride != null
        ? [option.title, option.subtitle].where((t) => t.isNotEmpty).join(' · ')
        : option.subtitle;
    final w = (option.spec.widthMm ?? 1500).toDouble();
    final h = (option.spec.heightMm ?? 1500).toDouble();
    final openings = frameWingCount(frameDrawingPlacements(option.spec, w, h));

    return Material(
      color: colors.neutral.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.neutral.border.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [

              DrawingStage(
                height: 236,
                topLeft: [
                  if (option.isPopular) const _StageTag('Ommabop', icon: Icons.star_rounded),
                ],
                child: Hero(
                  tag: proposalDrawingHeroTag(option),
                  child: FrameDrawing(
                    spec: option.spec,
                    frameTint: frameColor,
                    showDimensions: true,
                    showSill: showSill,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.md, ChizmaSpace.lg, ChizmaSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleOverride ?? option.title,
                      style: context.text.h4.copyWith(color: colors.neutral.textStrong),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.text.body5.copyWith(color: colors.neutral.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: ChizmaSpace.md),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: ChizmaSpace.xs + 2,
                            runSpacing: ChizmaSpace.xs + 2,
                            children: [
                              _Fact(
                                Icons.straighten_rounded,
                                '${option.spec.widthMm ?? w.round()}×${option.spec.heightMm ?? h.round()} mm',
                              ),
                              _Fact(
                                Icons.open_in_full_rounded,
                                openings > 0 ? '$openings ta ochiladi' : 'Qo\'zg\'almas',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: ChizmaSpace.sm),
                        FilledButton.tonalIcon(
                          onPressed: onDetails,
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.lg, vertical: ChizmaSpace.sm),
                            minimumSize: Size.zero,
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Tanlash'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _StageTag extends StatelessWidget {
  const _StageTag(this.text, {required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final fg = colors.categorizedColor.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 3),
          Text(text, style: context.text.label.copyWith(color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: colors.neutral.surface2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.neutral.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.label.copyWith(color: colors.neutral.textBody, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
