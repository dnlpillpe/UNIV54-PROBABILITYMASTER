import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/data/content/sample_space_catalog.dart';
import 'package:probability_master/domain/math/sample_space.dart';

void main() {
  group('Espacios muestrales', () {
    test('monedas: 2^n resultados equiprobables', () {
      expect(SampleSpace.coins(1).size, 2);
      expect(SampleSpace.coins(2).size, 4);
      expect(SampleSpace.coins(3).size, 8);
      expect(SampleSpace.coins(4).size, 16);
      expect(SampleSpace.coins(3).isUniform, isTrue);
    });

    test('dos monedas: «una de cada» vale 1/2, no 1/3', () {
      final s = SampleSpace.coins(2);
      final p = s.probabilityWhere((o) => o.count('C') == 1);
      expect(p.asFraction, '1/2');
    });

    test('tres monedas: exactamente dos caras vale 3/8', () {
      final s = SampleSpace.coins(3);
      expect(s.probabilityWhere((o) => o.count('C') == 2).asFraction, '3/8');
      expect(s.probabilityWhere((o) => o.count('C') == 3).asFraction, '1/8');
    });

    test('dos dados: 36 resultados, no 21', () {
      final s = SampleSpace.dice(2);
      expect(s.size, 36);
      expect(s.probabilityWhere((o) => o.sum == 7).asFraction, '1/6');
      expect(s.probabilityWhere((o) => o.sum == 12).asFraction, '1/36');
      expect(
        s.probabilityWhere((o) => o.values.contains(6)).asFraction,
        '11/36',
      );
    });

    test('las sumas NO son un espacio equiprobable', () {
      final s = SampleSpace.diceSum();
      expect(s.size, 11);
      expect(s.isUniform, isFalse);
      expect(s.totalWeight, BigInt.from(36));
      expect(s.probabilityWhere((o) => o.values.first == 7).asFraction, '1/6');
    });

    test('baraja de 52', () {
      final s = SampleSpace.card52();
      expect(s.size, 52);
      // 13 corazones + 12 figuras - 3 comunes = 22.
      final corazones = s.indicesWhere((o) => o.values[1] == 0);
      final figuras = s.indicesWhere((o) => o.values[0] >= 11);
      expect(corazones.length, 13);
      expect(figuras.length, 12);
      expect(corazones.intersection(figuras).length, 3);
      expect(corazones.union(figuras).length, 22);
    });

    test('urna sin reposición enumera bolas, no colores', () {
      final s = SampleSpace.urn(
        counts: const {'R': 4, 'A': 6},
        draws: 2,
        withReplacement: false,
      );
      expect(s.size, 90); // 10 x 9 pares ordenados de bolas distintas
      expect(
        s.probabilityWhere((o) => o.parts.every((p) => p == 'R')).asFraction,
        '2/15',
      );
    });

    test('urna con reposición', () {
      final s = SampleSpace.urn(
        counts: const {'R': 4, 'A': 6},
        draws: 2,
        withReplacement: true,
      );
      expect(s.size, 100);
      expect(
        s.probabilityWhere((o) => o.parts.every((p) => p == 'R')).asFraction,
        '4/25',
      );
    });

    test('álgebra de eventos', () {
      final s = SampleSpace.dice(2);
      final a = EventDef.of(s, 'A', 'suma 7', (o) => o.sum == 7);
      final b = EventDef.of(s, 'B', 'dobles',
          (o) => o.values[0] == o.values[1]);
      expect(a.size, 6);
      expect(b.size, 6);
      expect(a.intersect(b).size, 0);
      expect(a.union(b).size, 12);
      expect(a.complementIn(s).size, 30);
      expect(a.isDisjointWith(b), isTrue);
    });

    test('el catálogo resuelve todos sus espacios', () {
      for (final id in SampleSpaceCatalog.ids) {
        final s = SampleSpaceCatalog.byId(id);
        expect(s.size, greaterThan(0), reason: 'espacio vacío: $id');
      }
    });

    test('los predicados del catálogo devuelven eventos no vacíos', () {
      final dice = SampleSpaceCatalog.byId('dice_2_6');
      expect(
        dice
            .indicesWhere(SampleSpaceCatalog.predicate('sumEquals', [7]))
            .length,
        6,
      );
      expect(
        dice
            .indicesWhere(SampleSpaceCatalog.predicate('anyEquals', [6]))
            .length,
        11,
      );
      expect(
        dice.indicesWhere(SampleSpaceCatalog.predicate('doubles', [])).length,
        6,
      );
      final coins = SampleSpaceCatalog.byId('coins_3');
      expect(
        coins
            .indicesWhere(SampleSpaceCatalog.predicate('exactHeads', [2]))
            .length,
        3,
      );
    });
  });
}
