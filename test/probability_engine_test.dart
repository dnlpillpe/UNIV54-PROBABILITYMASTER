import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/domain/math/probability_engine.dart';
import 'package:probability_master/domain/math/rational.dart';
import 'package:probability_master/domain/math/sample_space.dart';

void main() {
  group('Reglas', () {
    test('Laplace', () {
      final r = ProbabilityEngine.laplace(BigInt.from(6), BigInt.from(36));
      expect(r.value.asFraction, '1/6');
      expect(r.warnings, isNotEmpty,
          reason: 'Laplace siempre advierte sobre la equiprobabilidad');
    });

    test('Laplace rechaza datos imposibles', () {
      expect(
        () => ProbabilityEngine.laplace(BigInt.from(7), BigInt.from(6)),
        throwsArgumentError,
      );
      expect(
        () => ProbabilityEngine.laplace(BigInt.one, BigInt.zero),
        throwsArgumentError,
      );
    });

    test('regla general de la suma', () {
      final r = ProbabilityEngine.unionGeneral(
        Rational.fromInts(2, 5),
        Rational.fromInts(3, 10),
        Rational.fromInts(3, 25),
      );
      expect(r.value.toDouble(), closeTo(0.58, 1e-12));
    });

    test('la suma rechaza datos incoherentes', () {
      expect(
        () => ProbabilityEngine.unionGeneral(
          Rational.fromInts(9, 10),
          Rational.fromInts(9, 10),
          Rational.zero,
        ),
        throwsArgumentError,
      );
    });

    test('complemento', () {
      expect(
        ProbabilityEngine.complement(Rational.fromInts(29, 50))
            .value
            .toDouble(),
        closeTo(0.42, 1e-12),
      );
    });

    test('al menos uno no es n·p', () {
      final r = ProbabilityEngine.atLeastOne(Rational.fromInts(1, 10), 20);
      expect(r.value.toDouble(), closeTo(0.8784233, 1e-6));
      expect(r.value <= Rational.one, isTrue);
      // El error clásico daría 2.
      expect(r.value.toDouble() < 1, isTrue);
    });

    test('al menos uno nunca llega a 1', () {
      for (final n in [10, 100, 1000, 5000]) {
        final r = ProbabilityEngine.atLeastOne(Rational.fromInts(1, 100), n);
        expect(r.value < Rational.one, isTrue);
      }
    });

    test('condicional', () {
      final r = ProbabilityEngine.conditional(
        Rational.fromInts(45, 100),
        Rational.fromInts(55, 100),
      );
      expect(r.value.toDouble(), closeTo(45 / 55, 1e-12));
      expect(
        () => ProbabilityEngine.conditional(Rational.zero, Rational.zero),
        throwsArgumentError,
      );
    });

    test('independencia: excluyentes con probabilidad positiva NO lo son', () {
      final space = SampleSpace.dice(1);
      final par = EventDef.of(space, 'A', 'par', (o) => o.values.first.isEven);
      final impar =
          EventDef.of(space, 'B', 'impar', (o) => o.values.first.isOdd);
      expect(par.isDisjointWith(impar), isTrue);
      expect(ProbabilityEngine.eventsIndependent(space, par, impar), isFalse);
    });

    test('independencia real: dos monedas', () {
      final space = SampleSpace.coins(2);
      final first =
          EventDef.of(space, 'A', 'cara en la 1.ª', (o) => o.parts[0] == 'C');
      final second =
          EventDef.of(space, 'B', 'cara en la 2.ª', (o) => o.parts[1] == 'C');
      expect(ProbabilityEngine.eventsIndependent(space, first, second), isTrue);
      expect(first.isDisjointWith(second), isFalse);
    });

    test('fiabilidad en serie y en paralelo', () {
      final r = List.filled(5, Rational.fromInts(98, 100));
      expect(
        ProbabilityEngine.seriesReliability(r).value.toDouble(),
        closeTo(0.9039207968, 1e-9),
      );
      final p = List.filled(3, Rational.fromInts(80, 100));
      expect(
        ProbabilityEngine.parallelReliability(p).value.toDouble(),
        closeTo(0.992, 1e-12),
      );
    });

    test('probabilidad total', () {
      final r = ProbabilityEngine.totalProbability(
        [Rational.fromInts(3, 5), Rational.fromInts(2, 5)],
        [Rational.fromInts(1, 50), Rational.fromInts(1, 20)],
      );
      expect(r.value.toDouble(), closeTo(0.032, 1e-12));
    });

    test('Bayes: la máquina defectuosa', () {
      final r = ProbabilityEngine.bayes(
        [Rational.fromInts(3, 5), Rational.fromInts(2, 5)],
        [Rational.fromInts(1, 50), Rational.fromInts(1, 20)],
      );
      expect(r.value.toDouble(), closeTo(0.375, 1e-12));
    });

    test('prueba diagnóstica: el VPP no es la sensibilidad', () {
      final r = ProbabilityEngine.diagnosticTest(
        prevalence: Rational.fromInts(1, 100),
        sensitivity: Rational.fromInts(99, 100),
        specificity: Rational.fromInts(95, 100),
      );
      expect(r.value.toDouble(), closeTo(0.16666666, 1e-6));

      final r10 = ProbabilityEngine.diagnosticTest(
        prevalence: Rational.fromInts(1, 10),
        sensitivity: Rational.fromInts(99, 100),
        specificity: Rational.fromInts(95, 100),
      );
      expect(r10.value.toDouble(), closeTo(0.6875, 1e-9));
      // Mismo test, distinta población: el VPP se multiplica por más de 4.
      expect(r10.value > r.value, isTrue);
    });

    test('momios', () {
      expect(
        ProbabilityEngine.oddsToProbability(1, 4).asFraction,
        '1/5',
      );
      expect(
        ProbabilityEngine.probabilityToOdds(Rational.fromInts(1, 5)),
        '1 a 4',
      );
    });

    test('todo resultado del motor está en [0,1]', () {
      for (var i = 1; i <= 9; i++) {
        for (var j = 1; j <= 9; j++) {
          final pa = Rational.fromInts(i, 10);
          final pb = Rational.fromInts(j, 10);
          final maxAb = pa < pb ? pa : pb;
          final r = ProbabilityEngine.unionGeneral(
            pa,
            pb,
            (pa + pb) > Rational.one ? (pa + pb - Rational.one) : maxAb,
          );
          expect(r.value >= Rational.zero, isTrue);
          expect(r.value <= Rational.one, isTrue);
        }
      }
    });
  });
}
