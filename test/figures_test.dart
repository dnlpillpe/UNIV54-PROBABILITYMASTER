/// Decisión D5: **ningún número del contenido está escrito a mano**.
///
/// Este test recalcula con el motor real todas las cifras que el contenido
/// declara y comprueba que cada marca `{{id}}` del texto tiene su ficha. Es
/// la mitad Dart de una verificación doble: la otra mitad la hace
/// `tool/verify_content.py` con una réplica independiente en Python.
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/data/repositories/content_repository.dart';
import 'package:probability_master/domain/math/figure_registry.dart';
import 'package:probability_master/domain/math/rational.dart';

class _Item {
  final String id;
  final String text;
  final List<ContentFigure> figures;
  const _Item(this.id, this.text, this.figures);
}

List<_Item> _allItems(ContentRepository content) {
  final items = <_Item>[];
  for (final lesson in content.lessons) {
    for (var i = 0; i < lesson.cards.length; i++) {
      final card = lesson.cards[i];
      items.add(_Item('${lesson.id}#c$i', card.body, card.figures));
    }
  }
  for (final ex in content.exercises) {
    items.add(_Item(
      ex.id,
      '${ex.prompt}\n${ex.context ?? ''}\n${ex.explanation}',
      ex.figures,
    ));
  }
  for (final c in content.cases) {
    items.add(_Item(
      c.id,
      '${c.scenario}\n${c.question}\n${c.resolution}\n${c.assumptions}',
      c.figures,
    ));
  }
  return items;
}

void main() {
  const content = ContentRepository();

  group('Cifras del contenido (D5)', () {
    test('toda función declarada existe en el registro', () {
      for (final item in _allItems(content)) {
        for (final f in item.figures) {
          expect(
            FigureRegistry.knows(f.fn),
            isTrue,
            reason: '${item.id}: función desconocida ${f.fn}',
          );
        }
      }
    });

    test('toda ficha se evalúa y da un valor válido', () {
      var count = 0;
      for (final item in _allItems(content)) {
        for (final f in item.figures) {
          final rendered = FigureRegistry.render(f);
          expect(rendered.isNotEmpty, isTrue,
              reason: '${item.id}: ficha vacía ${f.id}');
          if (f.format != FigureFormat.count) {
            final v = FigureRegistry.evaluate(f);
            expect(v >= Rational.zero, isTrue,
                reason: '${item.id}/${f.id}: probabilidad negativa');
            expect(v <= Rational.one, isTrue,
                reason: '${item.id}/${f.id}: probabilidad mayor que 1');
          }
          count++;
        }
      }
      expect(count, greaterThan(60),
          reason: 'el contenido debería declarar decenas de cifras');
    });

    test('toda marca {{id}} tiene su ficha en el mismo elemento', () {
      final re = RegExp(r'\{\{([a-zA-Z_0-9]+)\}\}');
      for (final item in _allItems(content)) {
        final ids = item.figures.map((f) => f.id).toSet();
        for (final m in re.allMatches(item.text)) {
          expect(
            ids.contains(m.group(1)),
            isTrue,
            reason: '${item.id}: marca {{${m.group(1)}}} sin ficha declarada',
          );
        }
      }
    });

    test('no quedan marcas sin sustituir tras renderizar', () {
      for (final item in _allItems(content)) {
        var out = item.text;
        for (final f in item.figures) {
          out = out.replaceAll('{{${f.id}}}', FigureRegistry.render(f));
        }
        expect(out.contains('{{'), isFalse,
            reason: '${item.id}: quedan marcas sin sustituir');
      }
    });

    test('cifras clave, una por una', () {
      // Las que el análisis cita explícitamente. Si el motor cambia, este
      // test lo detecta antes que el estudiante.
      expect(
        FigureRegistry.evaluate(const ContentFigure(
          id: 't1', fn: 'diceSum', args: [7], label: '')).asFraction,
        '1/6',
      );
      expect(
        FigureRegistry.evaluate(const ContentFigure(
          id: 't2', fn: 'ppv', args: [1, 100, 99, 100, 95, 100],
          label: '')).toDouble(),
        closeTo(0.166666, 1e-5),
      );
      expect(
        FigureRegistry.evaluate(const ContentFigure(
          id: 't3', fn: 'atLeastOne', args: [1, 50, 30], label: ''))
            .toDouble(),
        closeTo(0.4545, 1e-4),
      );
      expect(
        FigureRegistry.evaluateCount(const ContentFigure(
          id: 't4', fn: 'combinations', args: [49, 6], label: '',
          format: FigureFormat.count)),
        BigInt.from(13983816),
      );
      expect(
        FigureRegistry.evaluate(const ContentFigure(
          id: 't5', fn: 'urnAllSameNoRep', args: [4, 10, 2], label: ''))
            .asFraction,
        '2/15',
      );
    });
  });
}
