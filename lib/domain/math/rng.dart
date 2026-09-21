/// Generador pseudoaleatorio propio, reproducible por semilla.
///
/// No se usa `dart:math`.`Random` para los laboratorios porque el estudiante
/// debe poder **repetir exactamente** una simulación que le sorprendió (y el
/// docente, reproducirla en clase). La semilla se muestra en pantalla y se
/// guarda con el resultado del experimento.
library;

/// xorshift128+ con estado de 64 bits en dos palabras.
class SeededRng {
  int _s0;
  int _s1;
  final int seed;

  SeededRng(this.seed)
      : _s0 = _splitMix(seed == 0 ? 0x9E3779B97F4A7C15 : seed),
        _s1 = _splitMix((seed == 0 ? 0x9E3779B97F4A7C15 : seed) ^ 0x94D049BB133111EB);

  static int _splitMix(int x) {
    var z = x + 0x9E3779B97F4A7C15;
    z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9;
    z = (z ^ (z >>> 27)) * 0x94D049BB133111EB;
    return z ^ (z >>> 31);
  }

  /// Siguiente entero de 64 bits.
  int nextInt64() {
    var x = _s0;
    final y = _s1;
    _s0 = y;
    x ^= x << 23;
    _s1 = x ^ y ^ (x >>> 17) ^ (y >>> 26);
    return _s1 + y;
  }

  /// Entero uniforme en `[0, max)`.
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError('max debe ser > 0');
    final v = nextInt64() & 0x3FFFFFFFFFFFFFFF;
    return v % max;
  }

  /// Doble uniforme en `[0, 1)`.
  double nextDouble() =>
      (nextInt64() & 0x1FFFFFFFFFFFFF) / 9007199254740992.0;

  /// Ensayo de Bernoulli con probabilidad [p].
  bool bernoulli(double p) => nextDouble() < p;

  /// Índice según pesos relativos (ruleta sesgada, urna).
  int weightedIndex(List<int> weights) {
    var total = 0;
    for (final w in weights) {
      total += w;
    }
    if (total <= 0) throw ArgumentError('pesos no positivos');
    var r = nextInt(total);
    for (var i = 0; i < weights.length; i++) {
      r -= weights[i];
      if (r < 0) return i;
    }
    return weights.length - 1;
  }

  /// Barajado de Fisher-Yates in situ.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  /// Toma [k] elementos sin reposición de una lista (no la modifica).
  List<T> sampleWithoutReplacement<T>(List<T> source, int k) {
    final copy = List<T>.from(source);
    shuffle(copy);
    return copy.sublist(0, k.clamp(0, copy.length));
  }
}
