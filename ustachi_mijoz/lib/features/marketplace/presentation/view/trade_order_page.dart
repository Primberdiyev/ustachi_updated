import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/master_picker_page.dart';

class TradeOrderPage extends StatefulWidget {
  const TradeOrderPage({
    super.key,
    required this.specialty,
    this.calculatedPrice,
    this.proposal,
    this.summary,
    this.isRepair = false,
    this.initialDescription,
  });

  final SpecialtyEntity specialty;

  final int? calculatedPrice;

  final Map<String, dynamic>? proposal;

  final String? summary;

  final bool isRepair;

  final String? initialDescription;

  bool get hasPrice => (calculatedPrice ?? 0) > 0;

  @override
  State<TradeOrderPage> createState() => _TradeOrderPageState();
}

class _TradeOrderPageState extends State<TradeOrderPage> {
  late final _descriptionCtrl =
      TextEditingController(text: widget.initialDescription ?? '');
  final _addressCtrl = TextEditingController();
  bool _sending = false;

  String? _validationError;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  bool _validate() {

    if (widget.hasPrice) {
      if (_validationError != null) setState(() => _validationError = null);
      return true;
    }
    final description = _descriptionCtrl.text.trim();
    setState(() {
      _validationError =
          description.length < 10 ? 'Ishni qisqacha yozib bering' : null;
    });
    return _validationError == null;
  }

  Future<void> _pickMasters() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    final picked = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute<List<int>>(
        builder: (_) => MasterPickerPage(
          summary: widget.specialty.name,

          specialtyId: widget.specialty.id,

          repairsOnly: widget.isRepair,
          actionLabel: 'Yuborish',
        ),
      ),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    await _publish(masterIds: picked);
  }

  Future<void> _publish({List<int> masterIds = const []}) async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _sending = true);

    final result = await sl<MarketplaceRepository>().create({

      'title': widget.summary == null
          ? widget.specialty.name
          : '${widget.specialty.name} — ${widget.summary}',
      'description': _descriptionCtrl.text.trim(),

      if (widget.specialty.id > 0) 'specialty': widget.specialty.id,
      'address': _addressCtrl.text.trim(),
      if (masterIds.isNotEmpty) 'master_ids': masterIds,

      if (widget.hasPrice) 'calculated_price': widget.calculatedPrice,
      if (widget.proposal != null) 'proposal': widget.proposal,

      if (widget.isRepair) 'is_repair': true,
    });

    if (!mounted) return;
    setState(() => _sending = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }

    if (!inviteHonored(result.right, masterIds)) {
      sl<SnackbarService>().showMessage(
        'Tanlangan usta biriktirilmadi — buyurtma ochiq e\'lon bo\'lib '
        'joylandi. Buyurtma sahifasidan qayta taklif qilishingiz mumkin.',
      );
    }
    Navigator.of(context).pop<OrderEntity>(result.right);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final image = SpecialtyVisuals.imageOf(widget.specialty.code);

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: const Text('Usta chaqirish')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ChizmaSpace.lg,
          ChizmaSpace.lg,
          ChizmaSpace.lg,
          ChizmaSpace.xxl + context.viewPaddingBottom,
        ),
        children: [

          ChizmaSheet(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: colors.neutral.white,
                    padding: const EdgeInsets.all(4),
                    child: image != null
                        ? Image.asset(image,
                            fit: BoxFit.contain, cacheWidth: 200)
                        : Icon(
                            SpecialtyVisuals.iconOf(widget.specialty.code),
                            color: colors.categorizedColor.primary,
                          ),
                  ),
                ),
                const SizedBox(width: ChizmaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.specialty.name,
                        style: context.text.h4
                            .copyWith(color: colors.neutral.textStrong),
                      ),
                      const SizedBox(height: 2),
                      Text(

                        widget.summary ??
                            'Ishni yozing — soha ustalari javob beradi',
                        style: context.text.body5.copyWith(
                          color: widget.hasPrice
                              ? colors.categorizedColor.primary
                              : colors.neutral.textMuted,
                          fontWeight: widget.hasPrice ? FontWeight.w700 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          ChizmaEyebrow(
              widget.hasPrice ? 'Qo\'shimcha (ixtiyoriy)' : 'Qanday ish?'),
          const SizedBox(height: ChizmaSpace.sm),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              if (_validationError != null) _validate();
            },
            decoration: InputDecoration(
              hintText: uz(widget.hasPrice
                  ? 'Masalan: hovli darvozadan uygacha. Eski qatlam '
                      'olinishi kerak.'

                  : widget.specialty.isTexnika
                      ? 'Qanday ish, qancha vaqt yoki hajm, qachon kerak — '
                          'yozing.'
                      : 'Masalan: 60 m² tomni profnastil bilan yopish kerak. '
                          'Eski shifer olib tashlanadi.'),
              errorText:
                  _validationError == null ? null : uz(_validationError!),
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          ChizmaEyebrow('Manzil'),
          const SizedBox(height: ChizmaSpace.sm),
          TextField(
            controller: _addressCtrl,
            decoration: InputDecoration(
              hintText: uz('Ko\'cha, uy, xonadon'),
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
            ),
          ),
          const SizedBox(height: ChizmaSpace.lg),

          ChizmaSheet(
            color: colors.neutral.surface2,
            child: Row(
              children: [
                Icon(
                  widget.hasPrice
                      ? Icons.calculate_outlined
                      : Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: colors.neutral.textMuted,
                ),
                const SizedBox(width: ChizmaSpace.sm),
                Expanded(
                  child: Text(
                    widget.hasPrice
                        ? 'Hisob e\'lon bilan birga ketadi. Usta o\'lchovga '
                            'kelib aniq narxni aytadi — u shu summadan biroz '
                            'yuqori yoki past bo\'lishi mumkin.'
                        : 'Narxni usta bilan chatda kelishasiz — u ishni '
                            'ko\'rib aniq aytadi.',
                    style: context.text.body5
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.xl),

          ChizmaEyebrow('Kimga yuboramiz?'),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _sending ? null : () => _publish(),
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Usta qidirish'),
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: _sending ? null : _pickMasters,
                  child: const Text('Usta tanlash'),
                ),
              ),
            ],
          ),
          if (widget.hasPrice) const PriceEstimateNotice(),
        ],
      ),
    );
  }
}
