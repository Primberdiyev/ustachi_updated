import 'package:flutter/material.dart';
import 'package:ustachi/features/home/presentation/view/all_specialties_page.dart';
import 'package:ustachi/features/home/presentation/widgets/specialty_flow.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

abstract final class SpecialtyGroups {

  static const SpecialtyEntity texnika = SpecialtyEntity(
    id: -1,
    code: SpecialtyEntity.texnikaGroup,
    name: 'Polvon texnika',
  );

  static bool isGroup(SpecialtyEntity s) => s.id < 0 && s.code == texnika.code;

  static List<SpecialtyEntity> texnikaOf(List<SpecialtyEntity> all) => [
        for (final s in all)
          if (s.isTexnika) s
      ];

  static List<SpecialtyEntity> collapse(List<SpecialtyEntity> all) {
    final out = <SpecialtyEntity>[];
    var added = false;
    for (final s in all) {
      if (!s.isTexnika) {
        out.add(s);
      } else if (!added) {
        out.add(texnika);
        added = true;
      }
    }
    return out;
  }

  static Future<void> open(
    BuildContext context,
    SpecialtyEntity specialty,
    List<SpecialtyEntity> all,
  ) {
    if (!isGroup(specialty)) return openSpecialtyFlow(context, specialty);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AllSpecialtiesPage(
          specialties: texnikaOf(all),
          title: texnika.name,
          searchHint: 'Qidirish: ekskavator, kran, samosval…',
        ),
      ),
    );
  }
}
