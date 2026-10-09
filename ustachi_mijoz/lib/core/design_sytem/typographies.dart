import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _letterSpacingMultiplier = 0.0;

const _monoFamily = 'monospace';
const _tabular = <FontFeature>[FontFeature.tabularFigures()];

class Typographies {
  const Typographies._();

  static TextStyle get h1 => TextStyle(
    fontSize: 33.sp,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static TextStyle get h4 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get h5 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle1 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static TextStyle get subtitle2 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static TextStyle get subtitle3 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle4 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle5 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle6 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get subtitle7 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get body1 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get body2 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get body3 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get body4 => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get body5 => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get button1 => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get button2 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: _letterSpacingMultiplier,
  );

  static TextStyle get label => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.0,
  );

  static TextStyle get numeric => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: _letterSpacingMultiplier,
    fontFamily: _monoFamily,
    fontFeatures: _tabular,
  );

  static TextStyle get numericLg => TextStyle(
    fontSize: 26.sp,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.2,
    fontFamily: _monoFamily,
    fontFeatures: _tabular,
  );
}
