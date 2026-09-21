/// Registro de funciones con nombre (decisión D5).
///
/// El contenido educativo **nunca escribe un número**. Declara
/// `ContentFigure(id: 'p_suma7', fn: 'diceSum', args: [7])` y la app lo
/// calcula con el motor real en tiempo de ejecución. Un test recalcula todas
/// las fichas y una réplica en Python las vuelve a calcular en CI: si alguna
/// vez el motor cambia, el contenido deja de coincidir y la compilación falla.
library;

import 'combinatorics.dart';
import 'probability_engine.dart';
import 'rational.dart';
import 'sample_space.dart';

/// Cómo se muestra una cifra en el texto.
enum FigureFormat { fraction, decimal, percent, triple, count }

/// Una cifra declarada por el contenido.
class ContentFigure {
  final String id;
  final String fn;
  final List<int> args;
  final FigureFormat format;

  /// Qué representa, para el glosario de cifras y los mensajes de error
  /// del test de verificación.
  final String label;

  const ContentFigure({
    required this.id,
    required this.fn,
    required this.args,
    required this.label,
    this.format = FigureFormat.fraction,
  });
}

class FigureRegistry {
  const FigureRegistry._();

  /// Funciones que devuelven una probabilidad exacta.
  static final Map<String, Rational Function(List<int>)> probabilityFns = {
    // --- Espacios muestrales elementales -----------------------------
    'coinsAllHeads': (a) =>
        Rational.fromInts(1, 1 << a[0]),
    'coinsExactHeads': (a) => Rational(
          Combinatorics.combinations(a[0], a[1]),
          BigInt.from(1 << a[0]),
        ),
    'coinsAtLeastOneHead': (a) =>
        Rational.fromInts((1 << a[0]) - 1, 1 << a[0]),
    'diceSum': (a) => SampleSpace.diceSum().probabilityWhere(
          (o) => o.values.first == a[0],
        ),
    'diceSumAtLeast': (a) => SampleSpace.diceSum().probabilityWhere(
          (o) => o.values.first >= a[0],
        ),
    'twoDiceDoubles': (a) => SampleSpace.dice(2).probabilityWhere(
          (o) => o.values[0] == o.values[1],
        ),
    'twoDiceMaxAtLeast': (a) => SampleSpace.dice(2).probabilityWhere(
          (o) => o.maxValue >= a[0],
        ),
    'oneDieEven': (a) =>
        SampleSpace.dice(1).probabilityWhere((o) => o.values.first.isEven),
    'cardIs': (a) => Rational.fromInts(a[0], 52),

    // --- Reglas -------------------------------------------------------
    // args: [pA_num, pA_den, pB_num, pB_den, pAB_num, pAB_den]
    'unionGeneral': (a) => ProbabilityEngine.unionGeneral(
          Rational.fromInts(a[0], a[1]),
          Rational.fromInts(a[2], a[3]),
          Rational.fromInts(a[4], a[5]),
        ).value,
    // args: [num, den]
    'complement': (a) => Rational.fromInts(a[0], a[1]).complement,
    // args: [pAB_num, pAB_den, pB_num, pB_den]
    'conditional': (a) => ProbabilityEngine.conditional(
          Rational.fromInts(a[0], a[1]),
          Rational.fromInts(a[2], a[3]),
        ).value,
    // args: [p_num, p_den, n]
    'atLeastOne': (a) =>
        ProbabilityEngine.atLeastOne(Rational.fromInts(a[0], a[1]), a[2]).value,
    // args: [p_num, p_den, n]  — ninguno en n ensayos
    'noneIn': (a) => Rational.fromInts(a[0], a[1]).complement.pow(a[2]),
    // args: [r_num, r_den, n] componentes iguales en serie
    'seriesEqual': (a) => Rational.fromInts(a[0], a[1]).pow(a[2]),
    // args: [r_num, r_den, n] componentes iguales en paralelo
    'parallelEqual': (a) =>
        Rational.fromInts(a[0], a[1]).complement.pow(a[2]).complement,

    // --- Urnas y extracciones ----------------------------------------
    // args: [favorables, total, extracciones] sin reposición, todas del color
    'urnAllSameNoRep': (a) => Rational(
          Combinatorics.combinations(a[0], a[2]),
          Combinatorics.combinations(a[1], a[2]),
        ),
    'urnAllSameWithRep': (a) => Rational.fromInts(a[0], a[1]).pow(a[2]),
    // args: [N, K, n, k] hipergeométrica
    'hypergeometric': (a) =>
        Combinatorics.hypergeometric(a[0], a[1], a[2], a[3]),

    // --- Bayes --------------------------------------------------------
    // args: [prev_num, prev_den, sens_num, sens_den, spec_num, spec_den]
    'ppv': (a) => ProbabilityEngine.diagnosticTest(
          prevalence: Rational.fromInts(a[0], a[1]),
          sensitivity: Rational.fromInts(a[2], a[3]),
          specificity: Rational.fromInts(a[4], a[5]),
        ).value,
    // args: [p1n, p1d, l1n, l1d, p2n, p2d, l2n, l2d] -> posterior del primero
    'bayes2': (a) => ProbabilityEngine.bayes(
          [Rational.fromInts(a[0], a[1]), Rational.fromInts(a[4], a[5])],
          [Rational.fromInts(a[2], a[3]), Rational.fromInts(a[6], a[7])],
        ).value,
    'totalProbability2': (a) => ProbabilityEngine.totalProbability(
          [Rational.fromInts(a[0], a[1]), Rational.fromInts(a[4], a[5])],
          [Rational.fromInts(a[2], a[3]), Rational.fromInts(a[6], a[7])],
        ).value,

    // --- Conteo aplicado ----------------------------------------------
    'birthday': (a) => Combinatorics.birthdayCollision(a[0]),
    // args: [n, k, p_num, p_den]
    'binomial': (a) => Combinatorics.binomialPmf(
          a[0],
          a[1],
          Rational.fromInts(a[2], a[3]),
        ),
    'binomialAtLeast': (a) => Combinatorics.binomialAtLeast(
          a[0],
          a[1],
          Rational.fromInts(a[2], a[3]),
        ),
    // args: [n, k] — acertar una combinación de lotería
    'lotteryWin': (a) =>
        Rational(BigInt.one, Combinatorics.combinations(a[0], a[1])),
    // args: [num, den] — identidad, para cifras dadas por enunciado
    'literal': (a) => Rational.fromInts(a[0], a[1]),
  };

