import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/domain/math/combinatorics.dart';
import 'package:probability_master/domain/math/rational.dart';

void main() {
  group('Combinatoria', () {
    test('factorial', () {
      expect(Combinatorics.factorial(0), BigInt.one);
      expect(Combinatorics.factorial(5), BigInt.from(120));
      expect(Combinatorics.factorial(10), BigInt.from(3628800));
    });

    test('combinaciones y su simetría', () {
      expect(Combinatorics.combinations(5, 3), BigInt.from(10));
      expect(Combinatorics.combinations(52, 5), BigInt.from(2598960));
      expect(
        Combinatorics.combinations(52, 50),
        Combinatorics.combinations(52, 2),
      );
      expect(Combinatorics.combinations(3, 5), BigInt.zero);
    });

    test('C(49,6): el número de la lotería', () {
      expect(Combinatorics.combinations(49, 6), BigInt.from(13983816));
    });

    test('variaciones', () {
      expect(Combinatorics.variations(5, 3), BigInt.from(60));
      expect(Combinatorics.variations(10, 4), BigInt.from(5040));
      expect(Combinatorics.variationsWithRepetition(10, 4),
          BigInt.from(10000));
    });

    test('variaciones = combinaciones x k!', () {
      for (var n = 2; n <= 8; n++) {
        for (var k = 1; k <= n; k++) {
          expect(
            Combinatorics.variations(n, k),
            Combinatorics.combinations(n, k) * Combinatorics.factorial(k),
            reason: 'falla en n=$n k=$k',
          );
        }
      }
    });

    test('permutaciones con repetición', () {
      // CASAS: dos A, dos S, una C.
      expect(
        Combinatorics.permutationsWithRepetition([2, 2, 1]),
        BigInt.from(30),
      );
      // Rutas en una malla 4x3.
      expect(
        Combinatorics.permutationsWithRepetition([4, 3]),
        BigInt.from(35),
      );
    });

    test('combinaciones con repetición', () {
      expect(Combinatorics.combinationsWithRepetition(5, 3), BigInt.from(35));
    });

    test('la suma de C(n,k) para todo k es 2^n', () {
      for (var n = 0; n <= 12; n++) {
        var acc = BigInt.zero;
        for (var k = 0; k <= n; k++) {
          acc += Combinatorics.combinations(n, k);
        }
        expect(acc, Combinatorics.subsets(n));
      }
    });

    test('problema del cumpleaños', () {
      expect(
        Combinatorics.birthdayCollision(23).toDouble(),
        closeTo(0.507297, 1e-5),
      );
      expect(
        Combinatorics.birthdayCollision(50).toDouble(),
        closeTo(0.970374, 1e-5),
      );
      expect(Combinatorics.birthdayCollision(1).isZero, isTrue);
      expect(Combinatorics.birthdayCollision(400).isOne, isTrue);
    });

    test('binomial suma 1 sobre todos los k', () {
      final p = Rational.fromInts(3, 10);
      var acc = Rational.zero;
      for (var k = 0; k <= 12; k++) {
        acc = acc + Combinatorics.binomialPmf(12, k, p);
      }
      expect(acc.isOne, isTrue);
    });

    test('hipergeométrica suma 1', () {
      var acc = Rational.zero;
      for (var k = 0; k <= 5; k++) {
        acc = acc + Combinatorics.hypergeometric(50, 5, 10, k);
      }
      expect(acc.toDouble(), closeTo(1.0, 1e-12));
    });

    test('formato con separador de miles', () {
      expect(Combinatorics.formatBig(BigInt.from(13983816)), '13 983 816');
      expect(Combinatorics.formatBig(BigInt.from(100)), '100');
    });

    test('enumerar coincide con contar', () {
      expect(Combinatorics.listCombinations(5, 3).length, 10);
      expect(Combinatorics.listVariations(5, 3).length, 60);
    });
  });
}
