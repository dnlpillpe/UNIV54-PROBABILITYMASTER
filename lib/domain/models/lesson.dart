/// Lecciones y tarjetas.
///
/// Una tarjeta = una pantalla = una idea. Las lecciones son deliberadamente
/// cortas: en esta app el texto llega *después* de la simulación, para poner
/// nombre a algo que el estudiante ya vio.
library;

import '../math/figure_registry.dart';

enum CardKind {
  idea, // explicación central
  formula, // regla, con su condición de uso
  ejemplo, // aplicación resuelta
  alerta, // confusión frecuente, explícita
  conexion, // enlace con un laboratorio o con otro módulo
}

class LessonCard {
  final String title;

  /// Cuerpo del texto. Puede contener marcas `{{id}}` que se sustituyen por
  /// el valor de la ficha con ese id (decisión D5).
  final String body;

  final CardKind kind;

  /// Fichas numéricas usadas en el cuerpo.
  final List<ContentFigure> figures;

  /// Confusión que esta tarjeta desactiva, si aplica.
  final String? targetsMisconception;

  const LessonCard({
    required this.title,
    required this.body,
    this.kind = CardKind.idea,
    this.figures = const [],
    this.targetsMisconception,
  });
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;

  /// Una frase: qué sabrá hacer el estudiante al terminar.
  final String objective;

  final List<LessonCard> cards;

  /// Experimento recomendado antes de leer.
  final String? preferredExperimentId;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.objective,
    required this.cards,
    this.preferredExperimentId,
  });

  int get cardCount => cards.length;
}
