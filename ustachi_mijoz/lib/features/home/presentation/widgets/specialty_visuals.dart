import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/assets/app_images.dart';

abstract final class SpecialtyVisuals {

  static const Map<String, String> _images = {
    'rom': AppImages.serviceWindow,
    'mebel': AppImages.serviceFurniture,
    'elektrik': AppImages.serviceElectric,
    'santexnik': AppImages.servicePlumbing,
    'tom': AppImages.serviceRoof,
    'penthaus_gidro_tom': AppImages.serviceRoof,
    'beton': AppImages.serviceConcrete,
    'darvoza': AppImages.serviceGate,
    'gisht': AppImages.serviceBrick,
    'asfalt': AppImages.serviceAsphalt,
    'eshik': AppImages.serviceDoorMdf,
  };

  static const Map<String, IconData> _icons = {
    'rom': Icons.window_outlined,
    'tom': Icons.roofing_outlined,
    'gisht': Icons.dashboard_customize_outlined,
    'beton': Icons.foundation_outlined,
    'elektrik': Icons.electrical_services_outlined,
    'santexnik': Icons.plumbing_outlined,
    'mebel': Icons.chair_outlined,
    'darvoza': Icons.fence_outlined,
    'suvoq': Icons.format_paint_outlined,
    'kafel': Icons.grid_view_rounded,
    'boyoq': Icons.brush_outlined,
    'gipskarton': Icons.dashboard_outlined,
    'payvand': Icons.bolt_outlined,
    'pol': Icons.layers_outlined,
    'quduq': Icons.water_drop_outlined,
    'konditsioner': Icons.ac_unit_rounded,

    'kamera': Icons.videocam_outlined,
    'mardikor': Icons.engineering_outlined,
    'zina': Icons.stairs_outlined,
    'parda': Icons.blinds_outlined,
    'fasad': Icons.apartment_outlined,
    'bruschatka': Icons.view_module_outlined,
    'travertin': Icons.texture_outlined,
    'landshaft': Icons.yard_outlined,
    'asfalt': Icons.add_road_outlined,
    'eshik': Icons.door_front_door_outlined,

    'texnika': Icons.construction_outlined,
    'texnika_ekskavator_zanjirli': Icons.construction_outlined,
    'texnika_ekskavator_gildirakli': Icons.construction_outlined,
    'texnika_mini_ekskavator': Icons.construction_outlined,
    'texnika_jcb': Icons.agriculture_outlined,
    'texnika_transheya': Icons.construction_outlined,
    'texnika_gidromolot': Icons.hardware_outlined,
    'texnika_samosval': Icons.local_shipping_outlined,
    'texnika_manipulyator': Icons.local_shipping_outlined,
    'texnika_tral': Icons.local_shipping_outlined,
    'texnika_suvovoz': Icons.water_drop_outlined,
    'texnika_avtokran': Icons.precision_manufacturing_outlined,
    'texnika_minorali_kran': Icons.precision_manufacturing_outlined,
    'texnika_zanjirli_kran': Icons.precision_manufacturing_outlined,
    'texnika_avtovyshka': Icons.elevator_outlined,
    'texnika_beton_mikser': Icons.local_shipping_outlined,
    'texnika_beton_nasos': Icons.foundation_outlined,
  };

  static const Set<String> _glyphs = {'asfalt'};

  static String? imageOf(String code) => _images[code];

  static IconData iconOf(String code) =>
      _icons[code] ??
      (code.isEmpty ? Icons.window_outlined : Icons.handyman_outlined);

  static bool hasImage(String code) => _images.containsKey(code);

  static Widget thumb(
    BuildContext context, {
    required String code,
    required double size,
    required Color tint,
  }) {
    final image = imageOf(code);
    if (image == null) {
      return Icon(iconOf(code), size: size, color: tint);
    }
    return Image.asset(
      image,
      fit: BoxFit.contain,
      width: size,
      height: size,

      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      color: _glyphs.contains(code) ? tint : null,
    );
  }
}
