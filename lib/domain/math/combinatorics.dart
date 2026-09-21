/// Técnicas de conteo exactas (módulo 3).
///
/// Todo devuelve [BigInt]: C(52,5), 52!/(52-5)! y el problema del cumpleaños
/// desbordan enteros de 64 bits, y el módulo 3 vive precisamente de mostrar
/// números grandes.
library;

import 'rational.dart';

class Combinatorics {
  const Combinatorics._();

  /// n!  — factorial exacto.
  static BigInt factorial(int n) {
    if (n < 0) throw ArgumentError('factorial de negativo: $n');
    if (n > 20000) throw ArgumentError('factorial demasiado grande: $n');
    var r = BigInt.one;
    for (var i = 2; i <= n; i++) {
      r *= BigInt.from(i);
    }
    return r;
  }

  /// Principio multiplicativo: producto de las opciones de cada etapa.
  static BigInt multiplicationRule(List<int> stageOptions) {
    var r = BigInt.one;
    for (final o in stageOptions) {
      if (o < 0) throw ArgumentError('etapa con opciones negativas');
      r *= BigInt.from(o);
    }
    return r;
  }

  /// Variaciones sin repetición P(n,k) = n!/(n-k)!  — importa el orden,
  /// no se repite.
  static BigInt variations(int n, int k) {
    if (k < 0 || n < 0) throw ArgumentError('n y k deben ser >= 0');
    if (k > n) return BigInt.zero;
    var r = BigInt.one;
    for (var i = 0; i < k; i++) {
      r *= BigInt.from(n - i);
    }
    return r;
  }

  /// Variaciones con repetición n^k — importa el orden, se repite.
  static BigInt variationsWithRepetition(int n, int k) {
    if (k < 0 || n < 0) throw ArgumentError('n y k deben ser >= 0');
    return BigInt.from(n).pow(k);
  }

  /// Permutaciones de n elementos distintos: n!
  static BigInt permutations(int n) => factorial(n);

  /// Permutaciones con elementos repetidos (coeficiente multinomial):
  /// n! / (n1! n2! ... nk!)
  static BigInt permutationsWithRepetition(List<int> groupSizes) {
    final n = groupSizes.fold<int>(0, (a, b) => a + b);
    var r = factorial(n);
    for (final g in groupSizes) {
      r = r ~/ factorial(g);
    }
    return r;
  }

  /// Permutaciones circulares: (n-1)!
  static BigInt circularPermutations(int n) =>
      n <= 0 ? BigInt.zero : factorial(n - 1);

  /// Combinaciones C(n,k) — no importa el orden, no se repite.
  /// Calculado de forma incremental para no construir factoriales enormes.
  static BigInt combinations(int n, int k) {
    if (n < 0 || k < 0) throw ArgumentError('n y k deben ser >= 0');
    if (k > n) return BigInt.zero;
    final kk = k > n - k ? n - k : k;
    var r = BigInt.one;
    for (var i = 1; i <= kk; i++) {
      r = r * BigInt.from(n - kk + i) ~/ BigInt.from(i);
    }
    return r;
  }

  /// Combinaciones con repetición C(n+k-1, k).
  static BigInt combinationsWithRepetition(int n, int k) =>
      combinations(n + k - 1, k);

  /// Coeficiente multinomial n! / (n1!...nk!) — alias legible del anterior.
  static BigInt multinomial(List<int> parts) =>
      permutationsWithRepetition(parts);

  /// Número de subconjuntos de un conjunto de n elementos: 2^n.
  static BigInt subsets(int n) => BigInt.two.pow(n);

  // ---------------------------------------------------------------------
  // Aplicaciones clásicas usadas en el contenido
  // ---------------------------------------------------------------------

  /// Probabilidad exacta de que en un grupo de [k] personas haya al menos
  /// dos que cumplan años el mismo día, con [days] días equiprobables.
  static Rational birthdayCollision(int k, {int days = 365}) {
    if (k <= 1) return Rational.zero;
    if (k > days) return Rational.one;
    final total = BigInt.from(days).pow(k);
    final distinct = variations(days, k);
    return Rational(total - distinct, total);
  }

  /// Probabilidad binomial exacta P(X = k) con n ensayos y éxito p.
  static Rational binomialPmf(int n, int k, Rational p) {
    if (k < 0 || k > n) return Rational.zero;
    final c = Rational(combinations(n, k));
    return c * p.pow(k) * p.complement.pow(n - k);
  }

  /// P(X >= k) binomial exacta.
  static Rational binomialAtLeast(int n, int k, Rational p) {
    var acc = Rational.zero;
    for (var i = k; i <= n; i++) {
      acc = acc + binomialPmf(n, i, p);
    }
    return acc;
  }

  /// P(X <= k) binomial exacta.
  static Rational binomialAtMost(int n, int k, Rational p) {
    var acc = Rational.zero;
    for (var i = 0; i <= k && i <= n; i++) {
      acc = acc + binomialPmf(n, i, p);
    }
    return acc;
  }

  /// Distribución hipergeométrica: en una población de [n] objetos con [k]
  /// del tipo buscado, se extraen [draws] sin reposición; P(exactamente
  /// [hits] del tipo buscado).
  static Rational hypergeometric(int n, int k, int draws, int hits) {
    final favorable = combinations(k, hits) * combinations(n - k, draws - hits);
    final total = combinations(n, draws);
    if (total == BigInt.zero) return Rational.zero;
    return Rational(favorable, total);
  }

  /// Genera efectivamente las combinaciones de [k] índices de `0..n-1`.
  /// Solo para espacios pequeños (los laboratorios enumeran, no simulan,
  /// cuando el espacio cabe en pantalla).
  static List<List<int>> listCombinations(int n, int k) {
    final out = <List<int>>[];
    final current = <int>[];
    void rec(int start) {
      if (current.length == k) {
        out.add(List<int>.from(current));
        return;
      }
      for (var i = start; i < n; i++) {
        current.add(i);
        rec(i + 1);
        current.removeLast();
      }
    }

    if (k >= 0 && k <= n) rec(0);
    return out;
  }

  /// Genera las variaciones (listas ordenadas sin repetición) de [k] índices.
  static List<List<int>> listVariations(int n, int k) {
    final out = <List<int>>[];
    final current = <int>[];
    final used = List<bool>.filled(n, false);
    void rec() {
      if (current.length == k) {
        out.add(List<int>.from(current));
        return;
      }
      for (var i = 0; i < n; i++) {
        if (used[i]) continue;
        used[i] = true;
        current.add(i);
        rec();
        current.removeLast();
        used[i] = false;
      }
    }

    if (k >= 0 && k <= n) rec();
    return out;
  }

  /// Formatea un [BigInt] con separador de miles (espacio fino, estilo SI).
  static String formatBig(BigInt v) {
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return (v.isNegative ? '-' : '') + buf.toString();
  }
}
