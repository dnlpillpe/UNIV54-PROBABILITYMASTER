/// Solucionador paso a paso.
///
/// Un mismo objeto alimenta dos pantallas: la **calculadora** (el estudiante
/// mete los datos) y el **tutor** (muestra los pasos de un ejercicio). Los dos
/// usan el motor, de modo que nunca pueden mostrar números distintos
/// (decisión D5).
library;

import '../math/combinatorics.dart';
import '../math/probability_engine.dart';
import '../math/rational.dart';
import 'problem_classifier.dart';

/// Tipo de dato que pide un campo del solucionador.
enum FieldType { probability, count, fractionNum, fractionDen }

class SolverField {
  final String key;
  final String label;
  final String hint;
  final FieldType type;
  final double defaultValue;

  const SolverField({
    required this.key,
    required this.label,
    required this.type,
    this.hint = '',
    this.defaultValue = 0,
  });
}

/// Salida del solucionador.
class SolverOutput {
  final String headline;
  final List<SolutionStep> steps;
  final List<String> warnings;

  /// Valor, si el método devuelve una probabilidad.
  final Rational? probability;

  /// Valor, si el método devuelve un conteo.
  final BigInt? count;

  const SolverOutput({
    required this.headline,
    required this.steps,
    this.warnings = const [],
    this.probability,
    this.count,
  });
}

/// Receta: qué pide un método y cómo se calcula.
class SolverRecipe {
  final TutorMethod method;
  final List<SolverField> fields;
  final SolverOutput Function(Map<String, double> v) compute;

  const SolverRecipe(this.method, this.fields, this.compute);
}

class StepSolver {
  const StepSolver._();

  static int _i(Map<String, double> v, String k) => (v[k] ?? 0).round();
  static Rational _p(Map<String, double> v, String k) =>
      Rational.fromDouble((v[k] ?? 0).clamp(0.0, 1.0));

  static const _pField = FieldType.probability;
  static const _cField = FieldType.count;

