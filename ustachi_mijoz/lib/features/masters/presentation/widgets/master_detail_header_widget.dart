import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MasterDetailHeaderWidget extends StatelessWidget {
  const MasterDetailHeaderWidget({
    super.key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewLabel,
    required this.imageUrl,
  });

  final String name;
  final String profession;
  final String rating;
  final String reviewLabel;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = context.text;

    return Center(
      child: Column(
        children: [
          Container(
            width: 116.w,
            height: 116.w,
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.neutral.black5,
                width: 3.w,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colors.neutral.black8,
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.neutral.black8,
                  child: Icon(
                    Icons.person,
                    color: colors.neutral.black4,
                    size: 52.sp,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
            child: Text(
              name,
              style: text.subtitle2Black1.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            profession,
            style: text.body2Black1.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 18.sp,
                color: colors.uncategorized.yellow1,
              ),
              SizedBox(width: 4.w),
              Text(
                rating,
                style: text.body4Black2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                reviewLabel,
                style: text.body4.copyWith(
                  color: colors.neutral.black3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
