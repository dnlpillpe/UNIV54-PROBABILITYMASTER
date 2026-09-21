/// Persistencia local con `shared_preferences`.
///
/// Una sola clave con un JSON. No hay backend, no hay cuenta y no hay red:
/// además de simplificar, permite que CI compile sin credenciales.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/progress.dart';

abstract class ProgressStorage {
  Future<UserProgress> load();
  Future<void> save(UserProgress progress);
  Future<void> clear();
}

class PrefsProgressStorage implements ProgressStorage {
  static const String _key = 'probability_master_progress_v1';

  @override
  Future<UserProgress> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const UserProgress();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const UserProgress();
      return UserProgress.fromJson(
        decoded.map((k, v) => MapEntry('$k', v)),
      );
    } catch (_) {
      // Un progreso corrupto no debe impedir usar la app.
      return const UserProgress();
    }
  }

  @override
  Future<void> save(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(progress.toJson()));
    } catch (_) {
      // Persistencia best-effort: la sesión sigue siendo válida en memoria.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // Ignorado a propósito.
    }
  }
}

/// Implementación en memoria, para pruebas.
class MemoryProgressStorage implements ProgressStorage {
  UserProgress _value = const UserProgress();

  @override
  Future<UserProgress> load() async => _value;

  @override
  Future<void> save(UserProgress progress) async => _value = progress;

  @override
  Future<void> clear() async => _value = const UserProgress();
}
