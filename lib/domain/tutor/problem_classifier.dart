/// Clasificador de problemas: el árbol de decisión que el tutor enseña.
///
/// Es el antídoto del fallo F6 del análisis. El estudiante no recibe la
/// respuesta: recibe **las preguntas que debía haberse hecho**, y al final el
/// método aplicable con su condición de uso. El árbol se muestra entero en la
/// pantalla del tutor: la meta es que deje de necesitarlo.
library;

/// Métodos a los que puede llegar el árbol.
enum TutorMethod {
  enumerarLaplace,
  principioMultiplicativo,
  permutaciones,
  variaciones,
  variacionesConRepeticion,
  combinaciones,
  combinacionesConRepeticion,
  permutacionesConRepeticion,
  reglaSumaGeneral,
  reglaSumaExcluyentes,
  complemento,
  alMenosUno,
  productoIndependientes,
  productoDependientes,
  condicional,
  probabilidadTotal,
  bayes,
  binomial,
  hipergeometrica,
  noAplica,
}

extension TutorMethodInfo on TutorMethod {
  String get title {
    switch (this) {
      case TutorMethod.enumerarLaplace:
        return 'Enumerar el espacio muestral y aplicar Laplace';
      case TutorMethod.principioMultiplicativo:
        return 'Principio multiplicativo';
      case TutorMethod.permutaciones:
        return 'Permutaciones: n!';
      case TutorMethod.variaciones:
        return 'Variaciones sin repetición: P(n,k) = n!/(n−k)!';
      case TutorMethod.variacionesConRepeticion:
        return 'Variaciones con repetición: nᵏ';
      case TutorMethod.combinaciones:
        return 'Combinaciones: C(n,k)';
      case TutorMethod.combinacionesConRepeticion:
        return 'Combinaciones con repetición: C(n+k−1, k)';
      case TutorMethod.permutacionesConRepeticion:
        return 'Permutaciones con elementos repetidos: n!/(n₁!·n₂!…)';
      case TutorMethod.reglaSumaGeneral:
        return 'Regla general de la suma: P(A)+P(B)−P(A∩B)';
      case TutorMethod.reglaSumaExcluyentes:
        return 'Suma de eventos excluyentes: P(A)+P(B)';
      case TutorMethod.complemento:
        return 'Complemento: 1 − P(A)';
      case TutorMethod.alMenosUno:
        return 'Al menos uno: 1 − P(ninguno)';
      case TutorMethod.productoIndependientes:
        return 'Producto (independientes): P(A)·P(B)';
      case TutorMethod.productoDependientes:
        return 'Regla del producto: P(A)·P(B|A)';
      case TutorMethod.condicional:
        return 'Probabilidad condicional: P(A∩B)/P(B)';
      case TutorMethod.probabilidadTotal:
        return 'Probabilidad total: Σ P(Aᵢ)·P(B|Aᵢ)';
      case TutorMethod.bayes:
        return 'Teorema de Bayes';
      case TutorMethod.binomial:
        return 'Modelo binomial: C(n,k)·pᵏ·(1−p)ⁿ⁻ᵏ';
      case TutorMethod.hipergeometrica:
        return 'Modelo hipergeométrico (muestreo sin reposición)';
      case TutorMethod.noAplica:
        return 'Aquí no corresponde calcular una probabilidad';
    }
  }

  /// Condición que debe cumplirse para usarlo. La app nunca da una fórmula
  /// sin su condición.
  String get condition {
    switch (this) {
      case TutorMethod.enumerarLaplace:
        return 'Todos los resultados del espacio deben ser igualmente '
            'probables, y el espacio debe caber en una lista.';
      case TutorMethod.principioMultiplicativo:
        return 'Las etapas deben ser independientes en cuanto al número de '
            'opciones: la cantidad de opciones de cada etapa no depende de '
            'qué se eligió antes.';
      case TutorMethod.permutaciones:
        return 'Se usan TODOS los elementos y todos son distinguibles.';
      case TutorMethod.variaciones:
        return 'Importa el orden y no hay reposición.';
      case TutorMethod.variacionesConRepeticion:
        return 'Importa el orden y cada elemento puede repetirse.';
      case TutorMethod.combinaciones:
        return 'NO importa el orden y no hay reposición.';
      case TutorMethod.combinacionesConRepeticion:
        return 'NO importa el orden y los elementos pueden repetirse.';
      case TutorMethod.permutacionesConRepeticion:
        return 'Se ordenan todos los elementos y hay grupos indistinguibles '
            'entre sí.';
      case TutorMethod.reglaSumaGeneral:
        return 'Siempre vale. Si la intersección es vacía, su término es 0.';
      case TutorMethod.reglaSumaExcluyentes:
        return 'Los eventos NO pueden ocurrir a la vez. Compruébalo: es el '
            'error más caro del curso.';
      case TutorMethod.complemento:
        return 'Siempre vale: A y A\' cubren todo el espacio y no se solapan.';
      case TutorMethod.alMenosUno:
        return 'Los ensayos deben ser independientes y con la misma p.';
      case TutorMethod.productoIndependientes:
        return 'Exige independencia real. Sin reposición NO hay independencia.';
      case TutorMethod.productoDependientes:
        return 'Siempre vale. P(B|A) se lee sobre el espacio ya reducido.';
      case TutorMethod.condicional:
        return 'P(B) debe ser distinta de 0. Cuidado con el orden: P(A|B) no '
            'es P(B|A).';
      case TutorMethod.probabilidadTotal:
        return 'Los Aᵢ deben ser excluyentes y cubrir todo el espacio.';
      case TutorMethod.bayes:
        return 'Necesitas las tasas base P(Aᵢ). Sin ellas el resultado no se '
            'puede calcular, y la intuición se equivoca justo por ignorarlas.';
      case TutorMethod.binomial:
        return 'n fijo, ensayos independientes, misma p, y solo dos '
            'resultados por ensayo.';
      case TutorMethod.hipergeometrica:
        return 'Población finita, muestreo sin reposición. Si la población es '
            'muy grande frente a la muestra, la binomial aproxima bien.';
      case TutorMethod.noAplica:
        return 'Faltan supuestos verificables, o el dato no proviene de un '
            'experimento aleatorio.';
    }
  }
}

