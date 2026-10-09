import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class ListLoadingPlaceholder extends StatefulWidget {
  const ListLoadingPlaceholder({super.key, this.showAvatar = false});
  final bool showAvatar;

  @override
  State<ListLoadingPlaceholder> createState() => _ListLoadingPlaceholderState();
}

class _ListLoadingPlaceholderState extends State<ListLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _opacity = Tween<double>(begin: 0.4, end: 0.9).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    Widget bar(double width, {double height = 12}) => FractionallySizedBox(
          widthFactor: width,
          alignment: Alignment.centerLeft,
          child: Container(
              height: height,
              decoration: BoxDecoration(
                color: colors.neutral.border,
                borderRadius: BorderRadius.circular(6),
              )),
        );
    return Semantics(
      label: context.t.common.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: Column(children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.only(bottom: ChizmaSpace.md),
                padding: const EdgeInsets.all(ChizmaSpace.lg),
                decoration: BoxDecoration(
                  color: colors.neutral.surface,
                  borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                  border: Border.all(color: colors.neutral.border),
                ),
                child: FadeTransition(
                    opacity: _opacity,
                    child: Row(children: [
                      if (widget.showAvatar) ...[
                        Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.neutral.border,
                              borderRadius: BorderRadius.circular(14),
                            )),
                        const SizedBox(width: ChizmaSpace.md),
                      ],
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            bar(0.68, height: 16),
                            const SizedBox(height: 14),
                            bar(0.9),
                            const SizedBox(height: 10),
                            bar(0.48),
                            const SizedBox(height: 20),
                            bar(0.58, height: 22),
                          ])),
                    ])),
              ),
          ]),
        ),
      ),
    );
  }
}
