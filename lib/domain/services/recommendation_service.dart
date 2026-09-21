/// Qué hacer ahora: una sola recomendación, con motivo.
///
/// Prioridad, en orden estricto:
/// 1. Confusión activa persistente → su remedio enlazado.
/// 2. Laboratorio del módulo actual sin hacer (la simulación va antes que
///    el texto, por diseño).
/// 3. Lección pendiente del módulo en curso.
/// 4. Práctica del módulo donde el dominio de práctica está por debajo de 0,70.
/// 5. Caso profesional de la carrera elegida.
/// 6. Repaso del módulo más flojo.
library;

import '../models/exercise.dart';
import '../models/experiment.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import 'diagnosis_service.dart';

enum RecommendationKind { experimento, leccion, practica, caso, repaso, listo }

class Recommendation {
  final RecommendationKind kind;
  final String targetId;
  final String moduleId;
  final String title;

  /// Por qué esto y no otra cosa. Nunca se recomienda sin decir el motivo.
  final String reason;

  const Recommendation({
    required this.kind,
    required this.targetId,
    required this.moduleId,
    required this.title,
    required this.reason,
  });
}

class RecommendationService {
  const RecommendationService();

  Recommendation next({
    required UserProgress progress,
    required List<ActiveMisconception> active,
    required List<Lesson> lessons,
    required List<Experiment> experiments,
    required List<Exercise> exercises,
    required Map<String, double> practiceByModule,
    required List<String> moduleOrder,
  }) {
    // 1 — confusión persistente con remedio enlazado
    for (final a in active) {
      if (a.level < 2) continue;
      final expId = a.misconception.remedyExperimentId;
      if (expId != null && experiments.any((e) => e.id == expId)) {
        final exp = experiments.firstWhere((e) => e.id == expId);
        return Recommendation(
          kind: RecommendationKind.experimento,
          targetId: expId,
          moduleId: _moduleOfExperiment(exp, experiments, moduleOrder),
          title: exp.title,
          reason: 'Tienes activa la confusión «${a.misconception.name}» '
              '(${a.levelLabel.toLowerCase()}). Este experimento la contradice '
              'con tus propios datos.',
        );
      }
      final lessonId = a.misconception.remedyLessonId;
      if (lessonId != null && lessons.any((l) => l.id == lessonId)) {
        final l = lessons.firstWhere((x) => x.id == lessonId);
        return Recommendation(
          kind: RecommendationKind.leccion,
          targetId: l.id,
          moduleId: l.moduleId,
          title: l.title,
          reason: 'Repasa esto: explica directamente lo que estás confundiendo '
              '(${a.misconception.name}).',
        );
      }
    }

    // 2 a 5 — avance ordenado por módulo
    for (final moduleId in moduleOrder) {
      final moduleExperiments =
          experiments.where((e) => e.labId.startsWith(moduleId)).toList();
      for (final e in moduleExperiments) {
        if (!progress.experiments.containsKey(e.id)) {
          return Recommendation(
            kind: RecommendationKind.experimento,
            targetId: e.id,
            moduleId: moduleId,
            title: e.title,
            reason: 'En esta app la simulación va antes que la teoría: '
                'predice, simula y recién entonces lee.',
          );
        }
      }
      final moduleLessons = lessons.where((l) => l.moduleId == moduleId);
      for (final l in moduleLessons) {
        if (!progress.completedLessons.contains(l.id)) {
          return Recommendation(
            kind: RecommendationKind.leccion,
            targetId: l.id,
            moduleId: moduleId,
            title: l.title,
            reason: 'Ya viste el fenómeno; esta lección le pone nombre.',
          );
        }
      }
      final practice = practiceByModule[moduleId] ?? 0;
      if (practice < 0.70) {
        final pending = exercises.firstWhere(
          (e) =>
              e.moduleId == moduleId &&
              (progress.bestAttempts[e.id]?.score ?? 0) < 1.0,
          orElse: () => exercises.firstWhere((e) => e.moduleId == moduleId),
        );
        return Recommendation(
          kind: RecommendationKind.practica,
          targetId: pending.id,
          moduleId: moduleId,
          title: pending.kind.label,
          reason: 'Tu práctica en este módulo está en '
              '${(practice * 100).round()} %. El umbral de competencia exige '
              '70 % también en práctica, no solo en el total.',
        );
      }
    }

    return const Recommendation(
      kind: RecommendationKind.listo,
      targetId: '',
      moduleId: '',
      title: 'Todo al día',
      reason: 'Has cubierto los cuatro módulos. Vuelve a los casos '
          'profesionales de otras carreras: son el mejor entrenamiento de '
          'transferencia.',
    );
  }

  String _moduleOfExperiment(
      Experiment e, List<Experiment> all, List<String> moduleOrder) {
    for (final m in moduleOrder) {
      if (e.labId.startsWith(m)) return m;
    }
    return moduleOrder.isEmpty ? '' : moduleOrder.first;
  }
}
