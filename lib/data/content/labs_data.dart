/// Los cinco laboratorios y sus 16 experimentos.
///
/// Todos siguen la decisión D1: la predicción es obligatoria y los controles
/// permanecen bloqueados hasta registrarla. El campo `finding` no se muestra
/// hasta alcanzar `minTrials`.
library;

import '../../domain/models/experiment.dart';

const List<Lab> kLabs = [
  // =================================================================
  Lab(
    id: 'm1_lab1',
    moduleId: 'm1',
    name: 'Ley de los grandes números',
    subtitle: 'Qué hace el azar cuando lo dejas correr mucho rato',
    engine: LabEngine.granNumeros,
    experiments: [
      Experiment(
        id: 'x1_moneda_justa',
        labId: 'm1_lab1',
        title: 'La moneda honesta',
        manipulates: 'Número de lanzamientos (10 a 20 000)',
        minTrials: 500,
        defaults: {'pNum': 1, 'pDen': 2, 'trials': 500},
        prediction: PredictionQuestion(
          question:
              'Lanzarás una moneda equilibrada. ¿A partir de cuántos '
              'lanzamientos la proporción de caras se quedará ya cerca del '
              '50 % (dentro de ±2 puntos)?',
          kind: PredictionKind.opcion,
          options: [
            'Unos 20 lanzamientos',
            'Unos 100 lanzamientos',
            'Unos 2 500 lanzamientos',
            'Nunca se queda quieta',
          ],
          correctOption: 2,
          revealsMisconception: 'muestra_pequena_representa',
        ),
        finding:
            'Con 20 lanzamientos la proporción salta entre 30 % y 70 % sin '
            'ningún pudor. Con 100 sigue moviéndose varios puntos. Recién '
            'pasados los ~2 500 se queda dentro de ±2 puntos de forma '
            'estable. El ancho de la oscilación se reduce con √n: para '
            'reducirlo a la mitad hay que cuadruplicar los lanzamientos. '
            'Y fíjate en la racha más larga: en 500 tiros ver 8 o 9 caras '
            'seguidas es normal, no sospechoso.',
        lessonId: 'm1_l4',
      ),
      Experiment(
        id: 'x2_moneda_sesgada',
        labId: 'm1_lab1',
        title: 'La moneda cargada',
        manipulates: 'Probabilidad real de la moneda y número de lanzamientos',
        minTrials: 300,
        defaults: {'pNum': 7, 'pDen': 10, 'trials': 300},
        prediction: PredictionQuestion(
          question:
              'Una moneda tiene p = 0,55 de cara (apenas cargada). ¿Cuántos '
              'lanzamientos necesitas para distinguirla con seguridad de una '
              'moneda honesta?',
          kind: PredictionKind.opcion,
          options: [
            'Unos 50',
            'Unos 200',
            'Más de 1 000',
            'Se nota enseguida, en 20',
          ],
          correctOption: 2,
          revealsMisconception: 'muestra_pequena_representa',
        ),
        finding:
            'Un sesgo pequeño se esconde durante muchísimo tiempo dentro del '
            'ruido. Con p = 0,55 y 200 lanzamientos, la proporción observada '
            'cae con frecuencia por debajo de 0,50: cualquiera juraría que la '
            'moneda es honesta. Con p = 0,70 la diferencia salta a los ojos '
            'en 50 tiros. Conclusión práctica: la cantidad de datos que hace '
            'falta depende de lo grande que sea el efecto que buscas.',
        lessonId: 'm1_l4',
      ),
      Experiment(
        id: 'x3_falacia',
        labId: 'm1_lab1',
        title: 'Después de la racha',
        manipulates: 'Largo de la racha observada antes de mirar el siguiente '
            'lanzamiento',
        minTrials: 2000,
        defaults: {'pNum': 1, 'pDen': 2, 'trials': 5000, 'runLength': 4},
        prediction: PredictionQuestion(
          question:
              'La app buscará todas las veces en que salgan 4 caras seguidas '
              'y mirará el lanzamiento siguiente. ¿Qué porcentaje de esas '
              'veces saldrá cara?',
          kind: PredictionKind.porcentaje,
          correctMin: 45,
          correctMax: 55,
          revealsMisconception: 'falacia_jugador',
        ),
        finding:
            'Exactamente 50 %, dentro del ruido de muestreo. La moneda no '
            'sabe qué salió antes: no tiene memoria, no tiene cuenta '
            'pendiente y no «debe» nada. Si predijiste menos de 45 %, tienes '
            'la falacia del jugador, que es la creencia errónea más común y '
            'más cara del mundo: es literalmente el modelo de negocio de los '
            'casinos. Sube la racha a 6 y vuelve a mirar: sigue siendo 50 %.',
        lessonId: 'm1_l4',
      ),
      Experiment(
        id: 'x4_desbalance',
        labId: 'm1_lab1',
        title: '¿Se compensa de verdad?',
        manipulates: 'Número de lanzamientos, mirando la diferencia ABSOLUTA '
            'entre caras y sellos',
        minTrials: 1000,
        defaults: {'pNum': 1, 'pDen': 2, 'trials': 10000},
        prediction: PredictionQuestion(
          question:
              'Si vas lanzando y anotas cuántas caras hay DE MÁS respecto a '
              'los sellos, ¿qué le pasa a esa diferencia a medida que lanzas '
              'más?',
          kind: PredictionKind.opcion,
          options: [
            'Tiende a 0: el azar se compensa',
            'Se queda más o menos igual',
            'Tiende a crecer',
          ],
          correctOption: 2,
          revealsMisconception: 'ley_de_promedios',
        ),
        finding:
            'Lo que se estabiliza es la PROPORCIÓN, no la diferencia. La '
            'diferencia absoluta crece del orden de √n: con 100 lanzamientos '
            'ronda 5; con 10 000, ronda 50. Y sin embargo 50 de más sobre '
            '10 000 es solo medio punto porcentual. Ahí está el malentendido '
            'entero de la «ley de los promedios»: el azar no corrige lo '
            'pasado, simplemente lo diluye.',
        lessonId: 'm1_l4',
      ),
    ],
  ),

  // =================================================================
  Lab(
    id: 'm1_lab2',
    moduleId: 'm1',
    name: 'Fábrica de espacios muestrales',
    subtitle: 'Construir Ω con las manos antes de contarlo con fórmulas',
    engine: LabEngine.espacioMuestral,
    experiments: [
      Experiment(
        id: 'x5_dos_dados',
        labId: 'm1_lab2',
        title: 'Las 36 casillas',
        manipulates: 'El evento que marcas sobre la cuadrícula de 6×6',
        minTrials: 600,
        defaults: {'space': 2, 'trials': 600},
        prediction: PredictionQuestion(
          question:
              'Con dos dados hay 11 sumas posibles (de 2 a 12). ¿Son todas '
              'igual de probables?',
          kind: PredictionKind.opcion,
          options: [
            'Sí, 1/11 cada una',
            'No: la 7 es la más probable',
            'No: la 2 y la 12 son las más probables',
          ],
          correctOption: 1,
          revealsMisconception: 'equiprobabilidad_asumida',
        ),
        finding:
            'El espacio muestral real tiene 36 resultados, no 11. La suma 7 '
            'ocurre de 6 maneras (1-6, 2-5, 3-4, 4-3, 5-2, 6-1) y la suma 12 '
            'de una sola. Por eso 7 vale 6/36 y 12 vale 1/36: seis veces más. '
            'Los 11 valores de la suma son un espacio muestral perfectamente '
            'válido, pero NO equiprobable, y aplicarle Laplace es el error. '
            'Marca «la suma es 7» en la cuadrícula y cuenta la diagonal.',
        lessonId: 'm1_l2',
      ),
      Experiment(
        id: 'x6_tres_monedas',
        labId: 'm1_lab2',
        title: 'Tres monedas, ocho historias',
        manipulates: 'Número de monedas (1 a 5) y evento marcado',
        minTrials: 400,
        defaults: {'space': 0, 'coins': 3, 'trials': 400},
        prediction: PredictionQuestion(
          question:
              'Lanzas tres monedas. ¿Qué es más probable: exactamente dos '
              'caras, o tres caras?',
          kind: PredictionKind.opcion,
          options: [
            'Igual de probables: son dos resultados',
            'Exactamente dos caras, tres veces más probable',
            'Tres caras, porque es más específico',
          ],
          correctOption: 1,
          revealsMisconception: 'espacio_incompleto',
        ),
        finding:
            'Ω tiene 8 resultados: CCC, CCS, CSC, SCC, CSS, SCS, SSC, SSS. '
            '«Tres caras» es 1 de esos 8. «Exactamente dos caras» son 3 '
            '(CCS, CSC, SCC): tres veces más probable. Cada SECUENCIA '
            'concreta vale lo mismo (1/8); lo que cambia es de cuántas '
            'maneras se puede cumplir la descripción. Por eso SSSSS y '
            'CSCSSC son igual de probables, aunque una «parezca» más '
            'aleatoria que la otra.',
        lessonId: 'm1_l2',
      ),
      Experiment(
        id: 'x7_carta',
        labId: 'm1_lab2',
        title: 'Una carta, muchos eventos',
        manipulates: 'Evento marcado sobre las 52 cartas',
        minTrials: 500,
        defaults: {'space': 3, 'trials': 500},
        prediction: PredictionQuestion(
          question:
              'Sacas una carta de 52. ¿Qué probabilidad tiene «es corazón O '
              'es figura (J, Q, K)»?',
          kind: PredictionKind.porcentaje,
          correctMin: 40,
          correctMax: 48,
          revealsMisconception: 'suma_sin_restar_interseccion',
        ),
        finding:
            'Hay 13 corazones y 12 figuras, pero 3 cartas son ambas cosas '
            '(J♥, Q♥, K♥). Sumar 13 + 12 = 25 las cuenta dos veces: la '
            'respuesta es 13 + 12 − 3 = 22, o sea 22/52 ≈ 42,3 %. Si '
            'predijiste 48 % (25/52), acabas de cometer en vivo el error de '
            'la regla de la suma. Márcalos en la cuadrícula: verás las tres '
            'casillas que están en los dos eventos.',
        lessonId: 'm1_l3',
      ),
    ],
  ),

  // =================================================================
  Lab(
    id: 'm2_lab1',
    moduleId: 'm2',
    name: 'Mesa de eventos',
    subtitle: 'Dos eventos sobre una población, y sus cuatro regiones',
    engine: LabEngine.dosEventos,
    experiments: [
      Experiment(
        id: 'x8_union_interseccion',
        labId: 'm2_lab1',
        title: 'La región que se cuenta dos veces',
        manipulates: 'P(A), P(B) y P(A∩B) sobre una población de 1 000',
        minTrials: 1000,
        defaults: {'pA': 40, 'pB': 30, 'pAB': 12, 'population': 1000},
        prediction: PredictionQuestion(
          question:
              'En una población, el 40 % usa transporte público y el 30 % '
              'tiene auto; un 12 % hace las dos cosas. ¿Qué porcentaje hace '
              'al menos una?',
          kind: PredictionKind.porcentaje,
          correctMin: 56,
          correctMax: 60,
          revealsMisconception: 'suma_sin_restar_interseccion',
        ),
        finding:
            '58 %, no 70 %. El diagrama lo muestra: la región central (12 %) '
            'está dentro de los dos círculos, y sumar 40 + 30 la cuenta dos '
            'veces. P(A∪B) = 40 + 30 − 12 = 58. Mueve el deslizador de la '
            'intersección hasta 0 y observa que solo entonces la suma simple '
            'da el resultado correcto: ese es exactamente el caso de eventos '
            'mutuamente excluyentes.',
        lessonId: 'm2_l3',
      ),
      Experiment(
        id: 'x9_excluyente_independiente',
        labId: 'm2_lab1',
        title: 'Excluyentes contra independientes',
        manipulates: 'La intersección, comparando P(A∩B) con P(A)·P(B)',
        minTrials: 1000,
        defaults: {'pA': 50, 'pB': 40, 'pAB': 20, 'population': 2000},
        prediction: PredictionQuestion(
          question:
              'Si dos eventos con probabilidad positiva son mutuamente '
              'excluyentes, ¿son independientes?',
          kind: PredictionKind.opcion,
          options: [
            'Sí: no se influyen porque no se tocan',
            'No: son lo más dependientes que dos eventos pueden ser',
            'Depende de los valores',
          ],
          correctOption: 1,
          revealsMisconception: 'excluyente_es_independiente',
        ),
        finding:
            'Son lo contrario. Si A y B son excluyentes, saber que ocurrió A '
            'te dice con CERTEZA que B no ocurrió: P(B|A) = 0, muy lejos de '
            'P(B). La prueba numérica está en pantalla: con A y B '
            'excluyentes, P(A∩B) = 0 mientras que P(A)·P(B) = 0,20. Solo '
            'cuando deslizas la intersección hasta que P(A∩B) coincide '
            'exactamente con P(A)·P(B) los eventos se vuelven independientes '
            '— y entonces sí se solapan. Independiente y excluyente no solo '
            'son cosas distintas: son casi incompatibles.',
        lessonId: 'm2_l5',
      ),
      Experiment(
        id: 'x10_condicional_tabla',
        labId: 'm2_lab1',
        title: 'Los dos denominadores',
        manipulates: 'La tabla de contingencia y qué evento condiciona',
        minTrials: 1000,
        defaults: {'pA': 30, 'pB': 20, 'pAB': 15, 'population': 2000},
        prediction: PredictionQuestion(
          question:
              'En la tabla, P(A|B) y P(B|A) se calculan con la misma celda '
              'central. ¿Pueden dar valores muy distintos?',
          kind: PredictionKind.opcion,
          options: [
            'No: es la misma intersección',
            'Sí, y normalmente dan muy distinto',
            'Solo si los eventos son dependientes',
          ],
          correctOption: 1,
          revealsMisconception: 'condicional_invertida',
        ),
        finding:
            'Con los valores de arranque: P(A|B) = 15/20 = 75 %, mientras que '
            'P(B|A) = 15/30 = 50 %. Misma celda arriba, distinto denominador '
            'abajo. Condicionar es cambiar de espacio muestral: al decir '
            '«dado B», el mundo se reduce a la columna B. Esta es la raíz de '
            'la confusión más peligrosa del curso: P(síntoma|enfermedad) es '
            'alta, pero P(enfermedad|síntoma) puede ser mínima.',
        lessonId: 'm2_l7',
      ),
    ],
  ),

  // =================================================================
  Lab(
    id: 'm2_lab2',
    moduleId: 'm2',
    name: 'Urnas y evidencia',
    subtitle: 'Reposición, dependencia y el cálculo que la intuición falla',
    engine: LabEngine.urnaYEvidencia,
    experiments: [
      Experiment(
        id: 'x11_urna',
        labId: 'm2_lab2',
        title: 'Con y sin reposición',
        manipulates: 'Composición de la urna, número de extracciones y '
            'reposición',
        minTrials: 800,
        defaults: {'rojas': 4, 'azules': 6, 'draws': 2, 'replace': 0},
        prediction: PredictionQuestion(
          question:
              'Urna con 4 bolas rojas y 6 azules. Sacas dos SIN reponer. '
              '¿Probabilidad de que las dos sean rojas?',
          kind: PredictionKind.porcentaje,
          correctMin: 11,
          correctMax: 15,
          revealsMisconception: 'producto_sin_independencia',
        ),
        finding:
            'Sin reposición: (4/10)·(3/9) = 12/90 ≈ 13,3 %. Con reposición: '
            '(4/10)² = 16 %. Quien multiplica 0,4 × 0,4 sin mirar si hay '
            'reposición sobreestima. Después de sacar la primera roja quedan '
            '3 rojas de 9 bolas: el denominador cambió y el numerador '
            'también. Activa y desactiva la reposición y observa cómo se '
            'separan las dos curvas: esa separación ES la dependencia.',
        lessonId: 'm2_l6',
      ),
      Experiment(
        id: 'x12_tamizaje',
        labId: 'm2_lab2',
        title: 'El test que acierta el 99 %',
        manipulates: 'Prevalencia, sensibilidad y especificidad sobre 100 000 '
            'personas',
        minTrials: 10000,
        defaults: {'prev': 1, 'sens': 99, 'spec': 95, 'population': 100000},
        prediction: PredictionQuestion(
          question:
              'Una enfermedad afecta al 1 % de la población. Un test detecta '
              'al 99 % de los enfermos y da falso positivo en el 5 % de los '
              'sanos. Das positivo. ¿Probabilidad de estar enfermo?',
          kind: PredictionKind.porcentaje,
          correctMin: 12,
          correctMax: 23,
          revealsMisconception: 'tasa_base_ignorada',
        ),
        finding:
            'Alrededor de 16,7 %, no 99 %. Cuenta personas y se ve solo: de '
            '100 000, hay 1 000 enfermos (990 dan positivo) y 99 000 sanos '
            '(4 950 dan positivo por error). Total de positivos: 5 940, de '
            'los cuales solo 990 están enfermos → 990/5 940 ≈ 16,7 %. Los '
            'falsos positivos ganan por goleada porque salen de una '
            'población enorme. El 99 % que recuerdas es P(positivo | '
            'enfermo); lo que te importa es P(enfermo | positivo).',
        lessonId: 'm2_l8',
      ),
      Experiment(
        id: 'x13_prevalencia',
        labId: 'm2_lab2',
        title: 'Mueve la tasa base',
        manipulates: 'Solo la prevalencia, dejando el test intacto',
        minTrials: 10000,
        defaults: {'prev': 10, 'sens': 99, 'spec': 95, 'population': 100000},
        prediction: PredictionQuestion(
          question:
              'Con el MISMO test, si la enfermedad pasa de afectar al 1 % a '
              'afectar al 10 %, ¿cuánto sube la fiabilidad de un positivo?',
          kind: PredictionKind.opcion,
          options: [
            'No cambia: el test es el mismo',
            'Sube un poco, unos 10 puntos',
            'Sube muchísimo: de ~17 % a ~69 %',
          ],
          correctOption: 2,
          revealsMisconception: 'tasa_base_ignorada',
        ),
        finding:
            'El mismo test, sobre la misma persona, con el mismo resultado, '
            'significa cosas completamente distintas según a quién se le '
            'aplique. Con prevalencia 10 % el valor predictivo positivo sube '
            'a ~68,8 %. Por eso el tamizaje masivo de enfermedades raras '
            'produce una avalancha de falsos positivos, y por eso los '
            'protocolos clínicos piden factores de riesgo ANTES de pedir la '
            'prueba: no para ahorrar, sino porque un test aplicado a una '
            'población de baja prevalencia informa muy poco.',
        lessonId: 'm2_l8',
      ),
    ],
  ),

  // =================================================================
  Lab(
    id: 'm3_lab1',
    moduleId: 'm3',
    name: 'Máquina de conteo',
    subtitle: 'Cuándo el orden importa, y por qué los números son tan grandes',
    engine: LabEngine.conteo,
    experiments: [
      Experiment(
        id: 'x14_cumpleanos',
        labId: 'm3_lab1',
        title: 'El problema del cumpleaños',
        manipulates: 'Tamaño del grupo (2 a 60)',
        minTrials: 1000,
        defaults: {'group': 23, 'trials': 2000},
        prediction: PredictionQuestion(
          question:
              '¿Cuántas personas hacen falta en una sala para que haya un '
              '50 % de probabilidad de que dos cumplan años el mismo día?',
          kind: PredictionKind.opcion,
          options: ['Unas 23', 'Unas 60', 'Unas 128', 'Más de 180'],
          correctOption: 0,
          revealsMisconception: 'formula_por_parecido',
        ),
        finding:
            'Con 23 personas la probabilidad ya pasa del 50 %; con 50 supera '
            'el 97 %. La intuición falla porque cuenta personas, cuando lo '
            'que importa son PAREJAS: con 23 personas hay C(23,2) = 253 '
            'parejas posibles, no 23. El cálculo va por el complemento: '
            'P(todos distintos) = (365·364·…·343)/365²³, y se le resta a 1. '
            'La simulación confirma la fórmula: las dos líneas se juntan.',
        lessonId: 'm3_l5',
      ),
      Experiment(
        id: 'x15_loteria',
        labId: 'm3_lab1',
        title: 'La lotería, en años',
        manipulates: 'Números del bombo y cuántos se eligen',
        minTrials: 1000,
        defaults: {'numbers': 49, 'picks': 6, 'trials': 5000},
        prediction: PredictionQuestion(
          question:
              'Eliges 6 números de 49. Si juegas un boleto por semana, '
              '¿cuánto tardarías en promedio en acertar los seis?',
          kind: PredictionKind.opcion,
          options: [
            'Unos 500 años',
            'Unos 27 000 años',
            'Unos 270 000 años',
            'Unos 5 millones de años',
          ],
          correctOption: 2,
          revealsMisconception: 'control_del_azar',
        ),
        finding:
            'C(49,6) = 13 983 816 combinaciones. A un boleto por semana, eso '
            'es una espera media de unos 269 000 años. Y un detalle que '
            'incomoda: la combinación 1-2-3-4-5-6 tiene exactamente la misma '
            'probabilidad que cualquier otra. Parece «menos probable» porque '
            'confundimos un resultado concreto con la descripción «números '
            'desordenados», que agrupa millones de resultados.',
        lessonId: 'm3_l3',
      ),
      Experiment(
        id: 'x16_orden',
        labId: 'm3_lab1',
        title: '¿Importa el orden?',
        manipulates: 'n, k, y si se permite repetir',
        minTrials: 1,
        defaults: {'n': 5, 'k': 3, 'repeat': 0},
        prediction: PredictionQuestion(
          question:
              'De 5 personas eliges 3 para un comité (sin cargos). ¿Cuántos '
              'comités distintos hay?',
          kind: PredictionKind.opcion,
          options: ['10', '15', '60', '125'],
          correctOption: 0,
          revealsMisconception: 'orden_importa_confundido',
        ),
        finding:
            'Son 10 = C(5,3). Si en cambio los cargos fueran presidente, '
            'secretario y tesorero, serían 60 = P(5,3), seis veces más, '
            'porque cada comité se puede repartir de 3! = 6 maneras. La '
            'pantalla enumera las dos listas una al lado de la otra: se ve '
            'que los 60 casos son los mismos 10 grupos repetidos 6 veces. '
            'Prueba definitiva: intercambia dos elegidos. Si el resultado es '
            'otro caso, el orden importa.',
        lessonId: 'm3_l3',
      ),
    ],
  ),
];

final List<Experiment> kAllExperiments = [
  for (final lab in kLabs) ...lab.experiments,
];

final Map<String, Experiment> kExperimentsById = {
  for (final e in kAllExperiments) e.id: e,
};

final Map<String, Lab> kLabsById = {for (final l in kLabs) l.id: l};
