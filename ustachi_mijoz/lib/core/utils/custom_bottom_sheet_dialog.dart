import 'package:ustachi/core/utils/extensions.dart';
import 'package:flutter/material.dart';

Future<T?> customBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool? isDismissible,
  bool? enableDrag,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool willPop = true,
  double? heightOfWidget,
}) =>
    showModalBottomSheet(
      isDismissible: isDismissible ?? true,
      isScrollControlled: isScrollControlled,
      context: context,
      useRootNavigator: useRootNavigator,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      barrierColor: Colors.black.withValues(alpha: 0.1),
      useSafeArea: useSafeArea,
      showDragHandle: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          topSignBottomSheet(context: context),
          Flexible(child: builder(context)),
        ],
      ),
    );

Widget topSignBottomSheet({BuildContext? context}) => Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color:
            context != null ? context.color.neutral.black6 : Color(0xFFDCE4EB),
        borderRadius: BorderRadius.circular(41),
      ),
    );
