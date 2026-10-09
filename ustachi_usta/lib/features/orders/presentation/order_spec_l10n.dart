import 'package:flutter/widgets.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';

String orderSpecLabel(BuildContext context, String key) {
  final t = context.t.orders.spec;
  return switch (key) {
    specSize => t.size,
    specShape => t.shape,
    specBrand => t.brand,
    specColor => t.color,
    specMaterial => t.material,
    specGlass => t.glass,
    specSill => t.sill,
    specFlower => t.flower,
    specAddress => t.address,
    specProduct => t.product,
    specSpecialty => context.t.professional.specialty,
    specPhone => t.phone,
    specDiscount => t.discount,
    specNote => t.note,
    specArea => t.area,
    specUnitPrice => t.unitPrice,
    specVariant => t.variant,
    _ => key,
  };
}

String orderSpecValue(BuildContext context, String value) {
  if (!value.startsWith(specValuePrefix)) return value;

  final t = context.t.orders.spec;
  switch (value) {
    case specValuePlastic:
      return t.values.plastic;
    case specValueAluminium:
      return t.values.aluminium;
    case specValueTermo:
      return t.values.termo;
    case specValueDoubleGlass:
      return t.values.doubleGlass;
    case specValueSingleGlass:
      return t.values.singleGlass;
    case specValueLarge:
      return t.values.large;
    case specValueMedium:
      return t.values.medium;
    case specValueSmall:
      return t.values.small;
  }

  final parts = value.substring(specValuePrefix.length).split(':');
  if (parts.length == 3 && parts.first == 'items') {
    return t.itemsValue(kinds: parts[1], count: parts[2]);
  }

  return value.substring(specValuePrefix.length);
}
