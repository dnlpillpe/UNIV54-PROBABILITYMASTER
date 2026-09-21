/// Glosario.
library;

class GlossaryTerm {
  final String term;
  final String definition;

  /// Notación asociada, si la tiene.
  final String? notation;

  /// Error frecuente al usarlo.
  final String? caution;

  final String moduleId;

  const GlossaryTerm({
    required this.term,
    required this.definition,
    required this.moduleId,
    this.notation,
    this.caution,
  });
}
