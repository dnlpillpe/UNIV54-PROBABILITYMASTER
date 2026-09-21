/// Diagnóstico de confusiones (decisión D3).
///
/// Regla: +1 por error que activa la confusión, −0,5 por acierto posterior en
/// un ítem capaz de detectarla, y decaimiento del 3 % por evento registrado,
/// para que una confusión superada desaparezca sola en vez de perseguir al
/// estudiante para siempre.
library;

import '../models/misconception.dart';
import '../models/progress.dart';

/// Confusión activa con su intensidad.
class ActiveMisconception {
  final Misconception misconception;
  final double score;

  const ActiveMisconception(this.misconception, this.score);

  /// 1 = leve, 2 = marcada, 3 = persistente.
  int get level => score >= 3.0 ? 3 : (score >= 1.8 ? 2 : 1);

  String get levelLabel {
    switch (level) {
      case 3:
        return 'Persistente';
      case 2:
        return 'Marcada';
      default:
        return 'Leve';
    }
  }
}

class DiagnosisService {
  /// Umbral por debajo del cual una confusión deja de reportarse.
  static const double activeThreshold = 0.8;

  static const double _decay = 0.97;
  static const double _hitWeight = 1.0;
  static const double _detectedCorrectWeight = -0.5;

  final List<Misconception> catalog;

  const DiagnosisService(this.catalog);

  /// Aplica un intento al mapa de puntajes y devuelve el mapa nuevo.
  Map<String, double> apply(
    Map<String, double> current,
    AttemptRecord attempt,
  ) {
    final next = <String, double>{};
    // Decaimiento global por evento.
    current.forEach((k, v) {
      final d = v * _decay;
      if (d.abs() > 0.01) next[k] = d;
    });

    for (final id in attempt.misconceptionsHit) {
      next[id] = (next[id] ?? 0) + _hitWeight;
    }
    if (attempt.choiceCorrect) {
      for (final id in attempt.detects) {
        if (attempt.misconceptionsHit.contains(id)) continue;
        final v = (next[id] ?? 0) + _detectedCorrectWeight;
        if (v <= 0.01) {
          next.remove(id);
        } else {
          next[id] = v;
        }
      }
    }
    return next;
  }

  /// Confusiones activas, ordenadas de mayor a menor intensidad.
  List<ActiveMisconception> active(Map<String, double> scores, {int? limit}) {
    final byId = {for (final m in catalog) m.id: m};
    final list = <ActiveMisconception>[];
    scores.forEach((id, score) {
      final m = byId[id];
      if (m != null && score >= activeThreshold) {
        list.add(ActiveMisconception(m, score));
      }
    });
    list.sort((a, b) => b.score.compareTo(a.score));
    if (limit != null && list.length > limit) {
      return list.sublist(0, limit);
    }
    return list;
  }

  /// Confusiones superadas: aparecieron alguna vez en el historial y hoy
  /// están por debajo del umbral.
  List<Misconception> overcome(
    Map<String, double> scores,
    List<AttemptRecord> history,
  ) {
    final seen = <String>{};
    for (final a in history) {
      seen.addAll(a.misconceptionsHit);
    }
    final byId = {for (final m in catalog) m.id: m};
    final out = <Misconception>[];
    for (final id in seen) {
      final s = scores[id] ?? 0;
      if (s < activeThreshold && byId.containsKey(id)) {
        out.add(byId[id]!);
      }
    }
    return out;
  }

  /// Agrupa las confusiones activas por familia, para el informe.
  Map<MisconceptionFamily, List<ActiveMisconception>> byFamily(
      List<ActiveMisconception> list) {
    final map = <MisconceptionFamily, List<ActiveMisconception>>{};
    for (final a in list) {
      map.putIfAbsent(a.misconception.family, () => []).add(a);
    }
    return map;
  }
}
