/// Corrección de ejercicios y casos.
///
/// Implementa la decisión D4: en los ítems de decisión la elección vale 0,6 y
/// la justificación 0,4, y el «acierto ciego» se registra como tal.
library;

import '../math/combinatorics.dart';
import '../math/figure_registry.dart';
import '../math/rational.dart';
import '../models/case_study.dart';
import '../models/exercise.dart';
import '../models/progress.dart';

/// Resultado de corregir un ítem.
class GradeResult {
  final double score;
  final bool choiceCorrect;
  final bool? justificationCorrect;

  /// Retroalimentación de la alternativa elegida.
  final String feedback;

  /// Retroalimentación de la justificación elegida.
  final String? justificationFeedback;

  final List<String> misconceptionsHit;
  final List<String> detects;

  const GradeResult({
    required this.score,
    required this.choiceCorrect,
    required this.feedback,
    this.justificationCorrect,
    this.justificationFeedback,
    this.misconceptionsHit = const [],
    this.detects = const [],
  });

  bool get blindHit => choiceCorrect && justificationCorrect == false;

  AttemptRecord toRecord(String itemId, String moduleId, DateTime at) =>
      AttemptRecord(
        itemId: itemId,
        moduleId: moduleId,
        score: score,
        choiceCorrect: choiceCorrect,
        justificationCorrect: justificationCorrect,
        misconceptionsHit: misconceptionsHit,
        detects: detects,
        timestamp: at.millisecondsSinceEpoch,
      );
}

class GradingService {
  const GradingService();

  /// Corrige un ejercicio de alternativas (concepto, clasificación,
  /// auditoría) o de decisión justificada.
  GradeResult gradeChoice(
    Exercise ex, {
    required int choiceIndex,
    int? justificationIndex,
  }) {
    if (choiceIndex < 0 || choiceIndex >= ex.choices.length) {
      throw ArgumentError('Alternativa fuera de rango');
    }
    final chosen = ex.choices[choiceIndex];
    final hits = <String>[
      if (!chosen.correct && chosen.misconceptionId != null)
        chosen.misconceptionId!,
    ];

    if (ex.kind != ExerciseKind.decisionJustificada) {
      return GradeResult(
        score: chosen.correct ? 1.0 : 0.0,
        choiceCorrect: chosen.correct,
        feedback: chosen.feedback,
        misconceptionsHit: hits,
        detects: ex.detects,
      );
    }

    if (justificationIndex == null ||
        justificationIndex < 0 ||
        justificationIndex >= ex.justifications.length) {
      throw ArgumentError('Este ejercicio exige justificación');
    }
    final just = ex.justifications[justificationIndex];
    if (!just.correct && just.misconceptionId != null) {
      hits.add(just.misconceptionId!);
    }
    final score = (chosen.correct ? 0.6 : 0.0) + (just.correct ? 0.4 : 0.0);
    return GradeResult(
      score: score,
      choiceCorrect: chosen.correct,
      justificationCorrect: just.correct,
      feedback: chosen.feedback,
      justificationFeedback: just.feedback,
      misconceptionsHit: hits,
      detects: ex.detects,
    );
  }

  /// Corrige un caso profesional (siempre decisión + justificación).
  GradeResult gradeCase(
    CaseStudy c, {
    required int optionIndex,
    int? justificationIndex,
  }) {
    final chosen = c.options[optionIndex];
    final hits = <String>[
      if (!chosen.correct && chosen.misconceptionId != null)
        chosen.misconceptionId!,
    ];
    if (c.justifications.isEmpty) {
      return GradeResult(
        score: chosen.correct ? 1.0 : 0.0,
        choiceCorrect: chosen.correct,
        feedback: chosen.feedback,
        misconceptionsHit: hits,
        detects: c.detects,
      );
    }
    final ji = justificationIndex ?? -1;
    if (ji < 0 || ji >= c.justifications.length) {
      throw ArgumentError('El caso exige justificación');
    }
    final just = c.justifications[ji];
    if (!just.correct && just.misconceptionId != null) {
      hits.add(just.misconceptionId!);
    }
    return GradeResult(
      score: (chosen.correct ? 0.6 : 0.0) + (just.correct ? 0.4 : 0.0),
      choiceCorrect: chosen.correct,
      justificationCorrect: just.correct,
      feedback: chosen.feedback,
      justificationFeedback: just.feedback,
      misconceptionsHit: hits,
      detects: c.detects,
    );
  }

  /// Corrige una respuesta numérica escrita por el estudiante.
  /// Acepta `3/8`, `0.375`, `0,375` y `37.5%`.
  GradeResult gradeNumeric(Exercise ex, String raw) {
    final target = ex.numeric;
    if (target == null) {
      throw ArgumentError('El ejercicio no tiene respuesta numérica');
    }
    // Las respuestas de conteo se comparan como enteros exactos: en el
    // módulo 3 «aproximadamente 2,6 millones» no es una respuesta.
    if (target.figure.format == FigureFormat.count) {
      final expectedCount = FigureRegistry.evaluateCount(target.figure);
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      final given = digits.isEmpty ? null : BigInt.tryParse(digits);
      if (given == null) {
        return GradeResult(
          score: 0,
          choiceCorrect: false,
          feedback: 'Escribe el número entero de casos, sin unidades.',
          detects: ex.detects,
        );
      }
      if (given == expectedCount) {
        return GradeResult(
          score: 1,
          choiceCorrect: true,
          feedback: 'Correcto: ${Combinatorics.formatBig(expectedCount)}.',
          detects: ex.detects,
        );
      }
      return GradeResult(
        score: 0,
        choiceCorrect: false,
        feedback: _countFeedback(given, expectedCount),
        misconceptionsHit: _countMisconceptions(given, expectedCount),
        detects: ex.detects,
      );
    }

    final expected = FigureRegistry.evaluate(target.figure);
    final parsed = parseAnswer(raw);
    if (parsed == null) {
      return GradeResult(
        score: 0,
        choiceCorrect: false,
        feedback: 'No se pudo leer la respuesta. Escribe una fracción '
            '(por ejemplo 3/8), un decimal (0,375) o un porcentaje (37,5 %).',
        detects: ex.detects,
      );
    }
    final ok = _close(parsed, expected, target.tolerance);
    if (ok) {
      return GradeResult(
        score: 1,
        choiceCorrect: true,
        feedback: 'Correcto: ${expected.triple}',
        detects: ex.detects,
      );
    }
    return GradeResult(
      score: 0,
      choiceCorrect: false,
      feedback: _numericFeedback(parsed, expected),
      misconceptionsHit: _numericMisconceptions(parsed, expected),
      detects: ex.detects,
    );
  }

