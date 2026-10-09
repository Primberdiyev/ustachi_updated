import 'package:ustachi/features/marketplace/data/models/master_card_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_page.dart';

class MasterPageModel {
  static MasterPage fromJson(dynamic data) {

    if (data is List) return MasterPage(items: MasterCardModel.listFrom(data));
    if (data is! Map || data['results'] is! List) {
      throw const FormatException('Invalid masters page');
    }
    final next = data['next_page'];
    if (next != null && (next is! int || next < 1)) {
      throw const FormatException('Invalid next masters page');
    }
    return MasterPage(
        items: MasterCardModel.listFrom(data['results']),
        nextPage: next as int?);
  }
}
