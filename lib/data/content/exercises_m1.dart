/// Módulo 1 — Ejercicios.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/exercise.dart';

const List<Exercise> kExercisesM1 = [
  Exercise(
    id: 'm1_e01',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 1,
    prompt: '¿Cuál de estas situaciones es un experimento aleatorio en '
        'sentido estricto?',
    explanation:
        'Un experimento aleatorio exige tres cosas: repetible, con resultados '
        'posibles conocidos de antemano, y sin poder predecir cuál saldrá. '
        'Extraer una pieza de un lote las cumple las tres. Las otras fallan '
        'en la repetibilidad o en el conocimiento previo de Ω.',
    detects: ['inferir_sin_experimento'],
    choices: [
      Choice('Extraer una pieza al azar de un lote de 500 y ver si es '
          'defectuosa',
          correct: true,
          feedback: 'Correcto. Es repetible, Ω = {defectuosa, buena} se '
              'conoce de antemano, y el resultado concreto no se puede '
              'predecir.'),
      Choice('Medir la altura de un edificio con un teodolito',
          feedback: 'Es una medición determinista: repitiéndola bien, sale '
              'siempre casi lo mismo. Hay error de medida, pero no un '
              'mecanismo aleatorio que genere resultados distintos.'),
      Choice('Preguntar a tus seguidores de una red qué candidato prefieren',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'No hay mecanismo aleatorio: la muestra se elige a sí '
              'misma. Puedes calcular porcentajes, pero no son probabilidades '
              'de nada más allá de tus seguidores.'),
      Choice('Predecir si tu equipo ganará el clásico del domingo',
          feedback: 'Ocurre una sola vez y no es repetible en las mismas '
              'condiciones. Se puede dar una probabilidad subjetiva, que es '
              'legítima, pero no se cuentan casos favorables.'),
    ],
    hints: ['Repasa las tres condiciones: repetible, Ω conocido, resultado '
        'impredecible.'],
  ),
  Exercise(
    id: 'm1_e02',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 1,
    prompt: 'Lanzas dos monedas. ¿Cuántos resultados tiene el espacio '
        'muestral?',
    explanation:
        'Ω = {CC, CS, SC, SS}: cuatro resultados equiprobables. «Una de cada» '
        'ocurre de dos maneras distintas, y por eso vale 2/4, no 1/3.',
    detects: ['espacio_incompleto'],
    choices: [
      Choice('4', correct: true, feedback: 'Correcto: CC, CS, SC, SS.'),
      Choice('3 (dos caras, dos sellos, una de cada)',
          misconceptionId: 'espacio_incompleto',
          feedback: 'Esos son tres EVENTOS, no tres resultados. «Una de cada» '
              'agrupa dos resultados (CS y SC), así que ese evento vale el '
              'doble que los otros: el espacio de tres casos no es '
              'equiprobable y no admite Laplace.'),
      Choice('2 (cara o sello)',
          feedback: 'Ese sería el espacio de UNA moneda. Con dos monedas hay '
              'que anotar el resultado de cada una.'),
      Choice('6',
          feedback: 'Seis sería con un dado. Con dos monedas: 2 × 2 = 4.'),
    ],
  ),
  Exercise(
    id: 'm1_e03',
    moduleId: 'm1',
    kind: ExerciseKind.construccion,
    difficulty: 2,
    prompt: 'Marca en la cuadrícula todos los resultados en que la suma de '
        'los dos dados es 7.',
    explanation:
        'Son 6 casillas: (1,6), (2,5), (3,4), (4,3), (5,2), (6,1). Forman la '
        'diagonal. Por eso P(suma 7) = 6/36 = 1/6, la suma más probable de '
        'todas.',
    detects: ['equiprobabilidad_asumida', 'orden_ignorado_en_espacio'],
    build: BuildTarget(
      spaceId: 'dice_2_6',
      eventDescription: 'La suma de los dos dados es 7',
      predicate: 'sumEquals',
      predicateArgs: [7],
    ),
    hints: [
      'Recuerda que (3,4) y (4,3) son dos casillas distintas.',
      'Fíjate en la diagonal que va de la esquina inferior izquierda a la '
          'superior derecha.',
    ],
  ),
  Exercise(
    id: 'm1_e04',
    moduleId: 'm1',
    kind: ExerciseKind.calculo,
    difficulty: 1,
    prompt: 'Con dos dados, ¿cuál es la probabilidad de que la suma sea 5? '
        'Responde como fracción, decimal o porcentaje.',
    explanation:
        'Casos favorables: (1,4), (2,3), (3,2), (4,1) → 4 de 36 = 1/9.',
    detects: ['equiprobabilidad_asumida'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_suma5',
        fn: 'diceSum',
        args: [5],
        label: 'P(suma 5)',
      ),
    ),
    hints: ['Enumera los pares ordenados que suman 5, sin olvidar los '
        'simétricos.'],
  ),
  Exercise(
    id: 'm1_e05',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Al lanzar dos dados, ¿qué suma es más probable?',
    explanation:
        'La 7, con 6 formas de 36. La 2 y la 12 tienen una sola forma cada '
        'una. Las 11 sumas no son equiprobables porque el espacio real tiene '
        '36 resultados, no 11.',
    detects: ['equiprobabilidad_asumida'],
    choices: [
      Choice('La 7', correct: true, feedback: 'Correcto: 6 formas de 36.'),
      Choice('Todas igual: hay 11 sumas posibles',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Las 11 sumas forman un espacio muestral válido, pero NO '
              'equiprobable. La 7 se puede formar de 6 maneras y la 12 solo '
              'de una. Laplace exige equiprobabilidad; aquí no la hay.'),
      Choice('La 12, porque necesita el máximo de los dos dados',
          feedback: 'Al revés: exigir 6 en los dos dados deja una sola '
              'casilla de las 36.'),
      Choice('La 6 y la 8, empatadas por encima de la 7',
          feedback: 'La 6 y la 8 tienen 5 formas cada una: van justo detrás '
              'de la 7, que tiene 6.'),
    ],
  ),
  Exercise(
    id: 'm1_e06',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Lanzas una moneda 5 veces. ¿Qué secuencia es más probable?',
    explanation:
        'Las dos son igual de probables: cada secuencia concreta de 5 '
        'lanzamientos vale 1/32. Lo que engaña es que «desordenada» describe '
        'muchas secuencias y «cinco caras», solo una — pero aquí comparamos '
        'secuencias concretas, no descripciones.',
    detects: ['aleatorio_es_parejo'],
    choices: [
      Choice('CSCSS y CCCCC son igual de probables',
          correct: true,
          feedback: 'Correcto: 1/32 cada una. Las secuencias concretas todas '
              'valen lo mismo.'),
      Choice('CSCSS, porque parece más aleatoria',
          misconceptionId: 'aleatorio_es_parejo',
          feedback: 'La apariencia de aleatoriedad no es probabilidad. Ambas '
              'secuencias son un camino concreto de los 32 posibles. Lo que '
              'sí es más probable es el EVENTO «dos o tres caras» frente al '
              'evento «cinco caras».'),
      Choice('CCCCC, porque las rachas son frecuentes',
          feedback: 'Las rachas son frecuentes en secuencias largas, pero eso '
              'no hace que una secuencia concreta valga más que otra.'),
    ],
  ),
  Exercise(
    id: 'm1_e07',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Una ruleta honesta ha salido roja 6 veces seguidas. ¿Qué '
        'conviene apostar en la siguiente?',
    explanation:
        'Nada cambia: la ruleta no tiene memoria. Las tiradas son '
        'independientes, así que la probabilidad del próximo giro es la misma '
        'que la del primero.',
    detects: ['falacia_jugador', 'racha_imposible'],
    choices: [
      Choice('Da igual: la probabilidad no cambió',
          correct: true,
          feedback: 'Correcto. Independencia significa exactamente esto.'),
      Choice('Negro, porque ya toca',
          misconceptionId: 'falacia_jugador',
          feedback: 'Falacia del jugador. La ruleta no lleva la cuenta ni '
              '«debe» nada. Este es el sesgo que sostiene la industria del '
              'juego, y el experimento «Después de la racha» lo mide con '
              'miles de repeticiones: sale 50 %, siempre.'),
      Choice('Rojo, porque está caliente',
          misconceptionId: 'falacia_jugador',
          feedback: 'La versión inversa de la misma falacia («mano caliente»). '
              'Si la ruleta es honesta, las tiradas pasadas no informan sobre '
              'la siguiente.'),
      Choice('Nada: seis rojas seguidas prueban que está trucada',
          misconceptionId: 'racha_imposible',
          feedback: 'Seis rojas seguidas tienen probabilidad cercana a 1/64 '
              'en un tramo cualquiera: en una noche de ruleta es algo que '
              'pasa. Para sospechar de la mesa harían falta muchísimos más '
              'datos.'),
    ],
  ),
  Exercise(
    id: 'm1_e08',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Lanzas una moneda honesta 10 000 veces en vez de 100. ¿Qué le '
        'pasa a la DIFERENCIA absoluta entre número de caras y de sellos?',
    explanation:
        'La proporción se estabiliza, pero la diferencia absoluta tiende a '
        'crecer del orden de √n: ~5 con n = 100, ~50 con n = 10 000. Cincuenta '
        'sobre diez mil sigue siendo medio punto porcentual.',
    detects: ['ley_de_promedios'],
    choices: [
      Choice('Tiende a crecer, aunque la proporción se acerque a 0,5',
          correct: true,
          feedback: 'Correcto. Es la distinción que casi nadie hace: se '
              'estabiliza la proporción, no la diferencia.'),
      Choice('Tiende a 0: el azar compensa los desequilibrios',
          misconceptionId: 'ley_de_promedios',
          feedback: 'Esa es la inexistente «ley de los promedios». El azar no '
              'corrige lo pasado, lo diluye: la diferencia crece, pero '
              'dividida por n cada vez pesa menos.'),
      Choice('Se mantiene constante',
          misconceptionId: 'ley_de_promedios',
          feedback: 'No hay ningún mecanismo que la mantenga fija. Crece con '
              '√n.'),
    ],
    hints: ['Distingue entre la proporción (caras/n) y la diferencia '
        '(caras − sellos).'],
  ),
  Exercise(
    id: 'm1_e09',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Tiras un dado 30 veces y el 6 sale 9 veces. ¿Qué concluyes?',
    explanation:
        'Con n = 30 la frecuencia relativa oscila muchísimo: 9 de 30 (30 %) '
        'frente al 16,7 % esperado está dentro de lo normal. Para sospechar '
        'harían falta cientos o miles de tiros.',
    detects: ['muestra_pequena_representa'],
    choices: [
      Choice('Nada concluyente: con 30 tiros esa desviación es normal',
          correct: true,
          feedback: 'Correcto. El ancho típico de oscilación con n = 30 es de '
              'varios puntos porcentuales.'),
      Choice('El dado está cargado hacia el 6',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Con 30 tiros no puedes distinguir un dado cargado de la '
              'variación normal. Repite el experimento «La moneda honesta» '
              'con n = 30 varias veces: verás proporciones del 10 % al 30 % '
              'con un dado perfectamente honesto.'),
      Choice('El 6 saldrá menos en los próximos 30 tiros para compensar',
          misconceptionId: 'falacia_jugador',
          feedback: 'Falacia del jugador otra vez: el dado no compensa nada.'),
    ],
  ),
  Exercise(
    id: 'm1_e10',
    moduleId: 'm1',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: 'Una urna tiene 4 bolas rojas y 6 azules, y sacas UNA. ¿Se puede '
        'aplicar Laplace mirando solo el color?',
    context: 'No calcules: decide si la condición de la regla se cumple.',
    explanation:
        'Mirando el COLOR hay dos resultados no equiprobables, así que '
        'Laplace no aplica directamente. Bajando al espacio de las 10 bolas '
        'individuales, sí: P(roja) = 4/10.',
    detects: ['equiprobabilidad_asumida'],
    choices: [
      Choice('No sobre los colores, pero sí sobre las 10 bolas individuales',
          correct: true,
          feedback: 'Exacto, y ese es el truco general: cuando la '
              'equiprobabilidad falla, se arregla bajando a un espacio más '
              'fino.'),
      Choice('Sí: hay dos colores, luego P(roja) = 1/2',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Los dos colores no son igualmente probables: hay más '
              'azules que rojas. Contar «resultados» sin comprobar que valen '
              'lo mismo es el error central del módulo.'),
      Choice('No, y no hay forma de arreglarlo',
          feedback: 'Sí la hay: cuenta bolas, no colores. Las 10 bolas sí son '
              'equiprobables.'),
    ],
  ),
  Exercise(
    id: 'm1_e11',
    moduleId: 'm1',
    kind: ExerciseKind.calculo,
    difficulty: 1,
    prompt: 'Lanzas tres monedas. ¿Probabilidad de obtener exactamente dos '
        'caras?',
    explanation:
        'Ω tiene 8 resultados. «Exactamente dos caras» son CCS, CSC y SCC: 3 '
        'de 8.',
    detects: ['espacio_incompleto'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_dos_caras',
        fn: 'coinsExactHeads',
        args: [3, 2],
        label: 'P(exactamente 2 caras en 3 monedas)',
      ),
    ),
    hints: ['Escribe los 8 resultados y cuenta cuántos tienen dos caras.'],
  ),
  Exercise(
    id: 'm1_e12',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 1,
    prompt: 'En el experimento «lanzar un dado», ¿cuál de estos es un '
        'EVENTO y no un resultado?',
    explanation:
        'Un resultado es un elemento de Ω; un evento es un subconjunto. '
        '«Sale número par» = {2, 4, 6} contiene tres resultados.',
    detects: ['resultado_vs_evento'],
    choices: [
      Choice('«Sale número par»',
          correct: true,
          feedback: 'Correcto: es el subconjunto {2, 4, 6}.'),
      Choice('«Sale 5»',
          misconceptionId: 'resultado_vs_evento',
          feedback: 'Es un resultado elemental. También se puede ver como el '
              'evento {5}, pero de un solo elemento: lo que se pedía era un '
              'evento con varios.'),
      Choice('«El dado es de seis caras»',
          feedback: 'Eso describe el experimento, no un subconjunto de '
              'resultados.'),
    ],
  ),
  Exercise(
    id: 'm1_e13',
    moduleId: 'm1',
    kind: ExerciseKind.deteccionError,
    difficulty: 3,
    prompt: 'Un compañero entrega este desarrollo. ¿Dónde está el error?',
    context:
        '«Lanzo dos dados. Los resultados posibles de la suma van de 2 a 12, '
        'o sea 11 casos. La suma 7 es uno de ellos, así que P(suma 7) = 1/11 '
        '≈ 9,1 %.»',
    explanation:
        'El espacio de las sumas es válido pero NO equiprobable. Hay que '
        'trabajar con los 36 pares ordenados: P(suma 7) = 6/36 = 1/6 ≈ '
        '16,7 %.',
    detects: ['equiprobabilidad_asumida'],
    choices: [
      Choice('Aplicó Laplace a un espacio que no es equiprobable',
          correct: true,
          feedback: 'Exacto. Las 11 sumas no valen lo mismo: la 7 sale de 6 '
              'maneras y la 12 de una.'),
      Choice('Contó mal: las sumas van de 1 a 12',
          feedback: 'El rango 2-12 está bien: el mínimo con dos dados es 2.'),
      Choice('Debió usar 36 en el numerador y 11 en el denominador',
          misconceptionId: 'criterio_mixto',
          feedback: 'Mezclar criterios es otro error, no la solución. '
              'Numerador y denominador deben contar el mismo tipo de objeto: '
              '6 pares favorables sobre 36 pares posibles.'),
      Choice('Debió contar 21 pares, porque (3,5) y (5,3) son el mismo '
          'resultado',
          misconceptionId: 'orden_ignorado_en_espacio',
          feedback: 'Fundir (3,5) con (5,3) rompe la equiprobabilidad: «3 y '
              '5» ocurre el doble de veces que «3 y 3». Con dos dados '
              'distinguibles hay 36 pares ordenados, y son esos 36 los que '
              'valen lo mismo.'),
      Choice('No hay error: 1/11 es correcto',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Simula el experimento «Las 36 casillas»: verás que la '
              'suma 7 aparece alrededor del 16,7 % de las veces, no del '
              '9,1 %.'),
    ],
  ),
  Exercise(
    id: 'm1_e14',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Un cálculo da como resultado P(A) = 1,15. ¿Qué haces?',
    explanation:
        'Toda probabilidad vive en [0,1] por axioma. Un valor fuera de ese '
        'rango señala un error de método, casi siempre sumar eventos que se '
        'solapan.',
    detects: ['probabilidad_mayor_que_uno'],
    choices: [
      Choice('Buscar el error de método: probablemente sumé eventos que se '
          'solapan',
          correct: true,
          feedback: 'Correcto, y esa es la causa más frecuente de un valor '
              'mayor que 1.'),
      Choice('Redondearlo a 1, porque el evento es casi seguro',
          misconceptionId: 'probabilidad_mayor_que_uno',
          feedback: 'Redondear esconde el error en vez de corregirlo. El '
              'valor no es «casi seguro»: es imposible, y significa que el '
              'procedimiento estuvo mal.'),
      Choice('Interpretarlo como 115 %, que también se usa',
          misconceptionId: 'probabilidad_mayor_que_uno',
          feedback: 'Los porcentajes mayores que 100 tienen sentido para '
              'crecimientos, no para probabilidades. P(Ω) = 1 es el máximo '
              'posible.'),
    ],
  ),
  Exercise(
    id: 'm1_e15',
    moduleId: 'm1',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Sacas una carta de una baraja de 52. ¿Probabilidad de que sea '
        'corazón o figura (J, Q, K)?',
    explanation:
        '13 corazones + 12 figuras − 3 que son ambas cosas = 22 cartas. '
        'P = 22/52 = 11/26.',
    detects: ['suma_sin_restar_interseccion'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_cf',
        fn: 'cardIs',
        args: [22],
        label: 'P(corazón o figura)',
      ),
    ),
    hints: [
      'Cuenta las figuras de corazones: no las cuentes dos veces.',
      'J♥, Q♥ y K♥ pertenecen a los dos eventos.',
    ],
  ),
  Exercise(
    id: 'm1_e16',
    moduleId: 'm1',
    kind: ExerciseKind.construccion,
    difficulty: 2,
    prompt: 'Marca los resultados en que AL MENOS uno de los dos dados es 6.',
    explanation:
        'Son 11 casillas: la fila del 6 (6) más la columna del 6 (6), menos '
        'la casilla (6,6) que está en las dos. 11/36 ≈ 30,6 %. Quien suma 6 + '
        '6 = 12 comete el error de la regla de la suma en versión visual.',
    detects: ['suma_sin_restar_interseccion'],
    build: BuildTarget(
      spaceId: 'dice_2_6',
      eventDescription: 'Al menos uno de los dados muestra 6',
      predicate: 'anyEquals',
      predicateArgs: [6],
    ),
    hints: ['La casilla (6,6) está en la fila y en la columna: no la marques '
        'dos veces al contar.'],
  ),
  Exercise(
    id: 'm1_e17',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Un pronóstico dice «70 % de probabilidad de lluvia mañana». '
        '¿Qué tipo de probabilidad es?',
    explanation:
        'Mañana ocurre una sola vez: no es repetible. Es una probabilidad '
        'subjetiva (bayesiana) informada por modelos y por la frecuencia '
        'histórica de días parecidos.',
    detects: ['inferir_sin_experimento'],
    choices: [
      Choice('Subjetiva: un grado de creencia informado por datos',
          correct: true,
          feedback: 'Correcto. Es perfectamente legítima, pero conviene '
              'nombrarla como lo que es.'),
      Choice('Clásica: 70 casos favorables de 100',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'No hay 100 casos equiprobables que contar. El «70» no '
              'sale de contar nada.'),
      Choice('Frecuentista pura: mañana se repetirá muchas veces',
          feedback: 'Mañana ocurre una sola vez. Los modelos usan histórico '
              'de días similares, que es una base frecuentista, pero la '
              'afirmación sobre MAÑANA es subjetiva.'),
    ],
  ),
  Exercise(
    id: 'm1_e18',
    moduleId: 'm1',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Lanzas 4 monedas. ¿Probabilidad de obtener al menos una cara?',
    explanation:
        'Por complemento: 1 − P(ninguna cara) = 1 − 1/16 = 15/16 ≈ 93,75 %.',
    detects: ['al_menos_uno_suma'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_al_menos_cara',
        fn: 'coinsAtLeastOneHead',
        args: [4],
        label: 'P(al menos una cara en 4 monedas)',
      ),
    ),
    hints: ['«Al menos una» pide el complemento: ¿cuál es el único caso sin '
        'ninguna cara?'],
  ),
  Exercise(
    id: 'm1_e19',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'La frecuencia relativa de un evento tras 200 repeticiones es '
        '0,32 y su probabilidad teórica es 0,25. ¿Qué significa?',
    explanation:
        'Con n = 200 y p = 0,25, el error estándar es √(0,25·0,75/200) ≈ '
        '0,031, así que 0,32 está a poco más de dos errores estándar. Es una '
        'desviación grande pero no rara.',
    detects: ['muestra_pequena_representa'],
    choices: [
      Choice('Está dentro de lo que la variación de muestreo produce con '
          'n = 200',
          correct: true,
          feedback: 'Correcto: el error estándar ronda 0,03, así que 0,32 '
              'está a poco más de 2 EE.'),
      Choice('El modelo teórico es incorrecto',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Con 200 repeticiones no se puede descartar el modelo por '
              'una diferencia de 7 puntos. Habría que repetir con muchos más '
              'datos antes de acusar al modelo.'),
      Choice('En las próximas 200 repeticiones saldrá por debajo de 0,25 para '
          'compensar',
          misconceptionId: 'ley_de_promedios',
          feedback: 'No hay compensación. Las próximas 200 repeticiones '
              'rondarán 0,25 por su cuenta, y el promedio de las 400 se '
              'acercará porque el exceso inicial pesa menos, no porque se '
              'corrija.'),
    ],
  ),
  Exercise(
    id: 'm1_e20',
    moduleId: 'm1',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Una empresa te pide estimar la probabilidad de que una máquina '
        'nueva falle en su primer mes. ¿Qué haces?',
    context:
        'La máquina es un modelo recién lanzado. No hay histórico propio; el '
        'fabricante declara una tasa de fallos del 2 % mensual medida en su '
        'laboratorio.',
    explanation:
        'No hay datos propios ni espacio muestral contable, así que Laplace '
        'queda descartado. Lo honesto es usar el dato del fabricante como '
        'punto de partida declarado, advertir que las condiciones de '
        'laboratorio no son las de planta, y planificar recoger datos '
        'propios.',
    detects: ['inferir_sin_experimento', 'formula_por_parecido'],
    choices: [
      Choice('Usar el 2 % del fabricante como estimación inicial declarada, '
          'y empezar a registrar fallos propios',
          correct: true,
          feedback: 'Correcto: es una estimación subjetiva informada, y decir '
              'de dónde sale es parte de la respuesta.'),
      Choice('Responder 50 %: falla o no falla',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Dos resultados no significan dos resultados '
              'equiprobables. Con ese criterio, la probabilidad de ganar la '
              'lotería sería 1/2.'),
      Choice('Negarse a dar un número porque no hay experimento aleatorio',
          feedback: 'Es más riguroso que el error anterior, pero la decisión '
              'de la empresa necesita un número. Lo profesional es darlo '
              'diciendo qué es y de dónde sale.'),
    ],
    justifications: [
      Choice('Porque sin datos propios lo correcto es una estimación '
          'subjetiva explícita, revisable cuando lleguen datos',
          correct: true,
          feedback: 'Exacto: el valor de la respuesta está en declarar el '
              'supuesto y su fecha de caducidad.'),
      Choice('Porque el dato del fabricante es una probabilidad clásica '
          'calculada con casos favorables',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Es un dato frecuentista de laboratorio, no un conteo de '
              'casos equiprobables.'),
      Choice('Porque cualquier número sirve si viene de una fuente oficial',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'La autoridad de la fuente no convierte una medición de '
              'laboratorio en una predicción para tu planta.'),
    ],
  ),
  Exercise(
    id: 'm1_e21',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Los momios de un caballo son «4 a 1 en contra». ¿Qué '
        'probabilidad de ganar le asignan?',
    explanation:
        '4 a 1 en contra significa 4 casos desfavorables por cada favorable: '
        'P = 1/(4+1) = 1/5 = 20 %.',
    choices: [
      Choice('20 %', correct: true, feedback: 'Correcto: 1/(4+1) = 0,20.'),
      Choice('25 %',
          feedback: 'Ese sería 1/4, que confunde momios con fracción directa. '
              'El total de casos es 4 + 1 = 5, no 4.'),
      Choice('80 %',
          feedback: 'Ese es el complemento: la probabilidad de que NO gane.'),
      Choice('40 %', feedback: 'No sale de ninguna lectura de «4 a 1».'),
    ],
  ),
  Exercise(
    id: 'm1_e22',
    moduleId: 'm1',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: 'Para calcular P(al menos un 6 al lanzar tres dados), ¿qué '
        'camino es más corto?',
    context: 'Decide el método, no lo ejecutes.',
    explanation:
        'Por complemento: 1 − (5/6)³. Contar directamente obligaría a sumar '
        'los casos con exactamente uno, dos y tres seises, cuidando de no '
        'contar dos veces.',
    detects: ['al_menos_uno_suma'],
    choices: [
      Choice('Complemento: 1 − P(ningún 6)',
          correct: true,
          feedback: 'Correcto. «Al menos uno» pide casi siempre el '
              'complemento.'),
      Choice('Sumar 1/6 + 1/6 + 1/6',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'Eso da 1/2 y es falso: cuenta dos veces los casos con '
              'más de un 6. Con seis dados daría 1, que es claramente '
              'imposible.'),
      Choice('Contar los casos con uno, dos y tres seises por separado',
          feedback: 'Funciona y da el mismo resultado, pero son tres cálculos '
              'en vez de uno, con tres oportunidades de equivocarse.'),
    ],
  ),
  Exercise(
    id: 'm1_e23',
    moduleId: 'm1',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Lanzas tres dados. ¿Probabilidad de que al menos uno sea 6?',
    explanation:
        '1 − (5/6)³ = 1 − 125/216 = 91/216 ≈ 42,1 %. Nada que ver con el 50 % '
        'de sumar 1/6 tres veces.',
    detects: ['al_menos_uno_suma'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_tres_dados',
        fn: 'atLeastOne',
        args: [1, 6, 3],
        label: 'P(al menos un 6 en tres dados)',
      ),
    ),
    hints: ['Calcula primero P(ningún 6) en los tres dados.'],
  ),
  Exercise(
    id: 'm1_e24',
    moduleId: 'm1',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'En un examen, un estudiante dice: «la probabilidad de que salga '
        'el tema 3 es 1/2, porque o sale o no sale». ¿Cuál es el fallo?',
    explanation:
        'Enumerar dos resultados no los hace equiprobables. La regla de '
        'Laplace exige comprobar la condición, y aquí no se cumple.',
    detects: ['equiprobabilidad_asumida'],
    choices: [
      Choice('Confundió «dos resultados posibles» con «dos resultados '
          'igualmente probables»',
          correct: true,
          feedback: 'Exacto. Es el sesgo de equiprobabilidad en su forma más '
              'pura.'),
      Choice('Debió decir 1/3, porque hay tres temas',
          feedback: 'Puede ser, si los tres temas son igualmente probables. '
              'Pero el fallo del razonamiento no es el número, es haber '
              'asumido equiprobabilidad sin comprobarla.'),
      Choice('Ninguno: con dos opciones siempre es 50-50',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Con ese criterio, ganar la lotería sería 50 %: o toca o '
              'no toca.'),
    ],
  ),,
  Exercise(
    id: 'm1_e25',
    moduleId: 'm1',
    kind: ExerciseKind.construccion,
    difficulty: 1,
    prompt: 'Lanzas tres monedas. Marca todos los resultados con EXACTAMENTE '
        'dos caras.',
    explanation:
        'Son 3 de los 8 resultados: CCS, CSC y SCC. «Tres caras» es solo 1 de '
        '8. Por eso «exactamente dos» es tres veces más probable que «tres»: '
        'no porque cada resultado valga más, sino porque la descripción '
        'agrupa más resultados.',
    detects: ['espacio_incompleto'],
    build: BuildTarget(
      spaceId: 'coins_3',
      eventDescription: 'Exactamente dos caras',
      predicate: 'exactHeads',
      predicateArgs: [2],
    ),
    hints: ['Escribe los 8 resultados en orden y ve tachando.'],
  ),
];