  /// Diagnostica el error de conteo por el factor entre lo dado y lo
  /// esperado: un factor k! delata la confusión orden/combinación.
  static String _countFeedback(BigInt got, BigInt expected) {
    if (got > expected && expected > BigInt.zero && got % expected == BigInt.zero) {
      final factor = (got ~/ expected).toInt();
      final k = _factorialIndex(factor);
      if (k != null) {
        return 'Tu resultado es $factor = $k! veces el correcto '
            '(${Combinatorics.formatBig(expected)}). Contaste el orden donde '
            'no importaba: cada grupo se te repitió $k! veces.';
      }
    }
    if (expected > got && got > BigInt.zero && expected % got == BigInt.zero) {
      final factor = (expected ~/ got).toInt();
      final k = _factorialIndex(factor);
      if (k != null) {
        return 'Tu resultado es $factor = $k! veces MENOR que el correcto '
            '(${Combinatorics.formatBig(expected)}). Ignoraste el orden donde '
            'sí importaba.';
      }
    }
    return 'No es el valor. El correcto es '
        '${Combinatorics.formatBig(expected)}. Revisa dos preguntas: '
        '¿importa el orden? ¿se pueden repetir elementos?';
  }

  static List<String> _countMisconceptions(BigInt got, BigInt expected) {
    if (expected == BigInt.zero || got == BigInt.zero) return const [];
    final bigger = got > expected ? got : expected;
    final smaller = got > expected ? expected : got;
    if (bigger % smaller == BigInt.zero) {
      final factor = (bigger ~/ smaller).toInt();
      if (_factorialIndex(factor) != null) {
        return const ['orden_importa_confundido'];
      }
    }
    return const [];
  }

  /// Devuelve k si [value] es k! con k ≥ 2; si no, `null`.
  static int? _factorialIndex(int value) {
    var acc = 1;
    for (var k = 2; k <= 12; k++) {
      acc *= k;
      if (acc == value) return k;
      if (acc > value) return null;
    }
    return null;
  }

  static bool _close(Rational a, Rational b, double tol) {
    if (a == b) return true;
    return (a.toDouble() - b.toDouble()).abs() <= tol;
  }

  /// Diagnostica el error numérico más frecuente en vez de decir «mal».
  static String _numericFeedback(Rational got, Rational expected) {
    final g = got.toDouble();
    final e = expected.toDouble();
    if (g > 1) {
      return 'Una probabilidad nunca puede ser mayor que 1. '
          'Revisa si sumaste eventos que se solapan o si dividiste al revés.';
    }
    if (g < 0) {
      return 'Una probabilidad nunca es negativa. Revisa el signo del '
          'complemento.';
    }
    if ((g - (1 - e)).abs() < 1e-9) {
      return 'Ese es el valor del complemento: calculaste P(A\') en vez de '
          'P(A). La respuesta es ${expected.triple}.';
    }
    if (e != 0 && (g - 1 / e).abs() < 1e-9 && 1 / e <= 1) {
      return 'Invertiste la fracción. La respuesta es ${expected.triple}.';
    }
    if (e != 0 && g > e * 1.9 && g < e * 2.1) {
      return 'Tu valor es el doble del correcto: probablemente contaste dos '
          'veces la intersección, o duplicaste un caso simétrico. '
          'La respuesta es ${expected.triple}.';
    }
    if (e != 0 && g > e * 0.45 && g < e * 0.55) {
      return 'Tu valor es la mitad del correcto: seguramente olvidaste un '
          'orden posible. La respuesta es ${expected.triple}.';
    }
    return 'No es el valor. La respuesta correcta es ${expected.triple}.';
  }

  static List<String> _numericMisconceptions(Rational got, Rational expected) {
    final g = got.toDouble();
    final e = expected.toDouble();
    if (g > 1) return const ['probabilidad_mayor_que_uno'];
    if ((g - (1 - e)).abs() < 1e-9) return const ['complemento_invertido'];
    return const [];
  }

  /// Lee una respuesta escrita en cualquiera de las tres formas.
  static Rational? parseAnswer(String raw) {
    var s = raw.trim().replaceAll(' ', '');
    if (s.isEmpty) return null;
    var percent = false;
    if (s.endsWith('%')) {
      percent = true;
      s = s.substring(0, s.length - 1);
    }
    s = s.replaceAll(',', '.');
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length != 2) return null;
      final n = double.tryParse(parts[0]);
      final d = double.tryParse(parts[1]);
      if (n == null || d == null || d == 0) return null;
      final r = Rational.fromDouble(n / d);
      return percent ? r / Rational.fromInts(100) : r;
    }
    final v = double.tryParse(s);
    if (v == null) return null;
    final r = Rational.fromDouble(v);
    return percent ? r / Rational.fromInts(100) : r;
  }
}
