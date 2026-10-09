import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';

enum ChizmaBreakpoint {
  compact,

  regular,

  medium,

  expanded;

  bool get isCompact => this == ChizmaBreakpoint.compact;
  bool get isExpanded => this == ChizmaBreakpoint.expanded;

  bool get isWide =>
      this == ChizmaBreakpoint.medium || this == ChizmaBreakpoint.expanded;
}

extension ChizmaResponsiveX on BuildContext {
  ChizmaBreakpoint get breakpoint {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 360) return ChizmaBreakpoint.compact;
    if (width < 600) return ChizmaBreakpoint.regular;
    if (width < 900) return ChizmaBreakpoint.medium;
    return ChizmaBreakpoint.expanded;
  }

  double get pagePadding => switch (breakpoint) {
        ChizmaBreakpoint.compact => ChizmaSpace.md,
        ChizmaBreakpoint.regular => ChizmaSpace.lg,
        ChizmaBreakpoint.medium => ChizmaSpace.xl,
        ChizmaBreakpoint.expanded => ChizmaSpace.xxl,
      };

  int get galleryColumns => switch (breakpoint) {
        ChizmaBreakpoint.compact => 2,
        ChizmaBreakpoint.regular => 2,
        ChizmaBreakpoint.medium => 3,
        ChizmaBreakpoint.expanded => 4,
      };
}

class ChizmaPageBody extends StatelessWidget {
  const ChizmaPageBody({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final systemBottom = MediaQuery.paddingOf(context).bottom;
    final resolved = (padding ??
            EdgeInsets.fromLTRB(
              context.pagePadding,
              ChizmaSpace.md,
              context.pagePadding,
              ChizmaSpace.xxl,
            ))
        .add(EdgeInsets.only(bottom: systemBottom));

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: resolved, child: child),
      ),
    );

    if (!scrollable) return content;
    return SingleChildScrollView(child: content);
  }
}

class ChizmaMasterDetail extends StatelessWidget {
  const ChizmaMasterDetail({
    super.key,
    required this.list,
    required this.detail,
    this.listWidth = 320,
  });

  final Widget list;
  final Widget detail;
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    if (!context.breakpoint.isExpanded) return list;

    final border = context.dividerColorOrBorder;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: listWidth, child: list),
        VerticalDivider(width: 1, thickness: 1, color: border),
        Expanded(child: detail),
      ],
    );
  }
}

extension on BuildContext {
  Color get dividerColorOrBorder => Theme.of(this).dividerColor;
}
