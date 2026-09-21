/// Catálogo de espacios muestrales y predicados nombrados.
///
/// Los ejercicios de construcción declaran `spaceId` + `predicate` + `args`;
/// aquí se resuelven. Así el contenido no contiene código y el test puede
/// verificar que todo predicado declarado existe.
library;

import '../../domain/math/sample_space.dart';

class SampleSpaceCatalog {
  const SampleSpaceCatalog._();

  static SampleSpace byId(String id) {
    switch (id) {
      case 'coins_1':
        return SampleSpace.coins(1);
      case 'coins_2':
        return SampleSpace.coins(2);
      case 'coins_3':
        return SampleSpace.coins(3);
      case 'coins_4':
        return SampleSpace.coins(4);
      case 'dice_1_6':
        return SampleSpace.dice(1);
      case 'dice_2_6':
        return SampleSpace.dice(2);
      case 'dice_sum':
        return SampleSpace.diceSum();
      case 'card52':
        return SampleSpace.card52();
      case 'urn_4r6a_2':
        return SampleSpace.urn(
          counts: const {'R': 4, 'A': 6},
          draws: 2,
          withReplacement: false,
        );
      default:
        return SampleSpace.dice(2);
    }
  }

  static const List<String> ids = [
    'coins_1',
    'coins_2',
    'coins_3',
    'coins_4',
    'dice_1_6',
    'dice_2_6',
    'dice_sum',
    'card52',
    'urn_4r6a_2',
  ];

  static bool knowsPredicate(String name) => _names.contains(name);

  static const Set<String> _names = {
    'sumEquals',
    'sumAtLeast',
    'sumAtMost',
    'anyEquals',
    'allEqual',
    'doubles',
    'exactHeads',
    'atLeastHeads',
    'allHeads',
    'isEven',
    'greaterThan',
    'suitIs',
    'rankAtLeast',
    'allSameColor',
    'sumSevenOrAnySix',
  };

  /// Resuelve un predicado declarado por el contenido.
  static bool Function(Outcome) predicate(String name, List<int> args) {
    switch (name) {
      case 'sumEquals':
        return (o) => o.sum == args[0];
      case 'sumAtLeast':
        return (o) => o.sum >= args[0];
      case 'sumAtMost':
        return (o) => o.sum <= args[0];
      case 'anyEquals':
        return (o) => o.values.contains(args[0]);
      case 'allEqual':
        return (o) => o.values.every((v) => v == args[0]);
      case 'doubles':
        return (o) =>
            o.values.isNotEmpty && o.values.every((v) => v == o.values.first);
      case 'exactHeads':
        return (o) => o.count('C') == args[0];
      case 'atLeastHeads':
        return (o) => o.count('C') >= args[0];
      case 'allHeads':
        return (o) => o.parts.every((p) => p == 'C');
      case 'isEven':
        return (o) => o.values.isNotEmpty && o.values.first.isEven;
      case 'greaterThan':
        return (o) => o.maxValue > args[0];
      case 'suitIs':
        return (o) => o.values.length > 1 && o.values[1] == args[0];
      case 'rankAtLeast':
        return (o) => o.values.isNotEmpty && o.values.first >= args[0];
      case 'allSameColor':
        return (o) =>
            o.parts.isNotEmpty && o.parts.every((p) => p == o.parts.first);
      // Unión de dos eventos que se solapan: el caso que hace visible por
      // qué la regla de la suma resta la intersección.
      case 'sumSevenOrAnySix':
        return (o) => o.sum == 7 || o.values.contains(6);
      default:
        return (o) => false;
    }
  }

  /// Descripción legible de un predicado, para la cabecera de la cuadrícula.
  static String describe(String name, List<int> args) {
    switch (name) {
      case 'sumEquals':
        return 'La suma es ${args[0]}';
      case 'sumAtLeast':
        return 'La suma es ${args[0]} o más';
      case 'sumAtMost':
        return 'La suma es ${args[0]} o menos';
      case 'anyEquals':
        return 'Al menos un dado muestra ${args[0]}';
      case 'doubles':
        return 'Los dos dados coinciden';
      case 'exactHeads':
        return 'Exactamente ${args[0]} cara(s)';
      case 'atLeastHeads':
        return 'Al menos ${args[0]} cara(s)';
      case 'allHeads':
        return 'Todas caras';
      case 'isEven':
        return 'Resultado par';
      case 'allSameColor':
        return 'Todas del mismo color';
      case 'sumSevenOrAnySix':
        return 'La suma es 7 o algún dado muestra 6';
      default:
        return 'Evento';
    }
  }
}
