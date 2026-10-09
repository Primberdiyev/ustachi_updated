import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MasterDetailStatCard extends StatelessWidget {
  const MasterDetailStatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = context.text;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colors.neutral.black6,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.neutral.black1.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.body5.copyWith(
              color: colors.neutral.black1,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: text.subtitle4Black1.copyWith(
              color: colors.categorizedColor.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
