import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/profile/domain/models/profile_item_model.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  const ProfileMenuItemWidget({super.key, required this.model});

  final ProfileItemModel model;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: model.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(

                color: context.color.neutral.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                model.icon,
                size: 30,
                color: context.color.categorizedColor.primary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                model.title,
                style: context.text.subtitle4,
              ),
            ),
            model.trailingBuilder?.call(context) ??
                Icon(
                  Icons.chevron_right,
                  size: 30,
                ),
          ],
        ),
      ),
    );
  }
}
