import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

abstract final class SpecialtyCalculatorDefaults {

  static const Map<String, SpecialtyCalculator> _kinds = {
    'rom': SpecialtyCalculator.rom,
    'asfalt': SpecialtyCalculator.area,
    'penthaus_gidro_tom': SpecialtyCalculator.area,
    'travertin': SpecialtyCalculator.area,
    'eshik': SpecialtyCalculator.variant,
    'kafel': SpecialtyCalculator.variant,

    'tom': SpecialtyCalculator.roof,

    'beton': SpecialtyCalculator.beton,

    'santexnik': SpecialtyCalculator.heating,
    'elektrik': SpecialtyCalculator.electrical,
  };

  static const Set<String> _materialPriced = {'kafel'};

  static const Map<String, List<SpecialtyVariant>> _variants = {
    'eshik': [
      SpecialtyVariant(
        name: 'Odatiy',
        note: '1 qanotli laminatsiya',
        pricePerM2: 500000,
      ),
      SpecialtyVariant(name: 'Standart', pricePerM2: 1000000),
      SpecialtyVariant(name: 'Premium', pricePerM2: 1500000),
    ],

    'kafel': [
      SpecialtyVariant(
        name: 'Pol kafeli',
        size: '40×40 sm',
        pricePerM2: 45000,
      ),
      SpecialtyVariant(
        name: 'Devor kafeli',
        size: '30×60 sm',
        pricePerM2: 50000,
      ),
      SpecialtyVariant(
        name: 'Sokl kafeli',
        size: '60×120 sm',
        pricePerM2: 125000,
      ),
    ],
  };

  static const Map<String, List<AreaTier>> _tiers = {
    'penthaus_gidro_tom': [AreaTier(upToArea: null, pricePerM2: 424000)],
    'asfalt': [
      AreaTier(upToArea: 100, pricePerM2: 100000),
      AreaTier(upToArea: null, pricePerM2: 75000),
    ],
    'travertin': [
      AreaTier(upToArea: null, pricePerM2: 120000),
    ],
  };

  static SpecialtyCalculator kindOf(String code) =>
      _kinds[code] ?? SpecialtyCalculator.none;

  static List<AreaTier> tiersOf(String code) => _tiers[code] ?? const [];

  static List<SpecialtyVariant> variantsOf(String code) =>
      _variants[code] ?? const [];

  static bool priceIsMaterial(String code) => _materialPriced.contains(code);
}
