/// Módulo 3 — Ejercicios.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/exercise.dart';

const List<Exercise> kExercisesM3 = [
  Exercise(
    id: 'm3_e01',
    moduleId: 'm3',
    kind: ExerciseKind.clasificacion,
    difficulty: 1,
    prompt: 'Eliges 3 personas de un grupo de 10 para formar un comité sin '
        'cargos. ¿Qué técnica de conteo corresponde?',
    context: 'Solo el método.',
    explanation:
        'No importa el orden (el comité es el mismo si cambias a quién '
        'nombras primero) y no hay repetición: combinaciones, C(10,3) = 120.',
    detects: ['orden_importa_confundido'],
    choices: [
      Choice('Combinaciones C(10,3)',
          correct: true,
          feedback: 'Correcto: intercambiar dos miembros da el mismo comité.'),
      Choice('Variaciones P(10,3)',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'Eso cuenta 720 y multiplica por 6 el resultado correcto: '
              'estarías contando cada comité una vez por cada orden en que '
              'puedes nombrar a sus tres miembros.'),
      Choice('Variaciones con repetición 10³',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Una persona no puede ocupar dos plazas del comité: no '
              'hay repetición.'),
      Choice('Permutaciones 10!',
          feedback: 'Eso ordenaría a las diez personas. Aquí solo eliges '
              'tres.'),
    ],
  ),
  Exercise(
    id: 'm3_e02',
    moduleId: 'm3',
    kind: ExerciseKind.clasificacion,
    difficulty: 1,
    prompt: 'Eliges 3 personas de 10 para presidente, secretario y tesorero. '
        '¿Qué técnica corresponde?',
    context: 'Solo el método.',
    explanation:
        'Ahora el orden importa (no es lo mismo quién es presidente): '
        'variaciones sin repetición, P(10,3) = 720.',
    detects: ['orden_importa_confundido'],
    choices: [
      Choice('Variaciones P(10,3)',
          correct: true,
          feedback: 'Correcto: intercambiar presidente y tesorero da otro '
              'reparto.'),
      Choice('Combinaciones C(10,3)',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'C(10,3) = 120 cuenta los GRUPOS, no los repartos de '
              'cargos. Cada grupo admite 3! = 6 asignaciones distintas.'),
      Choice('10³',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Una persona no puede tener dos cargos: sin repetición.'),
    ],
  ),
  Exercise(
    id: 'm3_e03',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 1,
    prompt: '¿Cuántas claves de 4 dígitos existen si los dígitos pueden '
        'repetirse?',
    explanation: '10⁴ = 10 000: cada posición vuelve a tener 10 opciones.',
    detects: ['reposicion_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_pin',
        fn: 'variationsRep',
        args: [10, 4],
        label: 'Claves de 4 dígitos con repetición',
        format: FigureFormat.count,
      ),
      acceptFraction: false,
      acceptPercent: false,
      tolerance: 0.0,
    ),
  ),
  Exercise(
    id: 'm3_e04',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: '¿Cuántas claves de 4 dígitos existen si los dígitos deben ser '
        'todos distintos?',
    explanation: '10 × 9 × 8 × 7 = 5 040 = P(10,4).',
    detects: ['reposicion_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_pin_dist',
        fn: 'variations',
        args: [10, 4],
        label: 'Claves de 4 dígitos distintos',
        format: FigureFormat.count,
      ),
      acceptFraction: false,
      acceptPercent: false,
      tolerance: 0.0,
    ),
    hints: ['Cada posición tiene una opción menos que la anterior.'],
  ),
  Exercise(
    id: 'm3_e05',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: '¿De cuántas formas se pueden ordenar las letras de la palabra '
        'CASAS?',
    explanation: '5!/(2!·2!) = 30: hay dos A y dos S indistinguibles.',
    detects: ['sobreconteo_repetidos'],
    choices: [
      Choice('30', correct: true, feedback: 'Correcto: 120/(2·2).'),
      Choice('120',
          misconceptionId: 'sobreconteo_repetidos',
          feedback: 'Eso es 5!, que trata las dos A como distinguibles. '
              'Intercambiar las dos A da la misma palabra, así que cada '
              'ordenación se cuenta cuatro veces (2! por las A, 2! por las '
              'S).'),
      Choice('60',
          misconceptionId: 'sobreconteo_repetidos',
          feedback: 'Dividiste solo por una de las repeticiones. Hay dos '
              'grupos repetidos: las A y las S.'),
      Choice('20',
          feedback: 'No corresponde a ninguna lectura del problema: 5!/(2!·2!) '
              '= 30.'),
    ],
  ),
  Exercise(
    id: 'm3_e06',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: '¿Cuántas manos distintas de 5 cartas se pueden formar con una '
        'baraja de 52?',
    explanation: 'C(52,5) = 2 598 960. El orden en que recibes las cartas no '
        'cambia la mano.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_manos',
        fn: 'combinations',
        args: [52, 5],
        label: 'Manos de 5 cartas',
        format: FigureFormat.count,
      ),
      acceptFraction: false,
      acceptPercent: false,
      tolerance: 0.0,
    ),
  ),
  Exercise(
    id: 'm3_e07',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'C(52,50) es igual a…',
    explanation:
        'C(n,k) = C(n, n−k): elegir 50 cartas equivale a decidir cuáles 2 '
        'quedan fuera. C(52,50) = C(52,2) = 1 326.',
    choices: [
      Choice('C(52,2) = 1 326',
          correct: true,
          feedback: 'Correcto. La simetría ahorra muchísimo cálculo.'),
      Choice('Un número astronómico, cercano a 52!',
          feedback: 'Elegir casi todas es tan fácil como decidir las pocas '
              'que quedan fuera: solo hay 1 326 formas.'),
      Choice('50! / 2!',
          feedback: 'No corresponde a la fórmula de combinaciones.'),
    ],
  ),
  Exercise(
    id: 'm3_e08',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'En una lotería eliges 6 números de 49. ¿Cuántas combinaciones '
        'posibles hay?',
    explanation: 'C(49,6) = 13 983 816.',
    detects: ['control_del_azar'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_loteria',
        fn: 'combinations',
        args: [49, 6],
        label: 'Combinaciones de lotería 6/49',
        format: FigureFormat.count,
      ),
      acceptFraction: false,
      acceptPercent: false,
      tolerance: 0.0,
    ),
  ),
  Exercise(
    id: 'm3_e09',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'En esa lotería, ¿qué combinación es más probable que salga?',
    explanation:
        'Todas son igual de probables: 1 entre 13 983 816. 1-2-3-4-5-6 parece '
        'menos probable porque confundimos un resultado concreto con la '
        'descripción «números desordenados», que agrupa millones de '
        'resultados.',
    detects: ['aleatorio_es_parejo', 'control_del_azar'],
    choices: [
      Choice('Todas exactamente igual',
          correct: true,
          feedback: 'Correcto: cada combinación es un resultado del espacio '
              'muestral y todos valen lo mismo.'),
      Choice('Una combinación «dispersa» como 3-17-22-31-38-44',
          misconceptionId: 'aleatorio_es_parejo',
          feedback: 'Parece más aleatoria, pero como resultado concreto vale '
              'exactamente lo mismo que 1-2-3-4-5-6. Lo que sí es más '
              'probable es el EVENTO «números dispersos», que reúne muchos '
              'resultados.'),
      Choice('1-2-3-4-5-6, porque casi nadie la juega',
          misconceptionId: 'control_del_azar',
          feedback: 'Cuánta gente la juegue afecta al premio que te tocaría '
              'compartir, no a la probabilidad de que salga.'),
    ],
  ),
  Exercise(
    id: 'm3_e10',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: '¿Cuántas personas hacen falta para que la probabilidad de que '
        'dos cumplan años el mismo día supere el 50 %?',
    explanation:
        'Con 23 personas la probabilidad es {{p23}}. La intuición falla '
        'porque cuenta personas cuando lo que manda son parejas: con 23 hay '
        '253 parejas.',
    figures: [
      ContentFigure(
        id: 'p23',
        fn: 'birthday',
        args: [23],
        label: 'P(coincidencia con 23 personas)',
        format: FigureFormat.percent,
      ),
    ],
    choices: [
      Choice('23', correct: true, feedback: 'Correcto: 50,7 %.'),
      Choice('183 (la mitad de 365)',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Ese número respondería a otra pregunta: cuántas personas '
              'para que alguien coincida contigo EN CONCRETO. Aquí vale '
              'cualquier pareja.'),
      Choice('60',
          feedback: 'Con 60 personas la probabilidad ya pasa del 99 %: te '
              'quedaste corto por mucho.'),
      Choice('365',
          feedback: 'Con 366 la coincidencia es segura, pero el 50 % se '
              'alcanza muchísimo antes.'),
    ],
    hints: ['¿Cuántas PAREJAS distintas hay en un grupo de n personas?'],
  ),
  Exercise(
    id: 'm3_e11',
    moduleId: 'm3',
    kind: ExerciseKind.deteccionError,
    difficulty: 3,
    prompt: 'Audita este desarrollo.',
    context:
        '«Quiero P(dos ases al sacar dos cartas de 52). Los casos favorables '
        'son 4 × 3 = 12 (as en la primera y as en la segunda). Los casos '
        'posibles son C(52,2) = 1 326. Luego P = 12/1 326 ≈ 0,9 %.»',
    explanation:
        'Mezcló criterios: contó los favorables CON orden (4×3 = 12) y los '
        'posibles SIN orden (1 326). O bien 12/2 652, o bien 6/1 326 — las '
        'dos dan 1/221 ≈ 0,45 %.',
    detects: ['criterio_mixto'],
    choices: [
      Choice('Contó favorables con orden y posibles sin orden',
          correct: true,
          feedback: 'Exacto. El resultado sale al doble del correcto, y ese '
              'factor 2 = 2! es la firma del error.'),
      Choice('C(52,2) está mal calculado',
          feedback: 'C(52,2) = 1 326 es correcto.'),
      Choice('Debió usar 4 × 4 = 16 favorables',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Eso asumiría reposición: tras sacar un as quedan 3, no '
              '4.'),
      Choice('No hay error',
          misconceptionId: 'criterio_mixto',
          feedback: 'El valor correcto es 1/221 ≈ 0,45 %, la mitad del '
              'obtenido.'),
    ],
  ),
  Exercise(
    id: 'm3_e12',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: 'De un lote de 50 piezas con 5 defectuosas se toma una muestra de '
        '10 sin reposición. ¿Probabilidad de que la muestra tenga exactamente '
        '1 defectuosa?',
    explanation: 'C(5,1)·C(45,9)/C(50,10) ≈ 0,4313.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_hiper1',
        fn: 'hypergeometric',
        args: [50, 5, 10, 1],
        label: 'P(1 defectuosa en muestra de 10)',
      ),
    ),
    hints: ['Elige cuál defectuosa entra y cuáles 9 buenas la acompañan.'],
  ),
  Exercise(
    id: 'm3_e13',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Tienes 5 sabores de helado y eliges 3 bolas pudiendo repetir '
        'sabor. El orden no importa. ¿Cuántas combinaciones hay?',
    explanation: 'C(5+3−1, 3) = C(7,3) = 35.',
    choices: [
      Choice('35', correct: true, feedback: 'Correcto: combinaciones con '
          'repetición, C(7,3).'),
      Choice('10 (= C(5,3))',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'C(5,3) excluye repetir sabor, y aquí sí se puede: dos '
              'bolas de chocolate son una opción válida.'),
      Choice('125 (= 5³)',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'Eso cuenta el orden de las bolas. Chocolate-vainilla-'
              'chocolate y chocolate-chocolate-vainilla son el mismo pedido.'),
      Choice('60 (= P(5,3))',
          feedback: 'Variaciones sin repetición: ni permite repetir ni '
              'ignora el orden. Falla en las dos cosas.'),
    ],
  ),
  Exercise(
    id: 'm3_e14',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 2,
    prompt: '¿De cuántas maneras puedes ir de una esquina a la opuesta en una '
        'cuadrícula de 4 cuadras al este y 3 al norte, moviéndote solo al '
        'este o al norte?',
    explanation:
        'Cada ruta es una palabra de 4 «E» y 3 «N»: 7!/(4!·3!) = 35.',
    detects: ['sobreconteo_repetidos'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_rutas',
        fn: 'permutationsRep',
        args: [4, 3],
        label: 'Rutas en cuadrícula 4×3',
        format: FigureFormat.count,
      ),
      acceptFraction: false,
      acceptPercent: false,
      tolerance: 0.0,
    ),
    hints: ['Cada camino es una secuencia de 7 movimientos, 4 de un tipo y 3 '
        'de otro.'],
  ),
  Exercise(
    id: 'm3_e15',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Un comité debe tener 2 hombres de 6 y 3 mujeres de 7. ¿Cuántos '
        'comités distintos hay?',
    explanation:
        'Se eligen por separado y se multiplica: C(6,2)·C(7,3) = 15 × 35 = '
        '525.',
    choices: [
      Choice('525', correct: true, feedback: 'Correcto: 15 × 35.'),
      Choice('50 (= 15 + 35)',
          feedback: 'Sumar responde a «una cosa O la otra». Aquí hacen falta '
              'las dos a la vez: se multiplica.'),
      Choice('C(13,5) = 1 287',
          feedback: 'Eso elegiría 5 personas cualesquiera, sin respetar la '
              'composición de 2 hombres y 3 mujeres.'),
      Choice('6 × 7 = 42',
          feedback: 'Eso elegiría un hombre y una mujer. Hay que elegir 2 y '
              '3.'),
    ],
  ),
  Exercise(
    id: 'm3_e16',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: '8 personas se sientan en una mesa REDONDA. ¿Cuántas '
        'disposiciones distintas hay?',
    explanation:
        '(8−1)! = 5 040. En una mesa redonda, rotar a todos una silla no '
        'cambia la disposición relativa: se fija a una persona y se ordenan '
        'las otras 7.',
    choices: [
      Choice('5 040 = 7!',
          correct: true,
          feedback: 'Correcto: las 8 rotaciones de cada disposición son la '
              'misma.'),
      Choice('40 320 = 8!',
          misconceptionId: 'sobreconteo_repetidos',
          feedback: 'Eso cuenta cada disposición 8 veces, una por cada '
              'rotación posible.'),
      Choice('64 = 8²', feedback: 'No corresponde a ninguna lectura del '
          'problema.'),
    ],
  ),
  Exercise(
    id: 'm3_e17',
    moduleId: 'm3',
    kind: ExerciseKind.clasificacion,
    difficulty: 3,
    prompt: 'Quieres P(los 3 tornillos elegidos de una caja de 20 sean todos '
        'del lote nuevo, que tiene 8 tornillos). ¿Qué haces?',
    context: 'Solo el método.',
    explanation:
        'Muestreo sin reposición de una población pequeña: C(8,3)/C(20,3), '
        'que es la hipergeométrica con 0 defectuosos del otro lote.',
    detects: ['reposicion_ignorada', 'criterio_mixto'],
    choices: [
      Choice('C(8,3)/C(20,3)',
          correct: true,
          feedback: 'Correcto: mismo criterio arriba y abajo, y sin '
              'reposición.'),
      Choice('(8/20)³',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Eso asume reposición. Con 20 tornillos, sacar 3 cambia '
              'bastante la composición: sobreestima.'),
      Choice('C(8,3)/20³',
          misconceptionId: 'criterio_mixto',
          feedback: 'Numerador sin orden y denominador con orden y '
              'repetición: tres criterios mezclados en una sola fracción.'),
      Choice('8/20 + 7/19 + 6/18',
          feedback: 'Sumar responde a «o». «Los tres» es una intersección: se '
              'multiplica, o se cuenta con combinaciones.'),
    ],
  ),
  Exercise(
    id: 'm3_e18',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Con una baraja de 52, ¿probabilidad de que una mano de 5 cartas '
        'sean todas corazones?',
    explanation: 'C(13,5)/C(52,5) = 1 287/2 598 960 ≈ 0,000495.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_flush',
        fn: 'urnAllSameNoRep',
        args: [13, 52, 5],
        label: 'P(cinco corazones)',
      ),
      tolerance: 0.0005,
    ),
    hints: ['Cuenta las manos de 5 corazones y divídelas entre todas las '
        'manos posibles.'],
  ),
  Exercise(
    id: 'm3_e19',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Un restaurante ofrece 4 entradas, 6 fondos y 3 postres. ¿Cuántos '
        'menús de tres tiempos hay?',
    explanation: '4 × 6 × 3 = 72, por el principio multiplicativo.',
    choices: [
      Choice('72', correct: true, feedback: 'Correcto: etapas independientes '
          'que se multiplican.'),
      Choice('13 (= 4 + 6 + 3)',
          feedback: 'Sumar contaría «elegir UN plato cualquiera», no armar un '
              'menú completo.'),
      Choice('C(13,3) = 286',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Esa fórmula elegiría 3 platos cualesquiera entre los 13, '
              'permitiendo tres postres y ninguna entrada.'),
    ],
  ),
  Exercise(
    id: 'm3_e20',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: '¿Cuál de estas afirmaciones sobre C(n,k) es FALSA?',
    explanation:
        'C(n,k) nunca es mayor que 2ⁿ: la suma de TODAS las C(n,k) es '
        'exactamente 2ⁿ, así que cada una por separado es menor.',
    choices: [
      Choice('C(n,k) puede ser mayor que 2ⁿ',
          correct: true,
          feedback: 'Correcto, es la falsa: la suma de todas las C(n,k) es '
              '2ⁿ.'),
      Choice('C(n,k) = C(n, n−k)',
          feedback: 'Es verdadera: elegir quién entra equivale a elegir quién '
              'queda fuera.'),
      Choice('C(n,0) = 1',
          feedback: 'Es verdadera: hay una sola forma de no elegir a nadie.'),
      Choice('La suma de C(n,k) para todo k es 2ⁿ',
          feedback: 'Es verdadera: cuenta todos los subconjuntos posibles.'),
    ],
  ),
  Exercise(
    id: 'm3_e21',
    moduleId: 'm3',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Debes fijar el largo mínimo de una contraseña alfanumérica '
        '(letras minúsculas y dígitos, 36 símbolos) para que un atacante que '
        'prueba mil millones por segundo tarde más de un año.',
    context:
        'Un año tiene unos 3,15 × 10⁷ segundos, así que el atacante prueba '
        'unas 3,15 × 10¹⁶ contraseñas al año.',
    explanation:
        '36¹⁰ ≈ 3,66 × 10¹⁵ es insuficiente; 36¹¹ ≈ 1,3 × 10¹⁷ ya supera las '
        '3,15 × 10¹⁶ del año. El largo mínimo es 11. Nota que cada símbolo '
        'extra multiplica por 36: el crecimiento exponencial es el que hace '
        'el trabajo, no la complejidad del símbolo.',
    detects: ['reposicion_ignorada'],
    choices: [
      Choice('11 símbolos',
          correct: true,
          feedback: 'Correcto: 36¹¹ ≈ 1,3 × 10¹⁷, unas cuatro veces lo que el '
              'atacante alcanza en un año.'),
      Choice('8 símbolos',
          feedback: '36⁸ ≈ 2,8 × 10¹², que ese atacante agota en menos de una '
              'hora.'),
      Choice('16 símbolos',
          feedback: 'Es seguro, pero la pregunta pedía el MÍNIMO. Exigir de '
              'más tiene un costo real: contraseñas anotadas en papel.'),
    ],
    justifications: [
      Choice('Porque cada símbolo adicional multiplica el espacio por 36, y '
          'el espacio total es 36ⁿ (variaciones con repetición)',
          correct: true,
          feedback: 'Exacto: con repetición y con orden, que es justo lo que '
              'es una contraseña.'),
      Choice('Porque el espacio es C(36,n), combinaciones de símbolos',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'En una contraseña el orden importa y los símbolos se '
              'repiten: no son combinaciones.'),
      Choice('Porque cada símbolo adicional duplica el tiempo de ataque',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Lo duplicaría si el alfabeto tuviera 2 símbolos. Con 36 '
              'lo multiplica por 36.'),
    ],
  ),
  Exercise(
    id: 'm3_e22',
    moduleId: 'm3',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'En un grupo de 30 personas, ¿probabilidad de que al menos dos '
        'cumplan años el mismo día?',
    explanation: '1 − (365·364·…·336)/365³⁰ ≈ 70,6 %.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_cumple30',
        fn: 'birthday',
        args: [30],
        label: 'P(coincidencia con 30 personas)',
      ),
      tolerance: 0.01,
    ),
    hints: ['Por complemento: primero P(todos con cumpleaños distintos).'],
  ),
  Exercise(
    id: 'm3_e23',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: '¿Cuántos subconjuntos tiene un conjunto de 10 elementos '
        '(incluyendo el vacío y el total)?',
    explanation: '2¹⁰ = 1 024: cada elemento entra o no entra, dos opciones '
        'independientes.',
    choices: [
      Choice('1 024', correct: true, feedback: 'Correcto: 2¹⁰.'),
      Choice('10! = 3 628 800',
          feedback: 'Eso ordena los 10 elementos; los subconjuntos no están '
              'ordenados.'),
      Choice('100',
          feedback: 'No corresponde: cada elemento aporta un factor 2, no un '
              'sumando.'),
      Choice('C(10,5) = 252',
          feedback: 'Ese es el número de subconjuntos de tamaño 5, no de '
              'todos los tamaños.'),
    ],
  ),
  Exercise(
    id: 'm3_e24',
    moduleId: 'm3',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Al calcular P(A) = |A|/|Ω| con técnicas de conteo, ¿cuál es la '
        'regla que no se puede romper?',
    explanation:
        'Numerador y denominador deben contarse con el mismo criterio: los '
        'dos con orden o los dos sin orden. Cualquiera funciona; mezclarlos, '
        'no.',
    detects: ['criterio_mixto'],
    choices: [
      Choice('Contar favorables y posibles con el mismo criterio',
          correct: true,
          feedback: 'Correcto. Es la causa del error de conteo más difícil de '
              'detectar, porque el resultado parece razonable.'),
      Choice('Usar siempre combinaciones, que son más simples',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'Con orden también funciona, y en algunos problemas es '
              'más natural. Lo que importa es la coherencia, no la fórmula '
              'elegida.'),
      Choice('Usar siempre el espacio muestral más pequeño',
          feedback: 'El tamaño no importa; lo que importa es que el espacio '
              'elegido sea equiprobable y que se cuente igual arriba y '
              'abajo.'),
    ],
  ),
  Exercise(
    id: 'm3_e25',
    moduleId: 'm3',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Debes elegir el esquema de códigos de inventario para un almacén '
        'que espera crecer hasta 500 000 ítems.',
    context:
        'Opción 1: 4 letras (26) sin repetir.\n'
        'Opción 2: 4 letras (26) con repetición.\n'
        'Opción 3: 2 letras + 3 dígitos, todo con repetición.\n'
        'El código debe ser corto y legible al dictarlo por radio.',
    explanation:
        'Opción 1: P(26,4) = 358 800 — insuficiente. Opción 2: 26⁴ = 456 976 '
        '— también insuficiente, y además admite códigos como AAAA, malos al '
        'dictar. Opción 3: 26²·10³ = 676 000 — suficiente, y separa letras de '
        'dígitos, que es lo que hace un código legible por radio.',
    detects: ['reposicion_ignorada', 'orden_importa_confundido'],
    choices: [
      Choice('Opción 3: 676 000 códigos, con margen sobre los 500 000',
          correct: true,
          feedback: 'Correcto, y es la única que supera el objetivo con '
              'margen.'),
      Choice('Opción 2: 456 976 códigos bastan',
          misconceptionId: 'reposicion_ignorada',
          feedback: '456 976 < 500 000: se queda corta antes de llegar al '
              'objetivo. Conviene comprobar la cifra, no la sensación de que '
              '«cuatro letras dan para mucho».'),
      Choice('Opción 1: sin repetir los códigos se confunden menos',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'El argumento de legibilidad es razonable, pero P(26,4) = '
              '358 800 no alcanza ni de lejos los 500 000 ítems.'),
    ],
    justifications: [
      Choice('Porque cada posición con repetición multiplica por el tamaño de '
          'su alfabeto, y mezclar letras con dígitos amplía el espacio sin '
          'alargar el código',
          correct: true,
          feedback: 'Exacto: 26²·10³, variaciones con repetición en cada '
              'bloque.'),
      Choice('Porque con 4 posiciones siempre hay más combinaciones que con 5',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Al revés: cada posición adicional multiplica el espacio. '
              'Lo que decide aquí es el tamaño del alfabeto por posición.'),
      Choice('Porque C(26,2)·C(10,3) da 676 000',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'C(26,2)·C(10,3) = 325 · 120 = 39 000, no 676 000. En un '
              'código el orden importa y los símbolos se repiten: son '
              'variaciones con repetición.'),
    ],
  ),
];
