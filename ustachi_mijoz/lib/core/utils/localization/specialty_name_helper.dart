import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

String localizedSpecialtyName(BuildContext context, String code, String defaultName) {
  if (LocaleSettings.currentLocale == AppLocale.uz) return defaultName;
  final codeLower = code.toLowerCase();
  final nameLower = defaultName.toLowerCase();

  if (codeLower == 'rom' || nameLower.contains('rom') || nameLower.contains('окна')) return 'Окна и двери';
  if (codeLower == 'mebel' || nameLower.contains('mebel') || nameLower.contains('мебель')) return 'Мебель';
  if (codeLower == 'elektrik' || nameLower.contains('elektrik') || nameLower.contains('электр')) return 'Электрика';
  if (codeLower == 'santexnik' || nameLower.contains('santexn') || nameLower.contains('сантех')) return 'Сантехника';
  if (codeLower == 'tom' || nameLower.contains('tom') || nameLower.contains('крыша')) return 'Крыша';
  if (codeLower == 'beton' || nameLower.contains('beton') || nameLower.contains('бетон')) return 'Бетон';
  if (codeLower == 'darvoza' || nameLower.contains('darvoza') || nameLower.contains('ворот')) return 'Ворота';
  if (codeLower == 'gisht' || nameLower.contains('gisht') || nameLower.contains('g\'isht') || nameLower.contains('кирпич')) return 'Кирпич';
  if (codeLower == 'asfalt' || nameLower.contains('asfalt') || nameLower.contains('асфальт')) return 'Асфальт';
  if (codeLower == 'eshik' || nameLower.contains('eshik') || nameLower.contains('двер')) return 'Двери';
  if (codeLower == 'suvoq' || nameLower.contains('suvoq') || nameLower.contains('штукатур')) return 'Штукатурка';
  if (codeLower == 'kafel' || nameLower.contains('kafel') || nameLower.contains('плитк')) return 'Плитка';
  if (codeLower == 'boyoq' || nameLower.contains('boyoq') || nameLower.contains('bo\'yoq') || nameLower.contains('маляр') || nameLower.contains('покрас')) return 'Покраска';
  if (codeLower == 'gipskarton' || nameLower.contains('gipskarton') || nameLower.contains('гипсокартон')) return 'Гипсокартон';
  if (codeLower == 'payvand' || nameLower.contains('payvand') || nameLower.contains('сварк')) return 'Сварка';
  if (codeLower == 'pol' || nameLower.contains('pol') || nameLower.contains('пол')) return 'Пол';
  if (codeLower == 'quduq' || nameLower.contains('quduq') || nameLower.contains('колодец')) return 'Колодец';
  if (codeLower == 'konditsioner' || nameLower.contains('konditsioner') || nameLower.contains('кондиционер')) return 'Кондиционеры';
  if (codeLower == 'mardikor' || nameLower.contains('mardikor') || nameLower.contains('разнорабоч')) return 'Разнорабочий';
  if (codeLower == 'zina' || nameLower.contains('zina') || nameLower.contains('лестни')) return 'Лестницы';
  if (codeLower == 'parda' || nameLower.contains('parda') || nameLower.contains('штор')) return 'Шторы';
  if (codeLower == 'fasad' || nameLower.contains('fasad') || nameLower.contains('фасад')) return 'Фасад';
  if (codeLower == 'bruschatka' || nameLower.contains('bruschatka') || nameLower.contains('брусчатк')) return 'Брусчатка';
  if (codeLower == 'travertin' || nameLower.contains('travertin') || nameLower.contains('травертин')) return 'Травертин';
  if (codeLower == 'landshaft' || nameLower.contains('landshaft') || nameLower.contains('ландшафт')) return 'Ландшафт';

  return defaultName;
}

