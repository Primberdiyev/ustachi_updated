import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart'
    show proposalMaterialLabel;
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';

@immutable
class OrderProposalItem {
  const OrderProposalItem({
    required this.title,
    required this.qty,
    this.widthMm,
    this.heightMm,
    this.shapeTitle = '',
    this.shapeSubtitle = '',
    this.material,
    this.colorLabel = '',
    this.colorArgb,
    this.hasSill = false,
    this.sillWidthCm = 0,
    this.spec,
  });

  final String title;
  final int qty;

  final int? widthMm;
  final int? heightMm;
  final String shapeTitle;
  final String shapeSubtitle;
  final int? material;
  final String colorLabel;
  final int? colorArgb;
  final bool hasSill;
  final int sillWidthCm;

  final FramePreviewSpec? spec;

  String? get sizeLabel =>
      (widthMm != null && heightMm != null) ? '$widthMm×$heightMm mm' : null;

  Color? get frameTint {
    final argb = colorArgb;
    if (argb == null || argb == 0) return null;
    return (argb & 0xFFFFFF) == 0xFFFFFF ? null : Color(argb);
  }

  String get materialLabel => proposalMaterialLabel(material);

  List<(String, String)> get specRows => [
        if (shapeTitle.isNotEmpty) ('Shakl', shapeTitle),
        if (sizeLabel != null) ('O\'lcham', sizeLabel!),
        if (materialLabel.isNotEmpty) ('Material', materialLabel),
        if (colorLabel.isNotEmpty) ('Rang', colorLabel),
        if (hasSill && sillWidthCm > 0) ('Tokcha', '$sillWidthCm sm'),
      ];
}

List<OrderProposalItem> orderProposalItems(Map<String, dynamic> proposal) {
  if (proposal.isEmpty) return const [];
  final raw = proposal['items'];
  if (raw is List && raw.isNotEmpty) {
    return [
      for (final item in raw)
        if (item is Map) _item(Map<String, dynamic>.from(item)),
    ];
  }
  final single = _item(proposal);

  if (single.spec == null && single.sizeLabel == null) return const [];
  return [single];
}

OrderProposalItem _item(Map<String, dynamic> json) {
  final qty = _int(json['qty']) ?? 1;
  return OrderProposalItem(
    title: json['title']?.toString().trim().isNotEmpty == true
        ? json['title'].toString()
        : 'Rom',
    qty: qty < 1 ? 1 : qty,
    widthMm: _int(json['width_mm']),
    heightMm: _int(json['height_mm']),
    shapeTitle: json['shape_title']?.toString() ?? '',
    shapeSubtitle: json['shape_subtitle']?.toString() ?? '',
    material: _int(json['material']),
    colorLabel: json['color_label']?.toString() ?? '',
    colorArgb: _int(json['color_argb']),
    hasSill: json['has_sill'] == true,
    sillWidthCm: _int(json['sill_width_cm']) ?? 0,
    spec: ProposalSpecCodec.decode(json['spec']),
  );
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

int orderItemsCount(List<OrderProposalItem> items) =>
    items.fold(0, (sum, i) => sum + i.qty);
