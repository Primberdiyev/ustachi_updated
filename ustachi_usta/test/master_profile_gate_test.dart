
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

void main() {
  group('MasterProfileData.isComplete — eshik shu qiymatga qaraydi', () {
    test('yo\'nalish + tajriba bo\'lsa TO\'LIQ', () {
      const profile = MasterProfileData(specialtyId: 1, experienceYears: 5);
      expect(profile.isComplete, isTrue);
    });

    test('tajriba 0 bo\'lsa ham to\'liq (yangi usta — haqiqiy holat)', () {
      const profile = MasterProfileData(specialtyId: 1, experienceYears: 0);
      expect(profile.isComplete, isTrue,
          reason: '0 yil — yaroqli javob, "to\'ldirilmagan" emas');
    });

    test('yo\'nalish yo\'q — TO\'LIQ EMAS', () {
      const profile = MasterProfileData(experienceYears: 5);
      expect(profile.isComplete, isFalse);
    });

    test('tajriba yo\'q — TO\'LIQ EMAS', () {
      const profile = MasterProfileData(specialtyId: 1);
      expect(profile.isComplete, isFalse);
    });

    test('bo\'sh profil — TO\'LIQ EMAS', () {
      expect(const MasterProfileData().isComplete, isFalse);
    });
  });

  group('MasterProfileData.fromJson', () {
    test('serverning to\'liq javobini o\'qiydi', () {
      final profile = MasterProfileData.fromJson(const {
        'specialty': 2,
        'specialty_name': 'Rom ustasi',
        'experience_years': 7,
        'bio': 'tajribali',
        'is_verified': true,
        'accepts_orders': false,
        'work_samples': [
          {'id': 3, 'image': '/media/a.jpg', 'caption': 'Balkon'},
        ],
      });

      expect(profile.specialtyId, 2);
      expect(profile.specialtyName, 'Rom ustasi');
      expect(profile.experienceYears, 7);
      expect(profile.bio, 'tajribali');
      expect(profile.isVerified, isTrue);
      expect(profile.acceptsOrders, isFalse);
      expect(profile.isComplete, isTrue);
      expect(profile.workSamples, hasLength(1));
      expect(profile.workSamples.first.imageUrl, '/media/a.jpg');
      expect(profile.workSamples.first.caption, 'Balkon');
    });

    test('bo\'sh javobda yiqilmaydi va TO\'LIQ EMAS deb hisoblaydi', () {
      final profile = MasterProfileData.fromJson(const {});
      expect(profile.isComplete, isFalse);
      expect(profile.workSamples, isEmpty);
      expect(profile.acceptsOrders, isTrue, reason: 'maydon yo\'q → default');
    });

    test('accepts_orders maydoni yo\'q bo\'lsa DEFAULT true', () {
      final profile = MasterProfileData.fromJson(const {
        'specialty': 1,
        'experience_years': 3,
      });
      expect(profile.acceptsOrders, isTrue);
      expect(profile.isComplete, isTrue);
    });
  });

  group('MasterWorkSample', () {
    test('rasm va izohni o\'qiydi', () {
      final sample = MasterWorkSample.fromJson(const {
        'id': 9,
        'image': '/media/w.jpg',
      });
      expect(sample.id, 9);
      expect(sample.imageUrl, '/media/w.jpg');
      expect(sample.caption, isEmpty);
    });
  });

  group('MasterSpecialty', () {
    test('katalog elementini o\'qiydi', () {
      final specialty = MasterSpecialty.fromJson(const {
        'id': 1,
        'name': 'Rom ustasi',
      });
      expect(specialty.id, 1);
      expect(specialty.name, 'Rom ustasi');
    });
  });
}
