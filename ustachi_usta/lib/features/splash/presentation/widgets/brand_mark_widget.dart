import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';
import 'package:ustachi/core/utils/extensions.dart';

class BrandMarkWidget extends StatelessWidget {
  const BrandMarkWidget({
    super.key,
    required this.decoration,
    required this.iconColor,
    this.borderColor,
  });

  final Color decoration;
  final Color iconColor;

  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: decoration.withValues(alpha: 0.55),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        width: 162,
        height: 162,
        decoration: BoxDecoration(
          color: decoration.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: borderColor ?? context.color.neutral.white,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              AppImages.logo,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
