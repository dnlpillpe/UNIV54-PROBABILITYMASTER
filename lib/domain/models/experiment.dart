/// Laboratorios y experimentos.
///
/// Un laboratorio es una pantalla con un simulador; un experimento es una
/// configuración concreta con su pregunta de predicción y su hallazgo.
/// La predicción es obligatoria (decisión D1).
library;

/// Qué simulador usa el laboratorio.
enum LabEngine {
  granNumeros, // Bernoulli / categórico repetido
  espacioMuestral, // construcción + muestreo
  dosEventos, // población con dos atributos
  urnaYEvidencia, // extracciones + tamizaje
  conteo, // cumpleaños + lotería + selecciones
}

/// Tipo de predicción que se pide antes de habilitar los controles.
enum PredictionKind {
  porcentaje, // deslizador 0-100
  opcion, // una de varias afirmaciones
  comparacion, // mayor / igual / menor
}

class PredictionQuestion {
  final String question;
  final PredictionKind kind;

  /// Opciones cuando [kind] no es porcentaje.
  final List<String> options;

  /// Índice de la opción correcta, o `-1` si la predicción es un porcentaje.
  final int correctOption;

  /// Rango aceptado como «predicción acertada» para porcentajes.
  final double? correctMin;
  final double? correctMax;

  /// Qué confusión revela equivocarse aquí.
  final String? revealsMisconception;

  const PredictionQuestion({
    required this.question,
    required this.kind,
    this.options = const [],
    this.correctOption = -1,
    this.correctMin,
    this.correctMax,
    this.revealsMisconception,
  });
}

class Experiment {
  final String id;
  final String labId;
  final String title;

  /// Qué se manipula, en una frase.
  final String manipulates;

  final PredictionQuestion prediction;

  /// Repeticiones mínimas antes de desbloquear la conclusión.
  final int minTrials;

  /// Parámetros iniciales del simulador (interpretados por cada laboratorio).
  final Map<String, int> defaults;

  /// El hallazgo: qué debería haber visto. Se muestra **después** de simular.
  final String finding;

  /// Enlace con la lección que formaliza lo visto.
  final String? lessonId;

  const Experiment({
    required this.id,
    required this.labId,
    required this.title,
    required this.manipulates,
    required this.prediction,
    required this.finding,
    this.minTrials = 200,
    this.defaults = const {},
    this.lessonId,
  });
}

class Lab {
  final String id;
  final String moduleId;
  final String name;
  final String subtitle;
  final LabEngine engine;
  final List<Experiment> experiments;

  const Lab({
    required this.id,
    required this.moduleId,
    required this.name,
    required this.subtitle,
    required this.engine,
    required this.experiments,
  });
}
