import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    required this.userModel,
    this.onEdit,
  });

  final UserModel userModel;

  final VoidCallback? onEdit;

  String get _initial {
    final name = userModel.fullName.trim();
    if (name.isNotEmpty) return name.characters.first.toUpperCase();
    final phone = userModel.phoneNumber.trim();
    return phone.isEmpty ? '?' : phone.characters.last;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final photo = userModel.photo.trim();

    Widget fallback() => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.categorizedColor.gray,
          ),
          alignment: Alignment.center,
          child: Text(
            _initial,
            style: context.text.h1.copyWith(
              color: colors.categorizedColor.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            height: 150.h,
            width: 150.w,
            padding: EdgeInsets.all(10.r),
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.categorizedColor.gray,
            ),
            child: photo.isEmpty
                ? fallback()
                : CachedNetworkImage(
                    imageUrl: photo,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => fallback(),
                    errorWidget: (context, url, error) => fallback(),
                  ),
          ),
          if (onEdit != null)
            Positioned(
              bottom: 25.h,
              right: 0,
              child: Material(
                color: colors.categorizedColor.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onEdit,
                  child: SizedBox(
                    height: 40.h,
                    width: 40.w,
                    child: Icon(
                      Icons.edit,
                      size: 20.sp,
                      color: colors.neutral.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
