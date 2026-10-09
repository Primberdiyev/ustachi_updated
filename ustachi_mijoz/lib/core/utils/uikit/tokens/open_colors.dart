import 'package:flutter/material.dart';
import 'package:ustachi/core/design_sytem/base_colors.dart';
import 'package:ustachi/core/design_sytem/dark_colors.dart';
import 'package:ustachi/core/design_sytem/light_colors.dart';

class OpenColors extends ThemeExtension<OpenColors> {
  const OpenColors({required this.uncategorized, required this.neutral});

  final UncategorizedColor uncategorized;
  final NeutralColor neutral;

  static final light = OpenColors(
    uncategorized: LightUncategorizedColor(),
    neutral: LightNeutralColor(),
  );

  static final dark = OpenColors(
    uncategorized: DarkUncategorizedColor(),
    neutral: DarkNeutralColor(),
  );

  @override
  OpenColors copyWith(
      {UncategorizedColor? uncategorized, NeutralColor? neutral}) {
    return OpenColors(
      uncategorized: uncategorized ?? this.uncategorized,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  OpenColors lerp(covariant ThemeExtension<OpenColors>? other, double t) {
    return this;
  }
}
