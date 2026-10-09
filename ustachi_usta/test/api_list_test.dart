
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/api_list.dart';
import 'package:ustachi/features/marketplace/data/models/chat_model.dart';
import 'package:ustachi/features/marketplace/data/models/master_card_model.dart';
import 'package:ustachi/features/marketplace/data/models/order_model.dart';
import 'package:ustachi/features/orders/data/models/own_order_model.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

void main() {
  group('apiList — ikkala javob shakli', () {
    test('oddiy massiv o\'zi qaytadi', () {
      expect(apiList([1, 2, 3]), [1, 2, 3]);
    });

    test('SAHIFALANGAN javobdan `results` olinadi', () {
      expect(
        apiList(const {
          'count': 2,
          'next': null,
          'previous': null,
          'results': [1, 2],
        }),
        [1, 2],
      );
    });

    test('kutilmagan shakl — BO\'SH ro\'yxat, xato EMAS', () {

      expect(apiList(null), isEmpty);
      expect(apiList('axlat'), isEmpty);
      expect(apiList(const {'detail': 'Topilmadi'}), isEmpty);
      expect(apiList(const {'results': 'massiv emas'}), isEmpty);
    });
  });

  group('Parserlar sahifalangan javobda YIQILMAYDI', () {

    void bothShapes<T>(
      String name,
      List<dynamic> items,
      List<T> Function(dynamic) parse,
    ) {
      test(name, () {
        final plain = parse(items);
        final paged = parse({'count': items.length, 'results': items});

        expect(paged.length, plain.length);
        expect(plain, isNotEmpty, reason: 'fikstura bo\'sh bo\'lmasin');
      });
    }

    bothShapes<MasterSpecialty>(
      'yo\'nalishlar (Ish namunalari ekrani shu yerda yiqilgan edi)',
      [
        {'id': 1, 'name': 'Rom ustasi'},
      ],
      (data) => apiList(data)
          .whereType<Map>()
          .map((e) => MasterSpecialty.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    bothShapes(
      'ustalar ro\'yxati',
      [
        {'id': 1, 'full_name': 'Usta', 'phone_number': '+998901112233'},
      ],
      MasterCardModel.listFrom,
    );

    bothShapes(
      'marketplace buyurtmalari',
      [
        {'id': 1, 'title': 'Deraza'},
      ],
      OrderModel.listFrom,
    );

    bothShapes(
      'chat suhbatlari',
      [
        {'id': 1, 'order': 2},
      ],
      ChatThreadModel.listFrom,
    );

    bothShapes(
      'ustaning o\'z buyurtmalari',
      [
        {'id': 1, 'customer_name': 'Aziz aka'},
      ],
      OwnOrderModel.listFrom,
    );
  });

  group('Profil javobi', () {
    test('ish namunalari SAHIFALANGAN bo\'lsa ham o\'qiladi', () {
      final profile = MasterProfileData.fromJson(const {
        'specialty': 1,
        'experience_years': 5,
        'work_samples': {
          'count': 1,
          'results': [
            {'id': 3, 'image': '/media/a.jpg', 'caption': 'Balkon'},
          ],
        },
      });

      expect(profile.workSamples, hasLength(1));
      expect(profile.workSamples.single.caption, 'Balkon');
    });

    test('oddiy massiv ham o\'qiladi (eski shakl)', () {
      final profile = MasterProfileData.fromJson(const {
        'specialty': 1,
        'experience_years': 5,
        'work_samples': [
          {'id': 3, 'image': '/media/a.jpg', 'caption': 'Balkon'},
        ],
      });

      expect(profile.workSamples, hasLength(1));
    });

    test('maydon umuman bo\'lmasa — bo\'sh', () {
      final profile = MasterProfileData.fromJson(const {'specialty': 1});
      expect(profile.workSamples, isEmpty);
    });
  });
}
