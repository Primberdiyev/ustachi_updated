import 'package:flutter/widgets.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class ShowErrorWidget extends StatelessWidget {
  const ShowErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 20.h,
        children: [
          Image.asset(
            AppImages.error,
            height: 200.h,
            width: 200.w,
            fit: BoxFit.contain,
          ),
          Text(
            context.t.common.wentWrong,
            style: context.text.h3,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
