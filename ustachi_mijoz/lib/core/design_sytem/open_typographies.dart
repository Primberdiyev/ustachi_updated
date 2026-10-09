import 'package:ustachi/core/design_sytem/base_colors.dart';
import 'package:ustachi/core/design_sytem/typographies.dart';
import 'package:flutter/material.dart';

class OpenTypographies extends ThemeExtension<OpenTypographies> {
  const OpenTypographies({
    required this.h1,
    required this.h2,
    required this.h2Green1,
    required this.h2Black1,
    required this.h3,
    required this.h3Black1,
    required this.h4,
    required this.h5,
    required this.subtitle,
    required this.subtitle1,
    required this.subtitle1Green1,
    required this.subtitle1Black1,
    required this.subtitle1White,
    required this.subtitle2,
    required this.subtitle2Green1,
    required this.subtitle2Black1,
    required this.subtitle3,
    required this.subtitle3Black1,
    required this.subtitle4,
    required this.subtitle4Black1,
    required this.subtitle5,
    required this.subtitle5Black1,
    required this.subtitle5Green1,
    required this.subtitle6,
    required this.subtitle6Red,
    required this.subtitle6Black1,
    required this.subtitle6Black3,
    required this.subtitle6Black4,
    required this.subtitle7,
    required this.subtitle7Black1,
    required this.subtitle7Black2,
    required this.subtitle7Black3,
    required this.subtitle7Black4,
    required this.body1,
    required this.body1Green1,
    required this.body1Black1,
    required this.body2,
    required this.body2White,
    required this.body2Black1,
    required this.body2Black2,
    required this.body2Black3,
    required this.body2Green1,
    required this.body3,
    required this.body3Black1,
    required this.body3Black2,
    required this.body3Black3,
    required this.body4,
    required this.body4Black2,
    required this.body4Green1,
    required this.body4White,
    required this.body4H1,
    required this.body5,
    required this.body5Yellow1,
    required this.body5Black3,
    required this.button1,
    required this.button1White,
    required this.button1Green1,
    required this.button1Red,
    required this.button2,
    required this.textButton,
    required this.textButtonUnderlined,
  });

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h2Black1;
  final TextStyle h2Green1;
  final TextStyle h3;
  final TextStyle h3Black1;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle subtitle;
  final TextStyle subtitle1;
  final TextStyle subtitle1Green1;
  final TextStyle subtitle1Black1;
  final TextStyle subtitle1White;
  final TextStyle subtitle2;
  final TextStyle subtitle2Green1;
  final TextStyle subtitle2Black1;
  final TextStyle subtitle3;
  final TextStyle subtitle3Black1;
  final TextStyle subtitle4;
  final TextStyle subtitle4Black1;
  final TextStyle subtitle5;
  final TextStyle subtitle5Black1;
  final TextStyle subtitle5Green1;
  final TextStyle subtitle6;
  final TextStyle subtitle6Red;
  final TextStyle subtitle6Black1;
  final TextStyle subtitle6Black3;
  final TextStyle subtitle6Black4;
  final TextStyle subtitle7;
  final TextStyle subtitle7Black1;
  final TextStyle subtitle7Black2;
  final TextStyle subtitle7Black3;
  final TextStyle subtitle7Black4;
  final TextStyle body1;
  final TextStyle body1Green1;
  final TextStyle body1Black1;
  final TextStyle body2;
  final TextStyle body2White;
  final TextStyle body2Black1;
  final TextStyle body2Black2;
  final TextStyle body2Black3;
  final TextStyle body2Green1;
  final TextStyle body3;
  final TextStyle body3Black1;
  final TextStyle body3Black2;
  final TextStyle body3Black3;
  final TextStyle body4;
  final TextStyle body4Black2;
  final TextStyle body4Green1;
  final TextStyle body4White;
  final TextStyle body4H1;
  final TextStyle body5;
  final TextStyle body5Yellow1;
  final TextStyle body5Black3;
  final TextStyle button1;
  final TextStyle button1White;
  final TextStyle button1Green1;
  final TextStyle button1Red;
  final TextStyle button2;
  final TextStyle textButton;
  final TextStyle textButtonUnderlined;

  TextStyle get label =>
      Typographies.label.copyWith(color: body5Black3.color);

  TextStyle get numeric =>
      Typographies.numeric.copyWith(color: body2Black1.color);

  TextStyle get numericLg =>
      Typographies.numericLg.copyWith(color: body2Black1.color);

  TextStyle get numericMuted =>
      Typographies.numeric.copyWith(color: body5Black3.color);

