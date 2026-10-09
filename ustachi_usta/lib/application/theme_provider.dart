import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();

  factory ThemeProvider() {
    return _instance;
  }

  ThemeProvider._internal();

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  void loadThemeMode() {
    final mode = StorageRepository.getString(StoreKeys.themeMode,
        defValue: ThemeMode.light.name);
    if (mode == 'light') {
      _mode = ThemeMode.light;
    } else if (mode == 'dark') {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _mode = mode;
    StorageRepository.putString(StoreKeys.themeMode, mode.name);
    notifyListeners();
  }
}
