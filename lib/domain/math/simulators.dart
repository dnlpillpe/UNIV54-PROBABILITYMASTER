/// Simuladores de los cinco laboratorios.
///
/// Todos comparten la misma forma: reciben parámetros y una semilla, devuelven
/// conteos observados **y** el valor teórico exacto, para que la pantalla
/// pueda mostrar los dos juntos. Ese contraste es el mecanismo educativo de
/// la app: la simulación no ilustra la fórmula, la **audita**.
library;

import 'combinatorics.dart';
import 'rational.dart';
import 'rng.dart';
import 'sample_space.dart';

/// Punto de la trayectoria de frecuencia relativa.
class TrajectoryPoint {
  final int trials;
  final double relativeFrequency;
  const TrajectoryPoint(this.trials, this.relativeFrequency);
}

/// Resultado de una corrida de simulación.
class SimulationRun {
  final int trials;
  final int successes;
  final Rational theoretical;
  final List<TrajectoryPoint> trajectory;

  /// Conteo por categoría, cuando el experimento tiene más de dos resultados.
  final Map<String, int> categoryCounts;

  /// Racha más larga observada del resultado marcado como éxito.
  final int longestStreak;
  final int seed;

  const SimulationRun({
    required this.trials,
    required this.successes,
    required this.theoretical,
    required this.trajectory,
    required this.seed,
    this.categoryCounts = const {},
    this.longestStreak = 0,
  });

  double get observed => trials == 0 ? 0 : successes / trials;
  double get theoreticalValue => theoretical.toDouble();

  /// Diferencia absoluta observada − teórica (lo que «no se cierra» con
  /// pocos ensayos).
  double get absoluteError => (observed - theoreticalValue).abs();

  /// Desviación en número de casos, no en proporción. Es la cifra que
  /// desmonta la «ley de los promedios»: al crecer n, la proporción se
  /// acerca pero el **desbalance absoluto crece**.
  double get absoluteImbalance =>
      (successes - trials * theoreticalValue).abs();
}

class Simulators {
  const Simulators._();

  /// Laboratorio 1 — Ley de los grandes números.
  /// Ensayos de Bernoulli repetidos con probabilidad [p].
  static SimulationRun bernoulliTrials({
    required Rational p,
    required int trials,
    required int seed,
    int trajectoryPoints = 120,
  }) {
    final rng = SeededRng(seed);
    final pv = p.toDouble();
    var successes = 0;
    var streak = 0;
    var longest = 0;
    final traj = <TrajectoryPoint>[];
    final every = trials <= trajectoryPoints
        ? 1
        : (trials / trajectoryPoints).ceil();
    for (var i = 1; i <= trials; i++) {
      final hit = rng.bernoulli(pv);
      if (hit) {
        successes++;
        streak++;
        if (streak > longest) longest = streak;
      } else {
        streak = 0;
      }
      if (i % every == 0 || i == trials || i <= 20) {
        traj.add(TrajectoryPoint(i, successes / i));
      }
    }
    return SimulationRun(
      trials: trials,
      successes: successes,
      theoretical: p,
      trajectory: traj,
      seed: seed,
      longestStreak: longest,
      categoryCounts: {'Éxito': successes, 'Fracaso': trials - successes},
    );
  }

  /// Lanzamientos de un dado (o ruleta) con pesos, contando por categoría.
  static SimulationRun categorical({
    required List<String> labels,
    required List<int> weights,
    required int targetIndex,
    required int trials,
    required int seed,
    int trajectoryPoints = 120,
  }) {
    final rng = SeededRng(seed);
    final counts = <String, int>{for (final l in labels) l: 0};
    var successes = 0;
    var streak = 0;
    var longest = 0;
    final traj = <TrajectoryPoint>[];
    final every =
        trials <= trajectoryPoints ? 1 : (trials / trajectoryPoints).ceil();
    for (var i = 1; i <= trials; i++) {
      final idx = rng.weightedIndex(weights);
      counts[labels[idx]] = (counts[labels[idx]] ?? 0) + 1;
      if (idx == targetIndex) {
        successes++;
        streak++;
        if (streak > longest) longest = streak;
      } else {
        streak = 0;
      }
      if (i % every == 0 || i == trials || i <= 20) {
        traj.add(TrajectoryPoint(i, successes / i));
      }
    }
    final totalW = weights.fold<int>(0, (a, b) => a + b);
    return SimulationRun(
      trials: trials,
      successes: successes,
      theoretical: Rational.fromInts(weights[targetIndex], totalW),
      trajectory: traj,
      seed: seed,
      categoryCounts: counts,
      longestStreak: longest,
    );
  }

