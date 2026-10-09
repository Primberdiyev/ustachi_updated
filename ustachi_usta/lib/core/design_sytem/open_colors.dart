import 'package:ustachi/core/design_sytem/base_colors.dart';
import 'package:ustachi/core/design_sytem/dark_categorized_color.dart';
import 'package:ustachi/core/design_sytem/dark_colors.dart';
import 'package:ustachi/core/design_sytem/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/light_categorized_color.dart';

class OpenColors extends ThemeExtension<OpenColors> {
  OpenColors({
    required this.uncategorized,
    required this.neutral,
    required this.categorizedColor,
  });

  final UncategorizedColor uncategorized;
  final NeutralColor neutral;

  final CategorizedColor categorizedColor;

  static final light = OpenColors(
    uncategorized: LightUncategorizedColor(),
    neutral: LightNeutralColor(),
    categorizedColor: LightCategorizedColor(),
  );

  static final dark = OpenColors(
    uncategorized: DarkUncategorizedColor(),
    neutral: DarkNeutralColor(),
    categorizedColor: DarkCategorizedColor(),
  );

  @override
  OpenColors copyWith(
      {UncategorizedColor? uncategorized,
      NeutralColor? neutral,
      CategorizedColor? categorizedColor}) {
    return OpenColors(
      uncategorized: uncategorized ?? this.uncategorized,
      neutral: neutral ?? this.neutral,
      categorizedColor: categorizedColor ?? this.categorizedColor,
    );
  }

  @override
  OpenColors lerp(covariant ThemeExtension<OpenColors>? other, double t) {
    return this;
  }
}
