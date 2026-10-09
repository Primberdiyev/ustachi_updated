
library;

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';

String orderDateText(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

typedef HisobOrderResult = ({String client, HisobOrder order});

class HisobOrderPage extends StatefulWidget {
  const HisobOrderPage({super.key, required this.client, required this.order});

  final String client;
  final HisobOrder order;

  static Future<HisobOrderResult?> open(
    BuildContext context, {
    required String client,
    required HisobOrder order,
  }) =>
      Navigator.of(context).push<HisobOrderResult>(
        MaterialPageRoute(
          builder: (_) => HisobOrderPage(client: client, order: order),
        ),
      );

  @override
  State<HisobOrderPage> createState() => _HisobOrderPageState();
}

class _HisobOrderPageState extends State<HisobOrderPage> {
  late final _client = TextEditingController(text: widget.client);
  late final _phone = TextEditingController(text: widget.order.phone);
  late final _address = TextEditingController(text: widget.order.address);
  late DateTime? _deadline = widget.order.deadline;

  @override
  void dispose() {
    for (final c in [_client, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? today.add(const Duration(days: 7)),
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    Navigator.of(context).pop<HisobOrderResult>((
      client: _client.text.trim(),
      order: HisobOrder(
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        deadline: _deadline,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text('Buyurtma ma\'lumoti')),
      body: ListView(
        padding: const EdgeInsets.all(ChizmaSpace.lg),
        children: [
          _Field(
            label: 'Mijoz ismi',
            controller: _client,
            icon: Icons.person_outline_rounded,
            capitalization: TextCapitalization.words,
          ),
          _Field(
            label: 'Telefon raqami',
            controller: _phone,
            icon: Icons.phone_outlined,
            keyboard: TextInputType.phone,
            hint: '+998 90 123 45 67',
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ()-]'))],
          ),
          _Field(
            label: 'Manzil',
            controller: _address,
            icon: Icons.location_on_outlined,
            capitalization: TextCapitalization.sentences,
            maxLines: 2,
          ),
          ChizmaSheet(
            onTap: _pickDate,
            padding: const EdgeInsets.all(ChizmaSpace.md),
            child: Row(
              children: [
                Icon(Icons.event_outlined, size: 20, color: colors.neutral.textMuted),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: Text(
                    'Bitkazish sanasi',
                    style: context.text.body4.copyWith(color: colors.neutral.textBody),
                  ),
                ),
                Text(
                  _deadline == null ? 'Tanlang' : orderDateText(_deadline!),
                  style: context.text.body3.copyWith(
                    color: _deadline == null ? colors.neutral.textMuted : colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_deadline != null)
                  IconButton(
                    tooltip: 'Sanani olib tashlash',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _deadline = null),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: colors.neutral.textMuted),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          child: FilledButton(onPressed: _save, child: Text('Saqlash')),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboard,
    this.hint,
    this.formatters,
    this.capitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final String? hint;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization capitalization;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        textCapitalization: capitalization,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: uz(label),
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
