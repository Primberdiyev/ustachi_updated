import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MasterDetailReviewCard extends StatelessWidget {
  const MasterDetailReviewCard({
    super.key,
    required this.initials,
    required this.fullName,
    required this.postedAt,
    required this.comment,
  });

  final String initials;
  final String fullName;
  final String postedAt;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = context.text;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.neutral.surface,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: colors.neutral.black1.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.categorizedColor.gray,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: text.body5.copyWith(
                    color: colors.categorizedColor.splashDecoration,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: text.body4Black2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      postedAt,
                      style: text.body5Black3,
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16.sp,
                      color: colors.uncategorized.yellow1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            comment,
            style: text.body4.copyWith(
              color: colors.neutral.black2,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
