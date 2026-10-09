import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MasterDetailGalleryItem extends StatelessWidget {
  const MasterDetailGalleryItem({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: colors.neutral.black8,
        ),
        errorWidget: (context, url, error) => Container(
          color: colors.neutral.black8,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            color: colors.neutral.black4,
            size: 28.sp,
          ),
        ),
      ),
    );
  }
}
