import 'package:flutter/foundation.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

@immutable
class AreaPrice {
  const AreaPrice({
    required this.areaM2,
    required this.pricePerM2,
    required this.total,
  });

  final double areaM2;

  final double pricePerM2;

  final int total;
}

abstract final class AreaPriceCalculator {

  static List<AreaTier> sorted(List<AreaTier> tiers) {
    final rows = [...tiers];
    rows.sort((a, b) {
      if (a.upToArea == null) return b.upToArea == null ? 0 : 1;
      if (b.upToArea == null) return -1;
      return a.upToArea!.compareTo(b.upToArea!);
    });
    return rows;
  }

  static AreaTier? tierFor(List<AreaTier> tiers, double areaM2) {
    for (final tier in sorted(tiers)) {
      if (tier.upToArea == null || areaM2 <= tier.upToArea!) return tier;
    }
    return null;
  }

  static AreaPrice? calculate(List<AreaTier> tiers, double areaM2) {
    if (!areaM2.isFinite || areaM2 <= 0) return null;
    final tier = tierFor(tiers, areaM2);
    if (tier == null) return null;
    return AreaPrice(
      areaM2: areaM2,
      pricePerM2: tier.pricePerM2,
      total: (areaM2 * tier.pricePerM2).round(),
    );
  }

  static List<AreaTierLabel> labels(List<AreaTier> tiers,
      {bool perMetre = false}) {
    final rows = sorted(tiers);
    final out = <AreaTierLabel>[];
    final unit = perMetre ? 'm' : 'm²';
    double? previous;
    for (final tier in rows) {
      final limit = tier.upToArea;
      final String text;
      if (limit == null) {
        text = previous == null
            ? (perMetre ? 'Har qanday uzunlik' : 'Har qanday maydon')
            : '${_area(previous)} $unit dan yuqori';
      } else {
        text = '${_area(limit)} $unit gacha';
      }
      out.add(AreaTierLabel(range: text, pricePerM2: tier.pricePerM2));
      previous = limit;
    }
    return out;
  }

  static String _area(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';
}

@immutable
class AreaTierLabel {
  const AreaTierLabel({required this.range, required this.pricePerM2});

  final String range;
  final double pricePerM2;
}
