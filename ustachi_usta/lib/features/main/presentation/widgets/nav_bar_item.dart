import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';

class NavBarItem extends StatelessWidget {
  final String activeIconPath;
  final String inActiveIconPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;
  final double height;
  final TextStyle activeTextStyle;
  final TextStyle passiveTextStyle;
  final double spacing;

  const NavBarItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeIconPath,
    required this.inActiveIconPath,
    required this.activeTextStyle,
    required this.passiveTextStyle,
    this.width = 24,
    this.height = 24,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Image.asset(
              selected ? activeIconPath : inActiveIconPath,
              height: 30,
              width: 30,
              color: selected
                  ? context.color.categorizedColor.primary
                  : context.color.neutral.textMuted,
            ),
          ),
          Text(
            label,
            style: selected ? activeTextStyle : passiveTextStyle,
          ),
        ],
      ),
    );
  }
}
