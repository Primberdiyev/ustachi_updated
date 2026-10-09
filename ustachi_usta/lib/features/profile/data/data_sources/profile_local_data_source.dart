import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';

class ProfileLocalDataSource {
  static const _key = 'cached_user_profile';

  Future<void> cache(UserModel user) async {
    try {
      await StorageRepository.putString(_key, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('[profil] kesh yozilmadi: $e');
    }
  }

  UserModel? getCached() {
    final raw = StorageRepository.getString(_key);
    if (raw.isEmpty) return null;
    try {
      return UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (e) {
      debugPrint('[profil] kesh o\'qilmadi: $e');
      return null;
    }
  }

  Future<void> clear() => StorageRepository.deleteString(_key);
}
