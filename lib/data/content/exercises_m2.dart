/// Módulo 2 — Ejercicios.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/exercise.dart';

const List<Exercise> kExercisesM2 = [
  Exercise(
    id: 'm2_e01',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 1,
    prompt: 'P(A) = 0,5, P(B) = 0,4 y P(A ∩ B) = 0,2. ¿Cuánto vale P(A ∪ B)?',
    explanation: '0,5 + 0,4 − 0,2 = 0,7. La intersección se resta porque al '
        'sumar A y B se cuenta dos veces.',
    detects: ['suma_sin_restar_interseccion'],
    choices: [
      Choice('0,7', correct: true, feedback: 'Correcto: 0,5 + 0,4 − 0,2.'),
      Choice('0,9',
          misconceptionId: 'suma_sin_restar_interseccion',
          feedback: 'Sumaste sin restar la intersección: los resultados que '
              'están en A y en B quedaron contados dos veces.'),
      Choice('0,2',
          misconceptionId: 'o_inclusivo_exclusivo',
          feedback: 'Eso es P(A ∩ B). La unión es «al menos uno», que incluye '
              'los tres trozos: solo A, solo B y ambos.'),
      Choice('0,1',
          feedback: 'Ese es P(A) − P(B). No hay ninguna regla que pida esa '
              'resta.'),
    ],
  ),
  Exercise(
    id: 'm2_e02',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Dos eventos con probabilidad positiva son mutuamente '
        'excluyentes. ¿Son independientes?',
    explanation:
        'No. Si son excluyentes, P(B|A) = 0 mientras que P(B) > 0: saber que '
        'ocurrió A cambia radicalmente la probabilidad de B. Son máximamente '
        'dependientes.',
    detects: ['excluyente_es_independiente'],
    choices: [
      Choice('No: de hecho son lo más dependientes posible',
          correct: true,
          feedback: 'Correcto. Saber que ocurrió uno te dice con certeza que '
              'el otro no ocurrió.'),
      Choice('Sí: si no se solapan, no se influyen',
          misconceptionId: 'excluyente_es_independiente',
          feedback: 'Es exactamente al revés. «No se tocan» significa que '
              'saber uno determina el otro: P(B|A) = 0, muy distinto de '
              'P(B). Revisa el experimento «Excluyentes contra '
              'independientes».'),
      Choice('Depende de los valores de P(A) y P(B)',
          feedback: 'No depende: si son excluyentes y ambos positivos, nunca '
              'pueden ser independientes.'),
    ],
  ),
  Exercise(
    id: 'm2_e03',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Un proceso produce piezas defectuosas con probabilidad 0,1. '
        'Tomas 20 piezas independientes. ¿Probabilidad de que haya al menos '
        'una defectuosa?',
    explanation:
        '1 − 0,9²⁰ ≈ 0,8784. La respuesta 20 × 0,1 = 2 es imposible: ninguna '
        'probabilidad pasa de 1.',
    detects: ['al_menos_uno_suma'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_almenos20',
        fn: 'atLeastOne',
        args: [1, 10, 20],
        label: 'P(al menos una defectuosa en 20)',
      ),
    ),
    hints: ['Calcula primero P(ninguna defectuosa) = 0,9²⁰.'],
  ),
  Exercise(
    id: 'm2_e04',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Urna con 4 rojas y 6 azules. Sacas dos SIN reposición. '
        '¿Probabilidad de que las dos sean rojas?',
    explanation: '(4/10)·(3/9) = 12/90 = 2/15 ≈ 13,3 %.',
    detects: ['producto_sin_independencia'],
    choices: [
      Choice('2/15 ≈ 13,3 %',
          correct: true,
          feedback: 'Correcto: después de sacar una roja quedan 3 rojas de 9 '
              'bolas.'),
      Choice('4/25 = 16 %',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Ese es el resultado CON reposición: (4/10)². Sin '
              'reposición la segunda extracción depende de la primera, y '
              'tanto el numerador como el denominador cambian.'),
      Choice('8/10 = 80 %',
          feedback: 'Sumaste en vez de multiplicar. «Las dos rojas» es una '
              'intersección, no una unión.'),
      Choice('2/5 = 40 %',
          feedback: 'Esa es la probabilidad de que la PRIMERA sea roja. '
              'Falta la segunda extracción.'),
    ],
  ),
  Exercise(
    id: 'm2_e05',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'En una tabla: de 100 personas, 60 estudiaron y de ellas 45 '
        'aprobaron; en total aprobaron 55. ¿Cuánto vale P(estudió | aprobó)?',
    context:
        '           Aprobó   No aprobó   Total\n'
        '  Estudió     45        15        60\n'
        '  No estudió  10        30        40\n'
        '  Total       55        45       100',
    explanation:
        'Condicionar a «aprobó» reduce el mundo a las 55 personas que '
        'aprobaron. De ellas, 45 estudiaron: 45/55 ≈ 0,818.',
    detects: ['condicional_invertida', 'denominador_no_reducido'],
    choices: [
      Choice('45/55 ≈ 0,818',
          correct: true,
          feedback: 'Correcto: el denominador es el total de la columna que '
              'condiciona.'),
      Choice('45/60 = 0,75',
          misconceptionId: 'condicional_invertida',
          feedback: 'Eso es P(aprobó | estudió): condicionaste al revés. '
              'Misma celda arriba, denominador equivocado abajo.'),
      Choice('45/100 = 0,45',
          misconceptionId: 'denominador_no_reducido',
          feedback: 'Eso es P(estudió ∩ aprobó), la conjunta. Al condicionar '
              'hay que reducir el denominador al evento que condiciona.'),
      Choice('55/100 = 0,55',
          feedback: 'Eso es P(aprobó) a secas, sin usar la información sobre '
              'estudiar.'),
    ],
  ),
  Exercise(
    id: 'm2_e06',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Una enfermedad afecta al 1 % de la población. Un test detecta al '
        '99 % de los enfermos y da falso positivo en el 5 % de los sanos. Das '
        'positivo. ¿Probabilidad de estar enfermo?',
    explanation:
        'Con 100 000 personas: 990 verdaderos positivos y 4 950 falsos '
        'positivos. 990/5 940 ≈ 16,7 %.',
    detects: ['tasa_base_ignorada', 'condicional_invertida'],
    choices: [
      Choice('Alrededor del 17 %',
          correct: true,
          feedback: 'Correcto: 990 de 5 940 positivos. La población sana es '
              'tan grande que sus falsos positivos dominan.'),
      Choice('99 %, que es lo que acierta el test',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El 99 % es P(positivo | enfermo). Te preguntan '
              'P(enfermo | positivo), que es la condicional inversa y '
              'depende de la tasa base. Cuenta personas en el experimento '
              '«El test que acierta el 99 %».'),
      Choice('95 %, por la especificidad',
          misconceptionId: 'condicional_invertida',
          feedback: 'La especificidad es P(negativo | sano), otra condicional '
              'distinta. Ninguna de las dos responde la pregunta por sí '
              'sola.'),
      Choice('1 %, la prevalencia',
          feedback: 'La prevalencia es la probabilidad ANTES de conocer el '
              'resultado. El positivo sí aporta información: la sube de 1 % a '
              '~17 %.'),
    ],
    hints: [
      'Imagina 100 000 personas y cuenta cuántas dan positivo en total.',
      'De los positivos, ¿cuántos vienen del grupo enfermo y cuántos del '
          'grupo sano?',
    ],
  ),
  Exercise(
    id: 'm2_e07',
    moduleId: 'm2',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«De los productos defectuosos, el 30 % viene de la línea A». '
        '¿Qué probabilidad es esa?',
    context: 'No calcules: identifica la condicional.',
    explanation:
        'La frase condiciona a «ser defectuoso» y pregunta por la línea: es '
        'P(línea A | defectuoso). La otra lectura, P(defectuoso | línea A), '
        'es un número distinto y lleva a decisiones opuestas.',
    detects: ['condicional_invertida'],
    choices: [
      Choice('P(línea A | defectuoso)',
          correct: true,
          feedback: 'Correcto: «de los defectuosos» define el grupo de '
              'referencia.'),
      Choice('P(defectuoso | línea A)',
          misconceptionId: 'condicional_invertida',
          feedback: 'Esa sería «el 30 % de lo que produce A sale defectuoso», '
              'que es otra afirmación. Si A produce poquísimo, puede aportar '
              'el 30 % de los defectos siendo malísima, o al revés.'),
      Choice('P(línea A ∩ defectuoso)',
          misconceptionId: 'condicional_es_conjunta',
          feedback: 'La conjunta se mediría sobre TODA la producción. Aquí el '
              'denominador ya está restringido a los defectuosos.'),
    ],
  ),
  Exercise(
    id: 'm2_e08',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Un sistema tiene 5 componentes en SERIE, cada uno con 98 % de '
        'fiabilidad. ¿Fiabilidad del sistema?',
    explanation:
        'En serie todos deben funcionar: 0,98⁵ ≈ 0,904. El sistema es menos '
        'fiable que cualquiera de sus partes.',
    choices: [
      Choice('≈ 90,4 %',
          correct: true,
          feedback: 'Correcto: 0,98⁵. Cada componente extra en serie baja la '
              'fiabilidad total.'),
      Choice('98 %, la de cada componente',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'En serie hacen falta los cinco a la vez: es una '
              'intersección de cinco eventos, no uno solo.'),
      Choice('≈ 99,999 %',
          feedback: 'Ese es el resultado en PARALELO, donde basta con que uno '
              'funcione. En serie ocurre lo contrario.'),
      Choice('≈ 9,6 % de fallar, luego 90,4 % — pero solo si fallan '
          'independientemente',
          feedback: 'El número está bien, pero la elección correcta es la '
              'primera. Dicho esto, la advertencia es pertinente: si los '
              'componentes comparten causa de falla, el cálculo no vale.'),
    ],
  ),
  Exercise(
    id: 'm2_e09',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Tres componentes en PARALELO, cada uno con 80 % de fiabilidad. '
        '¿Fiabilidad del sistema? (Basta con que uno funcione.)',
    explanation: '1 − 0,2³ = 1 − 0,008 = 0,992.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_paralelo',
        fn: 'parallelEqual',
        args: [80, 100, 3],
        label: 'Fiabilidad de 3 componentes al 80 % en paralelo',
      ),
    ),
    hints: ['El sistema falla solo si fallan los tres: 0,2 × 0,2 × 0,2.'],
  ),
  Exercise(
    id: 'm2_e10',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: '¿Cuál es el complemento de «los dos componentes funcionan»?',
    explanation:
        'Por De Morgan, (A ∩ B)\' = A\' ∪ B\': «al menos uno falla». No es '
        '«los dos fallan».',
    detects: ['complemento_de_interseccion'],
    choices: [
      Choice('Al menos uno falla',
          correct: true,
          feedback: 'Correcto: (A ∩ B)\' = A\' ∪ B\'.'),
      Choice('Los dos fallan',
          misconceptionId: 'complemento_de_interseccion',
          feedback: 'Eso es A\' ∩ B\', que es el complemento de «al menos uno '
              'funciona». Confundir «no ambos» con «ninguno» cambia por '
              'completo un análisis de fiabilidad.'),
      Choice('Ninguno funciona correctamente',
          misconceptionId: 'complemento_de_interseccion',
          feedback: 'Es la misma confusión: «ninguno funciona» es un caso '
              'particular de «al menos uno falla», no su equivalente.'),
    ],
  ),
  Exercise(
    id: 'm2_e11',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Linda tiene 31 años, es filósofa y participó en movimientos '
        'sociales. ¿Qué es más probable?',
    explanation:
        'Como «cajera y activista» ⊆ «cajera», la segunda opción nunca puede '
        'ser más probable. Es la falacia de la conjunción: la descripción '
        'detallada resulta más verosímil, y verosimilitud no es probabilidad.',
    detects: ['falacia_conjuncion'],
    choices: [
      Choice('Que sea cajera de banco',
          correct: true,
          feedback: 'Correcto. El conjunto «cajera» contiene al conjunto '
              '«cajera y activista»: no puede ser menos probable.'),
      Choice('Que sea cajera de banco Y activista',
          misconceptionId: 'falacia_conjuncion',
          feedback: 'Imposible: añadir una condición nunca aumenta la '
              'probabilidad, P(A ∩ B) ≤ P(A). La descripción encaja mejor, '
              'pero eso es verosimilitud, no probabilidad.'),
      Choice('No hay forma de saberlo sin más datos',
          feedback: 'Sí la hay, y sin ningún dato adicional: la relación de '
              'inclusión entre los conjuntos basta.'),
    ],
  ),
  Exercise(
    id: 'm2_e12',
    moduleId: 'm2',
    kind: ExerciseKind.deteccionError,
    difficulty: 3,
    prompt: 'Audita este desarrollo. ¿Dónde falla?',
    context:
        '«La probabilidad de que un paciente tenga gripe es 0,05. La '
        'probabilidad de tener fiebre teniendo gripe es 0,90. Por lo tanto, '
        'si un paciente tiene fiebre, la probabilidad de que tenga gripe es '
        '0,90.»',
    explanation:
        'Invirtió la condicional. P(fiebre | gripe) = 0,90 no da P(gripe | '
        'fiebre): para eso hacen falta la tasa base de gripe y la '
        'probabilidad de fiebre por otras causas, y se aplica Bayes.',
    detects: ['condicional_invertida', 'tasa_base_ignorada'],
    choices: [
      Choice('Confundió P(fiebre | gripe) con P(gripe | fiebre)',
          correct: true,
          feedback: 'Exacto. Y faltan datos: sin P(fiebre) no se puede '
              'calcular la inversa.'),
      Choice('El error es aritmético: debió multiplicar 0,05 × 0,90',
          misconceptionId: 'condicional_es_conjunta',
          feedback: '0,05 × 0,90 = 0,045 es P(gripe ∩ fiebre), la conjunta, '
              'no la condicional pedida. Faltaría dividir entre P(fiebre).'),
      Choice('No hay error: la condicional es simétrica',
          misconceptionId: 'condicional_invertida',
          feedback: 'No lo es. P(A|B) y P(B|A) comparten numerador pero '
              'tienen denominadores distintos.'),
      Choice('El error es usar 0,05 como tasa base',
          feedback: 'La tasa base está bien dada; el problema es no haberla '
              'usado, junto con la de fiebre, para invertir la condicional.'),
    ],
  ),
  Exercise(
    id: 'm2_e13',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Dos máquinas producen el 60 % y el 40 % de las piezas, con '
        'tasas de defecto de 2 % y 5 %. Si una pieza sale defectuosa, '
        '¿probabilidad de que venga de la primera máquina?',
    explanation:
        'P(defecto) = 0,6·0,02 + 0,4·0,05 = 0,012 + 0,020 = 0,032. '
        'P(M1 | defecto) = 0,012/0,032 = 0,375.',
    detects: ['tasa_base_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_bayes_maq',
        fn: 'bayes2',
        args: [3, 5, 1, 50, 2, 5, 1, 20],
        label: 'P(máquina 1 | pieza defectuosa)',
      ),
    ),
    hints: [
      'Calcula primero la probabilidad total de que una pieza salga '
          'defectuosa.',
      'La máquina 1 produce más piezas, así que aporta muchos defectos aunque '
          'su tasa sea menor.',
    ],
  ),
  Exercise(
    id: 'm2_e14',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'P(A) = 0,3, P(B) = 0,5 y P(A ∩ B) = 0,15. ¿Son independientes?',
    explanation:
        'P(A)·P(B) = 0,3 × 0,5 = 0,15, que coincide con P(A ∩ B). Sí son '
        'independientes. Y además se solapan, lo que muestra que '
        'independiente no es excluyente.',
    detects: ['independiente_es_excluyente'],
    choices: [
      Choice('Sí: P(A)·P(B) = 0,15 = P(A ∩ B)',
          correct: true,
          feedback: 'Correcto. La comprobación es esa multiplicación, nada '
              'más.'),
      Choice('No, porque se solapan',
          misconceptionId: 'independiente_es_excluyente',
          feedback: 'Solaparse no impide la independencia; al contrario, si '
              'no se solaparan sería imposible que fueran independientes.'),
      Choice('No hay datos suficientes',
          feedback: 'Con P(A), P(B) y P(A ∩ B) alcanza: basta comparar el '
              'producto con la intersección.'),
    ],
  ),
  Exercise(
    id: 'm2_e15',
    moduleId: 'm2',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: 'Sacas 3 cartas de una baraja sin reposición y quieres P(las tres '
        'son corazones). ¿Qué regla aplicas?',
    context: 'Solo el método.',
    explanation:
        'Regla del producto con condicionales: (13/52)·(12/51)·(11/50). Sin '
        'reposición no hay independencia.',
    detects: ['producto_sin_independencia', 'reposicion_ignorada'],
    choices: [
      Choice('Producto con probabilidades condicionadas, porque no hay '
          'reposición',
          correct: true,
          feedback: 'Correcto: cada factor se lee sobre la baraja que quedó.'),
      Choice('Producto simple: (13/52)³',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Eso asume reposición. Sin reponer, después del primer '
              'corazón quedan 12 corazones de 51 cartas.'),
      Choice('Regla de la suma, porque son tres cartas',
          feedback: '«Las tres» es una intersección, no una unión. La suma se '
              'usa para «o», no para «y».'),
    ],
  ),
  Exercise(
    id: 'm2_e16',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Urna con 5 rojas y 5 azules. Sacas 3 sin reposición. '
        '¿Probabilidad de que las tres sean rojas?',
    explanation: 'C(5,3)/C(10,3) = 10/120 = 1/12 ≈ 8,3 %.',
    detects: ['producto_sin_independencia'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_tres_rojas',
        fn: 'urnAllSameNoRep',
        args: [5, 10, 3],
        label: 'P(tres rojas sin reposición)',
      ),
    ),
    hints: ['(5/10)·(4/9)·(3/8), o bien C(5,3)/C(10,3): dan lo mismo.'],
  ),
  Exercise(
    id: 'm2_e17',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Con el mismo test (99 % sensibilidad, 95 % especificidad), la '
        'prevalencia pasa del 1 % al 10 %. ¿Qué pasa con la fiabilidad de un '
        'positivo?',
    explanation:
        'Sube de ~16,7 % a ~68,8 %. El test no cambió: cambió la población a '
        'la que se aplica.',
    detects: ['tasa_base_ignorada'],
    choices: [
      Choice('Sube muchísimo: de ~17 % a ~69 %',
          correct: true,
          feedback: 'Correcto. Por eso importa a quién se le aplica la '
              'prueba.'),
      Choice('No cambia: el test es el mismo',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El valor predictivo positivo NO es una propiedad del '
              'test: depende de la prevalencia. Sensibilidad y especificidad '
              'sí son del test.'),
      Choice('Sube exactamente 10 veces, como la prevalencia',
          feedback: 'La relación no es proporcional: pasa de 16,7 % a 68,8 %, '
              'algo más de cuatro veces.'),
    ],
  ),
  Exercise(
    id: 'm2_e18',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 1,
    prompt: '¿Cuál es la traducción correcta de «no ocurre ninguno de los dos '
        'eventos»?',
    explanation: 'De Morgan: (A ∪ B)\' = A\' ∩ B\'.',
    detects: ['complemento_de_interseccion'],
    choices: [
      Choice("A' ∩ B'", correct: true, feedback: 'Correcto.'),
      Choice("A' ∪ B'",
          misconceptionId: 'complemento_de_interseccion',
          feedback: 'Eso es «al menos uno no ocurre», es decir, el '
              'complemento de la intersección.'),
      Choice("(A ∩ B)'",
          misconceptionId: 'complemento_de_interseccion',
          feedback: 'Eso es «no ocurren los dos», que permite que ocurra uno.'),
    ],
  ),
  Exercise(
    id: 'm2_e19',
    moduleId: 'm2',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Un sistema de alarma antirrobo detecta el 99 % de las '
        'intrusiones y da una falsa alarma en el 2 % de las noches sin '
        'intrusión. Las intrusiones ocurren 1 noche de cada 1 000. Suena la '
        'alarma. ¿Qué haces con esta información?',
    context:
        'Eres responsable de seguridad y debes decidir el protocolo de '
        'respuesta.',
    explanation:
        'P(intrusión | alarma) = (0,001·0,99) / (0,001·0,99 + 0,999·0,02) ≈ '
        '0,0472: menos del 5 %. La alarma es informativa (sube la '
        'probabilidad 47 veces) pero la gran mayoría de las alarmas son '
        'falsas, así que el protocolo debe contemplarlo.',
    detects: ['tasa_base_ignorada', 'evidencia_confirma_causa'],
    choices: [
      Choice('Verificar antes de actuar: menos del 5 % de las alarmas '
          'corresponde a una intrusión real',
          correct: true,
          feedback: 'Correcto. Sigue siendo una señal valiosa —multiplica la '
              'probabilidad por 47— pero no justifica una respuesta máxima '
              'automática.'),
      Choice('Actuar como si hubiera intrusión: el sistema acierta el 99 %',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El 99 % es P(alarma | intrusión). Con intrusiones tan '
              'raras, las falsas alarmas del 2 % sobre 999 noches tranquilas '
              'superan ampliamente a las verdaderas.'),
      Choice('Ignorar la alarma: casi todas son falsas',
          misconceptionId: 'evidencia_confirma_causa',
          feedback: 'El error contrario. La alarma multiplica por 47 la '
              'probabilidad de intrusión: es muchísima información, aunque '
              'no sea concluyente.'),
    ],
    justifications: [
      Choice('Porque P(intrusión | alarma) ≈ 4,7 %, no 99 %: la tasa base es '
          'bajísima y domina el resultado',
          correct: true,
          feedback: 'Exacto, y esa es la cifra que debe ir en el protocolo.'),
      Choice('Porque el 2 % de falsas alarmas es un valor alto para un '
          'sistema de seguridad',
          feedback: 'El 2 % no es alto por sí mismo; el problema es que se '
              'aplica a 999 noches de cada 1 000. El mismo 2 % sería '
              'irrelevante si las intrusiones fueran frecuentes.'),
      Choice('Porque los sistemas automáticos nunca son fiables',
          misconceptionId: 'evidencia_confirma_causa',
          feedback: 'El sistema es excelente; el problema es la tasa base, no '
              'la tecnología.'),
    ],
  ),
  Exercise(
    id: 'm2_e20',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'P(A) = 0,4 y P(B|A) = 0,25. ¿Cuánto vale P(A ∩ B)?',
    explanation: 'Regla del producto: 0,4 × 0,25 = 0,10.',
    choices: [
      Choice('0,10', correct: true, feedback: 'Correcto: P(A)·P(B|A).'),
      Choice('0,65',
          feedback: 'Sumaste. La intersección se obtiene multiplicando, no '
              'sumando.'),
      Choice('0,25',
          misconceptionId: 'condicional_es_conjunta',
          feedback: 'Esa es la condicional, que se mide dentro de A. La '
              'conjunta se mide sobre todo Ω y es menor.'),
      Choice('0,625',
          feedback: 'Dividiste 0,25 entre 0,4. Esa operación despeja P(A∩B) '
              'de otra fórmula, no esta.'),
    ],
  ),
  Exercise(
    id: 'm2_e21',
    moduleId: 'm2',
    kind: ExerciseKind.construccion,
    difficulty: 2,
    prompt: 'Marca los resultados en que los dos dados muestran el mismo '
        'número (dobles).',
    explanation:
        'Son 6 casillas: (1,1) a (6,6), la diagonal principal. P = 6/36 = '
        '1/6.',
    build: BuildTarget(
      spaceId: 'dice_2_6',
      eventDescription: 'Los dos dados muestran el mismo número',
      predicate: 'doubles',
    ),
    detects: ['orden_ignorado_en_espacio'],
  ),
  Exercise(
    id: 'm2_e22',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'En una fábrica, A = «la pieza pasa control visual» y B = «la '
        'pieza pasa control dimensional». Se sabe que P(A) = 0,9, P(B) = 0,85 '
        'y P(A ∪ B) = 0,95. ¿Qué proporción de piezas pasa ambos controles?',
    explanation:
        'De P(A∪B) = P(A) + P(B) − P(A∩B): 0,95 = 0,9 + 0,85 − P(A∩B), así '
        'que P(A∩B) = 0,80.',
    detects: ['suma_sin_restar_interseccion'],
    choices: [
      Choice('0,80', correct: true, feedback: 'Correcto: se despeja de la '
          'regla general de la suma.'),
      Choice('0,765 (= 0,9 × 0,85)',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Eso asume independencia, que aquí no está dada. Los '
              'datos permiten despejar el valor real, que es 0,80: los '
              'controles NO son independientes.'),
      Choice('0,05',
          feedback: 'Ese es el porcentaje que no pasa ninguno de los dos, '
              '1 − P(A∪B).'),
      Choice('1,75',
          misconceptionId: 'probabilidad_mayor_que_uno',
          feedback: 'Sumar 0,9 + 0,85 da un valor mayor que 1: alarma '
              'inmediata de que falta restar la intersección.'),
    ],
  ),
  Exercise(
    id: 'm2_e23',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'Una tarea falla en el 3 % de las ejecuciones. ¿Probabilidad de '
        'que en 50 ejecuciones independientes NO falle ninguna?',
    explanation: '0,97⁵⁰ ≈ 0,2181.',
    detects: ['ninguno_es_uno_menos_p'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_ninguna50',
        fn: 'noneIn',
        args: [3, 100, 50],
        label: 'P(ninguna falla en 50 ejecuciones)',
      ),
    ),
    hints: ['«Ninguna» en n intentos es (1 − p)ⁿ, no 1 − p.'],
  ),
  Exercise(
    id: 'm2_e24',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Dos servidores fallan de forma independiente con probabilidad '
        '0,01 cada uno. Están en paralelo. ¿Cuál es el punto débil del '
        'cálculo «P(caída) = 0,01 × 0,01 = 0,0001»?',
    explanation:
        'La aritmética es correcta; el supuesto puede no serlo. Si los dos '
        'servidores comparten fuente de energía, red o centro de datos, sus '
        'fallos están correlacionados y la probabilidad real de caída '
        'conjunta es mucho mayor.',
    detects: ['producto_sin_independencia'],
    choices: [
      Choice('El supuesto de independencia: causas comunes de falla lo rompen',
          correct: true,
          feedback: 'Correcto. Es el error clásico en análisis de '
              'confiabilidad y en riesgo financiero: lo que falla junto '
              'nunca era independiente.'),
      Choice('Debió sumar en vez de multiplicar',
          feedback: '«Los dos caen» es una intersección: se multiplica. El '
              'problema está en el supuesto, no en la operación.'),
      Choice('Ninguno: el cálculo es correcto',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Es correcto solo BAJO independencia, y ese supuesto hay '
              'que justificarlo. Dos servidores en el mismo rack no fallan de '
              'forma independiente.'),
    ],
  ),
  Exercise(
    id: 'm2_e25',
    moduleId: 'm2',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Sabiendo que en una familia de dos hijos al menos uno es niña, '
        '¿cuál es la probabilidad de que los dos sean niñas?',
    explanation:
        'Ω = {NN, NV, VN, VV}. Condicionar a «al menos una niña» deja tres '
        'casos: NN, NV, VN. Solo uno tiene dos niñas: 1/3, no 1/2.',
    detects: ['denominador_no_reducido', 'espacio_incompleto'],
    choices: [
      Choice('1/3',
          correct: true,
          feedback: 'Correcto. Condicionar redujo el espacio a tres casos, no '
              'a dos.'),
      Choice('1/2, porque el otro hijo es niña o niño',
          misconceptionId: 'denominador_no_reducido',
          feedback: 'La trampa está en que «el otro» no está definido: la '
              'información recibida es sobre la pareja, no sobre un hijo '
              'concreto. Escribe los cuatro casos y tacha VV: quedan tres.'),
      Choice('1/4',
          feedback: 'Ese es P(dos niñas) sin condicionar. La información «al '
              'menos una niña» sube la probabilidad.'),
    ],
    hints: ['Escribe Ω = {NN, NV, VN, VV} y elimina los casos incompatibles '
        'con el dato.'],
  ),
  Exercise(
    id: 'm2_e26',
    moduleId: 'm2',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'El 20 % de los correos son spam. El filtro marca el 95 % del '
        'spam y también el 3 % del correo legítimo. Si un correo queda '
        'marcado, ¿probabilidad de que sea spam?',
    explanation:
        'P(marcado) = 0,2·0,95 + 0,8·0,03 = 0,19 + 0,024 = 0,214. '
        'P(spam | marcado) = 0,19/0,214 ≈ 0,8879.',
    detects: ['tasa_base_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_spam',
        fn: 'bayes2',
        args: [1, 5, 19, 20, 4, 5, 3, 100],
        label: 'P(spam | marcado)',
      ),
    ),
    hints: [
      'Imagina 1 000 correos: 200 spam y 800 legítimos.',
      'Compara los marcados que vienen de cada grupo.',
    ],
  ),,
  Exercise(
    id: 'm2_e27',
    moduleId: 'm2',
    kind: ExerciseKind.construccion,
    difficulty: 3,
    prompt: 'Marca los resultados en que la suma es 7 O al menos un dado '
        'muestra 6.',
    explanation:
        'Suma 7 son 6 casillas; «al menos un 6» son 11. Pero (1,6) y (6,1) '
        'están en los dos eventos, así que la unión tiene 6 + 11 − 2 = 15 '
        'casillas, no 17. Marcar la cuadrícula hace visible la regla de la '
        'suma: las dos casillas compartidas se cuentan una sola vez.',
    detects: ['suma_sin_restar_interseccion'],
    build: BuildTarget(
      spaceId: 'dice_2_6',
      eventDescription: 'Suma 7 o al menos un 6',
      predicate: 'sumSevenOrAnySix',
    ),
    hints: [
      'Marca primero la diagonal de la suma 7.',
      '¿Cuáles de esas casillas ya tienen un 6?',
    ],
  ),
  Exercise(
    id: 'm2_e28',
    moduleId: 'm2',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Un laboratorio ofrece dos pruebas para la misma enfermedad. '
        '¿Cuál pides para un tamizaje poblacional?',
    context:
        'Prueba A: sensibilidad 99 %, especificidad 90 %.\n'
        'Prueba B: sensibilidad 92 %, especificidad 99 %.\n'
        'La enfermedad afecta al 0,5 % de la población, y el objetivo es '
        'tamizar a 200 000 personas sanas en su mayoría.',
    explanation:
        'Con prevalencia 0,5 %: la prueba A produce 990 verdaderos positivos '
        'y 19 900 falsos (VPP ≈ 4,7 %); la B produce 920 verdaderos y 1 990 '
        'falsos (VPP ≈ 31,6 %). En tamizaje masivo la especificidad domina, '
        'porque se aplica a la enorme población sana. La sensibilidad manda '
        'cuando el costo de un falso negativo es el que importa, que es otro '
        'escenario.',
    detects: ['tasa_base_ignorada', 'condicional_invertida'],
    choices: [
      Choice('La prueba B: con prevalencia tan baja, la especificidad manda',
          correct: true,
          feedback: 'Correcto: la B genera diez veces menos falsos positivos, '
              'y su VPP es casi siete veces mayor.'),
      Choice('La prueba A, porque detecta más enfermos',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'Detecta 70 enfermos más, y a cambio genera 17 910 falsos '
              'positivos más. En 200 000 personas, eso son 17 910 alarmas y '
              'pruebas confirmatorias innecesarias.'),
      Choice('Cualquiera: las dos superan el 90 % en ambos indicadores',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Los indicadores se parecen, los resultados no: '
              'VPP de 4,7 % frente a 31,6 %. La diferencia la produce la '
              'prevalencia, que no aparece en ninguno de los dos '
              'indicadores.'),
    ],
    justifications: [
      Choice('Porque los falsos positivos salen de la población sana, que es '
          'el 99,5 %: un punto de especificidad pesa mucho más que un punto '
          'de sensibilidad',
          correct: true,
          feedback: 'Exacto. Y la frase clave del informe es esa, no el '
              'número.'),
      Choice('Porque la especificidad es siempre más importante que la '
          'sensibilidad',
          misconceptionId: 'formula_por_parecido',
          feedback: 'No siempre: si la enfermedad fuera frecuente, o si un '
              'falso negativo costara una vida, la prioridad se invierte. Lo '
              'que decide es la prevalencia y el costo de cada error.'),
      Choice('Porque la prueba B tiene mejor promedio entre los dos '
          'indicadores',
          misconceptionId: 'formula_por_parecido',
          feedback: 'El promedio de los dos indicadores no significa nada: se '
              'aplican a poblaciones de tamaños muy distintos.'),
    ],
    hints: [
      'Cuenta personas sobre 200 000, no porcentajes.',
      '¿Cuántos falsos positivos produce cada prueba sobre los 199 000 sanos?',
    ],
  ),
];
