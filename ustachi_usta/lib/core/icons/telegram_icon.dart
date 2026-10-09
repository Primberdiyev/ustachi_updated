import 'package:flutter/material.dart';

class TelegramIcon extends StatelessWidget {
  const TelegramIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _TelegramIconPainter()),
    );
  }
}

class _TelegramIconPainter extends CustomPainter {
  const _TelegramIconPainter();

  static const _telegramBlue = Color(0xFF29A9EA);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, r, Paint()..color = _telegramBlue);

    Offset p(double x, double y) => Offset(x * size.width, y * size.height);
    final plane = Path()
      ..moveTo(p(0.82, 0.28).dx, p(0.82, 0.28).dy)
      ..lineTo(p(0.24, 0.53).dx, p(0.24, 0.53).dy)
      ..lineTo(p(0.40, 0.60).dx, p(0.40, 0.60).dy)
      ..lineTo(p(0.68, 0.42).dx, p(0.68, 0.42).dy)
      ..lineTo(p(0.46, 0.64).dx, p(0.46, 0.64).dy)
      ..lineTo(p(0.45, 0.76).dx, p(0.45, 0.76).dy)
      ..lineTo(p(0.55, 0.66).dx, p(0.55, 0.66).dy)
      ..lineTo(p(0.72, 0.74).dx, p(0.72, 0.74).dy)
      ..close();
    canvas.drawPath(plane, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TelegramIconPainter oldDelegate) => false;
}
