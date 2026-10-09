import 'package:flutter/material.dart';

IconData specialtyIcon(String? code) {
  return switch (code) {
    'rom' => Icons.window_outlined,
    'tom' => Icons.roofing_outlined,
    'gisht' => Icons.dashboard_customize_outlined,
    'suvoq' => Icons.format_paint_outlined,
    'beton' => Icons.foundation_outlined,
    'elektrik' => Icons.electrical_services_outlined,
    'santexnik' => Icons.plumbing_outlined,
    'kafel' => Icons.grid_view_rounded,
    'boyoq' => Icons.brush_outlined,
    'gipskarton' => Icons.dashboard_outlined,
    'mebel' => Icons.chair_outlined,
    'darvoza' => Icons.fence_outlined,
    'payvand' => Icons.bolt_outlined,
    'pol' => Icons.layers_outlined,
    'quduq' => Icons.water_drop_outlined,
    'konditsioner' => Icons.ac_unit_rounded,
    'kamera' => Icons.videocam_outlined,
    'mardikor' => Icons.engineering_outlined,
    'zina' => Icons.stairs_outlined,
    'parda' => Icons.blinds_outlined,
    'fasad' => Icons.apartment_outlined,
    'bruschatka' => Icons.view_module_outlined,
    'travertin' => Icons.texture_outlined,
    'landshaft' => Icons.yard_outlined,
    'asfalt' => Icons.add_road_outlined,
    null || '' => Icons.window_outlined,
    _ => Icons.handyman_outlined,
  };
}
