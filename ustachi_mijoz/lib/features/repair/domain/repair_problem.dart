import 'package:flutter/material.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

/// Ta'mir sahifasidagi bitta band — soha qaysi bo'lishidan qat'i nazar.
class RepairOption {
  const RepairOption(this.code, this.title, this.desc, this.icon);

  final String code;
  final String title;
  final String desc;
  final IconData icon;

  /// "Boshqa muammo" — har sohada oxirgi band; tanlansa izoh majburiy.
  static const otherCode = 'boshqa';
  static const other = RepairOption(
    otherCode,
    'Boshqa muammo',
    'Ro\'yxatda yo\'q — o\'zim yozib beraman',
    Icons.more_horiz_rounded,
  );

  bool get isOther => code == otherCode;
}

/// Sohaning ta'mir bandlari: eshik-romda ilovadagi ro'yxat (ikonkalari
/// bilan), boshqalarda serverdan kelgani; oxirida doim "Boshqa muammo".
List<RepairOption> repairOptionsFor(SpecialtyEntity specialty) {
  if (specialty.isRom) {
    return [for (final p in RepairProblem.values) RepairOption(p.code, p.title, p.desc, p.icon)];
  }
  return [
    for (final p in specialty.repairProblems)
      if (p.code != RepairOption.otherCode) RepairOption(p.code, p.title, p.hint, Icons.build_outlined),
    RepairOption.other,
  ];
}

enum RepairProblem {
  tutqich(
    'tutqich',
    'Tutqich (ruchka)',
    'Singan, bo\'shab qolgan yoki aylanmayapti',
    Icons.pan_tool_alt_outlined,
  ),
  furnitura(
    'furnitura',
    'Furnitura (mexanizm)',
    'Ochilmayapti yoki yopilmayapti, tishlagan',
    Icons.settings_outlined,
  ),
  sozlash(
    'sozlash',
    'Sozlash kerak',
    'Rom pastga oshgan, ishqalanadi, zich yopilmayapti',
    Icons.tune_rounded,
  ),
  oyna(
    'oyna',
    'Oyna singan',
    'Shisha paketni almashtirish kerak',
    Icons.broken_image_outlined,
  ),
  bugOyna(
    'bug_oyna',
    'Oyna ichi terlaydi',
    'Shisha paket ichida bug\' yoki suv yig\'ilgan',
    Icons.water_drop_outlined,
  ),
  rezina(
    'rezina',
    'Rezina (uplotnitel)',
    'Eskirgan — shamol o\'tadi, sovuq kiradi',
    Icons.line_weight_rounded,
  ),
  qulf(
    'qulf',
    'Qulf yoki shpingalet',
    'Kirish eshigida qulf ishlamayapti',
    Icons.lock_outline_rounded,
  ),
  fortochka(
    'fortochka',
    'Fortochka / shamollatish',
    'Tepa fortochka yoki mikroventilyatsiya ishlamayapti',
    Icons.air_rounded,
  ),
  setka(
    'setka',
    'Chivin to\'ri (setka)',
    'Yirtilgan yoki yangisi kerak',
    Icons.grid_4x4_rounded,
  ),
  tokcha(
    'tokcha',
    'Tokcha yoki suv qopqog\'i',
    'Ichki tokcha / tashqi otliv almashtirish',
    Icons.horizontal_rule_rounded,
  ),
  ochiladigan(
    'ochiladigan',
    'Ochiladigan qilish',
    'Qo\'zg\'almas oynani ochiladigan qilib berish',
    Icons.open_in_browser_rounded,
  ),
  boshqa(
    'boshqa',
    'Boshqa muammo',
    'Ro\'yxatda yo\'q — o\'zim yozib beraman',
    Icons.more_horiz_rounded,
  );

  const RepairProblem(this.code, this.title, this.desc, this.icon);

  final String code;
  final String title;
  final String desc;
  final IconData icon;
}

enum RepairMaterial {
  plastik('plastik', 'Plastik'),
  alumin('alumin', 'Alyuminiy'),
  termo('termo', 'Termo'),
  yogoch('yogoch', 'Yog\'och'),
  bilmayman('bilmayman', 'Bilmayman');

  const RepairMaterial(this.code, this.title);

  final String code;
  final String title;
}
