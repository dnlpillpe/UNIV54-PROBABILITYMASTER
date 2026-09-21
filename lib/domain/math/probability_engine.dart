/// Reglas de probabilidad, exactas y con los pasos expuestos.
///
/// Cada método devuelve, además del número, la lista de pasos que el tutor
/// muestra al estudiante. El motor es la única fuente de verdad numérica de
/// la app (decisión D5): ni el contenido ni la interfaz escriben resultados
/// a mano.
library;

import 'combinatorics.dart';
import 'rational.dart';
import 'sample_space.dart';

/// Un paso de resolución: qué se hizo, con qué expresión y qué dio.
class SolutionStep {
  final String title;
  final String expression;
  final String? note;
  final Rational? value;

  const SolutionStep(this.title, this.expression, {this.note, this.value});

  @override
  String toString() => '$title: $expression'
      '${value != null ? ' = ${value!.asFraction}' : ''}';
}

/// Resultado de un cálculo: el valor y su derivación.
class ProbabilityResult {
  final Rational value;
  final List<SolutionStep> steps;

  /// Advertencias sobre supuestos (equiprobabilidad no verificada,
  /// independencia asumida, etc.). La competencia objetivo del análisis
  /// incluye «declarar qué supuestos asumió»; por eso viajan con el número.
  final List<String> warnings;

  const ProbabilityResult(this.value, this.steps, {this.warnings = const []});

  String get formatted => value.triple;
}

class ProbabilityEngine {
  const ProbabilityEngine._();

  // ------------------------------------------------------------------
  // Definición clásica
  // ------------------------------------------------------------------

  /// Regla de Laplace: casos favorables / casos posibles.
  static ProbabilityResult laplace(BigInt favorable, BigInt possible) {
    if (possible <= BigInt.zero) {
      throw ArgumentError('El espacio muestral no puede ser vacío');
    }
    if (favorable > possible) {
      throw ArgumentError('Los casos favorables no pueden exceder los posibles');
    }
    final p = Rational(favorable, possible);
    return ProbabilityResult(
      p,
      [
        SolutionStep(
          'Regla de Laplace',
          'P(A) = casos favorables / casos posibles = '
              '${Combinatorics.formatBig(favorable)} / '
              '${Combinatorics.formatBig(possible)}',
          value: p,
        ),
      ],
      warnings: const [
        'Laplace solo vale si todos los resultados del espacio muestral son '
            'igualmente probables. Verifícalo antes de dividir.',
      ],
    );
  }

  /// Probabilidad de un evento sobre un espacio muestral construido.
  static ProbabilityResult ofEvent(SampleSpace space, EventDef event) {
    final p = space.probabilityOfIndices(event.indices);
    final steps = <SolutionStep>[
      SolutionStep('Espacio muestral',
          '|Ω| = ${space.size} resultados — ${space.experiment}'),
      SolutionStep('Evento ${event.symbol}',
          '${event.description}: ${event.size} resultado(s) favorable(s)'),
      SolutionStep(
        'Probabilidad',
        space.isUniform
            ? 'P(${event.symbol}) = ${event.size}/${space.size}'
            : 'P(${event.symbol}) = suma de pesos favorables / peso total',
        value: p,
      ),
    ];
    return ProbabilityResult(p, steps,
        warnings: space.isUniform
            ? const []
            : const [
                'Este espacio NO es equiprobable: no se puede dividir '
                    'favorables entre posibles.',
              ]);
  }

  /// Frecuencia relativa (definición frecuentista).
  static Rational relativeFrequency(int successes, int trials) =>
      trials == 0 ? Rational.zero : Rational.fromInts(successes, trials);

  // ------------------------------------------------------------------
  // Axiomas y propiedades
  // ------------------------------------------------------------------

  /// Complemento: P(A') = 1 - P(A).
  static ProbabilityResult complement(Rational pA) {
    final p = pA.complement;
    return ProbabilityResult(p, [
      SolutionStep("Regla del complemento", "P(A') = 1 − P(A) = 1 − ${pA.asFraction}",
          value: p),
    ]);
  }

  /// Regla general de la suma: P(A∪B) = P(A) + P(B) − P(A∩B).
  static ProbabilityResult unionGeneral(
      Rational pA, Rational pB, Rational pAandB) {
    final p = pA + pB - pAandB;
    if (p > Rational.one) {
      throw ArgumentError('Los datos son incoherentes: P(A∪B) > 1');
    }
    return ProbabilityResult(p, [
      const SolutionStep('Regla general de la suma',
          'P(A ∪ B) = P(A) + P(B) − P(A ∩ B)'),
      SolutionStep(
        'Sustitución',
        '${pA.asFraction} + ${pB.asFraction} − ${pAandB.asFraction}',
        value: p,
        note: pAandB.isZero
            ? 'La intersección es vacía: aquí sí basta con sumar.'
            : 'Restar la intersección evita contar dos veces los resultados '
                'que están en A y en B.',
      ),
    ]);
  }