String localizedSpecialtyWorkName(BuildContext context, String code, String defaultWorkName) {
  if (LocaleSettings.currentLocale == AppLocale.uz) return defaultWorkName;
  final codeLower = code.toLowerCase();
  final nameLower = defaultWorkName.toLowerCase();

  if (codeLower == 'rom' || nameLower.contains('rom') || nameLower.contains('окна')) return 'Окна';
  if (codeLower == 'mebel' || nameLower.contains('mebel') || nameLower.contains('мебель')) return 'Мебель';
  if (codeLower == 'elektrik' || nameLower.contains('elektrik') || nameLower.contains('электр')) return 'Электрика';
  if (codeLower == 'santexnik' || nameLower.contains('santexn') || nameLower.contains('сантех')) return 'Сантехника';
  if (codeLower == 'tom' || nameLower.contains('tom') || nameLower.contains('крыша')) return 'Крыша';
  if (codeLower == 'beton' || nameLower.contains('beton') || nameLower.contains('бетон')) return 'Бетон';
  if (codeLower == 'darvoza' || nameLower.contains('darvoza') || nameLower.contains('ворот')) return 'Ворота';
  if (codeLower == 'gisht' || nameLower.contains('gisht') || nameLower.contains('g\'isht') || nameLower.contains('кирпич')) return 'Кирпич';
  if (codeLower == 'asfalt' || nameLower.contains('asfalt') || nameLower.contains('асфальт')) return 'Асфальт';
  if (codeLower == 'eshik' || nameLower.contains('eshik') || nameLower.contains('двер')) return 'Двери';
  if (codeLower == 'suvoq' || nameLower.contains('suvoq') || nameLower.contains('штукатур')) return 'Штукатурка';
  if (codeLower == 'kafel' || nameLower.contains('kafel') || nameLower.contains('плитк')) return 'Плитка';
  if (codeLower == 'boyoq' || nameLower.contains('boyoq') || nameLower.contains('bo\'yoq') || nameLower.contains('покрас')) return 'Покраска';
  if (codeLower == 'gipskarton' || nameLower.contains('gipskarton') || nameLower.contains('гипсокартон')) return 'Гипсокартон';
  if (codeLower == 'payvand' || nameLower.contains('payvand') || nameLower.contains('сварк')) return 'Сварка';
  if (codeLower == 'pol' || nameLower.contains('pol') || nameLower.contains('пол')) return 'Пол';
  if (codeLower == 'quduq' || nameLower.contains('quduq') || nameLower.contains('колодец')) return 'Колодец';
  if (codeLower == 'konditsioner' || nameLower.contains('konditsioner') || nameLower.contains('кондиционер')) return 'Кондиционеры';
  if (codeLower == 'mardikor' || nameLower.contains('mardikor') || nameLower.contains('разнорабоч')) return 'Разнорабочий';
  if (codeLower == 'zina' || nameLower.contains('zina') || nameLower.contains('лестни')) return 'Лестницы';
  if (codeLower == 'parda' || nameLower.contains('parda') || nameLower.contains('штор')) return 'Шторы';
  if (codeLower == 'fasad' || nameLower.contains('fasad') || nameLower.contains('фасад')) return 'Фасад';
  if (codeLower == 'bruschatka' || nameLower.contains('bruschatka') || nameLower.contains('брусчатк')) return 'Брусчатка';
  if (codeLower == 'travertin' || nameLower.contains('travertin') || nameLower.contains('травертин')) return 'Травертин';
  if (codeLower == 'landshaft' || nameLower.contains('landshaft') || nameLower.contains('ландшафт')) return 'Ландшафт';

  return defaultWorkName;
}

String localizedMasterSpecialties(
    BuildContext context, List<SpecialtyEntity> specialties, String? fallback) {
  if (specialties.isEmpty) {
    return fallback == null
        ? context.t.masters.noSpecialty
        : localizedSpecialtyName(context, '', fallback);
  }
  return specialties
      .map((s) => localizedSpecialtyName(context, s.code, s.name))
      .join(' · ');
}

String localizedMasterRate(BuildContext context, MasterRateEntity rate) {
  final name = localizedSpecialtyName(context, rate.code, rate.name);
  return rate.variantName == null ? name : '$name — ${rate.variantName}';
}