  factory OpenTypographies.fromColors(
    NeutralColor textColor,
    UncategorizedColor uncategorizedColor,
  ) {
    return OpenTypographies(
      h1: Typographies.h1.copyWith(color: textColor.black2),
      h2: Typographies.h2.copyWith(color: textColor.black2),
      h2Black1: Typographies.h2.copyWith(color: textColor.black1),
      h2Green1: Typographies.h2.copyWith(color: uncategorizedColor.green1),
      h3: Typographies.h3.copyWith(color: textColor.black2),
      h3Black1: Typographies.h3.copyWith(color: textColor.black1),
      h4: Typographies.h4.copyWith(color: textColor.black2),
      h5: Typographies.h5.copyWith(color: textColor.black2),
      subtitle: Typographies.subtitle.copyWith(color: textColor.black2),
      subtitle1: Typographies.subtitle1.copyWith(color: textColor.black2),
      subtitle1Green1:
          Typographies.subtitle1.copyWith(color: uncategorizedColor.green1),
      subtitle1Black1: Typographies.subtitle1.copyWith(color: textColor.black1),
      subtitle1White: Typographies.subtitle1.copyWith(color: textColor.white),
      subtitle2: Typographies.subtitle2.copyWith(color: textColor.black2),
      subtitle2Green1:
          Typographies.subtitle2.copyWith(color: uncategorizedColor.green1),
      subtitle2Black1: Typographies.subtitle2.copyWith(color: textColor.black1),
      subtitle3: Typographies.subtitle3.copyWith(color: textColor.black2),
      subtitle3Black1: Typographies.subtitle3.copyWith(color: textColor.black1),
      subtitle4: Typographies.subtitle4.copyWith(color: textColor.black2),
      subtitle4Black1: Typographies.subtitle4.copyWith(color: textColor.black1),
      subtitle5: Typographies.subtitle5.copyWith(color: textColor.black2),
      subtitle5Black1: Typographies.subtitle5.copyWith(color: textColor.black1),
      subtitle5Green1:
          Typographies.subtitle5.copyWith(color: uncategorizedColor.green1),
      subtitle6: Typographies.subtitle6.copyWith(color: textColor.black2),
      subtitle6Red:
          Typographies.subtitle6.copyWith(color: uncategorizedColor.red),
      subtitle6Black1: Typographies.subtitle6.copyWith(color: textColor.black1),
      subtitle6Black3: Typographies.subtitle6.copyWith(color: textColor.black3),
      subtitle6Black4: Typographies.subtitle6.copyWith(color: textColor.black4),
      subtitle7: Typographies.subtitle7.copyWith(color: textColor.black1),
      subtitle7Black1: Typographies.subtitle7.copyWith(color: textColor.black1),
      subtitle7Black2: Typographies.subtitle7.copyWith(color: textColor.black2),
      subtitle7Black3: Typographies.subtitle7.copyWith(color: textColor.black3),
      subtitle7Black4: Typographies.subtitle7.copyWith(color: textColor.black4),
      body1: Typographies.body1.copyWith(color: textColor.black2),
      body1Green1:
          Typographies.body1.copyWith(color: uncategorizedColor.green1),
      body1Black1: Typographies.body1.copyWith(color: textColor.black1),
      body2: Typographies.body2.copyWith(color: textColor.black2),
      body2White: Typographies.body2.copyWith(color: textColor.white),
      body2Black1: Typographies.body2.copyWith(color: textColor.black1),
      body2Black2: Typographies.body2.copyWith(color: textColor.black2),
      body2Black3: Typographies.body2.copyWith(color: textColor.black3),
      body2Green1:
          Typographies.body2.copyWith(color: uncategorizedColor.green1),
      body3: Typographies.body3.copyWith(color: textColor.black2),
      body3Black1: Typographies.body3.copyWith(color: textColor.black1),
      body3Black2: Typographies.body3.copyWith(color: textColor.black2),
      body3Black3: Typographies.body3.copyWith(color: textColor.black3),
      body4: Typographies.body4.copyWith(color: textColor.black2),
      body4Black2: Typographies.body4.copyWith(color: textColor.black2),
      body4Green1:
          Typographies.body4.copyWith(color: uncategorizedColor.green1),
      body4White: Typographies.body4.copyWith(color: textColor.white),
      body4H1: Typographies.body4.copyWith(color: textColor.black1, height: 1),
      body5: Typographies.body5.copyWith(color: textColor.black2),
      body5Yellow1:
          Typographies.body5.copyWith(color: uncategorizedColor.yellow1),
      body5Black3: Typographies.body5.copyWith(color: textColor.black3),
      button1: Typographies.button1.copyWith(color: textColor.black2),
      button1White: Typographies.button1.copyWith(color: textColor.white),
      button1Green1:
          Typographies.button1.copyWith(color: uncategorizedColor.green1),
      button1Red: Typographies.button1.copyWith(color: uncategorizedColor.red),
      button2: Typographies.button2.copyWith(color: textColor.black2),
      textButton: Typographies.body2
          .copyWith(color: uncategorizedColor.green1, height: 1.1),
      textButtonUnderlined: Typographies.body2.copyWith(
        color: uncategorizedColor.green1,
        decoration: TextDecoration.underline,
        decorationColor: uncategorizedColor.green1,
      ),
    );
  }

  @override
  ThemeExtension<OpenTypographies> copyWith() {
    return this;
  }

  @override
  ThemeExtension<OpenTypographies> lerp(
    covariant ThemeExtension<OpenTypographies>? other,
    double t,
  ) {
    return this;
  }
}
