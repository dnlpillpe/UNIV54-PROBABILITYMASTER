/// Casos profesionales del módulo 4.
///
/// Cada caso pertenece a una carrera y exige elegir **y justificar**. Dos de
/// los doce terminan en «no corresponde calcular»: saber cuándo el modelo no
/// aplica es parte de la competencia.
library;

import '../math/figure_registry.dart';
import 'exercise.dart';

class CaseStudy {
  final String id;
  final String career;
  final String title;

  /// Situación profesional, en 3-6 frases.
  final String scenario;

  /// Datos, ya tabulados.
  final List<String> data;

  /// Pregunta de decisión.
  final String question;

  final List<Choice> options;
  final List<Choice> justifications;

  /// Resolución completa.
  final String resolution;

  /// Qué supuestos asume la respuesta correcta y cuándo dejaría de valer.
  final String assumptions;

  final List<ContentFigure> figures;

  /// Confusiones que el caso pone a prueba.
  final List<String> detects;

  const CaseStudy({
    required this.id,
    required this.career,
    required this.title,
    required this.scenario,
    required this.question,
    required this.options,
    required this.resolution,
    required this.assumptions,
    this.data = const [],
    this.justifications = const [],
    this.figures = const [],
    this.detects = const [],
  });
}
