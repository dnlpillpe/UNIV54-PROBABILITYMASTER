/// Simuladores: reproducibilidad por semilla y convergencia al valor exacto.
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/domain/math/rational.dart';
import 'package:probability_master/domain/math/rng.dart';
import 'package:probability_master/domain/math/simulators.dart';

void main() {
  group('Generador con semilla', () {
    test('la misma semilla produce la misma secuencia', () {
      final a = SeededRng(12345);
      final b = SeededRng(12345);
      for (var i = 0; i < 200; i++) {
        expect(a.nextInt(1000), b.nextInt(1000));
      }
    });

    test('semillas distintas divergen', () {
      final a = SeededRng(1);
      final b = SeededRng(2);
      var equal = 0;
      for (var i = 0; i < 100; i++) {
        if (a.nextInt(1000) == b.nextInt(1000)) equal++;
      }
      expect(equal, lessThan(10));
    });

    test('nextDouble vive en [0,1)', () {
      final r = SeededRng(7);
      for (var i = 0; i < 1000; i++) {
        final v = r.nextDouble();
        expect(v >= 0 && v < 1, isTrue);
      }
    });

    test('nextInt cubre todo el rango y sin sesgo grosero', () {
      final r = SeededRng(99);
      final counts = List<int>.filled(6, 0);
      for (var i = 0; i < 60000; i++) {
        counts[r.nextInt(6)]++;
      }
      for (final c in counts) {
        expect(c, greaterThan(9000));
        expect(c, lessThan(11000));
      }
    });

    test('weightedIndex respeta los pesos', () {
      final r = SeededRng(5);
      final counts = List<int>.filled(3, 0);
      for (var i = 0; i < 30000; i++) {
        counts[r.weightedIndex([1, 2, 7])]++;
      }
      expect(counts[2] / 30000, closeTo(0.7, 0.02));
      expect(counts[1] / 30000, closeTo(0.2, 0.02));
    });

    test('el barajado conserva los elementos', () {
      final r = SeededRng(3);
      final list = List<int>.generate(52, (i) => i);
      r.shuffle(list);
      expect(list.toSet().length, 52);
    });
  });

  group('Ley de los grandes números', () {
    test('converge al valor teórico con n grande', () {
      final run = Simulators.bernoulliTrials(
        p: Rational.fromInts(1, 2),
        trials: 50000,
        seed: 2026,
      );
      expect(run.observed, closeTo(0.5, 0.02));
      expect(run.trajectory.isNotEmpty, isTrue);
      expect(run.trajectory.last.trials, 50000);
    });

    test('con n pequeño la desviación es grande: ese es el punto', () {
      var maxDeviation = 0.0;
      for (var seed = 1; seed <= 40; seed++) {
        final run = Simulators.bernoulliTrials(
          p: Rational.fromInts(1, 2),
          trials: 20,
          seed: seed,
        );
        final d = (run.observed - 0.5).abs();
        if (d > maxDeviation) maxDeviation = d;
      }
      expect(maxDeviation, greaterThan(0.15),
          reason: 'con 20 lanzamientos debe haber corridas muy desviadas');
    });

    test('la falacia del jugador no se cumple', () {
      final r = Simulators.gamblerFallacy(
        p: Rational.fromInts(1, 2),
        runLength: 4,
        trials: 200000,
        seed: 4242,
      );
      expect(r.occasions, greaterThan(1000));
      expect(r.observed, closeTo(0.5, 0.03));
    });

    test('el desbalance absoluto crece con n', () {
      final small = Simulators.bernoulliTrials(
        p: Rational.fromInts(1, 2),
        trials: 100,
        seed: 11,
      );
      var bigImbalance = 0.0;
      for (var seed = 1; seed <= 20; seed++) {
        final big = Simulators.bernoulliTrials(
          p: Rational.fromInts(1, 2),
          trials: 10000,
          seed: seed,
        );
        bigImbalance += big.absoluteImbalance;
      }
      bigImbalance /= 20;
      expect(bigImbalance, greaterThan(small.absoluteImbalance),
          reason: 'la diferencia absoluta debe crecer, no cerrarse');
    });
  });

  group('Urnas y tamizaje', () {
    test('sin reposición converge al valor hipergeométrico', () {
      final run = Simulators.urnDraws(
        counts: const {'R': 4, 'A': 6},
        targetColor: 'R',
        draws: 2,
        withReplacement: false,
        trials: 40000,
        seed: 808,
      );
      expect(run.theoretical.asFraction, '2/15');
      expect(run.observed, closeTo(2 / 15, 0.02));
    });

    test('con reposición converge a (k/n)^d', () {
      final run = Simulators.urnDraws(
        counts: const {'R': 4, 'A': 6},
        targetColor: 'R',
        draws: 2,
        withReplacement: true,
        trials: 40000,
        seed: 909,
      );
      expect(run.theoretical.asFraction, '4/25');
      expect(run.observed, closeTo(0.16, 0.02));
    });

    test('el tamizaje reproduce el valor predictivo positivo', () {
      final r = Simulators.screening(
        population: 200000,
        prevalence: 0.01,
        sensitivity: 0.99,
        specificity: 0.95,
        seed: 31415,
      );
      expect(r.ppv, closeTo(0.1667, 0.02));
      expect(r.falsePositives, greaterThan(r.truePositives));
    });
  });

  group('Dos eventos', () {
    test('las cuatro regiones suman la población', () {
      final r = Simulators.twoEvents(
        population: 5000,
        pA: 0.4,
        pB: 0.3,
        pAandB: 0.12,
        seed: 77,
      );
      expect(r.total, 5000);
      expect(r.pA, closeTo(0.4, 0.03));
      expect(r.pUnion, closeTo(0.58, 0.03));
      // Con estos valores A y B son independientes: 0,4 x 0,3 = 0,12.
      expect(r.productOfMarginals, closeTo(r.pBoth, 0.03));
    });

    test('rechaza datos incoherentes', () {
      expect(
        () => Simulators.twoEvents(
          population: 100,
          pA: 0.2,
          pB: 0.2,
          pAandB: 0.5,
          seed: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Conteo', () {
    test('cumpleaños: la simulación confirma la fórmula', () {
      final r = Simulators.birthdaySimulation(
        groupSize: 23,
        trials: 20000,
        seed: 1234,
      );
      expect(r.theoretical.toDouble(), closeTo(0.5073, 1e-3));
      expect(r.observed, closeTo(0.5073, 0.02));
    });

    test('lotería: casi siempre cero aciertos', () {
      final r = Simulators.lottery(
        numbers: 49,
        picks: 6,
        ticketsPlayed: 5000,
        seed: 55,
      );
      expect(r.wins, 0);
      expect(r.combinations, BigInt.from(13983816));
      expect(r.yearsPerWin, greaterThan(200000));
    });
  });
}
