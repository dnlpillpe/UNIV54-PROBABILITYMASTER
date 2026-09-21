/// Módulo 3 — Conteo.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/lesson.dart';

const List<Lesson> kLessonsM3 = [
  Lesson(
    id: 'm3_l1',
    moduleId: 'm3',
    title: 'Principio multiplicativo',
    objective: 'Contar procesos por etapas sin escribir todos los casos.',
    preferredExperimentId: 'x16_orden',
    cards: [
      LessonCard(
        title: 'La idea entera del módulo',
        body: 'Si una tarea se hace en etapas sucesivas, y la etapa 1 tiene '
            'n₁ formas, la etapa 2 tiene n₂ formas (sea cual sea lo elegido '
            'antes), etc., entonces el total es:\n\n'
            '**n₁ · n₂ · … · nₖ**\n\n'
            'Todas las fórmulas de conteo que verás después son casos '
            'particulares de esto. Si alguna vez te olvidas de una, puedes '
            'reconstruirla razonando por etapas.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'La condición escondida',
        body: 'El principio exige que el **número** de opciones de cada etapa '
            'no dependa de lo elegido antes. Cuáles sean puede cambiar; '
            'cuántas, no.\n\n'
            'En una urna sin reposición eso se cumple: la primera extracción '
            'tiene 10 opciones y la segunda siempre 9, sea cual sea la '
            'primera. En cambio, «elige un plato y una bebida que combine» '
            'no lo cumple si cada plato admite un número distinto de bebidas.',
        kind: CardKind.alerta,
      ),
      LessonCard(
        title: 'Ejemplos que se resuelven en una línea',
        body: '• Placas de 3 letras y 3 dígitos (27 letras, con repetición): '
            '{{placas}} placas.\n'
            '• PIN de 4 dígitos: {{pin}} combinaciones.\n'
            '• Menú con 4 entradas, 6 fondos y 3 postres: {{menu}} menús.\n\n'
            'El árbol de decisión dibuja el mismo cálculo: cada nivel '
            'multiplica el número de ramas.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'placas',
            fn: 'multiply',
            args: [27, 27, 27, 10, 10, 10],
            label: 'Placas de 3 letras y 3 dígitos',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'pin',
            fn: 'variationsRep',
            args: [10, 4],
            label: 'PIN de 4 dígitos',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'menu',
            fn: 'multiply',
            args: [4, 6, 3],
            label: 'Menús posibles',
            format: FigureFormat.count,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm3_l2',
    moduleId: 'm3',
    title: 'Variaciones: cuando el orden importa',
    objective: 'Distinguir con y sin repetición, y aplicar nᵏ o n!/(n−k)!',
    cards: [
      LessonCard(
        title: 'Las dos fórmulas',
        body: '**Con repetición**: cada posición vuelve a tener n opciones →'
            ' **nᵏ**.\n\n'
            '**Sin repetición**: cada posición tiene una opción menos →'
            ' **P(n,k) = n!/(n−k)! = n·(n−1)·…·(n−k+1)**.\n\n'
            'Fíjate en la segunda forma: son exactamente k factores '
            'descendentes. Es más fácil de calcular y más difícil de '
            'equivocar que la versión con factoriales.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'La pregunta que decide',
        body: '¿Un elemento puede aparecer dos veces?\n\n'
            '• Contraseñas, PIN, placas, lanzamientos de dado → **sí** → nᵏ\n'
            '• Podios, cargos, turnos, extracciones sin reposición → **no** → '
            'P(n,k)\n\n'
            'Contraseñas de 4 dígitos: {{c_rep}}. Contraseñas de 4 dígitos '
            '**distintos**: {{c_sin}}. La diferencia no es pequeña.',
        kind: CardKind.ejemplo,
        targetsMisconception: 'reposicion_ignorada',
        figures: [
          ContentFigure(
            id: 'c_rep',
            fn: 'variationsRep',
            args: [10, 4],
            label: 'Claves de 4 dígitos con repetición',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'c_sin',
            fn: 'variations',
            args: [10, 4],
            label: 'Claves de 4 dígitos distintos',
            format: FigureFormat.count,
          ),
        ],
      ),
      LessonCard(
        title: 'Permutaciones: el caso k = n',
        body: 'Cuando se usan TODOS los elementos, P(n,n) = n!.\n\n'
            'Ordenar 8 tareas: {{p8}} secuencias. Ordenar 10: {{p10}}. El '
            'factorial crece de forma brutal, y esa es la razón por la que '
            'los problemas de asignación se vuelven imposibles por fuerza '
            'bruta enseguida.\n\n'
            'Caso especial: en una mesa **circular**, las rotaciones son la '
            'misma disposición, así que hay (n−1)! y no n!.',
        kind: CardKind.formula,
        figures: [
          ContentFigure(
            id: 'p8',
            fn: 'factorial',
            args: [8],
            label: '8!',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'p10',
            fn: 'factorial',
            args: [10],
            label: '10!',
            format: FigureFormat.count,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm3_l3',
    moduleId: 'm3',
    title: 'Combinaciones: cuando el orden no importa',
    objective: 'Aplicar C(n,k) y justificar la división por k!',
    preferredExperimentId: 'x16_orden',
    cards: [
      LessonCard(
        title: 'De variaciones a combinaciones',
        body: '**C(n,k) = P(n,k) / k! = n! / (k!·(n−k)!)**\n\n'
            'Se divide entre k! porque cada grupo de k elementos aparece k! '
            'veces entre las variaciones, una por cada orden posible.\n\n'
            'Entender ESA división es entender el módulo. La fórmula sin la '
            'justificación es un ritual que se olvida en dos semanas.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'La prueba del intercambio',
        body: 'Para decidir si el orden importa, toma una selección concreta '
            'e **intercambia dos elementos**.\n\n'
            '• ¿Es otro caso distinto? → el orden importa → variaciones.\n'
            '• ¿Es el mismo caso? → no importa → combinaciones.\n\n'
            'Comité de 3 entre 5 personas: intercambiar dos miembros da el '
            'mismo comité → C(5,3) = {{c53}}. Presidente/secretario/tesorero: '
            'intercambiarlos da otro reparto → P(5,3) = {{v53}}.',
        kind: CardKind.alerta,
        targetsMisconception: 'orden_importa_confundido',
        figures: [
          ContentFigure(
            id: 'c53',
            fn: 'combinations',
            args: [5, 3],
            label: 'C(5,3)',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'v53',
            fn: 'variations',
            args: [5, 3],
            label: 'P(5,3)',
            format: FigureFormat.count,
          ),
        ],
      ),
      LessonCard(
        title: 'Propiedades útiles',
        body: '• C(n,k) = C(n, n−k) — elegir quién entra o quién queda fuera '
            'es lo mismo.\n'
            '• C(n,0) = C(n,n) = 1\n'
            '• ΣC(n,k) para k de 0 a n = 2ⁿ — el total de subconjuntos.\n\n'
            'La primera ahorra cálculo: C(52,50) parece enorme y es C(52,2) = '
            '{{c522}}.',
        kind: CardKind.formula,
        figures: [
          ContentFigure(
            id: 'c522',
            fn: 'combinations',
            args: [52, 2],
            label: 'C(52,2)',
            format: FigureFormat.count,
          ),
        ],
      ),
      LessonCard(
        title: 'Combinaciones con repetición',
        body: 'Cuando no importa el orden pero los elementos SÍ pueden '
            'repetirse (repartir objetos idénticos, elegir 3 sabores de 5 '
            'pudiendo repetir):\n\n'
            '**C(n + k − 1, k)**\n\n'
            'Con 5 sabores eligiendo 3 con repetición: {{crep}} '
            'combinaciones, frente a {{csin}} si no se pudiera repetir. Es la '
            'fórmula menos intuitiva del módulo y la que menos aparece; '
            'reconócela, pero no la memorices antes que las otras.',
        kind: CardKind.formula,
        figures: [
          ContentFigure(
            id: 'crep',
            fn: 'combinationsRep',
            args: [5, 3],
            label: 'C con repetición (5,3)',
            format: FigureFormat.count,
          ),
          ContentFigure(
            id: 'csin',
            fn: 'combinations',
            args: [5, 3],
            label: 'C(5,3)',
            format: FigureFormat.count,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm3_l4',
    moduleId: 'm3',
    title: 'Permutaciones con elementos repetidos',
    objective: 'Corregir el sobreconteo cuando hay objetos indistinguibles.',
    cards: [
      LessonCard(
        title: 'El problema',
        body: '¿De cuántas maneras se ordenan las letras de CASAS?\n\n'
            'Son 5 letras, pero hay tres A… no: hay dos A y dos S. Si fueran '
            'todas distintas serían 5! = 120. Pero intercambiar las dos A no '
            'produce una palabra nueva.\n\n'
            '**n! / (n₁!·n₂!·…)** → 5!/(2!·2!) = {{casas}}.',
        kind: CardKind.formula,
        targetsMisconception: 'sobreconteo_repetidos',
        figures: [
          ContentFigure(
            id: 'casas',
            fn: 'permutationsRep',
            args: [2, 2, 1],
            label: 'Ordenaciones de CASAS',
            format: FigureFormat.count,
          ),
        ],
      ),
      LessonCard(
        title: 'Es la misma idea que C(n,k)',
        body: 'De hecho, C(n,k) es un caso particular: ordenar n objetos de '
            'los que k son «elegidos» (idénticos entre sí) y n−k son «no '
            'elegidos» da n!/(k!·(n−k)!), que es exactamente C(n,k).\n\n'
            'Una sola idea —dividir por las permutaciones internas de cada '
            'grupo idéntico— genera las dos fórmulas.',
        kind: CardKind.conexion,
      ),
      LessonCard(
        title: 'Dónde aparece en la práctica',
        body: '• Rutas en una cuadrícula: ir de una esquina a la opuesta en '
            'una malla 4×3 son movimientos DDDDAAA → {{rutas}} rutas.\n'
            '• Repartir turnos idénticos entre grupos.\n'
            '• Contar secuencias de éxitos y fracasos con k éxitos, que es '
            'justo el coeficiente de la binomial.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'rutas',
            fn: 'permutationsRep',
            args: [4, 3],
            label: 'Rutas en malla 4×3',
            format: FigureFormat.count,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm3_l5',
    moduleId: 'm3',
    title: 'Conteo aplicado a la probabilidad',
    objective:
        'Contar favorables y posibles con el mismo criterio y no mezclarlos.',
    preferredExperimentId: 'x14_cumpleanos',
    cards: [
      LessonCard(
        title: 'La regla de oro',
        body: 'En P(A) = |A|/|Ω|, el numerador y el denominador deben '
            'contarse **con el mismo criterio**: los dos con orden, o los dos '
            'sin orden.\n\n'
            'Cualquiera de los dos funciona y dan el mismo resultado. '
            'Mezclarlos da un número que se parece al correcto pero está '
            'multiplicado o dividido por k!, y no hay forma de detectarlo '
            'mirando el resultado.',
        kind: CardKind.alerta,
        targetsMisconception: 'criterio_mixto',
      ),
      LessonCard(
        title: 'Ejemplo: dos ases de una baraja',
        body: 'Sin orden: C(4,2)/C(52,2) = 6/1 326 = {{p_ases}}.\n\n'
            'Con orden: (4·3)/(52·51) = 12/2 652 — el mismo valor.\n\n'
            'Lo que no puede hacerse es 6/2 652 ni 12/1 326. Elige un '
            'criterio al principio del problema y no lo sueltes.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_ases',
            fn: 'urnAllSameNoRep',
            args: [4, 52, 2],
            label: 'P(dos ases en dos cartas)',
            format: FigureFormat.triple,
          ),
        ],
      ),
      LessonCard(
        title: 'El problema del cumpleaños',
        body: 'Con 23 personas, P(dos cumplen el mismo día) = {{p_cumple23}}. '
            'Con 50 personas, {{p_cumple50}}.\n\n'
            'Se calcula por el complemento: P(todos distintos) = '
            '365·364·…·343 / 365²³.\n\n'
            'La intuición falla porque cuenta personas y lo que manda son '
            'PAREJAS: con 23 personas hay {{parejas}} parejas posibles. Es el '
            'mejor ejemplo de por qué conviene contar antes de opinar.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_cumple23',
            fn: 'birthday',
            args: [23],
            label: 'P(coincidencia con 23 personas)',
            format: FigureFormat.percent,
          ),
          ContentFigure(
            id: 'p_cumple50',
            fn: 'birthday',
            args: [50],
            label: 'P(coincidencia con 50 personas)',
            format: FigureFormat.percent,
          ),
          ContentFigure(
            id: 'parejas',
            fn: 'combinations',
            args: [23, 2],
            label: 'Parejas en un grupo de 23',
            format: FigureFormat.count,
          ),
        ],
      ),
      LessonCard(
        title: 'Muestreo sin reposición: hipergeométrica',
        body: 'De un lote de 50 piezas con 5 defectuosas se toman 10 al azar '
            'sin reposición. P(exactamente 1 defectuosa) = {{p_hiper}}.\n\n'
            '**C(5,1)·C(45,9) / C(50,10)**: elige cuáles defectuosas entran, '
            'cuáles buenas entran, sobre todas las muestras posibles.\n\n'
            'Esta es la fórmula del muestreo de aceptación en calidad y del '
            'muestreo de auditoría. Si la población fuese enorme, la binomial '
            'daría casi lo mismo y es más cómoda.',
        kind: CardKind.formula,
        figures: [
          ContentFigure(
            id: 'p_hiper',
            fn: 'hypergeometric',
            args: [50, 5, 10, 1],
            label: 'P(1 defectuosa en muestra de 10, lote 50 con 5)',
            format: FigureFormat.percent,
          ),
        ],
      ),
    ],
  ),
];