  static final Map<TutorMethod, SolverRecipe> recipes = {
    TutorMethod.enumerarLaplace: SolverRecipe(
      TutorMethod.enumerarLaplace,
      const [
        SolverField(
            key: 'fav',
            label: 'Casos favorables',
            type: _cField,
            hint: 'Cuántos resultados cumplen el evento',
            defaultValue: 6),
        SolverField(
            key: 'tot',
            label: 'Casos posibles',
            type: _cField,
            hint: 'Tamaño del espacio muestral',
            defaultValue: 36),
      ],
      (v) {
        final r = ProbabilityEngine.laplace(
            BigInt.from(_i(v, 'fav')), BigInt.from(_i(v, 'tot')));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          warnings: r.warnings,
          probability: r.value,
        );
      },
    ),
    TutorMethod.reglaSumaGeneral: SolverRecipe(
      TutorMethod.reglaSumaGeneral,
      const [
        SolverField(key: 'pa', label: 'P(A)', type: _pField, defaultValue: 0.5),
        SolverField(key: 'pb', label: 'P(B)', type: _pField, defaultValue: 0.4),
        SolverField(
            key: 'pab',
            label: 'P(A ∩ B)',
            type: _pField,
            hint: 'Pon 0 si no pueden ocurrir a la vez',
            defaultValue: 0.2),
      ],
      (v) {
        final r = ProbabilityEngine.unionGeneral(
            _p(v, 'pa'), _p(v, 'pb'), _p(v, 'pab'));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          warnings: r.warnings,
          probability: r.value,
        );
      },
    ),
    TutorMethod.complemento: SolverRecipe(
      TutorMethod.complemento,
      const [
        SolverField(key: 'pa', label: 'P(A)', type: _pField, defaultValue: 0.3),
      ],
      (v) {
        final r = ProbabilityEngine.complement(_p(v, 'pa'));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          probability: r.value,
        );
      },
    ),
    TutorMethod.alMenosUno: SolverRecipe(
      TutorMethod.alMenosUno,
      const [
        SolverField(
            key: 'p',
            label: 'p de cada intento',
            type: _pField,
            defaultValue: 0.1),
        SolverField(
            key: 'n', label: 'Número de intentos', type: _cField, defaultValue: 10),
      ],
      (v) {
        final r = ProbabilityEngine.atLeastOne(_p(v, 'p'), _i(v, 'n'));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          warnings: r.warnings,
          probability: r.value,
        );
      },
    ),
    TutorMethod.condicional: SolverRecipe(
      TutorMethod.condicional,
      const [
        SolverField(
            key: 'pab', label: 'P(A ∩ B)', type: _pField, defaultValue: 0.12),
        SolverField(key: 'pb', label: 'P(B)', type: _pField, defaultValue: 0.3),
      ],
      (v) {
        final r = ProbabilityEngine.conditional(_p(v, 'pab'), _p(v, 'pb'));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          probability: r.value,
        );
      },
    ),
    TutorMethod.productoDependientes: SolverRecipe(
      TutorMethod.productoDependientes,
      const [
        SolverField(key: 'pa', label: 'P(A)', type: _pField, defaultValue: 0.5),
        SolverField(
            key: 'pba', label: 'P(B | A)', type: _pField, defaultValue: 0.4),
      ],
      (v) {
        final r = ProbabilityEngine.productRule(_p(v, 'pa'), _p(v, 'pba'));
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          probability: r.value,
        );
      },
    ),
    TutorMethod.productoIndependientes: SolverRecipe(
      TutorMethod.productoIndependientes,
      const [
        SolverField(key: 'pa', label: 'P(A)', type: _pField, defaultValue: 0.5),
        SolverField(key: 'pb', label: 'P(B)', type: _pField, defaultValue: 0.4),
      ],
      (v) {
        final r = ProbabilityEngine.productRule(_p(v, 'pa'), _p(v, 'pb'),
            independent: true);
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          warnings: r.warnings,
          probability: r.value,
        );
      },
    ),
    TutorMethod.bayes: SolverRecipe(
      TutorMethod.bayes,
      const [
        SolverField(
            key: 'prev',
            label: 'Tasa base P(causa)',
            type: _pField,
            hint: 'La cifra que la intuición ignora',
            defaultValue: 0.01),
        SolverField(
            key: 'sens',
            label: 'P(evidencia | causa)',
            type: _pField,
            defaultValue: 0.99),
        SolverField(
            key: 'spec',
            label: 'P(no evidencia | no causa)',
            type: _pField,
            defaultValue: 0.95),
      ],
      (v) {
        final r = ProbabilityEngine.diagnosticTest(
          prevalence: _p(v, 'prev'),
          sensitivity: _p(v, 'sens'),
          specificity: _p(v, 'spec'),
        );
        return SolverOutput(
          headline: r.value.triple,
          steps: r.steps,
          probability: r.value,
        );
      },
    ),
    TutorMethod.binomial: SolverRecipe(
      TutorMethod.binomial,
      const [
        SolverField(key: 'n', label: 'Número de ensayos (n)', type: _cField, defaultValue: 10),
        SolverField(key: 'k', label: 'Éxitos buscados (k)', type: _cField, defaultValue: 3),
        SolverField(key: 'p', label: 'p de éxito', type: _pField, defaultValue: 0.2),
      ],
      (v) {
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final p = _p(v, 'p');
        final exact = Combinatorics.binomialPmf(n, k, p);
        final atLeast = Combinatorics.binomialAtLeast(n, k, p);
        final atMost = Combinatorics.binomialAtMost(n, k, p);
        return SolverOutput(
          headline: exact.triple,
          probability: exact,
          steps: [
            SolutionStep('Modelo binomial',
                'P(X = $k) = C($n,$k)·p^$k·(1−p)^${n - k}'),
            SolutionStep('Coeficiente',
                'C($n,$k) = ${Combinatorics.formatBig(Combinatorics.combinations(n, k))}'),
            SolutionStep('P(X = $k)', exact.asDecimal(digits: 6), value: exact),
            SolutionStep('P(X ≥ $k)', atLeast.asDecimal(digits: 6),
                value: atLeast),
            SolutionStep('P(X ≤ $k)', atMost.asDecimal(digits: 6), value: atMost),
          ],
          warnings: const [
            'Exige n fijo, ensayos independientes y la misma p en todos.',
          ],
        );
      },
    ),
    TutorMethod.hipergeometrica: SolverRecipe(
      TutorMethod.hipergeometrica,
      const [
        SolverField(key: 'N', label: 'Tamaño de la población (N)', type: _cField, defaultValue: 50),
        SolverField(key: 'K', label: 'Elementos del tipo buscado (K)', type: _cField, defaultValue: 5),
        SolverField(key: 'n', label: 'Tamaño de la muestra (n)', type: _cField, defaultValue: 10),
        SolverField(key: 'k', label: 'Aciertos buscados (k)', type: _cField, defaultValue: 1),
      ],
      (v) {
        final nn = _i(v, 'N');
        final kk = _i(v, 'K');
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final r = Combinatorics.hypergeometric(nn, kk, n, k);
        return SolverOutput(
          headline: r.triple,
          probability: r,
          steps: [
            SolutionStep('Modelo hipergeométrico',
                'P(X = $k) = C($kk,$k)·C(${nn - kk},${n - k}) / C($nn,$n)'),
            SolutionStep('Resultado', r.asDecimal(digits: 6), value: r),
          ],
          warnings: const [
            'Muestreo SIN reposición: cada extracción cambia la composición.',
          ],
        );
      },
    ),
    TutorMethod.combinaciones: SolverRecipe(
      TutorMethod.combinaciones,
      const [
        SolverField(key: 'n', label: 'Elementos disponibles (n)', type: _cField, defaultValue: 52),
        SolverField(key: 'k', label: 'Elementos elegidos (k)', type: _cField, defaultValue: 5),
      ],
      (v) {
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final c = Combinatorics.combinations(n, k);
        return SolverOutput(
          headline: Combinatorics.formatBig(c),
          count: c,
          steps: [
            SolutionStep('Combinaciones', 'C($n,$k) = $n! / ($k!·${n - k}!)'),
            SolutionStep('Resultado', Combinatorics.formatBig(c)),
            const SolutionStep('Comprobación',
                'Intercambia dos elementos elegidos: si es el mismo caso, '
                'efectivamente el orden no importa.'),
          ],
        );
      },
    ),
    TutorMethod.variaciones: SolverRecipe(
      TutorMethod.variaciones,
      const [
        SolverField(key: 'n', label: 'Elementos disponibles (n)', type: _cField, defaultValue: 10),
        SolverField(key: 'k', label: 'Posiciones a llenar (k)', type: _cField, defaultValue: 3),
      ],
      (v) {
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final c = Combinatorics.variations(n, k);
        return SolverOutput(
          headline: Combinatorics.formatBig(c),
          count: c,
          steps: [
            SolutionStep('Variaciones', 'P($n,$k) = $n!/(${n - k})!'),
            SolutionStep('Resultado', Combinatorics.formatBig(c)),
          ],
        );
      },
    ),
    TutorMethod.variacionesConRepeticion: SolverRecipe(
      TutorMethod.variacionesConRepeticion,
      const [
        SolverField(key: 'n', label: 'Opciones por posición (n)', type: _cField, defaultValue: 10),
        SolverField(key: 'k', label: 'Posiciones (k)', type: _cField, defaultValue: 4),
      ],
      (v) {
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final c = Combinatorics.variationsWithRepetition(n, k);
        return SolverOutput(
          headline: Combinatorics.formatBig(c),
          count: c,
          steps: [
            SolutionStep('Variaciones con repetición', '$n^$k'),
            SolutionStep('Resultado', Combinatorics.formatBig(c)),
          ],
        );
      },
    ),
    TutorMethod.combinacionesConRepeticion: SolverRecipe(
      TutorMethod.combinacionesConRepeticion,
      const [
        SolverField(key: 'n', label: 'Tipos disponibles (n)', type: _cField, defaultValue: 5),
        SolverField(key: 'k', label: 'Unidades a elegir (k)', type: _cField, defaultValue: 3),
      ],
      (v) {
        final n = _i(v, 'n');
        final k = _i(v, 'k');
        final c = Combinatorics.combinationsWithRepetition(n, k);
        return SolverOutput(
          headline: Combinatorics.formatBig(c),
          count: c,
          steps: [
            SolutionStep('Combinaciones con repetición',
                'C($n+$k−1, $k) = C(${n + k - 1},$k)'),
            SolutionStep('Resultado', Combinatorics.formatBig(c)),
          ],
        );
      },
    ),
    TutorMethod.permutaciones: SolverRecipe(
      TutorMethod.permutaciones,
      const [
        SolverField(key: 'n', label: 'Elementos (n)', type: _cField, defaultValue: 6),
      ],
      (v) {
        final n = _i(v, 'n');
        final c = Combinatorics.factorial(n);
        return SolverOutput(
          headline: Combinatorics.formatBig(c),
          count: c,
          steps: [
            SolutionStep('Permutaciones', '$n! = ${Combinatorics.formatBig(c)}'),
          ],
        );
      },
    ),
  };

  static bool supports(TutorMethod m) => recipes.containsKey(m);

  static SolverOutput solve(TutorMethod m, Map<String, double> values) {
    final r = recipes[m];
    if (r == null) {
      return SolverOutput(
        headline: '—',
        steps: [
          SolutionStep(m.title, m.condition),
          const SolutionStep('Sin calculadora',
              'Este método se resuelve razonando sobre el enunciado, no '
              'metiendo números en una fórmula.'),
        ],
      );
    }
    return r.compute(values);
  }
}
