/// Módulo 2 — Eventos.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/lesson.dart';

const List<Lesson> kLessonsM2 = [
  Lesson(
    id: 'm2_l1',
    moduleId: 'm2',
    title: 'Operaciones con eventos',
    objective: 'Manejar unión, intersección, complemento y diferencia sobre Ω.',
    preferredExperimentId: 'x8_union_interseccion',
    cards: [
      LessonCard(
        title: 'Cuatro regiones, siempre',
        body: 'Dos eventos cualesquiera parten Ω en exactamente cuatro '
            'regiones:\n\n'
            '• solo A (A − B)\n'
            '• solo B (B − A)\n'
            '• los dos (A ∩ B)\n'
            '• ninguno ((A ∪ B)\')\n\n'
            'Las cuatro suman el total. Si tu problema tiene dos eventos y '
            'no sabes por dónde empezar, **dibuja las cuatro regiones y '
            'rellena las que te den**: casi siempre las otras salen restando.',
      ),
      LessonCard(
        title: 'La tabla de contingencia es el mismo dibujo',
        body: 'Un diagrama de Venn de dos eventos y una tabla de 2×2 '
            'contienen exactamente la misma información:\n\n'
            '```\n'
            '            B      no B    total\n'
            '  A       A∩B     A−B      |A|\n'
            '  no A    B−A    ninguno   |A\'|\n'
            '  total    |B|    |B\'|      |Ω|\n'
            '```\n\n'
            'La tabla es más cómoda para condicionar (los totales de fila y '
            'columna son los denominadores); el Venn es más claro para la '
            'unión. Aprende a pasar de uno a otro sin pensarlo.',
        kind: CardKind.conexion,
      ),
      LessonCard(
        title: 'Diferencia y complemento',
        body: 'A − B = A ∩ B\' : «ocurre A pero no B».\n\n'
            'P(A − B) = P(A) − P(A ∩ B).\n\n'
            'Es la fórmula que más se olvida y la que más problemas resuelve '
            'de una línea: cuando el enunciado dice «solo», «pero no», '
            '«únicamente», te está pidiendo una diferencia.',
        kind: CardKind.formula,
      ),
    ],
  ),
  Lesson(
    id: 'm2_l2',
    moduleId: 'm2',
    title: 'De Morgan y el lenguaje del enunciado',
    objective:
        'Traducir sin error las frases «ninguno», «no ambos», «al menos uno».',
    cards: [
      LessonCard(
        title: 'Las dos leyes',
        body: '**(A ∪ B)\' = A\' ∩ B\'** — «no ocurre ninguno de los dos» es '
            'lo mismo que «no ocurre A y no ocurre B».\n\n'
            '**(A ∩ B)\' = A\' ∪ B\'** — «no ocurren los dos» es lo mismo que '
            '«falla al menos uno».\n\n'
            'Confundirlas es confundir «ninguno» con «no ambos», que son '
            'cosas muy distintas: en un sistema de dos componentes, «ninguno '
            'funciona» es catástrofe; «no funcionan los dos» puede ser '
            'operación normal.',
        kind: CardKind.formula,
        targetsMisconception: 'complemento_de_interseccion',
      ),
      LessonCard(
        title: 'Diccionario de enunciados',
        body: '| Frase | Conjunto |\n'
            '|---|---|\n'
            '| al menos uno | A ∪ B |\n'
            '| ninguno | A\' ∩ B\' |\n'
            '| ambos | A ∩ B |\n'
            '| no ambos | A\' ∪ B\' |\n'
            '| exactamente uno | (A−B) ∪ (B−A) |\n'
            '| a lo más uno | (A ∩ B)\' |\n\n'
            'Subraya estas palabras en el enunciado antes de escribir nada. '
            'La mayoría de los errores de examen se cometen en la traducción, '
            'no en el cálculo.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Añadir condiciones nunca ayuda',
        body: 'Como A ∩ B ⊆ A, siempre P(A ∩ B) ≤ P(A).\n\n'
            'Es matemáticamente trivial y psicológicamente muy difícil. El '
            'experimento clásico: dada una descripción de alguien con perfil '
            'activista, la mayoría dice que es más probable «cajera y '
            'feminista» que «cajera» a secas. Imposible: el segundo grupo '
            'contiene al primero.\n\n'
            'La descripción detallada resulta más **verosímil**, y '
            'verosimilitud no es probabilidad.',
        kind: CardKind.alerta,
        targetsMisconception: 'falacia_conjuncion',
      ),
    ],
  ),
  Lesson(
    id: 'm2_l3',
    moduleId: 'm2',
    title: 'Regla de la suma',
    objective: 'Calcular P(A ∪ B) sin contar dos veces la intersección.',
    preferredExperimentId: 'x8_union_interseccion',
    cards: [
      LessonCard(
        title: 'La regla general',
        body: '**P(A ∪ B) = P(A) + P(B) − P(A ∩ B)**\n\n'
            'Siempre vale. Cuando A y B son excluyentes, P(A ∩ B) = 0 y el '
            'término desaparece solo.\n\n'
            'Conclusión práctica: **usa siempre la general**. La versión '
            '«simplificada» para excluyentes no ahorra nada y sí introduce un '
            'paso donde equivocarse.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Por qué se resta',
        body: 'Al sumar |A| + |B| estás contando cada elemento de A ∩ B dos '
            'veces: una como miembro de A y otra como miembro de B. Restar '
            '|A ∩ B| lo devuelve a una.\n\n'
            'No es una corrección misteriosa; es contabilidad. Y por eso, con '
            'tres eventos, la fórmula alterna sumas y restas '
            '(inclusión-exclusión): P(A∪B∪C) = ΣP − ΣP(pares) + P(A∩B∩C).',
        targetsMisconception: 'suma_sin_restar_interseccion',
      ),
      LessonCard(
        title: 'Ejemplo con cifras',
        body: 'En una planta, el 40 % de los turnos registra retraso de '
            'insumos (A), el 30 % registra falla de equipo (B), y el 12 % '
            'registra ambas cosas.\n\n'
            '• Al menos un problema: 0,40 + 0,30 − 0,12 = {{p_union}}.\n'
            '• Ningún problema: {{p_ninguno}}.\n'
            '• Solo retraso: 0,40 − 0,12 = 0,28.\n\n'
            'Quien suma sin restar obtiene 70 % y planifica el doble de '
            'turnos problemáticos de los que hay.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_union',
            fn: 'unionGeneral',
            args: [2, 5, 3, 10, 3, 25],
            label: 'P(A ∪ B) con 0,40 · 0,30 · 0,12',
            format: FigureFormat.triple,
          ),
          ContentFigure(
            id: 'p_ninguno',
            fn: 'complement',
            args: [29, 50],
            label: 'P(ningún problema)',
            format: FigureFormat.triple,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm2_l4',
    moduleId: 'm2',
    title: 'Complemento y «al menos uno»',
    objective:
        'Reconocer cuándo el camino corto es calcular lo contrario de lo que '
        'se pregunta.',
    cards: [
      LessonCard(
        title: 'La herramienta más rentable del curso',
        body: '**P(A) = 1 − P(A\')**\n\n'
            'Cuando el evento que te piden se puede cumplir de muchas '
            'maneras, su contrario suele cumplirse de una sola. Ahí el '
            'complemento convierte diez cálculos en uno.\n\n'
            'Señal inequívoca: las palabras **«al menos»**. Casi siempre '
            'conviene pasar al complemento.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: '«Al menos uno» en n intentos',
        body: 'Si cada intento tiene probabilidad p y son independientes:\n\n'
            '**P(al menos uno) = 1 − (1 − p)ⁿ**\n\n'
            'NO es n·p. Con p = 0,1 y n = 20, n·p daría 2, que es imposible. '
            'La respuesta correcta es {{p_al_menos}}.\n\n'
            'Y «ninguno» tampoco es 1 − p: es (1 − p)ⁿ = {{p_ninguno_20}}.',
        kind: CardKind.alerta,
        targetsMisconception: 'al_menos_uno_suma',
        figures: [
          ContentFigure(
            id: 'p_al_menos',
            fn: 'atLeastOne',
            args: [1, 10, 20],
            label: 'P(al menos un éxito en 20 intentos con p = 0,1)',
            format: FigureFormat.percent,
          ),
          ContentFigure(
            id: 'p_ninguno_20',
            fn: 'noneIn',
            args: [1, 10, 20],
            label: 'P(ningún éxito en 20 intentos con p = 0,1)',
            format: FigureFormat.percent,
          ),
        ],
      ),
      LessonCard(
        title: 'Vuelve al final',
        body: 'El error más frecuente al usar el complemento no es el '
            'cálculo: es **olvidar el último paso**. Calculas P(A\') '
            'correctamente y entregas ese número.\n\n'
            'Truco de verificación: pregúntate si el resultado tiene el '
            'tamaño que esperabas. Si el evento era «probable» y te salió '
            '0,07, probablemente te quedaste con el complemento.',
        kind: CardKind.alerta,
        targetsMisconception: 'complemento_invertido',
      ),
      LessonCard(
        title: 'Un caso que sorprende',
        body: 'Un proceso falla en 1 de cada 100 piezas. Si produces 100 '
            'piezas, ¿probabilidad de al menos una fallada?\n\n'
            'La intuición dice «100 × 1 % = 100 %, seguro». La respuesta es '
            '{{p_cien}}: alta, pero no segura. Y con 300 piezas es '
            '{{p_trescientas}} — nunca llega a 1, por muchas piezas que '
            'produzcas.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_cien',
            fn: 'atLeastOne',
            args: [1, 100, 100],
            label: 'P(al menos una falla en 100 piezas con p = 0,01)',
            format: FigureFormat.percent,
          ),
          ContentFigure(
            id: 'p_trescientas',
            fn: 'atLeastOne',
            args: [1, 100, 300],
            label: 'P(al menos una falla en 300 piezas con p = 0,01)',
            format: FigureFormat.percent,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm2_l5',
    moduleId: 'm2',
    title: 'Excluyentes contra independientes',
    objective:
        'No volver a confundir los dos conceptos que más notas cuestan del '
        'curso.',
    preferredExperimentId: 'x9_excluyente_independiente',
    cards: [
      LessonCard(
        title: 'Dos preguntas distintas',
        body: '**Excluyentes**: ¿pueden ocurrir a la vez? Es una pregunta '
            'sobre **conjuntos**: A ∩ B = ∅.\n\n'
            '**Independientes**: ¿saber que ocurrió uno cambia la '
            'probabilidad del otro? Es una pregunta sobre '
            '**probabilidades**: P(A ∩ B) = P(A)·P(B).\n\n'
            'No son la misma pregunta, no se responden igual y no se deducen '
            'la una de la otra.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Excluyentes ⇒ dependientes',
        body: 'Si A y B son excluyentes y ambos tienen probabilidad '
            'positiva, entonces P(B|A) = 0, mientras que P(B) > 0.\n\n'
            'Es decir: saber que ocurrió A te informa **muchísimo** sobre B '
            '(te dice con certeza que no ocurrió). Son lo más dependientes '
            'que dos eventos pueden ser.\n\n'
            'Así que «no se tocan, luego no se influyen» es exactamente al '
            'revés de la verdad.',
        kind: CardKind.alerta,
        targetsMisconception: 'excluyente_es_independiente',
      ),
      LessonCard(
        title: 'Cómo se comprueban',
        body: '**Excluyentes**: busca un resultado que esté en los dos. Si lo '
            'encuentras, no lo son. Es una inspección del enunciado.\n\n'
            '**Independientes**: compara P(A ∩ B) con P(A)·P(B). Si coinciden, '
            'lo son. Es una cuenta.\n\n'
            'Atajo útil: la independencia casi nunca se «deduce» del '
            'enunciado; o está declarada (ensayos separados, con reposición) '
            'o hay que verificarla con números.',
        kind: CardKind.formula,
        targetsMisconception: 'independiente_es_excluyente',
      ),
      LessonCard(
        title: 'Tabla de decisión',
        body: '| Situación | Excluyentes | Independientes |\n'
            '|---|---|---|\n'
            '| Sale par / sale impar (un dado) | Sí | No |\n'
            '| Sale par / sale mayor que 4 | No | No |\n'
            '| Cara en la 1.ª / cara en la 2.ª moneda | No | Sí |\n'
            '| 1.ª roja / 2.ª roja, con reposición | No | Sí |\n'
            '| 1.ª roja / 2.ª roja, sin reposición | No | No |\n\n'
            'Las dos últimas filas son la misma urna. Lo único que cambia es '
            'si repones, y eso decide si puedes multiplicar directamente.',
        kind: CardKind.ejemplo,
      ),
    ],
  ),
  Lesson(
    id: 'm2_l6',
    moduleId: 'm2',
    title: 'Regla del producto',
    objective: 'Calcular P(A ∩ B) con y sin independencia, y saber cuál toca.',
    preferredExperimentId: 'x11_urna',
    cards: [
      LessonCard(
        title: 'La regla general',
        body: '**P(A ∩ B) = P(A) · P(B | A)**\n\n'
            'Siempre vale. Si además son independientes, P(B|A) = P(B) y '
            'queda el producto simple.\n\n'
            'Igual que con la suma: aprende la general y deja que el caso '
            'particular aparezca solo. Multiplicar P(A)·P(B) por costumbre es '
            'el segundo error más caro del curso.',
        kind: CardKind.formula,
        targetsMisconception: 'producto_sin_independencia',
      ),
      LessonCard(
        title: 'El árbol hace visible la regla',
        body: 'Un diagrama de árbol pone una etapa por nivel. En cada rama se '
            'escribe la probabilidad **condicionada a haber llegado hasta '
            'ahí**, y la probabilidad de un camino completo es el producto de '
            'sus ramas.\n\n'
            'Las ramas que salen de un mismo nodo suman 1. Esa es tu '
            'verificación gratuita: si no suman 1, hay un error antes de '
            'seguir.',
        kind: CardKind.conexion,
      ),
      LessonCard(
        title: 'Con y sin reposición, lado a lado',
        body: 'Urna con 4 rojas y 6 azules; dos extracciones, ambas rojas:\n\n'
            '• **Con** reposición: (4/10)·(4/10) = {{p_con}}\n'
            '• **Sin** reposición: (4/10)·(3/9) = {{p_sin}}\n\n'
            'La segunda fracción cambia arriba (quedan 3 rojas) y abajo '
            '(quedan 9 bolas). Quien no lo nota sobreestima el riesgo o la '
            'oportunidad, según el caso — y en muestreo de auditoría o de '
            'calidad esa diferencia es dinero.',
        kind: CardKind.ejemplo,
        figures: [
          ContentFigure(
            id: 'p_con',
            fn: 'urnAllSameWithRep',
            args: [4, 10, 2],
            label: 'P(dos rojas con reposición)',
            format: FigureFormat.triple,
          ),
          ContentFigure(
            id: 'p_sin',
            fn: 'urnAllSameNoRep',
            args: [4, 10, 2],
            label: 'P(dos rojas sin reposición)',
            format: FigureFormat.triple,
          ),
        ],
      ),
      LessonCard(
        title: 'Cadenas más largas',
        body: 'P(A ∩ B ∩ C) = P(A) · P(B|A) · P(C|A∩B)\n\n'
            'Cada factor se lee sobre el mundo que dejaron los anteriores. En '
            'una urna, eso significa ir restando del numerador y del '
            'denominador.\n\n'
            'Aplicación directa: fiabilidad de un sistema en serie, donde '
            'todos los componentes deben funcionar. Con 5 componentes al '
            '98 % cada uno, el sistema queda en {{p_serie}} — bastante peor '
            'que el peor componente.',
        kind: CardKind.formula,
        figures: [
          ContentFigure(
            id: 'p_serie',
            fn: 'seriesEqual',
            args: [98, 100, 5],
            label: 'Fiabilidad de 5 componentes al 98 % en serie',
            format: FigureFormat.percent,
          ),
        ],
      ),
    ],
  ),
  Lesson(
    id: 'm2_l7',
    moduleId: 'm2',
    title: 'Probabilidad condicional',
    objective:
        'Leer P(A|B) como un cambio de espacio muestral y no invertir la '
        'condición.',
    preferredExperimentId: 'x10_condicional_tabla',
    cards: [
      LessonCard(
        title: 'Condicionar es cambiar de mundo',
        body: '**P(A | B) = P(A ∩ B) / P(B)**, con P(B) > 0.\n\n'
            'La forma útil de entenderlo: al decir «dado que ocurrió B», el '
            'espacio muestral deja de ser Ω y pasa a ser B. Solo cuentan los '
            'resultados dentro de B, y hay que renormalizar dividiendo por '
            'P(B).\n\n'
            'Por eso P(A|B) ≥ P(A ∩ B) siempre: el mismo numerador sobre un '
            'denominador más pequeño.',
        kind: CardKind.formula,
        targetsMisconception: 'condicional_es_conjunta',
      ),
      LessonCard(
        title: 'En una tabla, sin fórmula',
        body: 'Con frecuencias no hace falta la fórmula: **divide la celda '
            'entre el total de la fila o columna que condiciona**.\n\n'
            '```\n'
            '           Aprobó   No aprobó   Total\n'
            '  Estudió     45        15        60\n'
            '  No estudió  10        30        40\n'
            '  Total       55        45       100\n'
            '```\n\n'
            'P(aprobó | estudió) = 45/60 = 0,75.\n'
            'P(estudió | aprobó) = 45/55 ≈ 0,818.\n\n'
            'Misma celda, distinto denominador, distinto significado.',
        kind: CardKind.ejemplo,
        targetsMisconception: 'denominador_no_reducido',
      ),
      LessonCard(
        title: 'La inversión: el error caro',
        body: 'P(A|B) y P(B|A) casi nunca coinciden, y confundirlos produce '
            'errores con consecuencias reales:\n\n'
            '• P(fiebre | gripe) es altísima; P(gripe | fiebre), no.\n'
            '• P(coincidencia de ADN | inocente) es minúscula; P(inocente | '
            'coincidencia) puede ser grande si la base de datos es enorme.\n'
            '• P(alarma | intruso) alta; P(intruso | alarma), bajísima.\n\n'
            'En tribunales esto tiene nombre propio —«falacia del fiscal»— y '
            'ha producido condenas erróneas.',
        kind: CardKind.alerta,
        targetsMisconception: 'condicional_invertida',
      ),
      LessonCard(
        title: 'Independencia, otra vez',
        body: 'A y B son independientes exactamente cuando '
            'P(A|B) = P(A): saber B no cambia nada.\n\n'
            'Es equivalente a P(A ∩ B) = P(A)·P(B), y suele ser la forma más '
            'fácil de comprobarlo con una tabla: mira si la proporción de la '
            'fila coincide con la proporción del total.',
        kind: CardKind.conexion,
      ),
    ],
  ),
  Lesson(
    id: 'm2_l8',
    moduleId: 'm2',
    title: 'Probabilidad total y Bayes',
    objective:
        'Ir del efecto a la causa sin ignorar la tasa base.',
    preferredExperimentId: 'x12_tamizaje',
    cards: [
      LessonCard(
        title: 'Probabilidad total: sumar por casos',
        body: 'Si A₁, A₂, …, Aₙ forman una **partición** de Ω:\n\n'
            '**P(B) = Σ P(Aᵢ) · P(B | Aᵢ)**\n\n'
            'Es el árbol leído hacia abajo: recorres todas las ramas que '
            'llegan a B y sumas sus caminos.\n\n'
            'Condición imprescindible: los Aᵢ deben ser excluyentes entre sí '
            'y cubrir todo el espacio. Si se solapan, cuentas doble.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Bayes: el árbol al revés',
        body: '**P(Aᵢ | B) = P(Aᵢ)·P(B|Aᵢ) / P(B)**\n\n'
            'Arriba, el camino que te interesa. Abajo, TODOS los caminos que '
            'llegan a B.\n\n'
            'Por eso la fórmula parece complicada: el denominador es la '
            'probabilidad total. Si haces el árbol y sumas los caminos, Bayes '
            'deja de ser una fórmula y se convierte en una división entre dos '
            'números que ya calculaste.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Cuenta personas, no probabilidades',
        body: 'Enfermedad en el 1 % de la población; test con 99 % de '
            'sensibilidad y 5 % de falsos positivos. Das positivo.\n\n'
            'Con 100 000 personas:\n'
            '• 1 000 enfermos → 990 positivos\n'
            '• 99 000 sanos → 4 950 positivos (falsos)\n'
            '• Total positivos: 5 940\n\n'
            'P(enfermo | positivo) = 990/5 940 = {{p_ppv}}.\n\n'
            'En frecuencias naturales la respuesta correcta se vuelve casi '
            'obvia. En porcentajes, casi nadie la acierta. Es el mismo '
            'cálculo.',
        kind: CardKind.ejemplo,
        targetsMisconception: 'tasa_base_ignorada',
        figures: [
          ContentFigure(
            id: 'p_ppv',
            fn: 'ppv',
            args: [1, 100, 99, 100, 95, 100],
            label: 'Valor predictivo positivo (prev 1 %, sens 99 %, esp 95 %)',
            format: FigureFormat.triple,
          ),
        ],
      ),
      LessonCard(
        title: 'La tasa base no es un detalle',
        body: 'Con el mismo test, si la prevalencia sube del 1 % al 10 %, el '
            'valor predictivo positivo salta a {{p_ppv10}}.\n\n'
            'El test no cambió. Lo que cambió es a quién se le aplica. Por '
            'eso el tamizaje masivo de enfermedades raras genera avalanchas '
            'de falsos positivos, y por eso los protocolos exigen factores de '
            'riesgo antes de pedir la prueba.\n\n'
            'Esta lección vale fuera de la medicina: alertas de fraude, '
            'detección de intrusos, filtros de spam y control de calidad '
            'tienen exactamente la misma estructura.',
        kind: CardKind.alerta,
        targetsMisconception: 'evidencia_confirma_causa',
        figures: [
          ContentFigure(
            id: 'p_ppv10',
            fn: 'ppv',
            args: [1, 10, 99, 100, 95, 100],
            label: 'VPP con prevalencia 10 %',
            format: FigureFormat.percent,
          ),
        ],
      ),
    ],
  ),
];
