import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/script/latin_to_cyrillic.dart';

void main() {
  void check(String latin, String cyrillic) =>
      expect(latinToCyrillic(latin), cyrillic, reason: latin);

  test('oddiy so\'zlar', () {
    check('Keyingi', 'Кейинги');
    check('Hammasi', 'Ҳаммаси');
    check('Standart', 'Стандарт');
    check('Premium', 'Премиум');
    check('Odatiy', 'Одатий');
    check('kafel', 'кафел');
    check('qidirish', 'қидириш');
    check('xona', 'хона');
    check('Jami', 'Жами');
  });

  test('o\' va g\' — hamma apostrof turlari', () {
    check('so\'m', 'сўм');
    check('O\'zbekiston', 'Ўзбекистон');
    check('g\'isht', 'ғишт');
    check('qo‘shish', 'қўшиш');
    check('toʻgʻri', 'тўғри');
  });

  test('sh, ch va katta harfli boshlanish', () {
    check('eshik', 'эшик');
    check('Shift', 'Шифт');
    check('Chizma', 'Чизма');
    check('ichki', 'ички');
  });

  test('yo, yu, ya, ye — va yo\' alohida', () {
    check('yangi', 'янги');
    check('yog\'och', 'ёғоч');
    check('Yo\'q', 'Йўқ');
    check('yo\'nalish', 'йўналиш');
    check('yer', 'ер');
    check('yuza', 'юза');
    check('Yana', 'Яна');
  });

  test('e: so\'z boshida э, ichida е', () {
    check('Elektrik', 'Электрик');
    check('Eni', 'Эни');
    check('beton', 'бетон');
    check('shifer', 'шифер');
  });

  test('tutuq belgisi → ъ', () {
    check('ma\'lumot', 'маълумот');
    check('san\'at', 'санъат');
    check('e\'lon', 'эълон');
  });

  test('gap: raqam, belgi va bo\'shliqlar saqlanadi', () {
    check('1-eshik', '1-эшик');
    check('2 ta yuza · 23,04 m²', '2 та юза · 23,04 м²');
    check('Yana eshik qo\'shish', 'Яна эшик қўшиш');
    check(
      'Aniq bilmasangiz taxminan yozing — usta o\'lchovga kelganda '
          'aniqlashtiriladi.',
      'Аниқ билмасангиз тахминан ёзинг — уста ўлчовга келганда '
          'аниқлаштирилади.',
    );
  });

  test('brend, qisqartma va havolalar LOTINDA qoladi', () {
    check('ROSSEN 6000 QVT', 'ROSSEN 6000 QVT');
    check('EKOPEN Life', 'EKOPEN Life');
    check('AKFA radiator', 'AKFA радиатор');
    check('MDF eshik', 'MDF эшик');
    check('Telegram orqali', 'Telegram орқали');
    check('https://ustachi.uz sayti', 'https://ustachi.uz сайти');
    check('info@ustachi.uz ga yozing', 'info@ustachi.uz га ёзинг');
  });

  test('foydalanuvchi aytgan istisnolar (2026-09-26)', () {
    check('Penthaus gidro tom', 'Penthaus гидро том');

    check(
      'Tom gidro izolyatsiya terassa pent haus PVX TPO membrana',
      'Том гидро изоляция терасса пент хаус ПВХ ТПО мембрана',
    );
    check('Alyumin va PVX eshik va rom', 'Алюмин ва ПВХ эшик ва ром');
  });

  test('lotin harfi yo\'q matn o\'zgarmaydi', () {
    check('', '');
    check('1 745 000', '1 745 000');
    check('Кирилл', 'Кирилл');
  });
}