  /// Prueba directa de la falacia del jugador: tras observar [runLength]
  /// éxitos seguidos, ¿con qué frecuencia el siguiente ensayo es éxito?
  /// La respuesta correcta es p; la intuición dice «menos».
  static GamblerFallacyResult gamblerFallacy({
    required Rational p,
    required int runLength,
    required int trials,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    final pv = p.toDouble();
    var current = 0;
    var occasions = 0;
    var followedBySuccess = 0;
    for (var i = 0; i < trials; i++) {
      final hit = rng.bernoulli(pv);
      if (current >= runLength) {
        occasions++;
        if (hit) followedBySuccess++;
      }
      current = hit ? current + 1 : 0;
    }
    return GamblerFallacyResult(
      occasions: occasions,
      followedBySuccess: followedBySuccess,
      theoretical: p,
      seed: seed,
    );
  }

  /// Laboratorio 2 — muestreo de un espacio muestral construido, para
  /// comparar la frecuencia observada de cada resultado con su peso exacto.
  static Map<String, int> sampleSpaceCounts({
    required SampleSpace space,
    required int trials,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    final counts = <String, int>{};
    final weights = space.isUniform
        ? List<int>.filled(space.size, 1)
        : space.weights;
    for (var i = 0; i < trials; i++) {
      final idx = rng.weightedIndex(weights);
      final key = space.outcomes[idx].label;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Laboratorio 3 — población simulada con dos atributos, para ver
  /// simultáneamente unión, intersección, exclusión e independencia.
  static TwoEventPopulation twoEvents({
    required int population,
    required double pA,
    required double pB,
    required double pAandB,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    // Celdas de la tabla de contingencia.
    final pAonly = pA - pAandB;
    final pBonly = pB - pAandB;
    final pNone = 1 - pA - pB + pAandB;
    if (pAonly < -1e-9 || pBonly < -1e-9 || pNone < -1e-9) {
      throw ArgumentError('Los datos son incoherentes: P(A∩B) fuera de rango');
    }
    final weights = [
      (pAandB * 1000000).round(),
      (pAonly * 1000000).round(),
      (pBonly * 1000000).round(),
      (pNone * 1000000).round(),
    ];
    var both = 0, onlyA = 0, onlyB = 0, neither = 0;
    for (var i = 0; i < population; i++) {
      switch (rng.weightedIndex(weights)) {
        case 0:
          both++;
          break;
        case 1:
          onlyA++;
          break;
        case 2:
          onlyB++;
          break;
        default:
          neither++;
      }
    }
    return TwoEventPopulation(
      both: both,
      onlyA: onlyA,
      onlyB: onlyB,
      neither: neither,
      seed: seed,
    );
  }

  /// Laboratorio 4 — extracciones de urna, con o sin reposición.
  /// Devuelve la frecuencia observada del evento «las [draws] extracciones
  /// son del color objetivo».
  static SimulationRun urnDraws({
    required Map<String, int> counts,
    required String targetColor,
    required int draws,
    required bool withReplacement,
    required int trials,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    final balls = <String>[];
    counts.forEach((c, n) {
      for (var i = 0; i < n; i++) {
        balls.add(c);
      }
    });
    var successes = 0;
    final traj = <TrajectoryPoint>[];
    final every = trials <= 120 ? 1 : (trials / 120).ceil();
    for (var t = 1; t <= trials; t++) {
      var ok = true;
      if (withReplacement) {
        for (var d = 0; d < draws; d++) {
          if (balls[rng.nextInt(balls.length)] != targetColor) ok = false;
        }
      } else {
        final picked = rng.sampleWithoutReplacement(balls, draws);
        ok = picked.every((b) => b == targetColor);
      }
      if (ok) successes++;
      if (t % every == 0 || t == trials || t <= 20) {
        traj.add(TrajectoryPoint(t, successes / t));
      }
    }
    final k = counts[targetColor] ?? 0;
    final n = balls.length;
    final theo = withReplacement
        ? Rational.fromInts(k, n).pow(draws)
        : Rational(
            Combinatorics.combinations(k, draws),
            Combinatorics.combinations(n, draws),
          );
    return SimulationRun(
      trials: trials,
      successes: successes,
      theoretical: theo,
      trajectory: traj,
      seed: seed,
    );
  }

  /// Laboratorio 4 — tamizaje: simula una población y cuenta positivos
  /// verdaderos y falsos. Es la versión contable de Bayes, la que convence.
  static ScreeningResult screening({
    required int population,
    required double prevalence,
    required double sensitivity,
    required double specificity,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    var sick = 0, truePos = 0, falsePos = 0, trueNeg = 0, falseNeg = 0;
    for (var i = 0; i < population; i++) {
      final isSick = rng.bernoulli(prevalence);
      if (isSick) sick++;
      final positive =
          isSick ? rng.bernoulli(sensitivity) : !rng.bernoulli(specificity);
      if (isSick && positive) truePos++;
      if (isSick && !positive) falseNeg++;
      if (!isSick && positive) falsePos++;
      if (!isSick && !positive) trueNeg++;
    }
    return ScreeningResult(
      population: population,
      sick: sick,
      truePositives: truePos,
      falsePositives: falsePos,
      trueNegatives: trueNeg,
      falseNegatives: falseNeg,
      seed: seed,
    );
  }

  /// Laboratorio 5 — problema del cumpleaños por simulación.
  static SimulationRun birthdaySimulation({
    required int groupSize,
    required int trials,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    var successes = 0;
    final traj = <TrajectoryPoint>[];
    final every = trials <= 120 ? 1 : (trials / 120).ceil();
    for (var t = 1; t <= trials; t++) {
      final seen = <int>{};
      var collision = false;
      for (var i = 0; i < groupSize; i++) {
        final d = rng.nextInt(365);
        if (!seen.add(d)) {
          collision = true;
          break;
        }
      }
      if (collision) successes++;
      if (t % every == 0 || t == trials || t <= 20) {
        traj.add(TrajectoryPoint(t, successes / t));
      }
    }
    return SimulationRun(
      trials: trials,
      successes: successes,
      theoretical: Combinatorics.birthdayCollision(groupSize),
      trajectory: traj,
      seed: seed,
    );
  }

  /// Laboratorio 5 — lotería: cuántos sorteos harían falta, en promedio,
  /// para acertar. Simula y compara con 1/p.
  static LotteryResult lottery({
    required int numbers,
    required int picks,
    required int ticketsPlayed,
    required int seed,
  }) {
    final rng = SeededRng(seed);
    final total = Combinatorics.combinations(numbers, picks);
    var wins = 0;
    final pool = List<int>.generate(numbers, (i) => i + 1);
    final ticket = rng.sampleWithoutReplacement(pool, picks).toSet();
    for (var i = 0; i < ticketsPlayed; i++) {
      final draw = rng.sampleWithoutReplacement(pool, picks).toSet();
      if (draw.length == ticket.length &&
          draw.difference(ticket).isEmpty) {
        wins++;
      }
    }
    return LotteryResult(
      combinations: total,
      ticketsPlayed: ticketsPlayed,
      wins: wins,
      seed: seed,
    );
  }
}

class GamblerFallacyResult {
  final int occasions;
  final int followedBySuccess;
  final Rational theoretical;
  final int seed;

  const GamblerFallacyResult({
    required this.occasions,
    required this.followedBySuccess,
    required this.theoretical,
    required this.seed,
  });

  double get observed => occasions == 0 ? 0 : followedBySuccess / occasions;
}

class TwoEventPopulation {
  final int both;
  final int onlyA;
  final int onlyB;
  final int neither;
  final int seed;

  const TwoEventPopulation({
    required this.both,
    required this.onlyA,
    required this.onlyB,
    required this.neither,
    required this.seed,
  });

  int get total => both + onlyA + onlyB + neither;
  int get countA => both + onlyA;
  int get countB => both + onlyB;
  int get union => both + onlyA + onlyB;

  double get pA => total == 0 ? 0 : countA / total;
  double get pB => total == 0 ? 0 : countB / total;
  double get pBoth => total == 0 ? 0 : both / total;
  double get pUnion => total == 0 ? 0 : union / total;

  /// P(A)·P(B) frente a P(A∩B): la comprobación de independencia que el
  /// estudiante hace con sus propios números simulados.
  double get productOfMarginals => pA * pB;

  double get pAgivenB => countB == 0 ? 0 : both / countB;
  double get pBgivenA => countA == 0 ? 0 : both / countA;
}

class ScreeningResult {
  final int population;
  final int sick;
  final int truePositives;
  final int falsePositives;
  final int trueNegatives;
  final int falseNegatives;
  final int seed;

  const ScreeningResult({
    required this.population,
    required this.sick,
    required this.truePositives,
    required this.falsePositives,
    required this.trueNegatives,
    required this.falseNegatives,
    required this.seed,
  });

  int get positives => truePositives + falsePositives;

  /// Valor predictivo positivo observado.
  double get ppv => positives == 0 ? 0 : truePositives / positives;

  int get negatives => trueNegatives + falseNegatives;
  double get npv => negatives == 0 ? 0 : trueNegatives / negatives;
}

class LotteryResult {
  final BigInt combinations;
  final int ticketsPlayed;
  final int wins;
  final int seed;

  const LotteryResult({
    required this.combinations,
    required this.ticketsPlayed,
    required this.wins,
    required this.seed,
  });

  /// Años jugando una vez por semana para esperar un acierto.
  double get yearsPerWin => combinations.toDouble() / 52.0;
}
