
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ustachi/core/constants/store_keys.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class HisobStore extends ChangeNotifier {
  List<HisobProject> _projects = const [];

  List<HisobProject> get projects => _projects;

  HisobProject? byId(String id) {
    for (final p in _projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Map<HisobKind, List<hisob.FrameDesign>> _templates = const {};

  List<hisob.FrameDesign> templatesOf(HisobKind kind) => _templates[kind] ?? const [];

  void saveTemplate(HisobKind kind, hisob.FrameDesign design) {
    _templates = {..._templates, kind: [design, ...templatesOf(kind)]};
    _persistTemplates();
    notifyListeners();
  }

  void removeTemplate(HisobKind kind, hisob.FrameDesign design) {
    _templates = {..._templates, kind: [for (final d in templatesOf(kind)) if (!identical(d, design)) d]};
    _persistTemplates();
    notifyListeners();
  }

  void _persistTemplates() {
    StorageRepository.putString(
      StoreKeys.hisobTemplates,
      jsonEncode({
        for (final e in _templates.entries) e.key.name: [for (final d in e.value) hisob.designToJson(d)],
      }),
    );
  }

  void _restoreTemplates() {
    final raw = StorageRepository.getString(StoreKeys.hisobTemplates);
    if (raw.isEmpty) return;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final out = <HisobKind, List<hisob.FrameDesign>>{};
      for (final kind in HisobKind.values) {
        final list = map[kind.name];
        if (list is! List) continue;
        final designs = <hisob.FrameDesign>[];
        for (final entry in list) {
          try {
            designs.add(hisob.designFromJson(Map<String, dynamic>.from(entry as Map)));
          } catch (_) {

          }
        }
        out[kind] = designs;
      }
      _templates = out;
    } catch (_) {
      _templates = const {};
    }
  }

  void restore() {
    _restoreTemplates();
    final raw = StorageRepository.getString(StoreKeys.hisobProjects);
    if (raw.isEmpty) {
      notifyListeners();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      final out = <HisobProject>[];
      for (final entry in list) {
        try {
          out.add(HisobProject.fromJson(Map<String, dynamic>.from(entry as Map)));
        } catch (_) {

        }
      }
      _projects = _sorted(out);
      notifyListeners();
    } catch (_) {
      _projects = const [];
    }
  }

  static List<HisobProject> _sorted(List<HisobProject> list) =>
      [...list]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  void save(HisobProject project) {
    final exists = _projects.any((p) => p.id == project.id);
    _projects = _sorted(
      exists ? [for (final p in _projects) p.id == project.id ? project : p] : [..._projects, project],
    );
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _projects = _projects.where((p) => p.id != id).toList();
    _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _projects = const [];
    await StorageRepository.putString(StoreKeys.hisobProjects, '');
    notifyListeners();
  }

  void _persist() {
    StorageRepository.putString(
      StoreKeys.hisobProjects,
      jsonEncode([for (final p in _projects) p.toJson()]),
    );
  }
}
