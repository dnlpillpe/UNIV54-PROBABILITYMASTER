/// Ejercicios: seis tipos, todos con retroalimentación por alternativa.
library;

import '../math/figure_registry.dart';

enum ExerciseKind {
  /// Opción múltiple conceptual.
  opcionMultiple,

  /// Cálculo con respuesta numérica y tolerancia.
  calculo,

  /// Clasificar el problema sin resolverlo (antídoto de F6).
  clasificacion,

  /// Marcar resultados en la cuadrícula del espacio muestral (F2, F5).
  construccion,

  /// Elección + justificación, con la regla 60/40 (decisión D4).
  decisionJustificada,

  /// Auditar el desarrollo de otro y localizar el error.
  deteccionError,
}

extension ExerciseKindLabel on ExerciseKind {
  String get label {
    switch (this) {
      case ExerciseKind.opcionMultiple:
        return 'Concepto';
      case ExerciseKind.calculo:
        return 'Cálculo';
      case ExerciseKind.clasificacion:
        return 'Clasificación';
      case ExerciseKind.construccion:
        return 'Construcción';
      case ExerciseKind.decisionJustificada:
        return 'Decisión';
      case ExerciseKind.deteccionError:
        return 'Auditoría';
    }
  }
}

class Choice {
  final String text;
  final bool correct;

  /// Retroalimentación propia de esta alternativa. Nunca «Incorrecto».
  final String feedback;

  /// Confusión que produce esta alternativa incorrecta.
  final String? misconceptionId;

  const Choice(
    this.text, {
    this.correct = false,
    required this.feedback,
    this.misconceptionId,
  });
}

/// Respuesta numérica esperada, declarada como ficha del registro.
class NumericTarget {
  final ContentFigure figure;

  /// Tolerancia relativa admitida al comparar decimales.
  final double tolerance;

  /// Formas aceptadas: fracción, decimal o porcentaje.
  final bool acceptFraction;
  final bool acceptPercent;

  const NumericTarget({
    required this.figure,
    this.tolerance = 0.005,
    this.acceptFraction = true,
    this.acceptPercent = true,
  });
}

/// Especificación de un ejercicio de construcción de espacio muestral.
class BuildTarget {
  /// Identificador del espacio (`dice_2_6`, `coins_3`, ...).
  final String spaceId;

  /// Descripción del evento que hay que marcar.
  final String eventDescription;

  /// Predicado codificado: nombre + argumentos, resuelto por
  /// `SampleSpaceCatalog.predicate`.
  final String predicate;
  final List<int> predicateArgs;

  const BuildTarget({
    required this.spaceId,
    required this.eventDescription,
    required this.predicate,
    this.predicateArgs = const [],
  });
}

class Exercise {
  final String id;
  final String moduleId;
  final ExerciseKind kind;

  /// Enunciado. Admite marcas `{{id}}` de fichas.
  final String prompt;

  /// Contexto largo opcional (caso, tabla, desarrollo a auditar).
  final String? context;

  final List<Choice> choices;

  /// Justificaciones, solo para [ExerciseKind.decisionJustificada].
  final List<Choice> justifications;

  final NumericTarget? numeric;
  final BuildTarget? build;

  /// Solución redactada, visible después de responder.
  final String explanation;

  /// Pistas escalonadas del tutor (sin dar el número).
  final List<String> hints;

  final List<ContentFigure> figures;

  /// 1 = reconocimiento, 2 = aplicación, 3 = transferencia.
  final int difficulty;

  /// Confusiones que este ítem es capaz de detectar; se usan para el
  /// descuento de −0,5 cuando el estudiante acierta.
  final List<String> detects;

  const Exercise({
    required this.id,
    required this.moduleId,
    required this.kind,
    required this.prompt,
    required this.explanation,
    this.context,
    this.choices = const [],
    this.justifications = const [],
    this.numeric,
    this.build,
    this.hints = const [],
    this.figures = const [],
    this.difficulty = 1,
    this.detects = const [],
  });

  int get correctIndex => choices.indexWhere((c) => c.correct);
  int get correctJustificationIndex =>
      justifications.indexWhere((c) => c.correct);
}
