/// Módulo 1 — Fundamentos.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/lesson.dart';

const List<Lesson> kLessonsM1 = [
  Lesson(
    id: 'm1_l1',
    moduleId: 'm1',
    title: 'Experimento aleatorio',
    objective:
        'Reconocer cuándo una situación admite un tratamiento probabilístico '
        'y cuándo no.',
    preferredExperimentId: 'x1_moneda_justa',
    cards: [
      LessonCard(
        title: 'Tres condiciones, no una',
        body: 'Un **experimento aleatorio** cumple tres cosas a la vez:\n\n'
            '1. Se puede repetir en condiciones parecidas.\n'
            '2. Se conocen de antemano todos los resultados posibles.\n'
            '3. No se puede predecir cuál saldrá en la próxima repetición.\n\n'
            'Fíjate en la condición 2: si no sabes qué puede pasar, no tienes '
            'espacio muestral, y sin espacio muestral no hay probabilidad que '
            'calcular. Mucho de lo que la gente llama «probabilidad» en la '
            'vida diaria falla justo ahí.',
      ),
      LessonCard(
        title: 'Determinista frente a aleatorio',
        body: 'Soltar una piedra es determinista: con la misma altura, el '
            'mismo tiempo de caída. Lanzar un dado es aleatorio: con el mismo '
            'gesto, distintos resultados.\n\n'
            'La frontera no siempre es física. Un dado obedece las leyes de '
            'Newton; si conocieras exactamente la fuerza, el rozamiento y el '
            'ángulo, podrías predecirlo. Lo tratamos como aleatorio porque '
            '**no tenemos acceso a esa información**, y ese es un motivo '
            'perfectamente legítimo: la probabilidad modela nuestra '
            'ignorancia tanto como el mundo.',
        kind: CardKind.idea,
      ),
      LessonCard(
        title: 'Casos que parecen aleatorios y no lo son',
        body: '• «¿Qué probabilidad hay de que apruebe el examen?» — No es '
            'repetible en las mismas condiciones. Se puede estimar, pero no '
            'contar casos.\n'
            '• «El 60 % de mis seguidores prefiere X» — Los seguidores no son '
            'una muestra aleatoria de nadie.\n'
            '• «Probabilidad de que llueva mañana» — Mañana ocurre una sola '
            'vez. Es probabilidad **subjetiva**: un grado de creencia, '
            'legítimo pero de otra naturaleza.\n\n'
            'Reconocer estos casos es la mitad del módulo 4.',
        kind: CardKind.alerta,
        targetsMisconception: 'inferir_sin_experimento',
      ),
      LessonCard(
        title: 'Notación que usarás todo el curso',
        body: '**Ω** (omega) — el espacio muestral: el conjunto de todos los '
            'resultados posibles.\n'
            '**ω** — un resultado elemental, un elemento de Ω.\n'
            '**A, B, C** — eventos: subconjuntos de Ω.\n'
            '**P(A)** — la probabilidad del evento A, un número entre 0 y 1.\n'
            '**|A|** — el número de resultados que contiene A.\n\n'
            'Que P(A) sea un número entre 0 y 1 no es una convención '
            'decorativa: es un axioma, y sirve de alarma. Si tu respuesta se '
            'sale de ahí, el error no es de cuentas, es de método.',
        kind: CardKind.formula,
      ),
    ],
  ),
  Lesson(
    id: 'm1_l2',
    moduleId: 'm1',
    title: 'Construir el espacio muestral',
    objective:
        'Enumerar Ω completo sin perder resultados ni fundir dos en uno.',
    preferredExperimentId: 'x5_dos_dados',
    cards: [
      LessonCard(
        title: 'La regla que evita el 90 % de los errores',
        body: 'Antes de calcular nada: **escribe Ω**. Si tiene menos de unos '
            '50 resultados, escríbelo entero. No es pérdida de tiempo: es el '
            'único momento del problema donde puedes verificar lo que estás '
            'haciendo.\n\n'
            'Los tres errores clásicos —perder resultados, fundir dos en uno '
            'y asumir equiprobabilidad sin comprobarla— desaparecen cuando el '
            'espacio está delante de los ojos.',
      ),
      LessonCard(
        title: 'Dos monedas: cuatro, no tres',
        body: 'Ω = {CC, CS, SC, SS}. Cuatro resultados, todos igual de '
            'probables.\n\n'
            'Quien escribe «dos caras, dos sellos, una de cada» tiene tres '
            'casos y concluye 1/3 para «una de cada». Es falso: «una de cada» '
            'ocurre de DOS maneras (CS y SC), así que vale {{p_una_cada}}, el '
            'doble que cada uno de los otros dos.\n\n'
            'Las monedas son indistinguibles a la vista, pero los resultados '
            'no lo son: CS y SC son dos historias distintas del mundo.',
        kind: CardKind.alerta,
        targetsMisconception: 'espacio_incompleto',
        figures: [
          ContentFigure(
            id: 'p_una_cada',
            fn: 'coinsExactHeads',
            args: [2, 1],
            label: 'P(exactamente una cara en dos monedas)',
            format: FigureFormat.triple,
          ),
        ],
      ),
      LessonCard(
        title: 'Dos dados: 36, no 21',
        body: 'Si anotas el resultado del primer dado y el del segundo, Ω '
            'tiene 6 × 6 = 36 pares ordenados. El par (3,5) y el par (5,3) '
            'son resultados DISTINTOS.\n\n'
            'Quien los funde obtiene 21 casos y todos sus cálculos se '
            'desvían, porque esos 21 casos ya no son equiprobables: «3 y 5» '
            'ocurre el doble de veces que «3 y 3».\n\n'
            'Con Ω de 36 casillas, P(suma 7) = {{p_suma7}} y P(suma 12) = '
            '{{p_suma12}}.',
        kind: CardKind.ejemplo,
        targetsMisconception: 'orden_ignorado_en_espacio',
        figures: [
          ContentFigure(
            id: 'p_suma7',
            fn: 'diceSum',
            args: [7],
            label: 'P(suma 7 con dos dados)',
            format: FigureFormat.triple,
          ),
          ContentFigure(
            id: 'p_suma12',
            fn: 'diceSum',
            args: [12],
            label: 'P(suma 12 con dos dados)',
            format: FigureFormat.triple,
          ),
        ],
      ),
      LessonCard(
        title: 'Un mismo experimento, varios espacios válidos',
        body: 'Con dos dados puedes describir el resultado como:\n\n'
            '• el par ordenado → 36 resultados, **equiprobables**;\n'
            '• la suma → 11 resultados, **no equiprobables**;\n'
            '• «hay al menos un 6» → 2 resultados, **no equiprobables**.\n\n'
            'Los tres son espacios muestrales correctos. Pero solo el primero '
            'admite la regla de «favorables entre posibles». Elegir el '
            'espacio más fino es lo que te deja usar Laplace sin mentir.',
        kind: CardKind.conexion,
        targetsMisconception: 'equiprobabilidad_asumida',
      ),
      LessonCard(
        title: 'Cuando Ω es enorme',
        body: 'No siempre puedes escribirlo: las manos de 5 cartas de una '
            'baraja de 52 son {{manos}}. Ahí entra el módulo 3, que enseña a '
            'contar sin enumerar.\n\n'
            'Pero el orden de aprendizaje importa: primero enumeras espacios '
            'pequeños hasta que sabes exactamente **qué objeto** estás '
            'contando; solo después la fórmula significa algo.',
        kind: CardKind.conexion,
        figures: [
          ContentFigure(
            id: 'manos',
            fn: 'combinations',
            args: [52, 5],
            label: 'Manos de 5 cartas de 52',
            format: FigureFormat.count,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm1_l3',
    moduleId: 'm1',
    title: 'Eventos',
    objective: 'Distinguir resultado de evento y traducir frases a conjuntos.',
    preferredExperimentId: 'x7_carta',
    cards: [
      LessonCard(
        title: 'Un evento es un subconjunto',
        body: 'Un **resultado** es un elemento de Ω. Un **evento** es un '
            'subconjunto de Ω: puede contener uno, varios o ningún '
            'resultado.\n\n'
            'Al lanzar un dado, «sale 4» es un evento con un solo resultado; '
            '«sale par» es un evento con tres: {2, 4, 6}.\n\n'
            'Esto importa porque el denominador de Laplace cuenta '
            '**resultados**, no eventos. Contar eventos ahí es un error '
            'silencioso: no da un número absurdo, da un número plausible y '
            'equivocado.',
        targetsMisconception: 'resultado_vs_evento',
      ),
      LessonCard(
        title: 'Del castellano al conjunto',
        body: 'Traducir es la mitad del trabajo:\n\n'
            '• «A o B» → A ∪ B (unión, incluye que ocurran los dos)\n'
            '• «A y B» → A ∩ B (intersección)\n'
            '• «no A» → A\' (complemento)\n'
            '• «A pero no B» → A − B\n'
            '• «al menos uno» → A ∪ B ∪ …\n'
            '• «ninguno» → (A ∪ B)\' = A\' ∩ B\'\n\n'
            'Cuidado con «o»: en probabilidad es **inclusivo** por defecto. '
            'Si el problema quiere «uno u otro pero no ambos», tiene que '
            'decirlo.',
        kind: CardKind.formula,
        targetsMisconception: 'o_inclusivo_exclusivo',
      ),
      LessonCard(
        title: 'Eventos especiales',
        body: '**Ω** — el evento seguro. P(Ω) = 1.\n'
            '**∅** — el evento imposible. P(∅) = 0.\n'
            '**Eventos elementales** — los de un solo resultado.\n'
            '**Excluyentes (incompatibles)** — A ∩ B = ∅.\n'
            '**Partición** — varios eventos excluyentes que juntos cubren Ω.\n\n'
            'La partición es la estructura sobre la que se apoyan la '
            'probabilidad total y Bayes. Cuando el módulo 2 pida «que los Aᵢ '
            'formen una partición», está pidiendo esto.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Ejemplo con la baraja',
        body: 'Ω son las 52 cartas. Sea C = «es corazón» (13 cartas) y F = '
            '«es figura J, Q o K» (12 cartas).\n\n'
            '• C ∩ F son 3 cartas: J♥, Q♥, K♥.\n'
            '• C ∪ F son 13 + 12 − 3 = 22 cartas → {{p_cf}}.\n'
            '• C\' son 39 cartas.\n\n'
            'Sumar 13 + 12 sin restar las tres comunes da 25/52, que es '
            'sencillamente otro número. El diagrama de Venn no es un adorno: '
            'es la contabilidad.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_cf',
            fn: 'cardIs',
            args: [22],
            label: 'P(corazón o figura)',
            format: FigureFormat.triple,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm1_l4',
    moduleId: 'm1',
    title: 'Frecuencia relativa y ley de los grandes números',
    objective:
        'Entender qué se estabiliza al repetir un experimento, y qué no.',
    preferredExperimentId: 'x3_falacia',
    cards: [
      LessonCard(
        title: 'La definición frecuentista',
        body: 'Repite el experimento n veces y cuenta cuántas ocurre A. La '
            '**frecuencia relativa** es fᵣ = (veces que ocurrió A) / n.\n\n'
            'La ley de los grandes números dice que, al crecer n, fᵣ se '
            'acerca a P(A). No dice que llegue, ni que lo haga rápido, ni que '
            'lo haga de forma ordenada. Dice que la probabilidad de '
            'desviarse más de cualquier margen fijo tiende a cero.',
      ),
      LessonCard(
        title: 'A qué velocidad',
        body: 'El ancho típico de la oscilación es del orden de √(p(1−p)/n). '
            'En castellano: **para reducir el error a la mitad hay que '
            'cuadruplicar los datos**.\n\n'
            'Con una moneda honesta:\n'
            '• n = 100 → oscila unos ±10 puntos\n'
            '• n = 400 → ±5 puntos\n'
            '• n = 10 000 → ±1 punto\n\n'
            'Por eso 30 tiros no prueban nada sobre un dado, y por eso '
            'cualquier «me pasó tres veces seguidas» no es evidencia de nada.',
        kind: CardKind.formula,
        targetsMisconception: 'muestra_pequena_representa',
      ),
      LessonCard(
        title: 'La moneda no tiene memoria',
        body: 'Después de cuatro caras seguidas, la probabilidad de cara en '
            'el quinto lanzamiento es exactamente la misma: 1/2.\n\n'
            'La **falacia del jugador** consiste en creer que el azar «debe» '
            'compensar. No debe nada: cada lanzamiento es independiente de '
            'todos los anteriores. La secuencia CCCCC tiene la misma '
            'probabilidad que CSCSC: {{p_cinco}} cada una.\n\n'
            'Este es el error que sostiene la industria del juego. No es '
            'ingenuidad: es un sesgo cognitivo robusto que persiste incluso '
            'en gente que sabe la teoría.',
        kind: CardKind.alerta,
        targetsMisconception: 'falacia_jugador',
        figures: [
          ContentFigure(
            id: 'p_cinco',
            fn: 'coinsAllHeads',
            args: [5],
            label: 'P(una secuencia concreta de 5 lanzamientos)',
            format: FigureFormat.fraction,
          ),
        ],
      ),
      LessonCard(
        title: 'Lo que NO se compensa',
        body: 'Lo que se estabiliza es la **proporción**. La **diferencia '
            'absoluta** entre caras y sellos tiende a crecer, del orden de '
            '√n.\n\n'
            'Con 100 lanzamientos, una diferencia de 5 es normal (5 %). Con '
            '10 000, una diferencia de 50 también es normal… pero ya es solo '
            'el 0,5 %.\n\n'
            'El azar no corrige lo pasado. Lo **diluye**. Esa es toda la '
            'diferencia entre la ley de los grandes números y la inexistente '
            '«ley de los promedios».',
        kind: CardKind.alerta,
        targetsMisconception: 'ley_de_promedios',
      ),
      LessonCard(
        title: 'Las rachas son normales',
        body: 'En 500 lanzamientos de una moneda honesta, ver 8 o 9 caras '
            'seguidas en algún momento es esperable. Lo raro sería que NO '
            'apareciera ninguna racha.\n\n'
            'Cuando alguien inventa una secuencia «al azar» de cabeza, casi '
            'siempre alterna demasiado: pone menos rachas de las que el azar '
            'produce. Por eso las secuencias realmente aleatorias parecen '
            'sospechosas, y las inventadas parecen creíbles.',
        kind: CardKind.alerta,
        targetsMisconception: 'racha_imposible',
      ),
    ],
  ),
  Lesson(
    id: 'm1_l5',
    moduleId: 'm1',
    title: 'Definición clásica y axiomas',
    objective:
        'Aplicar la regla de Laplace solo cuando su condición se cumple, y '
        'usar los axiomas como control de errores.',
    cards: [
      LessonCard(
        title: 'La regla de Laplace',
        body: 'Si TODOS los resultados de Ω son igualmente probables:\n\n'
            '**P(A) = |A| / |Ω|** = casos favorables / casos posibles.\n\n'
            'La condición no es un detalle: es la hipótesis de la que depende '
            'toda la fórmula. Antes de dividir, pregúntate siempre: '
            '¿realmente cada resultado de mi lista tiene la misma '
            'probabilidad?',
        kind: CardKind.formula,
        targetsMisconception: 'equiprobabilidad_asumida',
      ),
      LessonCard(
        title: 'Dónde falla la condición',
        body: '• Las 11 sumas de dos dados: NO equiprobables.\n'
            '• «Llueve o no llueve»: NO equiprobables.\n'
            '• «Me toca o no me toca la lotería»: NO equiprobables (y menos '
            'mal que no, porque si no serían 50-50).\n'
            '• Una urna con 4 rojas y 6 azules, mirando el COLOR: NO '
            'equiprobable. Mirando la BOLA concreta: sí.\n\n'
            'El último ejemplo enseña el truco general: cuando la '
            'equiprobabilidad falla, casi siempre se arregla bajando a un '
            'espacio más fino, donde sí vale.',
        kind: CardKind.alerta,
      ),
      LessonCard(
        title: 'Los tres axiomas de Kolmogórov',
        body: '1. **No negatividad**: P(A) ≥ 0.\n'
            '2. **Normalización**: P(Ω) = 1.\n'
            '3. **Aditividad**: si A y B son excluyentes, '
            'P(A ∪ B) = P(A) + P(B).\n\n'
            'Todo lo demás del curso se deduce de estos tres. Y sirven como '
            'detector de errores: si obtienes una probabilidad negativa, '
            'mayor que 1, o una unión de excluyentes que no cuadra con la '
            'suma, hay un fallo de método, no de aritmética.',
        kind: CardKind.formula,
        targetsMisconception: 'probabilidad_mayor_que_uno',
      ),
      LessonCard(
        title: 'Propiedades que se usan a diario',
        body: '• P(A\') = 1 − P(A)\n'
            '• P(∅) = 0\n'
            '• Si A ⊆ B entonces P(A) ≤ P(B)\n'
            '• 0 ≤ P(A) ≤ 1\n'
            '• P(A ∪ B) = P(A) + P(B) − P(A ∩ B)\n\n'
            'La tercera tiene una consecuencia que la intuición rechaza: '
            '**añadir una condición nunca aumenta la probabilidad**. '
            '«Ingeniera y deportista» no puede ser más probable que '
            '«ingeniera», por muy bien que encaje con la descripción.',
        kind: CardKind.formula,
        targetsMisconception: 'falacia_conjuncion',
      ),
    ],
  ),
  Lesson(
    id: 'm1_l6',
    moduleId: 'm1',
    title: 'Tres definiciones, tres usos',
    objective: 'Elegir cuál de las tres definiciones aplica a cada situación.',
    cards: [
      LessonCard(
        title: 'Clásica, frecuentista, subjetiva',
        body: '**Clásica (Laplace)** — cuenta casos. Necesita '
            'equiprobabilidad. Dados, cartas, urnas, sorteos.\n\n'
            '**Frecuentista** — repite y mide. Necesita repetibilidad. '
            'Control de calidad, fiabilidad, tasas de falla.\n\n'
            '**Subjetiva (bayesiana)** — grado de creencia, actualizable con '
            'evidencia. Eventos únicos: un proyecto, una elección, un '
            'diagnóstico.\n\n'
            'No compiten: resuelven problemas distintos. Y las tres obedecen '
            'los mismos axiomas, que es lo que permite mezclarlas en un mismo '
            'cálculo.',
      ),
      LessonCard(
        title: 'Cómo elegir',
        body: '¿Puedes enumerar casos igualmente probables? → **clásica**.\n'
            '¿Puedes repetir el experimento muchas veces? → **frecuentista**.\n'
            '¿Ninguna de las dos, pero tienes información? → **subjetiva**, '
            'y sé explícito en que lo es.\n\n'
            'El error profesional más común no es equivocarse de fórmula: es '
            'presentar una probabilidad subjetiva con la autoridad de una '
            'clásica.',
        kind: CardKind.conexion,
        targetsMisconception: 'inferir_sin_experimento',
      ),
      LessonCard(
        title: 'Momios y porcentajes',
        body: 'Fuera del aula la probabilidad viaja disfrazada. «Momios de '
            '3 a 1 en contra» significa 3 casos desfavorables por cada '
            'favorable: P = 1/4 = 25 %, no 33 %.\n\n'
            'Paso de momios a probabilidad: P = favor / (favor + contra).\n'
            'Paso inverso: momios = P : (1 − P).\n\n'
            'Y «1 de cada 8» suele comunicar mejor que «12,5 %», sobre todo '
            'cuando hay que tomar una decisión con el número en la mano.',
        kind: CardKind.formula,
      ),
    ],
  ),
];
