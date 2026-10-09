import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final regex = RegExp(r'^[ \t]*//.*$\n?', multiLine: true);

  for (final file in files) {
    String content = file.readAsStringSync();

    if (content.contains('//')) {
      final newContent = content.replaceAll(regex, '');
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Cleaned: ${file.path}');
      }
    }
  }
}
