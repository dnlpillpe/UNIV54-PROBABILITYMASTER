/// Adaptador de tutor conversacional — **preparado, no activado** (Fase 5).
///
/// La regla, fijada en el análisis y que ninguna implementación futura puede
/// romper: **el modelo redacta, el motor calcula**. Un `TutorClient` recibe el
/// resultado ya calculado y solo puede reformular la explicación. No se le
/// pasa el enunciado sin el resultado, no devuelve números y no toca el
/// puntaje.
library;

import 'step_solver.dart';

/// Petición de redacción: lo que el modelo puede ver.
class TutorRewriteRequest {
  /// Explicación determinista ya generada por la app.
  final String deterministicExplanation;

  /// Pasos ya calculados; el modelo puede citarlos, no recalcularlos.
  final List<String> computedSteps;

  /// Confusión detectada, si la hay.
  final String? misconceptionId;

  /// Nivel del estudiante, 1 a 3.
  final int level;

  const TutorRewriteRequest({
    required this.deterministicExplanation,
    required this.computedSteps,
    this.misconceptionId,
    this.level = 1,
  });
}

abstract class ProbabilityTutorClient {
  /// Reformula una explicación. Debe devolver texto sin cifras nuevas.
  Future<String> rewrite(TutorRewriteRequest request);

  /// ¿Está disponible? En el MVP siempre `false`.
  bool get available;
}

/// Implementación del MVP: no hay modelo. Devuelve la explicación
/// determinista tal cual. Existir así, y no faltar, es lo que permite
/// enchufar un modelo en v2 sin tocar la interfaz.
class DeterministicTutorClient implements ProbabilityTutorClient {
  const DeterministicTutorClient();

  @override
  bool get available => false;

  @override
  Future<String> rewrite(TutorRewriteRequest request) async =>
      request.deterministicExplanation;
}

/// Resultado que el tutor muestra tras clasificar y resolver.
class TutorAnswer {
  final String methodTitle;
  final String condition;
  final String reasoningPath;
  final SolverOutput? solved;

  const TutorAnswer({
    required this.methodTitle,
    required this.condition,
    required this.reasoningPath,
    this.solved,
  });
}
