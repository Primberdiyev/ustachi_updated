import 'package:flutter/widgets.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/assets/lib/gen/assets.gen.dart';
import 'package:ustachi/core/utils/extensions.dart';

class MainServiceCardWidget extends StatelessWidget {
  final Color bgColor;
  final Color iconBgColor;
  final AssetGenImage image;
  final String text;
  final double width;
  final VoidCallback? onTap;
  const MainServiceCardWidget({
    super.key,
    required this.bgColor,
    required this.iconBgColor,
    required this.image,
    required this.text,
    required this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: bgColor.withValues(alpha: 0.9),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: image.image(
                fit: BoxFit.contain,
                color: context.color.neutral.white,
              ),
            ),
            Text(
              text,
              style: context.text.h4.copyWith(
                color: context.color.neutral.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
