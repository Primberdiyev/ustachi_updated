import 'package:flutter/widgets.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/script/latin_to_cyrillic.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';

enum UzScript {

  latin('Lotin', 'O\'zbekcha'),
  cyrillic('Кирилл', 'Ўзбекча');

  const UzScript(this.label, this.sample);

  final String label;
  final String sample;
}

class ScriptProvider extends ChangeNotifier {
  factory ScriptProvider() => _instance;
  ScriptProvider._internal();
  static final ScriptProvider _instance = ScriptProvider._internal();

  UzScript _script = UzScript.latin;
  UzScript get script => _script;

  bool get isChosen => StorageRepository.getString(StoreKeys.uzScript).isNotEmpty;

  void load() {
    final saved = StorageRepository.getString(StoreKeys.uzScript);
    _script = UzScript.values.firstWhere(
      (s) => s.name == saved,
      orElse: () => UzScript.latin,
    );

    final language = StorageRepository.getString(StoreKeys.language);
    if (language.isNotEmpty && language != 'uz') _script = UzScript.latin;
  }

  void setScript(UzScript script) {
    StorageRepository.putString(StoreKeys.uzScript, script.name);
    if (_script == script) return;
    _script = script;
    notifyListeners();
  }
}

String uz(String latin) =>
    ScriptProvider().script == UzScript.cyrillic ? latinToCyrillic(latin) : latin;

void rebuildAllWidgets(BuildContext context) {
  void mark(Element e) {
    e.markNeedsBuild();

    if (e is RenderObjectElement) e.renderObject.markNeedsPaint();
    e.visitChildren(mark);
  }

  (context as Element).visitChildren(mark);
}
