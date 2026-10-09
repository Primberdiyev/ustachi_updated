import 'package:flutter/cupertino.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/utils/extensions.dart';

class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const BaseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.borderSide,
    this.padding,
    this.textStyle,
  });

  factory BaseButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 56,
    double borderRadius = 12,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return BaseButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor ?? Colors.white,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
    );
  }

  factory BaseButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? width,
    double height = 56,
    double borderRadius = 12,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return BaseButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor ?? Colors.transparent,
      textColor: textColor,
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: borderColor ?? const Color(0xFF3B1F61),
        width: 1.5,
      ),
      padding: padding,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? context.color.categorizedColor.primary;
    final effectiveTextColor = textColor ?? context.color.neutral.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor:
              effectiveBackgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.6),
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CupertinoActivityIndicator(
                  color: effectiveTextColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: textStyle ??
                        context.text.body1.copyWith(
                          color: effectiveTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
