/// Construcción explícita de espacios muestrales finitos.
///
/// Decisión D2 del análisis: antes de que aparezca una fórmula de conteo, el
/// estudiante tiene que haber enumerado espacios de 4, 6, 8, 36 y 52
/// resultados. Este archivo es el que los produce, y el mismo objeto alimenta
/// la cuadrícula interactiva del laboratorio y el cálculo exacto de Laplace.
library;

import 'rational.dart';

/// Un resultado elemental del experimento.
class Outcome {
  /// Componentes del resultado, una por etapa del experimento
  /// (`['C','S']` para dos monedas, `['3','5']` para dos dados).
  final List<String> parts;

  /// Valores numéricos asociados cuando tienen sentido (caras de dados,
  /// valor de carta). Vacío si el resultado no es numérico.
  final List<int> values;

  const Outcome(this.parts, [this.values = const []]);

  /// Etiqueta corta para la cuadrícula: `CS`, `3-5`.
  String get label => parts.join(parts.length > 2 ? ',' : '');

  /// Etiqueta larga para lectura: `(3, 5)`.
  String get longLabel => parts.length == 1 ? parts.first : '(${parts.join(', ')})';

  int get sum => values.fold(0, (a, b) => a + b);
  int get maxValue => values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  int get minValue => values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);

  /// Cuántas veces aparece [part] entre las componentes.
  int count(String part) => parts.where((p) => p == part).length;

  @override
  String toString() => longLabel;
}

/// Espacio muestral finito y equiprobable o con pesos explícitos.
class SampleSpace {
  final String id;
  final String name;

  /// Descripción del experimento aleatorio que lo genera.
  final String experiment;
  final List<Outcome> outcomes;

  /// Pesos relativos. Vacío = todos los resultados equiprobables.
  /// Nunca se asume equiprobabilidad en silencio: los constructores que
  /// producen espacios no uniformes rellenan esta lista.
  final List<int> weights;

  /// Nombre de cada etapa, para los encabezados de la cuadrícula.
  final List<String> stageNames;

  const SampleSpace({
    required this.id,
    required this.name,
    required this.experiment,
    required this.outcomes,
    this.weights = const [],
    this.stageNames = const [],
  });

  int get size => outcomes.length;
  bool get isUniform => weights.isEmpty;

  BigInt get totalWeight => isUniform
      ? BigInt.from(outcomes.length)
      : weights.fold(BigInt.zero, (a, b) => a + BigInt.from(b));

  BigInt weightOf(int index) =>
      isUniform ? BigInt.one : BigInt.from(weights[index]);

  /// Probabilidad exacta de un conjunto de índices (regla de Laplace cuando
  /// el espacio es uniforme; suma de pesos cuando no lo es).
  Rational probabilityOfIndices(Iterable<int> indices) {
    var fav = BigInt.zero;
    for (final i in indices) {
      fav += weightOf(i);
    }
    return Rational(fav, totalWeight);
  }

  /// Índices que cumplen un predicado.
  Set<int> indicesWhere(bool Function(Outcome o) test) {
    final s = <int>{};
    for (var i = 0; i < outcomes.length; i++) {
      if (test(outcomes[i])) s.add(i);
    }
    return s;
  }

  Rational probabilityWhere(bool Function(Outcome o) test) =>
      probabilityOfIndices(indicesWhere(test));

  // -------------------------------------------------------------------
  // Constructores de los experimentos del catálogo
  // -------------------------------------------------------------------

  /// Lanzamiento de [n] monedas: 2^n resultados.
  static SampleSpace coins(int n) {
    final outs = <Outcome>[];
    final total = 1 << n;
    for (var mask = 0; mask < total; mask++) {
      final parts = <String>[];
      final vals = <int>[];
      for (var i = 0; i < n; i++) {
        final isHead = (mask >> (n - 1 - i)) & 1 == 1;
        parts.add(isHead ? 'C' : 'S');
        vals.add(isHead ? 1 : 0);
      }
      outs.add(Outcome(parts, vals));
    }
    return SampleSpace(
      id: 'coins_$n',
      name: n == 1 ? 'Una moneda' : '$n monedas',
      experiment: n == 1
          ? 'Lanzar una moneda equilibrada una vez'
          : 'Lanzar $n monedas equilibradas (o una moneda $n veces)',
      outcomes: outs,
      stageNames: List.generate(n, (i) => 'Moneda ${i + 1}'),
    );
  }

  /// Lanzamiento de [n] dados de [faces] caras.
  static SampleSpace dice(int n, {int faces = 6}) {
    final outs = <Outcome>[];
    final total = _intPow(faces, n);
    for (var code = 0; code < total; code++) {
      var rest = code;
      final vals = <int>[];
      for (var i = 0; i < n; i++) {
        vals.insert(0, rest % faces + 1);
        rest ~/= faces;
      }
      outs.add(Outcome(vals.map((v) => '$v').toList(), vals));
    }
    return SampleSpace(
      id: 'dice_${n}_$faces',
      name: n == 1 ? 'Un dado' : '$n dados',
      experiment: n == 1
          ? 'Lanzar un dado equilibrado de $faces caras'
          : 'Lanzar $n dados equilibrados de $faces caras',
      outcomes: outs,
      stageNames: List.generate(n, (i) => 'Dado ${i + 1}'),
    );
  }

