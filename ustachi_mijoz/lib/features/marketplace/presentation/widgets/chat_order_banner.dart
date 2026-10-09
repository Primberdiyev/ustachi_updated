import 'package:ustachi/features/home/presentation/widgets/specialty_visuals.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/order_widgets.dart';
import 'package:ustachi/core/utils/order_date.dart';

class ChatOrderBanner extends StatefulWidget {
  const ChatOrderBanner({super.key, required this.orderId});

  final int orderId;

  @override
  State<ChatOrderBanner> createState() => _ChatOrderBannerState();
}

class _ChatOrderBannerState extends State<ChatOrderBanner> {
  OrderEntity? _order;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<MarketplaceRepository>().detail(widget.orderId);
    if (!mounted) return;
    setState(() {
      if (result.isRight) {
        _order = result.right;
        _failed = false;
      } else {
        _failed = true;
      }
    });
  }

  Future<void> _openDetail() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: widget.orderId),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final order = _order;

    if (order == null) {
      if (_failed) return const SizedBox.shrink();
      return const SizedBox(height: 0);
    }

    final spec = ProposalSpecCodec.decode(order.proposal['spec']);
    final argb = order.proposal['color_argb'];
    final frameTint = argb is int && (argb & 0xFFFFFF) != 0xFFFFFF
        ? Color(argb)
        : null;

    return Material(
      color: colors.neutral.surface,
      child: InkWell(
        onTap: _openDetail,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              ChizmaSpace.md, ChizmaSpace.sm, ChizmaSpace.md, ChizmaSpace.sm),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.neutral.border)),
          ),
          child: Row(
            children: [

              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: frameDrawingTileColor(context),
                  borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                  border: Border.all(color: colors.neutral.border),
                ),
                child: spec == null

                    ? Icon(
                        SpecialtyVisuals.iconOf(order.specialtyCode ?? ''),
                        size: 20,
                        color: colors.neutral.textMuted,
                      )
                    : FrameDrawing(spec: spec, frameTint: frameTint),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.title,
                      style: context.text.body5.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _subtitle(order),
                            style: context.text.label
                                .copyWith(color: colors.neutral.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              OrderStatusPill(order.status),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: colors.neutral.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(OrderEntity order) {
    final p = order.proposal;
    final kinds = p['item_kinds'];
    final count = p['item_count'];
    final size = (p['width_mm'] != null && p['height_mm'] != null)
        ? '${p['width_mm']}×${p['height_mm']} mm'
        : null;

    final left = (kinds is int && kinds > 1)
        ? '$kinds xil · ${count is int ? count : kinds} dona'
        : size;

    return [
      if (left != null) left,
      if (order.calculatedPrice > 0)
        '${formatSom(order.calculatedPrice.toDouble())} so\'m',

      if (order.createdAt != null) orderDateShort(order.createdAt),
    ].join(' · ');
  }
}
