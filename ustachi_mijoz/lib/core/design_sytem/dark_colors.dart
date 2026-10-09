import 'package:ustachi/core/design_sytem/base_colors.dart';
import 'package:flutter/material.dart';

class DarkUncategorizedColor extends UncategorizedColor {
  @override
  Color get green1 => const Color(0xFF35B074);

  @override
  Color get green2 => const Color(0xFF14392A);

  @override
  Color get green3 => const Color(0xFF102C21);

  @override
  Color get green4 => const Color(0xFF35B074);

  @override
  Color get yellow1 => const Color(0xFFE0A44A);

  @override
  Color get yellow2 => const Color(0xFF33240F);

  @override
  Color get red => const Color(0xFFE8654E);
}

class DarkNeutralColor extends NeutralColor {

  @override
  Color get bg => const Color(0xFF0C1826);

  @override
  Color get surface => const Color(0xFF122234);

  @override
  Color get surface2 => const Color(0xFF0A1520);

  @override
  Color get border => const Color(0xFF26384E);

  @override
  Color get borderStrong => const Color(0xFF35495F);

  @override
  Color get textStrong => const Color(0xFFE9EFF7);

  @override
  Color get textBody => const Color(0xFFABBCD0);

  @override
  Color get textMuted => const Color(0xFF7E92A8);

  @override
  Color get black1 => textStrong;

  @override
  Color get black2 => textBody;

  @override
  Color get black3 => textMuted;

  @override
  Color get black4 => borderStrong;

  @override
  Color get black5 => borderStrong;

  @override
  Color get black6 => border;

  @override
  Color get black7 => surface2;

  @override
  Color get black8 => bg;

  @override
  Color get white => const Color(0xFFFFFFFF);

  @override
  Color get grey => textMuted;

  @override
  Color get blue1 => const Color(0xFF4E9BDC);

  @override
  Color get blue2 => const Color(0xFF7FB8E8);

  @override
  Color get blue3 => const Color(0xFFD4A657);

  @override
  Color get blue4 => const Color(0xFFE0B771);

  @override
  Color get yellow => const Color(0xFFD4A657);
}
