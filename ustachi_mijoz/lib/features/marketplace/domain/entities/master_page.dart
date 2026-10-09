import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';

class MasterPage {
  const MasterPage({required this.items, this.nextPage});
  final List<MasterCardEntity> items;
  final int? nextPage;
}
