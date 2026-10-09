import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';

class QuickAction {
  const QuickAction({
    required this.title,
    required this.hint,
    required this.onTap,
    this.icon,
    this.asset,
    this.color,
    this.badgeCount = 0,
  }) : assert(icon != null || asset != null, 'ikonka yoki rasm kerak');

  final String title;
  final String hint;
  final VoidCallback onTap;

  final IconData? icon;

  final String? asset;

  final Color? color;

  final int badgeCount;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: ChizmaSpace.md));
      if (i + 1 < actions.length) {
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _QuickActionCard(action: actions[i])),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(child: _QuickActionCard(action: actions[i + 1])),
            ],
          ),
        ));
      } else {
        rows.add(_QuickActionCard(action: actions[i], wide: true));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, this.wide = false});

  final QuickAction action;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final c = action.color ?? colors.categorizedColor.primary;

    final title = Text(
      action.title,
      style: context.text.h4.copyWith(color: colors.neutral.textStrong),
      maxLines: wide ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
    final hint = Text(
      action.hint,
      style: context.text.body5.copyWith(color: colors.neutral.textMuted),
      maxLines: wide ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
    final meta = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (action.badgeCount > 0) ...[
          _CountPill(count: action.badgeCount, color: c),
          const SizedBox(width: ChizmaSpace.sm),
        ],
        _GoButton(color: c),
      ],
    );

    if (wide) {
      return ChizmaSheet(
        onTap: action.onTap,
        padding: const EdgeInsets.all(ChizmaSpace.md),
        child: Row(
          children: [
            _Visual(action: action, color: c),
            const SizedBox(width: ChizmaSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [title, const SizedBox(height: 2), hint],
              ),
            ),
            const SizedBox(width: ChizmaSpace.sm),
            meta,
          ],
        ),
      );
    }

    return ChizmaSheet(
      onTap: action.onTap,
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Visual(action: action, color: c),
              const Spacer(),
              meta,
            ],
          ),
          const SizedBox(height: ChizmaSpace.md),
          title,
          const SizedBox(height: 2),
          hint,
        ],
      ),
    );
  }
}

class _Visual extends StatelessWidget {
  const _Visual({required this.action, required this.color});

  static const double size = 52;

  final QuickAction action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final asset = action.asset;
    if (asset != null) {
      return ChizmaImageTile(asset: asset, size: size, padding: 5);
    }
    return ChizmaIconTile(icon: action.icon!, color: color, size: size);
  }
}

class _GoButton extends StatelessWidget {
  const _GoButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.arrow_forward_rounded, size: 16, color: color),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: ChizmaSpace.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ChizmaRadius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: context.text.label.copyWith(
          color: context.color.neutral.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