  /// Funciones que devuelven un conteo entero grande.
  static final Map<String, BigInt Function(List<int>)> countFns = {
    'factorial': (a) => Combinatorics.factorial(a[0]),
    'combinations': (a) => Combinatorics.combinations(a[0], a[1]),
    'variations': (a) => Combinatorics.variations(a[0], a[1]),
    'variationsRep': (a) => Combinatorics.variationsWithRepetition(a[0], a[1]),
    'combinationsRep': (a) =>
        Combinatorics.combinationsWithRepetition(a[0], a[1]),
    'permutationsRep': (a) => Combinatorics.permutationsWithRepetition(a),
    'circular': (a) => Combinatorics.circularPermutations(a[0]),
    'subsets': (a) => Combinatorics.subsets(a[0]),
    'multiply': (a) => Combinatorics.multiplicationRule(a),
  };

  static bool knows(String fn) =>
      probabilityFns.containsKey(fn) || countFns.containsKey(fn);

  /// Evalúa y formatea una ficha.
  static String render(ContentFigure f) {
    if (f.format == FigureFormat.count) {
      final fn = countFns[f.fn];
      if (fn == null) {
        throw StateError('Función de conteo desconocida: ${f.fn}');
      }
      return Combinatorics.formatBig(fn(f.args));
    }
    final fn = probabilityFns[f.fn];
    if (fn == null) {
      throw StateError('Función de probabilidad desconocida: ${f.fn}');
    }
    final r = fn(f.args);
    switch (f.format) {
      case FigureFormat.fraction:
        return r.asFraction;
      case FigureFormat.decimal:
        return r.asDecimal();
      case FigureFormat.percent:
        return r.asPercent();
      case FigureFormat.triple:
        return r.triple;
      case FigureFormat.count:
        return r.asFraction;
    }
  }

  /// Valor numérico de una ficha de probabilidad (para tests y comparaciones).
  static Rational evaluate(ContentFigure f) {
    final fn = probabilityFns[f.fn];
    if (fn == null) throw StateError('Función desconocida: ${f.fn}');
    return fn(f.args);
  }

  static BigInt evaluateCount(ContentFigure f) {
    final fn = countFns[f.fn];
    if (fn == null) throw StateError('Función de conteo desconocida: ${f.fn}');
    return fn(f.args);
  }
}
