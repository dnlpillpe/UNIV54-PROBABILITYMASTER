/// Módulo 4 — Ejercicios de clasificación y transferencia.
///
/// Aquí los enunciados **no vienen agrupados por tema**: esa es justamente la
/// dificultad que el módulo entrena (fallo F6 del análisis).
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/exercise.dart';

const List<Exercise> kExercisesM4 = [
  Exercise(
    id: 'm4_e01',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«De 200 clientes, 120 compraron en línea y 90 usaron cupón; 50 '
        'hicieron ambas cosas. ¿Qué proporción de los que usaron cupón compró '
        'en línea?»',
    context: 'Clasifica el problema. No lo resuelvas.',
    explanation:
        '«De los que usaron cupón» condiciona: P(en línea | cupón) = 50/90. '
        'El denominador es el total de la columna que condiciona, no los 200.',
    detects: ['condicional_invertida', 'denominador_no_reducido'],
    choices: [
      Choice('Probabilidad condicional, con denominador 90',
          correct: true,
          feedback: 'Correcto: «de los que…» siempre señala condicional.'),
      Choice('Regla de la suma: 120 + 90 − 50',
          misconceptionId: 'suma_sin_restar_interseccion',
          feedback: 'Eso respondería «cuántos hicieron al menos una cosa», '
              'que no es lo que se pregunta.'),
      Choice('Intersección sobre el total: 50/200',
          misconceptionId: 'denominador_no_reducido',
          feedback: 'Esa es la conjunta. Al condicionar hay que reducir el '
              'denominador al evento que condiciona.'),
      Choice('Bayes, porque hay dos eventos',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Bayes se usa cuando vas del efecto a la causa y no '
              'tienes la conjunta. Aquí la tienes directamente: basta '
              'dividir.'),
    ],
  ),
  Exercise(
    id: 'm4_e02',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«Un almacén tiene 12 lotes, 3 de ellos vencidos. Se inspeccionan '
        '4 lotes al azar. ¿Probabilidad de que ninguno esté vencido?»',
    context: 'Clasifica el problema.',
    explanation:
        'Muestreo sin reposición de población pequeña: C(9,4)/C(12,4), es '
        'decir hipergeométrica. La binomial sobreestimaría porque la '
        'población se agota.',
    detects: ['reposicion_ignorada'],
    choices: [
      Choice('Conteo sin reposición: C(9,4)/C(12,4)',
          correct: true,
          feedback: 'Correcto. Con 12 lotes, sacar 4 cambia mucho la '
              'composición.'),
      Choice('Binomial con p = 9/12 y n = 4',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'La binomial exige p constante, es decir reposición. Aquí '
              'cada lote inspeccionado ya no vuelve al montón.'),
      Choice('Complemento de «al menos uno vencido», con 1 − (3/12)⁴',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'El complemento es buena idea, pero (3/12)⁴ vuelve a '
              'asumir reposición e independencia.'),
    ],
  ),
  Exercise(
    id: 'm4_e03',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 3,
    prompt: '«El 3 % de las transacciones son fraudulentas. El sistema marca '
        'el 90 % de los fraudes y el 4 % de las legítimas. Marca una '
        'transacción. ¿Probabilidad de que sea fraude?»',
    context: 'Clasifica el problema.',
    explanation:
        'Va del efecto (marcada) a la causa (fraude): Bayes. '
        'P = 0,03·0,90 / (0,03·0,90 + 0,97·0,04) ≈ 41,0 %.',
    detects: ['tasa_base_ignorada'],
    choices: [
      Choice('Teorema de Bayes',
          correct: true,
          feedback: 'Correcto: te dan P(marcada | fraude) y te piden '
              'P(fraude | marcada).'),
      Choice('Regla del producto: 0,03 × 0,90',
          misconceptionId: 'condicional_es_conjunta',
          feedback: 'Eso da la conjunta (2,7 % de todas las transacciones son '
              'fraudes marcados). Falta dividir entre la probabilidad total '
              'de ser marcada.'),
      Choice('Directamente 90 %, que es lo que acierta el sistema',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El 90 % es la condicional inversa. Con solo 3 % de '
              'fraudes, las marcas falsas del 4 % sobre el 97 % legítimo '
              'pesan mucho.'),
    ],
  ),
  Exercise(
    id: 'm4_e04',
    moduleId: 'm4',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Con los datos del ejercicio anterior (3 % de fraude, 90 % de '
        'detección, 4 % de falsas marcas), calcula P(fraude | marcada).',
    explanation:
        'P(marcada) = 0,027 + 0,0388 = 0,0658. P(fraude | marcada) = '
        '0,027/0,0658 ≈ 0,4104.',
    detects: ['tasa_base_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_fraude',
        fn: 'bayes2',
        args: [3, 100, 9, 10, 97, 100, 4, 100],
        label: 'P(fraude | transacción marcada)',
      ),
    ),
    hints: [
      'Imagina 10 000 transacciones: 300 fraudes y 9 700 legítimas.',
      'Cuenta cuántas marca en cada grupo y compara.',
    ],
  ),
  Exercise(
    id: 'm4_e05',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«Un equipo tiene 3 sensores redundantes, cada uno con 4 % de '
        'probabilidad de fallar. ¿Probabilidad de que el sistema pierda la '
        'medición, es decir, que fallen los tres?»',
    context: 'Clasifica el problema.',
    explanation:
        'Intersección de eventos independientes: 0,04³ = 0,000064. Es un '
        'sistema en paralelo visto desde el lado de la falla.',
    choices: [
      Choice('Producto de independientes: 0,04³',
          correct: true,
          feedback: 'Correcto, **siempre que** los sensores no compartan una '
              'causa común de falla.'),
      Choice('Suma: 3 × 0,04',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'Eso respondería «al menos uno falla», y además de forma '
              'incorrecta: lo correcto sería 1 − 0,96³.'),
      Choice('Complemento: 1 − 0,96³',
          feedback: 'Eso es «al menos uno falla», que en un sistema redundante '
              'no implica perder la medición.'),
      Choice('Complemento simple: 1 − 0,04, porque «ninguno funciona» es '
          '1 − p',
          misconceptionId: 'ninguno_es_uno_menos_p',
          feedback: '«Ninguno» en n intentos es (1−p)ⁿ, no 1 − p. El '
              'complemento se aplica a cada ensayo y luego se multiplica; si '
              'no, el número de sensores no aparecería por ningún lado.'),
    ],
  ),
  Exercise(
    id: 'm4_e06',
    moduleId: 'm4',
    kind: ExerciseKind.deteccionError,
    difficulty: 3,
    prompt: 'Audita este informe de una consultora.',
    context:
        '«Encuestamos a 400 visitantes de nuestra web que aceptaron responder. '
        'El 72 % declaró estar satisfecho. Concluimos que el 72 % de nuestros '
        'clientes está satisfecho, con un margen de error de ±4,9 %.»',
    explanation:
        'El problema no es el margen de error: es que la muestra se eligió a '
        'sí misma. Quienes aceptan responder no son una muestra aleatoria de '
        'los clientes. Ningún margen de error corrige un sesgo de selección; '
        'solo cuantifica el ruido de un muestreo que aquí no existe.',
    detects: ['inferir_sin_experimento'],
    choices: [
      Choice('La muestra no es aleatoria: el margen de error no corrige el '
          'sesgo de selección',
          correct: true,
          feedback: 'Exacto. Un margen de error calculado sobre una muestra '
              'autoseleccionada da una falsa sensación de rigor.'),
      Choice('El margen de error está mal calculado',
          feedback: '±4,9 % es aproximadamente correcto para n = 400 y '
              'p = 0,72… pero solo sería aplicable con muestreo aleatorio.'),
      Choice('Faltó preguntar a más gente',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Aumentar n no arregla nada: con 4 000 respuestas '
              'autoseleccionadas el sesgo es el mismo y el margen de error, '
              'más estrecho. Más datos sesgados dan más confianza en un '
              'número equivocado.'),
      Choice('No hay error: 400 respuestas son suficientes',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'El tamaño no es el problema. El mecanismo de selección '
              'sí.'),
    ],
  ),
  Exercise(
    id: 'm4_e07',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«¿De cuántas maneras se pueden asignar 5 turnos distintos a 5 '
        'operarios, uno cada uno?»',
    context: 'Clasifica el problema.',
    explanation:
        'Se usan todos los elementos y el orden importa: permutaciones, '
        '5! = 120. Además, fíjate: piden un CONTEO, no una probabilidad.',
    detects: ['formula_por_parecido'],
    choices: [
      Choice('Permutaciones: 5! = 120',
          correct: true,
          feedback: 'Correcto, y además no hay que dividir por nada: es un '
              'conteo, no una probabilidad.'),
      Choice('Combinaciones: C(5,5) = 1',
          misconceptionId: 'orden_importa_confundido',
          feedback: 'C(5,5) = 1 cuenta «de cuántas formas elegir a los cinco», '
              'que es una sola. Pero aquí importa QUIÉN recibe cada turno.'),
      Choice('Variaciones con repetición: 5⁵',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Eso permitiría dar dos turnos al mismo operario y dejar a '
              'otro sin ninguno.'),
    ],
  ),
  Exercise(
    id: 'm4_e08',
    moduleId: 'm4',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 3,
    prompt: 'Un gerente dice: «llevamos 8 meses sin accidentes, así que la '
        'probabilidad de que ocurra uno este mes ha bajado». ¿Qué respondes?',
    explanation:
        'Si los accidentes son independientes entre meses, 8 meses limpios no '
        'bajan la probabilidad del noveno. Ahora bien, si el historial refleja '
        'que las medidas de seguridad funcionan, la evidencia SÍ actualiza la '
        'estimación de la tasa — pero eso es Bayes sobre el parámetro, no la '
        '«racha» del gerente.',
    detects: ['falacia_jugador'],
    choices: [
      Choice('Depende: si la tasa es fija, no baja; si el historial es '
          'evidencia sobre la tasa, la estimación sí se actualiza',
          correct: true,
          feedback: 'Correcto, y es la respuesta profesional: distingue entre '
              'la probabilidad del mes y la estimación de la tasa.'),
      Choice('Sí, ha bajado: la evidencia es clara',
          misconceptionId: 'falacia_jugador',
          feedback: 'Confunde la racha con la probabilidad del próximo '
              'evento. Si la tasa no cambió, el noveno mes es idéntico al '
              'primero.'),
      Choice('No, y además ahora es más probable que ocurra: ya toca',
          misconceptionId: 'falacia_jugador',
          feedback: 'Esa es la falacia del jugador en su forma clásica. El '
              'proceso no acumula deuda.'),
    ],
  ),
  Exercise(
    id: 'm4_e09',
    moduleId: 'm4',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Un lote de 200 piezas contiene 8 defectuosas. Se extraen 5 sin '
        'reposición. ¿Probabilidad de que ninguna sea defectuosa?',
    explanation: 'C(192,5)/C(200,5) ≈ 0,8153.',
    detects: ['reposicion_ignorada'],
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_lote',
        fn: 'hypergeometric',
        args: [200, 8, 5, 0],
        label: 'P(ninguna defectuosa en 5 de 200 con 8 malas)',
      ),
      tolerance: 0.005,
    ),
    hints: ['Cuenta las muestras formadas solo por piezas buenas.'],
  ),
  Exercise(
    id: 'm4_e10',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 3,
    prompt: '«El 60 % de los estudiantes de una universidad son mujeres. El '
        '70 % de las mujeres y el 50 % de los hombres usan la biblioteca. '
        'Eliges a alguien que usa la biblioteca. ¿Probabilidad de que sea '
        'mujer?»',
    context: 'Clasifica el problema.',
    explanation:
        'Bayes con dos causas: P = 0,6·0,7 / (0,6·0,7 + 0,4·0,5) = '
        '0,42/0,62 ≈ 67,7 %.',
    choices: [
      Choice('Bayes, porque voy del uso observado a la característica',
          correct: true,
          feedback: 'Correcto. El denominador es la probabilidad total de '
              'usar la biblioteca.'),
      Choice('Directamente 70 %',
          misconceptionId: 'condicional_invertida',
          feedback: 'El 70 % es P(biblioteca | mujer). Te piden la inversa.'),
      Choice('Directamente 60 %, la proporción de mujeres',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'Esa es la tasa base, la probabilidad ANTES de saber que '
              'usa la biblioteca. La información sí cambia la respuesta: la '
              'sube a ~68 %.'),
    ],
  ),
  Exercise(
    id: 'm4_e11',
    moduleId: 'm4',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Con los datos anteriores (60 % mujeres; 70 % y 50 % de uso), '
        'calcula P(mujer | usa la biblioteca).',
    explanation: '0,42 / 0,62 ≈ 0,6774.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_biblio',
        fn: 'bayes2',
        args: [3, 5, 7, 10, 2, 5, 1, 2],
        label: 'P(mujer | usa biblioteca)',
      ),
    ),
  ),
  Exercise(
    id: 'm4_e12',
    moduleId: 'm4',
    kind: ExerciseKind.opcionMultiple,
    difficulty: 2,
    prompt: 'Terminas un problema y obtienes P = 0,93 para un evento que el '
        'enunciado describe como raro. ¿Qué haces?',
    explanation:
        'La señal más probable es que calculaste el complemento y olvidaste '
        'volver. Es el error más frecuente al usar «al menos uno».',
    detects: ['complemento_invertido'],
    choices: [
      Choice('Revisar si calculé el complemento y no volví al final',
          correct: true,
          feedback: 'Correcto: 1 − 0,93 = 0,07, que sí encaja con «raro».'),
      Choice('Aceptarlo: la intuición sobre lo «raro» no es fiable',
          misconceptionId: 'complemento_invertido',
          feedback: 'La intuición no decide, pero sí sirve como alarma. Un '
              'resultado que contradice frontalmente el enunciado merece una '
              'revisión antes de entregarse.'),
      Choice('Redondear a 1',
          misconceptionId: 'probabilidad_mayor_que_uno',
          feedback: 'Redondear no corrige nada y esconde el error.'),
    ],
  ),
  Exercise(
    id: 'm4_e13',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 3,
    prompt: '«Una máquina produce piezas con 2 % de defectos. Se toman 100 '
        'piezas de la producción del día (miles de unidades). ¿Probabilidad '
        'de encontrar exactamente 3 defectuosas?»',
    context: 'Clasifica el problema.',
    explanation:
        'Binomial: n = 100 fijo, p = 0,02 constante (la población es enorme '
        'frente a la muestra, así que el agotamiento es despreciable), '
        'ensayos independientes, dos resultados por ensayo.',
    detects: ['reposicion_ignorada'],
    choices: [
      Choice('Binomial con n = 100 y p = 0,02',
          correct: true,
          feedback: 'Correcto. Con población enorme frente a la muestra, la '
              'binomial aproxima muy bien a la hipergeométrica.'),
      Choice('Hipergeométrica, porque no hay reposición',
          feedback: 'Técnicamente es hipergeométrica, pero con miles de '
              'unidades la diferencia es despreciable y la binomial es la '
              'herramienta razonable. Buen ojo, de todos modos.'),
      Choice('Laplace: 3 favorables entre 100 posibles',
          misconceptionId: 'formula_por_parecido',
          feedback: 'No hay 100 resultados equiprobables que contar. Los '
              'números del enunciado no son casos favorables.'),
    ],
  ),
  Exercise(
    id: 'm4_e14',
    moduleId: 'm4',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Con n = 100 y p = 0,02, calcula P(exactamente 3 defectuosas).',
    explanation: 'C(100,3)·0,02³·0,98⁹⁷ ≈ 0,1823.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_binom3',
        fn: 'binomial',
        args: [100, 3, 1, 50],
        label: 'P(X = 3) binomial n=100 p=0,02',
      ),
      tolerance: 0.005,
    ),
  ),
  Exercise(
    id: 'm4_e15',
    moduleId: 'm4',
    kind: ExerciseKind.deteccionError,
    difficulty: 3,
    prompt: 'Audita este análisis de riesgo.',
    context:
        '«Cada uno de nuestros tres centros de datos tiene 0,1 % de '
        'probabilidad de caída diaria. La probabilidad de que caigan los tres '
        'el mismo día es 0,001³ = una entre mil millones. El servicio es '
        'prácticamente inmune.»',
    explanation:
        'La aritmética es correcta bajo independencia, y ese supuesto es el '
        'problema: si los tres centros comparten proveedor eléctrico, '
        'operador de red, software de orquestación o una misma actualización '
        'automática, sus caídas están correlacionadas. La probabilidad real '
        'de caída simultánea puede ser miles de veces mayor.',
    detects: ['producto_sin_independencia'],
    choices: [
      Choice('Asumió independencia sin justificarla: las causas comunes la '
          'rompen',
          correct: true,
          feedback: 'Exacto. Es el error que explica casi todas las caídas '
              'simultáneas reales.'),
      Choice('Debió sumar: 3 × 0,001',
          feedback: '«Los tres a la vez» es una intersección. La suma '
              'respondería «al menos uno cae», que es otra pregunta.'),
      Choice('El cálculo está bien y la conclusión también',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Está bien SOLO bajo independencia. Sin justificarla, la '
              'conclusión no se sostiene.'),
      Choice('0,001³ está mal calculado',
          feedback: 'El cálculo aritmético es correcto: 10⁻⁹.'),
    ],
  ),
  Exercise(
    id: 'm4_e16',
    moduleId: 'm4',
    kind: ExerciseKind.decisionJustificada,
    difficulty: 3,
    prompt: 'Tu jefe quiere saber «la probabilidad de que el proyecto se '
        'entregue a tiempo». ¿Qué respondes?',
    context:
        'Es un proyecto nuevo, sin precedentes internos comparables. Hay '
        'histórico de 12 proyectos anteriores de otro tipo, de los que 7 se '
        'entregaron a tiempo.',
    explanation:
        'No hay experimento aleatorio repetible ni espacio muestral contable. '
        'El 7/12 es un punto de partida útil, pero de proyectos de otro tipo: '
        'usarlo sin decirlo sería presentar una estimación subjetiva con la '
        'autoridad de un dato duro.',
    detects: ['inferir_sin_experimento', 'formula_por_parecido'],
    choices: [
      Choice('Dar una estimación declarada como tal, apoyada en el 7/12 y '
          'ajustada por las diferencias del proyecto',
          correct: true,
          feedback: 'Correcto: número + origen + supuestos. Es lo que permite '
              'a tu jefe decidir cuánto confiar.'),
      Choice('Responder 7/12 = 58 % sin más',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'Presenta como frecuencia de un proceso repetible algo '
              'que viene de proyectos distintos. El número puede ser el '
              'mismo; la afirmación, no.'),
      Choice('Responder 50 %: se entrega o no se entrega',
          misconceptionId: 'equiprobabilidad_asumida',
          feedback: 'Dos resultados no son dos resultados equiprobables.'),
    ],
    justifications: [
      Choice('Porque es una probabilidad subjetiva informada, y declarar sus '
          'supuestos es parte de la respuesta',
          correct: true,
          feedback: 'Exacto. Un número sin supuestos no es una respuesta '
              'profesional.'),
      Choice('Porque 12 proyectos son una muestra suficientemente grande',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Doce es poco, y además son de otro tipo: el problema no '
              'es el tamaño, es la comparabilidad.'),
      Choice('Porque toda probabilidad es subjetiva al final',
          feedback: 'Es una postura filosófica defendible, pero aquí lo '
              'relevante es concreto: estos datos no vienen de un experimento '
              'repetible en las mismas condiciones.'),
    ],
  ),
  Exercise(
    id: 'm4_e17',
    moduleId: 'm4',
    kind: ExerciseKind.clasificacion,
    difficulty: 2,
    prompt: '«¿Probabilidad de que al menos 2 de 5 servidores independientes '
        'estén activos, si cada uno lo está el 90 % del tiempo?»',
    context: 'Clasifica el problema.',
    explanation:
        'Binomial acumulada: P(X ≥ 2) con n = 5 y p = 0,9, o bien por '
        'complemento, 1 − P(X = 0) − P(X = 1).',
    choices: [
      Choice('Binomial, sumando desde k = 2 (o por complemento)',
          correct: true,
          feedback: 'Correcto: n fijo, p constante, ensayos independientes.'),
      Choice('Producto: 0,9²',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Eso sería «dos servidores CONCRETOS activos», sin decir '
              'nada de los otros tres.'),
      Choice('Suma: 2 × 0,9',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'Da 1,8, mayor que 1: alarma inmediata.'),
    ],
  ),
  Exercise(
    id: 'm4_e18',
    moduleId: 'm4',
    kind: ExerciseKind.calculo,
    difficulty: 3,
    prompt: 'Con 5 servidores independientes al 90 %, calcula P(al menos 2 '
        'activos).',
    explanation:
        'P(X ≥ 2) = 1 − P(0) − P(1) = 1 − 0,00001 − 0,00045 = 0,99954.',
    numeric: NumericTarget(
      figure: ContentFigure(
        id: 'r_servidores',
        fn: 'binomialAtLeast',
        args: [5, 2, 9, 10],
        label: 'P(al menos 2 activos de 5 al 90 %)',
      ),
      tolerance: 0.002,
    ),
    hints: ['Es más rápido por complemento: P(0 activos) + P(1 activo).'],
  ),
];
