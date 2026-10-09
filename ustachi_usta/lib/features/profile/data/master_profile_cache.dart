import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

class MasterProfileCache {
  static const _key = 'cached_master_profile';

  Future<void> save(Map<String, dynamic> raw) async {
    try {
      await StorageRepository.putString(_key, jsonEncode(raw));
    } catch (e) {
      debugPrint('[kasbiy profil] kesh yozilmadi: $e');
    }
  }

  MasterProfileData? read() {
    final raw = StorageRepository.getString(_key);
    if (raw.isEmpty) return null;
    try {
      return MasterProfileData.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (e) {
      debugPrint('[kasbiy profil] kesh o\'qilmadi: $e');
      return null;
    }
  }

  Future<void> clear() => StorageRepository.deleteString(_key);
}
