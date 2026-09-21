/// Providers de la aplicación (Riverpod).
///
/// Un único `ProgressController` concentra la escritura de estado; el resto
/// son providers derivados y sin estado propio. MVVM: las pantallas leen
/// providers y llaman métodos del controlador, nunca calculan dominio.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/prefs_storage.dart';
import '../../data/repositories/content_repository.dart';
import '../../domain/models/progress.dart';
import '../../domain/services/diagnosis_service.dart';
import '../../domain/services/grading_service.dart';
import '../../domain/services/mastery_service.dart';
import '../../domain/services/recommendation_service.dart';
import '../../domain/tutor/tutor_client.dart';

final contentProvider = Provider<ContentRepository>(
  (ref) => const ContentRepository(),
);

final storageProvider = Provider<ProgressStorage>(
  (ref) => PrefsProgressStorage(),
);

final gradingProvider = Provider<GradingService>(
  (ref) => const GradingService(),
);

final masteryServiceProvider = Provider<MasteryService>(
  (ref) => const MasteryService(),
);

final recommendationServiceProvider = Provider<RecommendationService>(
  (ref) => const RecommendationService(),
);

final diagnosisProvider = Provider<DiagnosisService>(
  (ref) => DiagnosisService(ref.read(contentProvider).misconceptions),
);

/// Adaptador de tutor conversacional. En el MVP no hay modelo (Fase 5);
/// el provider existe para que enchufar uno en v2 no toque ninguna pantalla.
final tutorClientProvider = Provider<ProbabilityTutorClient>(
  (ref) => const DeterministicTutorClient(),
);

/// Estado del progreso del estudiante.
class ProgressController extends StateNotifier<UserProgress> {
  final ProgressStorage storage;
  final DiagnosisService diagnosis;

  ProgressController(this.storage, this.diagnosis)
      : super(const UserProgress()) {
    _restore();
  }

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> _restore() async {
    final p = await storage.load();
    state = p;
    _loaded = true;
  }

  Future<void> _persist() => storage.save(state);

  Set<int> _withToday(Set<int> days) => {
        ...days,
        UserProgress.dayKey(DateTime.now()),
      };

  /// Registra el resultado de un ejercicio o caso.
  Future<void> recordAttempt(AttemptRecord attempt) async {
    final best = Map<String, AttemptRecord>.from(state.bestAttempts);
    final previous = best[attempt.itemId];
    if (previous == null || attempt.score > previous.score) {
      best[attempt.itemId] = attempt;
    }
    state = state.copyWith(
      bestAttempts: best,
      history: [...state.history, attempt],
      misconceptionScores:
          diagnosis.apply(state.misconceptionScores, attempt),
      activeDays: _withToday(state.activeDays),
    );
    await _persist();
  }

  /// Marca una tarjeta de lección como vista.
  Future<void> recordCard(String lessonId, int cardIndex, int total) async {
    final seen = Map<String, int>.from(state.lessonCardsSeen);
    final current = seen[lessonId] ?? 0;
    if (cardIndex + 1 > current) seen[lessonId] = cardIndex + 1;
    final done = Set<String>.from(state.completedLessons);
    if ((seen[lessonId] ?? 0) >= total) done.add(lessonId);
    state = state.copyWith(
      lessonCardsSeen: seen,
      completedLessons: done,
      activeDays: _withToday(state.activeDays),
    );
    await _persist();
  }

  /// Registra un experimento completado.
  Future<void> recordExperiment(ExperimentRecord record) async {
    final exp = Map<String, ExperimentRecord>.from(state.experiments);
    final previous = exp[record.experimentId];
    // Se conserva la PRIMERA predicción: repetir el experimento sabiendo el
    // resultado no puede mejorar el indicador de intuición inicial.
    if (previous == null) {
      exp[record.experimentId] = record;
    } else {
      exp[record.experimentId] = ExperimentRecord(
        experimentId: record.experimentId,
        labId: record.labId,
        predictionRecorded: previous.predictionRecorded,
        predictionCorrect: previous.predictionCorrect,
        trialsRun: record.trialsRun > previous.trialsRun
            ? record.trialsRun
            : previous.trialsRun,
        seed: record.seed,
        timestamp: record.timestamp,
      );
    }
    state = state.copyWith(
      experiments: exp,
      activeDays: _withToday(state.activeDays),
    );
    await _persist();
  }

  Future<void> setCareer(String? career) async {
    state = state.copyWith(career: career);
    await _persist();
  }

  Future<void> setPreferredSeed(int seed) async {
    state = state.copyWith(preferredSeed: seed);
    await _persist();
  }

  Future<void> reset() async {
    state = const UserProgress();
    await storage.clear();
  }

  @visibleForTesting
  Future<void> waitForLoad() async {
    var tries = 0;
    while (!_loaded && tries < 100) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      tries++;
    }
  }
}

final progressProvider =
    StateNotifierProvider<ProgressController, UserProgress>((ref) {
  return ProgressController(
    ref.read(storageProvider),
    ref.read(diagnosisProvider),
  );
});

/// Dominio de un módulo.
final moduleMasteryProvider =
    Provider.family<ModuleMastery, String>((ref, moduleId) {
  final content = ref.read(contentProvider);
  final progress = ref.watch(progressProvider);
  return ref.read(masteryServiceProvider).compute(
        moduleId: moduleId,
        progress: progress,
        lessons: content.lessonsOf(moduleId),
        experiments: content.experimentsOf(moduleId),
        exercises: content.exercisesOf(moduleId),
        caseCount: moduleId == 'm4' ? content.caseCount : 0,
        caseIds:
            moduleId == 'm4' ? content.cases.map((c) => c.id).toList() : const [],
      );
});

/// Dominio global.
final overallMasteryProvider = Provider<double>((ref) {
  final content = ref.read(contentProvider);
  final list = content.moduleOrder
      .map((m) => ref.watch(moduleMasteryProvider(m)))
      .toList();
  return ref.read(masteryServiceProvider).overall(list);
});

/// Confusiones activas, ordenadas por intensidad.
final activeMisconceptionsProvider =
    Provider<List<ActiveMisconception>>((ref) {
  final progress = ref.watch(progressProvider);
  return ref.read(diagnosisProvider).active(progress.misconceptionScores);
});

/// Confusiones superadas.
final overcomeMisconceptionsProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  return ref
      .read(diagnosisProvider)
      .overcome(progress.misconceptionScores, progress.history)
      .length;
});

/// Qué hacer ahora.
final recommendationProvider = Provider<Recommendation>((ref) {
  final content = ref.read(contentProvider);
  final progress = ref.watch(progressProvider);
  final active = ref.watch(activeMisconceptionsProvider);
  final practice = <String, double>{
    for (final m in content.moduleOrder)
      m: ref.watch(moduleMasteryProvider(m)).practicePart,
  };
  return ref.read(recommendationServiceProvider).next(
        progress: progress,
        active: active,
        lessons: content.lessons,
        experiments: content.experiments,
        exercises: content.exercises,
        practiceByModule: practice,
        moduleOrder: content.moduleOrder,
      );
});

/// Racha de días consecutivos.
final streakProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  return progress.streakFrom(DateTime.now());
});
