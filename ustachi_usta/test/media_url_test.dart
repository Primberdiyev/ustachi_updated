
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/core/api/media_url.dart';

void main() {
  group('mediaUrl', () {
    test('NISBIY yo\'l API hostiga ulanadi', () {
      expect(
        mediaUrl('/media/users/photos/image_picker_F68587F5.jpg'),
        '${ApiUrls.baseUrl}/media/users/photos/image_picker_F68587F5.jpg',
      );
    });

    test('bosh chizig\'i yo\'q yo\'l ham ishlaydi', () {
      expect(mediaUrl('media/a.jpg'), '${ApiUrls.baseUrl}/media/a.jpg');
    });

    test('TO\'LIQ URL o\'zgarmaydi (ikki marta host qo\'shilmaydi)', () {
      const url = 'https://ustachi.uz/media/a.jpg';
      expect(mediaUrl(url), url);
      expect(mediaUrl('http://127.0.0.1:8000/media/a.jpg'),
          'http://127.0.0.1:8000/media/a.jpg');
    });

    test('bo\'sh/null → null (chaqiruvchi harf-avatar ko\'rsatadi)', () {
      expect(mediaUrl(null), isNull);
      expect(mediaUrl(''), isNull);
      expect(mediaUrl('   '), isNull);
    });

    test('bo\'shliqlar tozalanadi', () {
      expect(mediaUrl('  /media/a.jpg  '), '${ApiUrls.baseUrl}/media/a.jpg');
    });
  });
}