  /// Suma para eventos mutuamente excluyentes.
  static ProbabilityResult unionDisjoint(List<Rational> ps) {
    var acc = Rational.zero;
    for (final p in ps) {
      acc = acc + p;
    }
    return ProbabilityResult(acc, [
      SolutionStep(
        'Suma de eventos mutuamente excluyentes',
        ps.map((p) => p.asFraction).join(' + '),
        value: acc,
        note: 'Solo es válido si NO pueden ocurrir a la vez.',
      ),
    ], warnings: const [
      'Comprueba que los eventos sean realmente incompatibles antes de sumar.',
    ]);
  }

  // ------------------------------------------------------------------
  // Condicional, producto e independencia
  // ------------------------------------------------------------------

  /// P(A|B) = P(A∩B)/P(B).
  static ProbabilityResult conditional(Rational pAandB, Rational pB) {
    if (pB.isZero) {
      throw ArgumentError('No se puede condicionar a un evento de probabilidad 0');
    }
    final p = pAandB / pB;
    return ProbabilityResult(p, [
      const SolutionStep('Probabilidad condicional', 'P(A | B) = P(A ∩ B) / P(B)'),
      SolutionStep(
        'Sustitución',
        '${pAandB.asFraction} / ${pB.asFraction}',
        value: p,
        note: 'Condicionar es cambiar el espacio muestral: ahora solo cuentan '
            'los resultados donde ocurrió B.',
      ),
    ]);
  }

  /// Regla del producto general: P(A∩B) = P(A)·P(B|A).
  static ProbabilityResult productRule(Rational pA, Rational pBgivenA,
      {bool independent = false}) {
    final p = pA * pBgivenA;
    return ProbabilityResult(p, [
      SolutionStep(
        independent ? 'Producto (eventos independientes)' : 'Regla del producto',
        independent ? 'P(A ∩ B) = P(A) · P(B)' : 'P(A ∩ B) = P(A) · P(B | A)',
      ),
      SolutionStep('Sustitución',
          '${pA.asFraction} · ${pBgivenA.asFraction}',
          value: p),
    ], warnings: independent
        ? const [
            'Multiplicar directamente exige independencia. Si una extracción '
                'es sin reposición, NO son independientes.',
          ]
        : const []);
  }

  /// Verificación de independencia: ¿P(A∩B) = P(A)·P(B)?
  static bool areIndependent(Rational pA, Rational pB, Rational pAandB) =>
      (pA * pB) == pAandB;

  /// Verificación de independencia sobre un espacio construido.
  static bool eventsIndependent(
      SampleSpace space, EventDef a, EventDef b) {
    final pA = space.probabilityOfIndices(a.indices);
    final pB = space.probabilityOfIndices(b.indices);
    final pAB = space.probabilityOfIndices(a.indices.intersection(b.indices));
    return areIndependent(pA, pB, pAB);
  }

  /// «Al menos uno» vía complemento: 1 − (1−p)^n.
  /// El antídoto contra la confusión `al_menos_uno_suma` (multiplicar p por n).
  static ProbabilityResult atLeastOne(Rational p, int n) {
    final none = p.complement.pow(n);
    final result = none.complement;
    return ProbabilityResult(result, [
      SolutionStep('Traducción', 'P(al menos uno) = 1 − P(ninguno)',
          note: 'Contar «al menos uno» directamente obliga a sumar muchos '
              'casos; el complemento es un solo cálculo.'),
      SolutionStep('P(ninguno)', '(1 − ${p.asFraction})^$n', value: none),
      SolutionStep('Resultado', '1 − ${none.asFraction}', value: result),
    ], warnings: const [
      'Exige que los n ensayos sean independientes y con la misma p.',
    ]);
  }

  /// Sistema en serie: falla si falla cualquiera. Fiabilidad = ∏ r_i.
  static ProbabilityResult seriesReliability(List<Rational> reliabilities) {
    var acc = Rational.one;
    for (final r in reliabilities) {
      acc = acc * r;
    }
    return ProbabilityResult(acc, [
      SolutionStep('Sistema en serie', 'R = ${reliabilities.map((r) => r.asFraction).join(' · ')}',
          value: acc,
          note: 'En serie todos deben funcionar: la fiabilidad del sistema '
              'es menor que la del peor componente.'),
    ]);
  }

  /// Sistema en paralelo: falla solo si fallan todos. R = 1 − ∏ (1−r_i).
  static ProbabilityResult parallelReliability(List<Rational> reliabilities) {
    var fail = Rational.one;
    for (final r in reliabilities) {
      fail = fail * r.complement;
    }
    final acc = fail.complement;
    return ProbabilityResult(acc, [
      SolutionStep('Sistema en paralelo', 'R = 1 − ∏ (1 − r_i)',
          value: acc,
          note: 'En paralelo basta con que uno funcione: la redundancia sube '
              'la fiabilidad por encima de la del mejor componente.'),
    ]);
  }

