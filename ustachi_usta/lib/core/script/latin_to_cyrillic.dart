
String latinToCyrillic(String input) {
  if (input.isEmpty || !_hasLatin.hasMatch(input)) return input;

  final out = StringBuffer();

  for (final chunk in input.split(_spaceKeep)) {
    if (_isLink(chunk)) {
      out.write(chunk);
    } else {
      out.write(chunk.replaceAllMapped(_word, (m) => _convertWord(m[0]!)));
    }
  }
  return out.toString();
}

final _hasLatin = RegExp('[A-Za-z]');

final _spaceKeep = RegExp(r'(?<=\s)|(?=\s)');

final _word = RegExp("[A-Za-z]+(?:['‘’ʻʼ`][A-Za-z]+)*['‘’ʻʼ`]?");

bool _isLink(String chunk) =>
    chunk.contains('://') || chunk.contains('www.') || chunk.contains('@');

const Set<String> _keepLatin = {

  'penthaus',
  'life',
  'telegram',
  'instagram',
  'google',
  'apple',
  'click',
  'payme',
  'uzum',
  'android',
  'ios',
};

const Map<String, String> _fixedCyrillic = {
  'PVX': 'ПВХ',

  'TPO': 'ТПО',
  'HAUS': 'хаус',
  'IZOLYATSIYA': 'изоляция',
};

const _apostrophes = "'‘’ʻʼ`";

String _convertWord(String word) {
  final letters = word.replaceAll(RegExp("[$_apostrophes]"), '');
  final fixed = _fixedCyrillic[letters.toUpperCase()];
  if (fixed != null) return fixed;
  if (_keepLatin.contains(letters.toLowerCase())) return word;

  if (letters.length >= 2 && letters == letters.toUpperCase()) return word;

  if (RegExp('.[A-Z]').hasMatch(letters)) return word;

  final out = StringBuffer();
  var i = 0;

  var afterVowelOrStart = true;

  while (i < word.length) {
    final c = word[i];
    final lower = c.toLowerCase();
    final upper = c != lower;
    final next = i + 1 < word.length ? word[i + 1] : '';
    final nextLower = next.toLowerCase();
    final nextIsApostrophe = next.isNotEmpty && _apostrophes.contains(next);

    String emit(String cyr) => upper ? cyr.toUpperCase() : cyr;

    if (_apostrophes.contains(c)) {

      out.write(i < word.length - 1 ? 'ъ' : c);
      i++;
      afterVowelOrStart = false;
      continue;
    }

    if ((lower == 'o' || lower == 'g') && nextIsApostrophe) {
      out.write(emit(lower == 'o' ? 'ў' : 'ғ'));
      i += 2;
      afterVowelOrStart = lower == 'o';
      continue;
    }

    if ((lower == 's' || lower == 'c') && nextLower == 'h') {
      out.write(emit(lower == 's' ? 'ш' : 'ч'));
      i += 2;
      afterVowelOrStart = false;
      continue;
    }

    if (lower == 'y' && 'ouae'.contains(nextLower) && nextLower.isNotEmpty) {
      final afterNext = i + 2 < word.length ? word[i + 2] : '';
      final isOApostrophe =
          nextLower == 'o' && afterNext.isNotEmpty && _apostrophes.contains(afterNext);
      if (!isOApostrophe) {
        out.write(emit(const {'o': 'ё', 'u': 'ю', 'a': 'я', 'e': 'е'}[nextLower]!));
        i += 2;
        afterVowelOrStart = true;
        continue;
      }
    }

    if (lower == 'e') {
      out.write(emit(afterVowelOrStart ? 'э' : 'е'));
      i++;
      afterVowelOrStart = true;
      continue;
    }

    final single = _single[lower];
    out.write(single == null ? c : emit(single));
    afterVowelOrStart = 'aiou'.contains(lower);
    i++;
  }
  return out.toString();
}

const Map<String, String> _single = {
  'a': 'а',
  'b': 'б',
  'c': 'ц',
  'd': 'д',
  'f': 'ф',
  'g': 'г',
  'h': 'ҳ',
  'i': 'и',
  'j': 'ж',
  'k': 'к',
  'l': 'л',
  'm': 'м',
  'n': 'н',
  'o': 'о',
  'p': 'п',
  'q': 'қ',
  'r': 'р',
  's': 'с',
  't': 'т',
  'u': 'у',
  'v': 'в',
  'w': 'в',
  'x': 'х',
  'y': 'й',
  'z': 'з',
};
