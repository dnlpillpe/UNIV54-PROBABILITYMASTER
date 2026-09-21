/// Cálculo de dominio por módulo (decisión D4).
library;

import '../models/exercise.dart';
import '../models/experiment.dart';
import '../models/lesson.dart';
import '../models/progress.dart';

class MasteryService {
  const MasteryService();

  /// 15 % lecciones + 15 % laboratorios + 70 % práctica.
  /// La práctica promedia el **mejor intento** de cada ítem del módulo, sobre
  /// el total de ítems del módulo (no sobre los intentados): así el dominio
  /// no se infla respondiendo solo tres ejercicios fáciles.
  ModuleMastery compute({
    required String moduleId,
    required UserProgress progress,
    required List<Lesson> lessons,
    required List<Experiment> experiments,
    required List<Exercise> exercises,
    required int caseCount,
    required List<String> caseIds,
  }) {
    final moduleLessons = lessons.where((l) => l.moduleId == moduleId).toList();
    final lessonPart = moduleLessons.isEmpty
        ? 1.0
        : moduleLessons
                .where((l) => progress.completedLessons.contains(l.id))
                .length /
            moduleLessons.length;

    final labPart = experiments.isEmpty
        ? 1.0
        : experiments
                .where((e) => progress.experiments.containsKey(e.id))
                .length /
            experiments.length;

    final items = <String>[
      ...exercises.where((e) => e.moduleId == moduleId).map((e) => e.id),
      ...caseIds,
    ];
    double practicePart;
    if (items.isEmpty) {
      practicePart = 1.0;
    } else {
      var acc = 0.0;
      for (final id in items) {
        acc += progress.bestAttempts[id]?.score ?? 0.0;
      }
      practicePart = acc / items.length;
    }

    return ModuleMastery(
      moduleId: moduleId,
      lessonPart: lessonPart.clamp(0.0, 1.0),
      labPart: labPart.clamp(0.0, 1.0),
      practicePart: practicePart.clamp(0.0, 1.0),
    );
  }

  /// Dominio global: promedio simple de los módulos, porque los cuatro pesan
  /// igual en la competencia declarada.
  double overall(List<ModuleMastery> masteries) {
    if (masteries.isEmpty) return 0;
    var acc = 0.0;
    for (final m in masteries) {
      acc += m.total;
    }
    return acc / masteries.length;
  }
}