  /// Suma de dos dados **como espacio con pesos**: 11 resultados con pesos
  /// 1,2,3,...,6,...,1. Es el contraejemplo canónico del sesgo de
  /// equiprobabilidad (F2), y por eso el espacio guarda sus pesos en vez de
  /// fingir uniformidad.
  static SampleSpace diceSum() {
    final outs = <Outcome>[];
    final w = <int>[];
    for (var s = 2; s <= 12; s++) {
      outs.add(Outcome(['$s'], [s]));
      w.add(6 - (s - 7).abs());
    }
    return SampleSpace(
      id: 'dice_sum',
      name: 'Suma de dos dados',
      experiment: 'Lanzar dos dados y anotar únicamente la suma',
      outcomes: outs,
      weights: w,
      stageNames: const ['Suma'],
    );
  }

  /// Ruleta o urna con categorías y pesos declarados.
  static SampleSpace weighted({
    required String id,
    required String name,
    required String experiment,
    required List<String> labels,
    required List<int> weights,
  }) {
    return SampleSpace(
      id: id,
      name: name,
      experiment: experiment,
      outcomes: labels.map((l) => Outcome([l])).toList(),
      weights: weights,
      stageNames: const ['Resultado'],
    );
  }

  /// Extracciones de una urna con bolas de colores.
  /// [counts] son las bolas por color, [draws] el número de extracciones.
  /// Con reposición el espacio es uniforme; sin reposición también lo es si
  /// se distinguen las bolas, por eso aquí se enumeran bolas individuales
  /// y luego se etiquetan por color: es el modo correcto de contar y el que
  /// evita el error clásico de F5.
  static SampleSpace urn({
    required Map<String, int> counts,
    required int draws,
    required bool withReplacement,
  }) {
    final balls = <String>[];
    counts.forEach((color, n) {
      for (var i = 0; i < n; i++) {
        balls.add(color);
      }
    });
    final outs = <Outcome>[];
    final chosen = <int>[];
    final used = List<bool>.filled(balls.length, false);

    void rec() {
      if (chosen.length == draws) {
        outs.add(Outcome(chosen.map((i) => balls[i]).toList()));
        return;
      }
      for (var i = 0; i < balls.length; i++) {
        if (!withReplacement && used[i]) continue;
        used[i] = true;
        chosen.add(i);
        rec();
        chosen.removeLast();
        used[i] = false;
      }
    }

    if (balls.isNotEmpty && draws > 0) rec();
    final desc = counts.entries.map((e) => '${e.value} ${e.key}').join(', ');
    return SampleSpace(
      id: 'urn_${withReplacement ? 'cr' : 'sr'}_$draws',
      name: 'Urna ($desc)',
      experiment: 'Extraer $draws bola(s) de una urna con $desc, '
          '${withReplacement ? 'con' : 'sin'} reposición',
      outcomes: outs,
      stageNames: List.generate(draws, (i) => 'Extracción ${i + 1}'),
    );
  }

  /// Baraja francesa de 52 cartas (un único naipe extraído).
  static SampleSpace card52() {
    const suits = ['♥', '♦', '♣', '♠'];
    const ranks = [
      'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
    ];
    final outs = <Outcome>[];
    for (var s = 0; s < suits.length; s++) {
      for (var r = 0; r < ranks.length; r++) {
        outs.add(Outcome(['${ranks[r]}${suits[s]}'], [r + 1, s]));
      }
    }
    return SampleSpace(
      id: 'card52',
      name: 'Una carta de 52',
      experiment: 'Extraer una carta de una baraja francesa de 52',
      outcomes: outs,
      stageNames: const ['Carta'],
    );
  }

  static int _intPow(int base, int exp) {
    var r = 1;
    for (var i = 0; i < exp; i++) {
      r *= base;
    }
    return r;
  }
}

/// Un evento definido sobre un espacio muestral: nombre, símbolo y el
/// conjunto de índices que lo componen.
class EventDef {
  final String symbol;
  final String description;
  final Set<int> indices;

  const EventDef(this.symbol, this.description, this.indices);

  int get size => indices.length;

  EventDef union(EventDef other, {String? symbol}) => EventDef(
        symbol ?? '${this.symbol} ∪ ${other.symbol}',
        'Ocurre ${this.symbol} o ${other.symbol} (o ambos)',
        indices.union(other.indices),
      );

  EventDef intersect(EventDef other, {String? symbol}) => EventDef(
        symbol ?? '${this.symbol} ∩ ${other.symbol}',
        'Ocurren ${this.symbol} y ${other.symbol} a la vez',
        indices.intersection(other.indices),
      );

  EventDef difference(EventDef other, {String? symbol}) => EventDef(
        symbol ?? '${this.symbol} − ${other.symbol}',
        'Ocurre ${this.symbol} pero no ${other.symbol}',
        indices.difference(other.indices),
      );

  EventDef complementIn(SampleSpace space, {String? symbol}) {
    final all = <int>{for (var i = 0; i < space.size; i++) i};
    return EventDef(
      symbol ?? "${this.symbol}'",
      'No ocurre ${this.symbol}',
      all.difference(indices),
    );
  }

  bool isDisjointWith(EventDef other) =>
      indices.intersection(other.indices).isEmpty;

  /// Construye un evento a partir de un predicado sobre los resultados.
  static EventDef of(
    SampleSpace space,
    String symbol,
    String description,
    bool Function(Outcome o) test,
  ) =>
      EventDef(symbol, description, space.indicesWhere(test));
}
