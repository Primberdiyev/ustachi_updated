import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

class WaitingForMasters extends StatefulWidget {
  const WaitingForMasters({super.key, required this.order});

  final OrderEntity order;

  @override
  State<WaitingForMasters> createState() => _WaitingForMastersState();
}

class _WaitingForMastersState extends State<WaitingForMasters>
    with SingleTickerProviderStateMixin {

  static const Duration _searchWindow = Duration(minutes: 1);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _syncPulse();

    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _syncPulse();

      if (!_searching && DateTime.now().second != 0) return;
      setState(() {});
    });
  }

  void _syncPulse() {
    final searching = _searching;
    if (searching && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!searching && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  String _left() {
    final left = widget.order.timeLeft(DateTime.now());
    if (left == Duration.zero) return 'muddati tugadi';
    if (left.inMinutes >= 60) {
      final hours = (left.inMinutes / 60).ceil();
      return '$hours soat';
    }
    return '${left.inMinutes < 1 ? 1 : left.inMinutes} daqiqa';
  }

  Duration get _sinceCreated {
    final created = widget.order.createdAt;
    if (created == null) return const Duration(days: 1);
    return DateTime.now().difference(created);
  }

  bool get _searching =>
      widget.order.responsesCount == 0 &&
      widget.order.timeLeft(DateTime.now()) > Duration.zero &&
      _sinceCreated < _searchWindow;

  int get _searchLeft {
    final left = _searchWindow - _sinceCreated;
    return left.isNegative ? 0 : left.inSeconds;
  }

  bool get _direct => widget.order.isDirect;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final expired = widget.order.timeLeft(DateTime.now()) == Duration.zero;
    final searching = _searching;

    final delivered = !searching && !expired;
    if (_direct) return _directView(context, expired: expired);

    return ChizmaSheet(
      padding: const EdgeInsets.symmetric(
        horizontal: ChizmaSpace.lg,
        vertical: ChizmaSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          SizedBox(
            height: 108,
            width: 108,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => CustomPaint(
                painter: _RadarPainter(
                  progress: _pulse.value,
                  color: colors.categorizedColor.primary,
                  active: searching,
                ),
                child: child,
              ),
              child: Center(
                child: Icon(
                  expired
                      ? Icons.timer_off_outlined

                      : (delivered
                          ? Icons.mark_email_read_outlined
                          : Icons.handyman_outlined),
                  size: 30,
                  color: colors.categorizedColor.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          Text(
            expired
                ? 'E\'lon muddati tugadi'
                : (searching
                    ? 'Ustalar qidirilmoqda…'
                    : 'E\'lon ustalarga yetkazildi'),
            style: context.text.h3.copyWith(color: colors.neutral.textStrong),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ChizmaSpace.xs),
          Text(
            expired
                ? 'Afsuski javob kelmadi. Buyurtmani qayta e\'lon qilishingiz mumkin.'
                : (searching

                    ? 'Hududingizdagi ustalarga bildirishnoma yuborilmoqda. '
                        'Birinchi javoblar odatda shu daqiqada keladi.'

                    : 'Buyurtmangiz hududingizdagi ustalarga yetib bordi va '
                        'e\'lon ochiq turibdi. Ustalar ish hajmi bilan tanishib '
                        'chiqib, o\'zlari aloqaga chiqadi — javob kelishi bilan '
                        'sizga bildirishnoma keladi.'),
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            textAlign: TextAlign.center,
          ),

          if (!expired) ...[
            const SizedBox(height: ChizmaSpace.md),
            ChizmaBadge(
              searching ? '$_searchLeft soniya' : 'E\'lon ochiq · yana ${_left()}',
              icon: searching ? Icons.radar_rounded : Icons.schedule_rounded,
            ),
          ],

          const SizedBox(height: ChizmaSpace.xl),
          Divider(height: 1, thickness: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.lg),

          _Step(
            icon: Icons.campaign_outlined,
            title: 'E\'lon qilindi',
            subtitle: searching
                ? 'Hududdagi ustalarga yuborilmoqda'
                : 'Hududdagi ustalarga yetkazildi',
            state: _StepState.done,
          ),
          _Step(
            icon: Icons.how_to_reg_outlined,
            title: 'Ustalar javobi',
            subtitle: searching
                ? 'Bildirishnoma tarqatilmoqda'
                : 'Ustalar buyurtmani ko\'rib chiqmoqda — rozi bo\'lgani '
                    'shu yerda chiqadi',
            state: expired ? _StepState.idle : _StepState.active,
          ),
          const _Step(
            icon: Icons.verified_outlined,
            title: 'Tanlash',
            subtitle: 'Profilini ko\'rib, chatda kelishasiz',
            state: _StepState.idle,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

extension _DirectView on _WaitingForMastersState {
  Widget _directView(BuildContext context, {required bool expired}) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final names = widget.order.pendingInvites
        .map((i) => i.master.displayName)
        .where((n) => n.isNotEmpty)
        .toList();

    return ChizmaSheet(
      padding: const EdgeInsets.symmetric(
        horizontal: ChizmaSpace.lg,
        vertical: ChizmaSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            ),
            child: Icon(
              expired ? Icons.timer_off_outlined : Icons.mark_email_read_outlined,
              size: 30,
              color: primary,
            ),
          ),
          const SizedBox(height: ChizmaSpace.md),
          Text(
            expired ? 'Muddat tugadi' : 'Usta javobini kutmoqdamiz',
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ChizmaSpace.xs),
          Text(
            expired
                ? 'Javob kelmadi. Boshqa usta tanlashingiz yoki e\'lonni '
                    'hammaga ochishingiz mumkin.'
                : (names.isEmpty
                    ? 'Buyurtma tanlagan ustangizga yuborildi. Javob kelishi '
                        'bilan sizga bildirishnoma keladi.'
                    : 'Buyurtma ${names.first}ga yuborildi'
                        '${names.length > 1 ? ' va yana ${names.length - 1} ta ustaga' : ''}. '
                        'Javob kelishi bilan bildirishnoma keladi.'),
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, idle }

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final cat = colors.categorizedColor;
    final tint = switch (state) {
      _StepState.done => cat.success,
      _StepState.active => cat.primary,
      _StepState.idle => colors.neutral.textMuted,
    };
    final strong = state != _StepState.idle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 32,
                width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: strong ? 0.12 : 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: state == _StepState.active
                        ? tint
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  state == _StepState.done ? Icons.check_rounded : icon,
                  size: 16,
                  color: tint,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: colors.neutral.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : ChizmaSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.text.body4.copyWith(
                      color: strong
                          ? colors.neutral.textStrong
                          : colors.neutral.textMuted,
                      fontWeight:
                          state == _StepState.active ? FontWeight.w700 : null,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: context.text.body5
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.progress,
    required this.color,
    required this.active,
  });

  final double progress;
  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      maxR * 0.34,
      Paint()..color = color.withValues(alpha: 0.12),
    );
    if (!active) return;

    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final radius = maxR * (0.34 + 0.66 * t);
      final fade = (1.0 - t).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color.withValues(alpha: 0.35 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.active != active || old.color != color;
}
