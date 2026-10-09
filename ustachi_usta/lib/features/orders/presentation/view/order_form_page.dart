import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/formatter.dart';
import 'package:ustachi/features/orders/domain/entities/order_draft.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/order_draft_store.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _draft = sl<OrderDraftStore>();
  late final _repository = sl<OwnOrdersRepository>();
  late final _outbox = sl<OwnOrderOutbox>();

  final _name = TextEditingController();

  final _phone = UzPhoneInput.createController();
  final _phoneMask = UzPhoneInput.createFormatter();
  final _address = TextEditingController();
  final _note = TextEditingController();

  void _notifyOrdersList() {
    if (!sl.isRegistered<OrdersBloc>()) return;
    sl<OrdersBloc>().add(const OrdersLoadRequested());
  }

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_draft.value.isEmpty) {
      sl<SnackbarService>().showMessage(context.t.orderForm.noProducts);
      return;
    }
    FocusScope.of(context).unfocus();

    final payload = OwnOrderPayload.fromDraft(
      draft: _draft.value,
      syncClientId: _draft.syncId,
      customerName: _name.text.trim(),
      customerPhone: UzPhoneInput.valueOf(_phone.text),
      customerAddress: _address.text.trim(),
      note: _note.text.trim(),
    );

    setState(() => _saving = true);
    final result = await _repository.create(payload);
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isLeft) {
      if (OwnOrderOutbox.shouldQueue(result.left)) {
        await _outbox.add(payload);
        if (!mounted) return;
        _draft.clear();
        sl<SnackbarService>().showMessage(context.t.orderForm.queued);
        _notifyOrdersList();
        Navigator.of(context).pop(true);
        return;
      }
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }

    _draft.clear();
    HapticFeedback.mediumImpact();
    sl<SnackbarService>().showMessage(context.t.orderForm.saved);
    _notifyOrdersList();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final accent = colors.categorizedColor.primary;
    final t = context.t.orderForm;

    return ValueListenableBuilder<OrderDraft>(
      valueListenable: _draft,
      builder: (context, draft, _) {
        return Scaffold(
          backgroundColor: colors.neutral.bg,
          appBar: AppBar(title: Text(t.saveTitle)),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(ChizmaSpace.lg),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: accent,
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.t.common.save),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ChizmaPageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DraftSummary(draft: draft),
                  const SizedBox(height: ChizmaSpace.xl),

                  ChizmaEyebrow(t.customer),
                  const SizedBox(height: ChizmaSpace.md),
                  ChizmaSheet(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          enabled: !_saving,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: uz(t.nameLabel),
                            hintText: uz(t.nameHint),
                            prefixIcon:
                                const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? t.nameRequired
                              : null,
                        ),
                        const SizedBox(height: ChizmaSpace.md),
                        TextFormField(
                          controller: _phone,
                          enabled: !_saving,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMask],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: uz(context.t.orders.spec.phone),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: ChizmaSpace.md),
                        TextFormField(
                          controller: _address,
                          enabled: !_saving,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: uz(context.t.orders.spec.address),
                            hintText: uz(t.addressHint),
                            prefixIcon: const Icon(Icons.place_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ChizmaSpace.xl),

                  ChizmaEyebrow(context.t.orders.spec.note),
                  const SizedBox(height: ChizmaSpace.md),
                  ChizmaSheet(
                    child: TextFormField(
                      controller: _note,
                      enabled: !_saving,
                      maxLines: 3,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: uz(t.noteLabel),
                        hintText: uz(t.noteHint),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DraftSummary extends StatelessWidget {
  const _DraftSummary({required this.draft});

  final OrderDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return ChizmaSheet(
      color: colors.neutral.surface2,
      child: Row(
        children: [
          const ChizmaIconTile(icon: Icons.inventory_2_outlined, size: 40),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t.orderForm.itemsSummary(
                    kinds: draft.items.length.toString(),
                    count: draft.productCount.toString(),
                  ),
                  style: context.text.body4
                      .copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: 2),
                Text(
                  draft.items.map((item) => item.title).take(3).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
