library;

import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class MaterialOption {
  const MaterialOption(this.index, this.label, {this.comingSoon = false});

  final int index;
  final String label;

  final bool comingSoon;
}

const materialOptions = [
  MaterialOption(0, 'Plastik'),
  MaterialOption(1, 'Alyuminiy'),
  MaterialOption(2, 'Termo', comingSoon: true),
];

String materialLabel(int material) => materialOptions[material.clamp(0, 2)].label;

hisob.SeriesSpec seriesSpecOf(int material) => switch (material) {
      1 => hisob.SeriesSpec.aldoks,
      2 => hisob.SeriesSpec.termo,
      _ => hisob.SeriesSpec.akfaPlastic,
    };

class FrameColorOption {
  const FrameColorOption(this.name, this.argb);

  final String name;

  final int? argb;
}

const whiteFrameColor = FrameColorOption('Oq', null);

const frameColorOptions = [
  whiteFrameColor,
  FrameColorOption('Antrazit', 0xFF383E42),
  FrameColorOption('Kulrang', 0xFF8A8F94),
  FrameColorOption('Jigarrang', 0xFF5B3A29),
  FrameColorOption('Oltin eman', 0xFFB07B3E),
  FrameColorOption('Yong\'oq', 0xFF6E4A2F),
  FrameColorOption('Qora', 0xFF1E1E1E),
];

String colorDisplay(ItemSettings s) => s.isColored && s.colorName.isNotEmpty ? s.colorName : whiteFrameColor.name;
