import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';

enum OrderCardStatus {
  completed,
  inProgress,
}

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
    required this.title,
    required this.dateTime,
    required this.price,
    required this.status,
    required this.statusText,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String dateTime;
  final String price;
  final OrderCardStatus status;
  final String statusText;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final statusBackgroundColor = switch (status) {
      OrderCardStatus.completed => colors.uncategorized.green4,
      OrderCardStatus.inProgress =>
        colors.neutral.blue2.withValues(alpha: 0.24),
    };
    final statusTextColor = switch (status) {
      OrderCardStatus.completed => colors.neutral.white,
      OrderCardStatus.inProgress => colors.neutral.blue1,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(

        color: colors.neutral.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.neutral.black6,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.neutral.black1.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.subtitle2Black1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateTime,
                  style: context.text.body3Black3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(

                price,
                style: context.text.numeric.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: context.text.body4.copyWith(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
