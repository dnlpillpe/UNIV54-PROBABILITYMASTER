/// Catálogo de confusiones (decisión D3).
///
/// Una confusión no es «un tema que le sale mal»: es una creencia concreta,
/// nombrable, que produce errores predecibles. Cada alternativa incorrecta de
/// la app declara cuál produce, y el diagnóstico las acumula.
library;

/// Familia a la que pertenece la confusión, para agrupar el informe.
enum MisconceptionFamily {
  intuicionFrecuentista, // F1
  espacioMuestral, // F2
  reglasYEventos, // F3
  condicionalYBayes, // F4
  conteo, // F5
  modelado, // F6
}

extension MisconceptionFamilyLabel on MisconceptionFamily {
  String get label {
    switch (this) {
      case MisconceptionFamily.intuicionFrecuentista:
        return 'Intuición frecuentista';
      case MisconceptionFamily.espacioMuestral:
        return 'Espacio muestral';
      case MisconceptionFamily.reglasYEventos:
        return 'Reglas y eventos';
      case MisconceptionFamily.condicionalYBayes:
        return 'Condicional y Bayes';
      case MisconceptionFamily.conteo:
        return 'Conteo';
      case MisconceptionFamily.modelado:
        return 'Modelado del problema';
    }
  }
}

class Misconception {
  final String id;

  /// Nombre corto tal como se muestra al estudiante.
  final String name;

  /// Qué cree el estudiante, en su propia voz.
  final String belief;

  /// Por qué es falso, en una frase.
  final String correction;

  /// Cómo se detecta.
  final String symptom;

  final MisconceptionFamily family;

  /// Remedio enlazado: a qué volver.
  final String? remedyLessonId;
  final String? remedyExperimentId;

  const Misconception({
    required this.id,
    required this.name,
    required this.belief,
    required this.correction,
    required this.symptom,
    required this.family,
    this.remedyLessonId,
    this.remedyExperimentId,
  });
}
