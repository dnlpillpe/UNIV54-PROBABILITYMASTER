import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/domain/math/rational.dart';

void main() {
  group('Rational — aritmética exacta', () {
    test('normaliza y reduce', () {
      expect(Rational.fromInts(6, 36).asFraction, '1/6');
      expect(Rational.fromInts(-2, -4).asFraction, '1/2');
      expect(Rational.fromInts(3, -9).asFraction, '-1/3');
      expect(Rational.fromInts(0, 5).asFraction, '0');
    });

    test('suma, resta, producto y cociente sin error de punto flotante', () {
      final a = Rational.fromInts(1, 3);
      final b = Rational.fromInts(1, 6);
      expect((a + b).asFraction, '1/2');
      expect((a - b).asFraction, '1/6');
      expect((a * b).asFraction, '1/18');
      expect((a / b).asFraction, '2');
    });

    test('1/3 sumado tres veces da exactamente 1', () {
      final third = Rational.fromInts(1, 3);
      expect((third + third + third).isOne, isTrue);
      // El mismo cálculo en double NO da 1 exacto: este es el motivo de
      // existir de la clase.
      expect(0.1 + 0.2 == 0.3, isFalse);
      expect(
        (Rational.fromInts(1, 10) + Rational.fromInts(2, 10)) ==
            Rational.fromInts(3, 10),
        isTrue,
      );
    });

    test('complemento y potencia', () {
      expect(Rational.fromInts(1, 4).complement.asFraction, '3/4');
      expect(Rational.fromInts(1, 2).pow(5).asFraction, '1/32');
      expect(Rational.fromInts(9, 10).pow(20).toDouble(),
          closeTo(0.12157665, 1e-8));
    });

    test('comparaciones', () {
      expect(Rational.fromInts(1, 3) < Rational.fromInts(1, 2), isTrue);
      expect(Rational.fromInts(2, 4) == Rational.fromInts(1, 2), isTrue);
      expect(Rational.fromInts(5, 4) > Rational.one, isTrue);
    });

    test('formatos de salida', () {
      final r = Rational.fromInts(11, 36);
      expect(r.asFraction, '11/36');
      expect(r.asDecimal(), '0.3056');
      expect(r.asPercent(), '30,6 %');
      expect(r.triple.contains('11/36'), isTrue);
    });

    test('una fracción ilegible se muestra como decimal', () {
      // El problema del cumpleaños produce denominadores de más de cien
      // cifras: exactos, pero inservibles en pantalla.
      final huge = Rational(BigInt.from(1), BigInt.from(10).pow(30));
      expect(huge.isReadableFraction, isFalse);
      expect(huge.triple.contains('/'), isFalse);
    });

    test('fromDouble recupera fracciones sencillas', () {
      expect(Rational.fromDouble(0.25).asFraction, '1/4');
      expect(Rational.fromDouble(0.5).asFraction, '1/2');
    });
  });
}
