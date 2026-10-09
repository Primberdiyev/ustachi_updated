import 'package:flutter/material.dart';

abstract class UncategorizedColor {
  Color get green1;

  Color get green2;

  Color get green3;

  Color get green4;

  Color get yellow1;

  Color get yellow2;

  Color get red;
}

abstract class NeutralColor {

  Color get bg;

  Color get surface;

  Color get surface2;

  Color get border;

  Color get borderStrong;

  Color get textStrong;

  Color get textBody;

  Color get textMuted;

  Color get black1;

  Color get black2;

  Color get black3;

  Color get black4;

  Color get black5;

  Color get black6;

  Color get black7;

  Color get black8;

  Color get white;

  Color get blue1;

  Color get blue2;

  Color get blue3;

  Color get blue4;

  Color get grey;

  Color get yellow;
}

abstract class CategorizedColor {
  Color get primary;

  Color get secondaryColor;

  Color get secondary => secondaryColor;

  Color get accent;

  Color get accentDeep;

  Color get text;

  Color get success;

  Color get warning;

  Color get info;

  Color get error;

  Color get splashDecoration;

  Color get scaffoldColor;

  Color get gray;

  Color get onPrimary => const Color(0xFFFFFFFF);
}