  // ------------------------------------------------------------------
  // Probabilidad total y Bayes
  // ------------------------------------------------------------------

  /// Probabilidad total: P(B) = Σ P(Ai)·P(B|Ai).
  static ProbabilityResult totalProbability(
      List<Rational> priors, List<Rational> likelihoods,
      {List<String>? names}) {
    if (priors.length != likelihoods.length) {
      throw ArgumentError('priors y likelihoods deben tener el mismo tamaño');
    }
    var acc = Rational.zero;
    final terms = <String>[];
    for (var i = 0; i < priors.length; i++) {
      acc = acc + priors[i] * likelihoods[i];
      final n = names != null && i < names.length ? names[i] : 'A${i + 1}';
      terms.add('${priors[i].asFraction}·${likelihoods[i].asFraction} ($n)');
    }
    return ProbabilityResult(acc, [
      const SolutionStep('Probabilidad total', 'P(B) = Σ P(Aᵢ) · P(B | Aᵢ)'),
      SolutionStep('Sustitución', terms.join(' + '), value: acc),
    ], warnings: const [
      'Los Aᵢ deben formar una partición: excluyentes entre sí y cubrir todo Ω.',
    ]);
  }

  /// Teorema de Bayes para una partición completa; devuelve el posterior del
  /// índice [target].
  static ProbabilityResult bayes(
    List<Rational> priors,
    List<Rational> likelihoods, {
    int target = 0,
    List<String>? names,
  }) {
    final total = totalProbability(priors, likelihoods, names: names).value;
    if (total.isZero) {
      throw ArgumentError('La evidencia tiene probabilidad 0');
    }
    final numerator = priors[target] * likelihoods[target];
    final post = numerator / total;
    final name = names != null && target < names.length
        ? names[target]
        : 'A${target + 1}';
    return ProbabilityResult(post, [
      SolutionStep('Teorema de Bayes',
          'P($name | B) = P($name)·P(B | $name) / P(B)'),
      SolutionStep('Numerador',
          '${priors[target].asFraction} · ${likelihoods[target].asFraction}',
          value: numerator),
      SolutionStep('Denominador (probabilidad total)', 'P(B)', value: total),
      SolutionStep('Resultado',
          '${numerator.asFraction} / ${total.asFraction}',
          value: post,
          note: 'Si el resultado te sorprende, mira la tasa base: '
              'P($name) = ${priors[target].asPercent()}.'),
    ]);
  }

  /// Caso especial: prueba diagnóstica. Devuelve el **valor predictivo
  /// positivo**, el número que la intuición calcula mal (fallo F4).
  static ProbabilityResult diagnosticTest({
    required Rational prevalence,
    required Rational sensitivity,
    required Rational specificity,
  }) {
    final falsePositiveRate = specificity.complement;
    final r = bayes(
      [prevalence, prevalence.complement],
      [sensitivity, falsePositiveRate],
      names: const ['Enfermo', 'Sano'],
    );
    final steps = <SolutionStep>[
      SolutionStep('Datos',
          'Prevalencia ${prevalence.asPercent(digits: 2)} · '
          'Sensibilidad ${sensitivity.asPercent()} · '
          'Especificidad ${specificity.asPercent()}'),
      ...r.steps,
      SolutionStep(
        'Lectura',
        'Dar positivo NO es estar enfermo',
        note: 'Con una enfermedad rara, la mayoría de los positivos son falsos '
            'positivos de la gran población sana. P(enfermo | +) = '
            '${r.value.asPercent()}, no la sensibilidad.',
      ),
    ];
    return ProbabilityResult(r.value, steps);
  }

  // ------------------------------------------------------------------
  // Momios (odds), que aparecen en apuestas y en el lenguaje cotidiano
  // ------------------------------------------------------------------

  static Rational oddsToProbability(int favor, int against) =>
      Rational.fromInts(favor, favor + against);

  static String probabilityToOdds(Rational p) {
    final favor = p.num;
    final against = p.den - p.num;
    final g = favor.abs() == BigInt.zero ? BigInt.one : favor.gcd(against);
    return '${favor ~/ g} a ${against ~/ g}';
  }

  // ------------------------------------------------------------------
  // Atajos usados por el contenido (registro de funciones con nombre)
  // ------------------------------------------------------------------

  static Rational birthday(int k) => Combinatorics.birthdayCollision(k);

  static Rational binomial(int n, int k, int pNum, int pDen) =>
      Combinatorics.binomialPmf(n, k, Rational.fromInts(pNum, pDen));

  static Rational hyper(int n, int k, int draws, int hits) =>
      Combinatorics.hypergeometric(n, k, draws, hits);
}
