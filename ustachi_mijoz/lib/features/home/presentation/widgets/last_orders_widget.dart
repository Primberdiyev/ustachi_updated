import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class LastOrdersWidget extends StatelessWidget {
  const LastOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final orders = <_Order>[
      _Order(
        title: 'Balkon romi, 3 tavaqa',
        code: '#UT-2418',
        date: '18-iyul',
        price: '4 250 000',
        statusText: t.completed,
        status: ChizmaStatus.done,
        icon: Icons.window_outlined,
      ),
      _Order(
        title: 'Oshxona mebeli',
        code: '#UT-2431',
        date: '20-iyul',
        price: '6 900 000',
        statusText: t.inProgress,
        status: ChizmaStatus.progress,
        icon: Icons.chair_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChizmaSectionHeader(
          title: t.lastOrders,
          actionLabel: t.all,
          onAction: () {},
        ),
        const SizedBox(height: ChizmaSpace.md),
        ChizmaRowGroup(
          rows: [
            for (final o in orders)
              ChizmaListRow(
                onTap: () {},
                leading: ChizmaIconTile(icon: o.icon),
                title: o.title,
                subtitle: _CodeAndDate(code: o.code, date: o.date),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChizmaPrice(o.price),
                    const SizedBox(height: ChizmaSpace.xs),
                    ChizmaStatusPill(o.statusText, status: o.status),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CodeAndDate extends StatelessWidget {
  const _CodeAndDate({required this.code, required this.date});

  final String code;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: code,
            style: context.text.numericMuted.copyWith(fontSize: 12),
          ),
          const TextSpan(text: '  ·  '),
          TextSpan(text: date),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Order {
  const _Order({
    required this.title,
    required this.code,
    required this.date,
    required this.price,
    required this.statusText,
    required this.status,
    required this.icon,
  });

  final String title;
  final String code;
  final String date;
  final String price;
  final String statusText;
  final ChizmaStatus status;
  final IconData icon;
}
