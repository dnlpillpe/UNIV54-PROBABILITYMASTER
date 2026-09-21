#!/usr/bin/env python3
"""Réplica en Python del motor de probabilidad de la app.

Existe por un motivo concreto: el entorno de construcción no tiene el SDK de
Flutter, así que el contenido no puede verificarse ejecutando Dart. Esta
réplica recalcula, de forma **independiente**, todas las cifras que el
contenido declara, usando `fractions.Fraction` (exacto) igual que la clase
`Rational` de Dart usa `BigInt`.

En CI se ejecuta dos veces la misma verificación con motores distintos:
aquí en Python (job `contenido`) y en Dart dentro de `flutter test`
(`test/figures_test.dart`). Si los dos coinciden, la probabilidad de que un
error de implementación pase inadvertido es muy baja.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial, prod


# ---------------------------------------------------------------------
# Combinatoria
# ---------------------------------------------------------------------
def combinations(n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    return comb(n, k)


def variations(n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    r = 1
    for i in range(k):
        r *= n - i
    return r


def variations_rep(n: int, k: int) -> int:
    return n ** k


def combinations_rep(n: int, k: int) -> int:
    return combinations(n + k - 1, k)


def permutations_rep(groups) -> int:
    n = sum(groups)
    r = factorial(n)
    for g in groups:
        r //= factorial(g)
    return r


def circular(n: int) -> int:
    return factorial(n - 1) if n > 0 else 0


def subsets(n: int) -> int:
    return 2 ** n


def multiply(values) -> int:
    return prod(values)


def birthday_collision(k: int, days: int = 365) -> Fraction:
    if k <= 1:
        return Fraction(0)
    if k > days:
        return Fraction(1)
    total = days ** k
    distinct = variations(days, k)
    return Fraction(total - distinct, total)


def binomial_pmf(n: int, k: int, p: Fraction) -> Fraction:
    if k < 0 or k > n:
        return Fraction(0)
    return Fraction(combinations(n, k)) * (p ** k) * ((1 - p) ** (n - k))


def binomial_at_least(n: int, k: int, p: Fraction) -> Fraction:
    return sum((binomial_pmf(n, i, p) for i in range(k, n + 1)), Fraction(0))


def hypergeometric(n: int, k: int, draws: int, hits: int) -> Fraction:
    total = combinations(n, draws)
    if total == 0:
        return Fraction(0)
    fav = combinations(k, hits) * combinations(n - k, draws - hits)
    return Fraction(fav, total)


# ---------------------------------------------------------------------
# Espacios muestrales (los mismos que SampleSpace en Dart)
# ---------------------------------------------------------------------
def dice_sum_weights():
    """Pesos de las sumas 2..12 de dos dados."""
    return {s: 6 - abs(s - 7) for s in range(2, 13)}


def dice_sum(target: int) -> Fraction:
    return Fraction(dice_sum_weights().get(target, 0), 36)


def dice_sum_at_least(target: int) -> Fraction:
    w = dice_sum_weights()
    return Fraction(sum(v for s, v in w.items() if s >= target), 36)


# ---------------------------------------------------------------------
# Reglas
# ---------------------------------------------------------------------
def union_general(pa: Fraction, pb: Fraction, pab: Fraction) -> Fraction:
    return pa + pb - pab


def conditional(pab: Fraction, pb: Fraction) -> Fraction:
    if pb == 0:
        raise ValueError("condicionar a probabilidad 0")
    return pab / pb


def at_least_one(p: Fraction, n: int) -> Fraction:
    return 1 - (1 - p) ** n


def total_probability(priors, likelihoods) -> Fraction:
    return sum(
        (pr * li for pr, li in zip(priors, likelihoods)), Fraction(0)
    )


def bayes(priors, likelihoods, target: int = 0) -> Fraction:
    total = total_probability(priors, likelihoods)
    if total == 0:
        raise ValueError("evidencia de probabilidad 0")
    return (priors[target] * likelihoods[target]) / total


def ppv(prevalence: Fraction, sensitivity: Fraction,
        specificity: Fraction) -> Fraction:
    return bayes(
        [prevalence, 1 - prevalence],
        [sensitivity, 1 - specificity],
    )


# ---------------------------------------------------------------------
# Registro de funciones con nombre — espejo de FigureRegistry en Dart
# ---------------------------------------------------------------------
def _f(a: int, b: int) -> Fraction:
    return Fraction(a, b)


PROBABILITY_FNS = {
    "coinsAllHeads": lambda a: Fraction(1, 2 ** a[0]),
    "coinsExactHeads": lambda a: Fraction(combinations(a[0], a[1]), 2 ** a[0]),
    "coinsAtLeastOneHead": lambda a: Fraction(2 ** a[0] - 1, 2 ** a[0]),
    "diceSum": lambda a: dice_sum(a[0]),
    "diceSumAtLeast": lambda a: dice_sum_at_least(a[0]),
    "twoDiceDoubles": lambda a: Fraction(6, 36),
    "twoDiceMaxAtLeast": lambda a: Fraction(
        sum(1 for i in range(1, 7) for j in range(1, 7) if max(i, j) >= a[0]),
        36,
    ),
    "oneDieEven": lambda a: Fraction(3, 6),
    "cardIs": lambda a: Fraction(a[0], 52),
    "unionGeneral": lambda a: union_general(
        _f(a[0], a[1]), _f(a[2], a[3]), _f(a[4], a[5])
    ),
    "complement": lambda a: 1 - _f(a[0], a[1]),
    "conditional": lambda a: conditional(_f(a[0], a[1]), _f(a[2], a[3])),
    "atLeastOne": lambda a: at_least_one(_f(a[0], a[1]), a[2]),
    "noneIn": lambda a: (1 - _f(a[0], a[1])) ** a[2],
    "seriesEqual": lambda a: _f(a[0], a[1]) ** a[2],
    "parallelEqual": lambda a: 1 - (1 - _f(a[0], a[1])) ** a[2],
    "urnAllSameNoRep": lambda a: Fraction(
        combinations(a[0], a[2]), combinations(a[1], a[2])
    ),
    "urnAllSameWithRep": lambda a: _f(a[0], a[1]) ** a[2],
    "hypergeometric": lambda a: hypergeometric(a[0], a[1], a[2], a[3]),
    "ppv": lambda a: ppv(_f(a[0], a[1]), _f(a[2], a[3]), _f(a[4], a[5])),
    "bayes2": lambda a: bayes(
        [_f(a[0], a[1]), _f(a[4], a[5])],
        [_f(a[2], a[3]), _f(a[6], a[7])],
    ),
    "totalProbability2": lambda a: total_probability(
        [_f(a[0], a[1]), _f(a[4], a[5])],
        [_f(a[2], a[3]), _f(a[6], a[7])],
    ),
    "birthday": lambda a: birthday_collision(a[0]),
    "binomial": lambda a: binomial_pmf(a[0], a[1], _f(a[2], a[3])),
    "binomialAtLeast": lambda a: binomial_at_least(a[0], a[1], _f(a[2], a[3])),
    "lotteryWin": lambda a: Fraction(1, combinations(a[0], a[1])),
    "literal": lambda a: _f(a[0], a[1]),
}

COUNT_FNS = {
    "factorial": lambda a: factorial(a[0]),
    "combinations": lambda a: combinations(a[0], a[1]),
    "variations": lambda a: variations(a[0], a[1]),
    "variationsRep": lambda a: variations_rep(a[0], a[1]),
    "combinationsRep": lambda a: combinations_rep(a[0], a[1]),
    "permutationsRep": lambda a: permutations_rep(a),
    "circular": lambda a: circular(a[0]),
    "subsets": lambda a: subsets(a[0]),
    "multiply": lambda a: multiply(a),
}


def evaluate(fn: str, args):
    """Evalúa una ficha por nombre de función."""
    if fn in PROBABILITY_FNS:
        return PROBABILITY_FNS[fn](args)
    if fn in COUNT_FNS:
        return COUNT_FNS[fn](args)
    raise KeyError(f"función desconocida: {fn}")


def format_fraction(value: Fraction) -> str:
    return str(value.numerator) if value.denominator == 1 else (
        f"{value.numerator}/{value.denominator}"
    )


def format_percent(value: Fraction, digits: int = 1) -> str:
    return f"{float(value) * 100:.{digits}f} %".replace(".", ",")


if __name__ == "__main__":
    # Comprobaciones rápidas del propio motor.
    assert dice_sum(7) == Fraction(1, 6)
    assert dice_sum(12) == Fraction(1, 36)
    assert combinations(52, 5) == 2598960
    assert permutations_rep([2, 2, 1]) == 30
    assert abs(float(birthday_collision(23)) - 0.507297) < 1e-5
    assert abs(float(ppv(Fraction(1, 100), Fraction(99, 100),
                         Fraction(95, 100))) - 0.166666) < 1e-5
    print("probability_core.py: todas las comprobaciones internas pasan")
