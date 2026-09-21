/// Aritmética racional exacta sobre [BigInt].
///
/// Decisión D6 del análisis: las probabilidades de espacios muestrales finitos
/// se calculan como fracciones exactas y no en punto flotante. El estudiante
/// debe ver `11/36`, no `0.3055555...`, y los conteos de C(52,5) o del problema
/// del cumpleaños desbordan `int` de 64 bits con facilidad.
library;

/// Número racional siempre normalizado: denominador positivo y fracción
/// irreducible. `Rational.zero` se representa como `0/1`.
class Rational implements Comparable<Rational> {
  final BigInt num;
  final BigInt den;

  const Rational._raw(this.num, this.den);

  factory Rational(BigInt numerator, [BigInt? denominator]) {
    final d = denominator ?? BigInt.one;
    if (d == BigInt.zero) {
      throw ArgumentError('Denominador cero en Rational');
    }
    var n = numerator;
    var dd = d;
    if (dd.isNegative) {
      n = -n;
      dd = -dd;
    }
    if (n == BigInt.zero) return Rational._raw(BigInt.zero, BigInt.one);
    final g = n.abs().gcd(dd);
    return Rational._raw(n ~/ g, dd ~/ g);
  }

  factory Rational.fromInts(int numerator, [int denominator = 1]) =>
      Rational(BigInt.from(numerator), BigInt.from(denominator));

  /// Convierte un decimal con a lo más [decimals] cifras en fracción exacta.
  factory Rational.fromDouble(double value, {int decimals = 10}) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError('Valor no finito en Rational.fromDouble');
    }
    var scale = BigInt.one;
    final ten = BigInt.from(10);
    for (var i = 0; i < decimals; i++) {
      scale *= ten;
    }
    final scaled = BigInt.from((value * scale.toDouble()).round());
    return Rational(scaled, scale);
  }

  static final Rational zero = Rational.fromInts(0);
  static final Rational one = Rational.fromInts(1);
  static final Rational half = Rational.fromInts(1, 2);

  bool get isZero => num == BigInt.zero;
  bool get isOne => num == den;
  bool get isInteger => den == BigInt.one;
  bool get isNegative => num.isNegative;

  Rational operator +(Rational other) =>
      Rational(num * other.den + other.num * den, den * other.den);

  Rational operator -(Rational other) =>
      Rational(num * other.den - other.num * den, den * other.den);

  Rational operator *(Rational other) =>
      Rational(num * other.num, den * other.den);

  Rational operator /(Rational other) {
    if (other.isZero) throw ArgumentError('División entre cero en Rational');
    return Rational(num * other.den, den * other.num);
  }

  Rational operator -() => Rational._raw(-num, den);

  /// Complemento `1 - x`, la operación más usada del dominio.
  Rational get complement => Rational(den - num, den);

  Rational pow(int exponent) {
    if (exponent < 0) {
      return Rational(den.pow(-exponent), num.pow(-exponent));
    }
    return Rational(num.pow(exponent), den.pow(exponent));
  }

  double toDouble() => num / den;

  @override
  int compareTo(Rational other) => (num * other.den).compareTo(other.num * den);

  bool operator <(Rational other) => compareTo(other) < 0;
  bool operator <=(Rational other) => compareTo(other) <= 0;
  bool operator >(Rational other) => compareTo(other) > 0;
  bool operator >=(Rational other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Rational && other.num == num && other.den == den;

  @override
  int get hashCode => Object.hash(num, den);

  /// Representación como fracción: `3/4`, o `3` si es entero.
  String get asFraction => isInteger ? '$num' : '$num/$den';

  /// Decimal redondeado, sin ceros finales innecesarios.
  String asDecimal({int digits = 4}) {
    final v = toDouble();
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toStringAsFixed(0);
    }
    var s = v.toStringAsFixed(digits);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  /// Porcentaje redondeado: `30,6 %`.
  String asPercent({int digits = 1}) {
    final v = toDouble() * 100;
    var s = v.toStringAsFixed(digits);
    s = s.replaceAll('.', ',');
    return '$s %';
  }

  /// ¿La fracción es legible para un estudiante? El problema del cumpleaños
  /// produce denominadores de más de cien cifras: exactos, pero inútiles en
  /// pantalla.
  bool get isReadableFraction => den.toString().length <= 7;

  /// Las tres formas juntas, como se muestran en la app. Cuando la fracción
  /// exacta es ilegible se omite en vez de invadir la pantalla.
  String get triple => isReadableFraction
      ? '$asFraction  =  ${asDecimal()}  =  $asPercent'
      : '${asDecimal(digits: 6)}  =  $asPercent';

  @override
  String toString() => asFraction;
}