/// Una opción de una pregunta del árbol.
class ClassifierOption {
  final String label;

  /// Nodo siguiente, o `null` si esta opción produce un método.
  final String? next;
  final TutorMethod? method;

  /// Pista corta que explica por qué esta opción lleva ahí.
  final String? why;

  const ClassifierOption(this.label, {this.next, this.method, this.why});
}

/// Un nodo del árbol.
class ClassifierNode {
  final String id;
  final String question;

  /// Ayuda para responder la pregunta, cuando la pregunta misma es difícil.
  final String? help;
  final List<ClassifierOption> options;

  const ClassifierNode({
    required this.id,
    required this.question,
    required this.options,
    this.help,
  });
}

class ProblemClassifier {
  const ProblemClassifier._();

  static const String rootId = 'q1';

  static const Map<String, ClassifierNode> nodes = {
    'q1': ClassifierNode(
      id: 'q1',
      question: '¿Qué te están pidiendo exactamente?',
      help: 'Léelo dos veces y subraya el verbo. «De cuántas maneras» no es '
          'lo mismo que «cuál es la probabilidad».',
      options: [
        ClassifierOption('La probabilidad de que ocurra un evento',
            next: 'q2'),
        ClassifierOption('De cuántas maneras se puede hacer algo (contar)',
            next: 'c1'),
        ClassifierOption('La probabilidad de A sabiendo que ya ocurrió B',
            next: 'q6',
            why: 'Condicionar reduce el espacio muestral: a partir de ahora '
                'solo existen los resultados donde ocurrió B.'),
        ClassifierOption(
            'La probabilidad de una causa, habiendo observado un resultado',
            method: TutorMethod.bayes,
            why: 'Vas del efecto a la causa: eso es Bayes. Busca la tasa base '
                'antes que nada.'),
        ClassifierOption('Un dato que no viene de un experimento aleatorio',
            method: TutorMethod.noAplica,
            why: 'Sin experimento aleatorio no hay espacio muestral, y sin '
                'espacio muestral no hay probabilidad que calcular.'),
      ],
    ),
    'q2': ClassifierNode(
      id: 'q2',
      question: '¿Puedes escribir la lista completa de resultados posibles?',
      help: 'Si el espacio tiene menos de ~50 resultados (dos dados, tres '
          'monedas, una carta), enumerarlo es más seguro que cualquier '
          'fórmula.',
      options: [
        ClassifierOption('Sí, son pocos y los puedo listar',
            method: TutorMethod.enumerarLaplace,
            why: 'Enumerar elimina de golpe el sesgo de equiprobabilidad: '
                'ves con tus ojos que «suma 7» tiene 6 casos y «suma 12», 1.'),
        ClassifierOption('No, son demasiados', next: 'q3'),
      ],
    ),
    'q3': ClassifierNode(
      id: 'q3',
      question: '¿Cómo está construido el evento?',
      help: 'Busca las palabras clave del enunciado: «o», «y», «al menos», '
          '«ninguno», «exactamente k».',
      options: [
        ClassifierOption('Con «o» (ocurre A o ocurre B)', next: 'q4'),
        ClassifierOption('Con «y» (ocurren A y B)', next: 'q5'),
        ClassifierOption('«Al menos uno» o «ninguno»',
            method: TutorMethod.alMenosUno,
            why: 'Contar «al menos uno» directamente obliga a sumar muchos '
                'casos. El complemento lo resuelve en un paso.'),
        ClassifierOption('«Exactamente k éxitos en n intentos»', next: 'q7'),
        ClassifierOption('Es un evento simple: hay que contar favorables y '
            'posibles', next: 'c1'),
      ],
    ),
    'q4': ClassifierNode(
      id: 'q4',
      question: '¿A y B pueden ocurrir a la vez?',
      help: 'Busca un resultado concreto que esté en los dos. Si lo '
          'encuentras, NO son excluyentes.',
      options: [
        ClassifierOption('Sí, hay resultados comunes',
            method: TutorMethod.reglaSumaGeneral,
            why: 'Hay que restar la intersección o la cuentas dos veces.'),
        ClassifierOption('No, son incompatibles',
            method: TutorMethod.reglaSumaExcluyentes,
            why: 'Excluyentes NO significa independientes: de hecho, dos '
                'eventos excluyentes con probabilidad positiva son siempre '
                'dependientes.'),
      ],
    ),
    'q5': ClassifierNode(
      id: 'q5',
      question: '¿Que ocurra A cambia la probabilidad de B?',
      help: 'Pregunta clave: ¿hay reposición? Sin reposición, la segunda '
          'extracción SIEMPRE depende de la primera.',
      options: [
        ClassifierOption('No cambia nada (con reposición, ensayos separados)',
            method: TutorMethod.productoIndependientes),
        ClassifierOption('Sí cambia (sin reposición, población que se agota)',
            method: TutorMethod.productoDependientes,
            why: 'Después de sacar una bola quedan n−1: el denominador cambia.'),
      ],
    ),
    'q6': ClassifierNode(
      id: 'q6',
      question: '¿Qué tienes como dato?',
      options: [
        ClassifierOption('P(A∩B) y P(B)', method: TutorMethod.condicional),
        ClassifierOption(
            'Las probabilidades de varias causas y la de B bajo cada una',
            method: TutorMethod.probabilidadTotal,
            why: 'Si te piden P(B) a secas, súmala por casos.'),
        ClassifierOption('Una tabla de contingencia con frecuencias',
            method: TutorMethod.condicional,
            why: 'Con la tabla no hace falta fórmula: divide la celda entre '
                'el total de la fila o columna que condiciona.'),
      ],
    ),
    'q7': ClassifierNode(
      id: 'q7',
      question: '¿Los intentos se hacen con reposición (o sobre una población '
          'enorme)?',
      options: [
        ClassifierOption('Sí, la probabilidad de éxito no cambia',
            method: TutorMethod.binomial),
        ClassifierOption('No, la población es pequeña y se agota',
            method: TutorMethod.hipergeometrica,
            why: 'Cada extracción cambia la composición: la binomial '
                'sobreestimaría la variabilidad.'),
      ],
    ),
    'c1': ClassifierNode(
      id: 'c1',
      question: '¿Importa el orden en que se eligen los elementos?',
      help: 'Prueba concreta: intercambia dos elementos de una selección. '
          'Si el resultado es OTRO caso distinto, el orden importa.',
      options: [
        ClassifierOption('Sí, importa', next: 'c2'),
        ClassifierOption('No importa', next: 'c3'),
        ClassifierOption('Hay etapas sucesivas con opciones fijas cada una',
            method: TutorMethod.principioMultiplicativo),
        ClassifierOption('Se ordenan todos, pero algunos son idénticos',
            method: TutorMethod.permutacionesConRepeticion,
            why: 'Las letras repetidas de una palabra: dividir entre el '
                'factorial de cada repetición corrige el sobreconteo.'),
      ],
    ),
    'c2': ClassifierNode(
      id: 'c2',
      question: '¿Un elemento puede aparecer más de una vez?',
      options: [
        ClassifierOption('Sí, puede repetirse',
            method: TutorMethod.variacionesConRepeticion,
            why: 'Cada posición vuelve a tener las n opciones: nᵏ.'),
        ClassifierOption('No, cada elemento se usa a lo más una vez',
            next: 'c4'),
      ],
    ),
    'c3': ClassifierNode(
      id: 'c3',
      question: '¿Un elemento puede aparecer más de una vez?',
      options: [
        ClassifierOption('No (una mano de cartas, un comité)',
            method: TutorMethod.combinaciones),
        ClassifierOption('Sí (repartir objetos idénticos, elegir sabores con '
            'repetición)', method: TutorMethod.combinacionesConRepeticion),
      ],
    ),
    'c4': ClassifierNode(
      id: 'c4',
      question: '¿Se usan todos los elementos disponibles?',
      options: [
        ClassifierOption('Sí, todos', method: TutorMethod.permutaciones),
        ClassifierOption('No, solo k de los n', method: TutorMethod.variaciones),
      ],
    ),
  };

  static ClassifierNode node(String id) =>
      nodes[id] ?? nodes[rootId]!;

  /// Ruta recorrida, para que el estudiante vea su propio razonamiento.
  static String pathSummary(List<String> nodeIds, List<int> choices) {
    final buf = StringBuffer();
    for (var i = 0; i < nodeIds.length && i < choices.length; i++) {
      final n = nodes[nodeIds[i]];
      if (n == null) continue;
      final opt = n.options[choices[i]];
      buf.writeln('• ${n.question} → ${opt.label}');
    }
    return buf.toString().trim();
  }
}
