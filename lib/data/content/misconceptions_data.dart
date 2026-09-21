/// Catálogo de confusiones de Probability Master.
///
/// 32 creencias erróneas documentadas, cada una con su remedio enlazado.
/// Ninguna está aquí por completar la lista: todas aparecen producidas por al
/// menos un distractor de los ejercicios, y un test lo verifica.
library;

import '../../domain/models/misconception.dart';

const List<Misconception> kMisconceptions = [
  // ---------------- F1 · Intuición frecuentista ----------------------
  Misconception(
    id: 'falacia_jugador',
    name: 'Falacia del jugador',
    belief: '«Ya salieron cuatro caras seguidas, ahora es más probable sello».',
    correction:
        'La moneda no tiene memoria. Después de cualquier racha, la '
        'probabilidad del siguiente lanzamiento sigue siendo la misma.',
    symptom: 'Ajusta la probabilidad del siguiente ensayo según lo ya '
        'observado en ensayos independientes.',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyLessonId: 'm1_l4',
    remedyExperimentId: 'x3_falacia',
  ),
  Misconception(
    id: 'ley_de_promedios',
    name: 'Ley de los promedios',
    belief: '«Al final el azar se compensa y todo queda parejo».',
    correction:
        'Lo que se estabiliza es la PROPORCIÓN. La diferencia absoluta entre '
        'caras y sellos tiende a crecer, no a cerrarse.',
    symptom: 'Espera que un déficit de éxitos se «recupere» más adelante.',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyLessonId: 'm1_l4',
    remedyExperimentId: 'x4_desbalance',
  ),
  Misconception(
    id: 'racha_imposible',
    name: 'Las rachas no son azar',
    belief: '«Seis caras seguidas significa que la moneda está trucada».',
    correction:
        'En muchas repeticiones las rachas largas son esperables. Su ausencia '
        'sería lo sospechoso.',
    symptom: 'Interpreta cualquier racha como evidencia de trampa o de patrón.',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyExperimentId: 'x1_moneda_justa',
  ),
  Misconception(
    id: 'muestra_pequena_representa',
    name: 'La muestra pequeña ya representa',
    belief: '«Con 20 lanzamientos ya debería salir 50 % y 50 %».',
    correction:
        'Con n pequeño la frecuencia relativa oscila muchísimo. La '
        'estabilización necesita cientos o miles de repeticiones.',
    symptom: 'Concluye que un dado está cargado tras 30 tiros.',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyLessonId: 'm1_l4',
    remedyExperimentId: 'x1_moneda_justa',
  ),
  Misconception(
    id: 'aleatorio_es_parejo',
    name: 'Lo aleatorio se ve ordenado',
    belief: '«Una secuencia aleatoria alterna: CSCSSC, no CCCCSC».',
    correction:
        'Toda secuencia concreta de n lanzamientos tiene la misma '
        'probabilidad. La que «parece» aleatoria no es más probable.',
    symptom: 'Elige la secuencia más alternada como «la más probable».',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyLessonId: 'm1_l3',
    remedyExperimentId: 'x6_tres_monedas',
  ),
  Misconception(
    id: 'control_del_azar',
    name: 'Control sobre el azar',
    belief: '«Si elijo yo los números o lanzo con cuidado, mejoro mis '
        'probabilidades».',
    correction:
        'En un sorteo equiprobable, ninguna estrategia de elección cambia la '
        'probabilidad de acertar.',
    symptom: 'Atribuye a la elección personal un efecto sobre el resultado.',
    family: MisconceptionFamily.intuicionFrecuentista,
    remedyExperimentId: 'x15_loteria',
  ),

  // ---------------- F2 · Espacio muestral ----------------------------
  Misconception(
    id: 'equiprobabilidad_asumida',
    name: 'Equiprobabilidad asumida',
    belief: '«Como hay 11 sumas posibles con dos dados, cada una vale 1/11».',
    correction:
        'Solo se divide favorables entre posibles cuando los resultados son '
        'igualmente probables. Las sumas NO lo son.',
    symptom: 'Aplica Laplace sin comprobar la condición de equiprobabilidad.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm1_l2',
    remedyExperimentId: 'x5_dos_dados',
  ),
  Misconception(
    id: 'espacio_incompleto',
    name: 'Espacio muestral incompleto',
    belief: '«Con dos monedas hay tres casos: dos caras, dos sellos y una de '
        'cada».',
    correction:
        'Hay cuatro: CC, CS, SC, SS. «Una de cada» ocurre de dos maneras y por '
        'eso vale el doble.',
    symptom: 'Cuenta menos resultados de los que hay y obtiene 1/3 en vez de '
        '1/4.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm1_l2',
    remedyExperimentId: 'x6_tres_monedas',
  ),
  Misconception(
    id: 'orden_ignorado_en_espacio',
    name: 'Orden ignorado al construir el espacio',
    belief: '«(3,5) y (5,3) son el mismo resultado».',
    correction:
        'Con dos dados distinguibles son dos resultados distintos, y contarlos '
        'como uno rompe la equiprobabilidad de todo el espacio.',
    symptom: 'Obtiene 21 resultados en vez de 36.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm1_l2',
    remedyExperimentId: 'x5_dos_dados',
  ),
  Misconception(
    id: 'resultado_vs_evento',
    name: 'Resultado y evento confundidos',
    belief: '«El evento “sale par” es un resultado del experimento».',
    correction:
        'Un resultado es un elemento de Ω; un evento es un SUBCONJUNTO de Ω, '
        'y puede contener muchos resultados.',
    symptom: 'Cuenta eventos en el denominador de Laplace.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm1_l3',
  ),
  Misconception(
    id: 'probabilidad_mayor_que_uno',
    name: 'Probabilidad fuera de rango',
    belief: 'Acepta como respuesta un valor mayor que 1 (o negativo).',
    correction:
        'Todo valor de probabilidad vive en [0,1]. Un resultado fuera de ahí '
        'delata un error de método, no de aritmética.',
    symptom: 'Entrega 1,2 o 120 % sin extrañarse.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm1_l5',
  ),
  Misconception(
    id: 'complemento_invertido',
    name: 'Complemento invertido',
    belief: 'Calcula P(A\') creyendo que calculó P(A).',
    correction:
        'Después de usar el complemento hay que volver: P(A) = 1 − P(A\').',
    symptom: 'Da exactamente el valor complementario del correcto.',
    family: MisconceptionFamily.espacioMuestral,
    remedyLessonId: 'm2_l4',
  ),

  // ---------------- F3 · Reglas y eventos -----------------------------
  Misconception(
    id: 'excluyente_es_independiente',
    name: 'Excluyente = independiente',
    belief: '«Si no pueden ocurrir a la vez, son independientes».',
    correction:
        'Es al revés: si A y B son excluyentes y tienen probabilidad '
        'positiva, saber que ocurrió A te dice con certeza que B no ocurrió. '
        'Son máximamente DEPENDIENTES.',
    symptom: 'Multiplica probabilidades de eventos incompatibles.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l5',
    remedyExperimentId: 'x9_excluyente_independiente',
  ),
  Misconception(
    id: 'independiente_es_excluyente',
    name: 'Independiente = excluyente',
    belief: '«Si son independientes, no pueden ocurrir juntos».',
    correction:
        'Independientes significa que ocurran juntos con probabilidad '
        'P(A)·P(B), que salvo casos triviales es positiva.',
    symptom: 'Suma probabilidades de eventos independientes que sí se solapan.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l5',
    remedyExperimentId: 'x9_excluyente_independiente',
  ),
  Misconception(
    id: 'suma_sin_restar_interseccion',
    name: 'Suma sin restar la intersección',
    belief: '«P(A o B) = P(A) + P(B), siempre».',
    correction:
        'Si A y B se solapan, esa suma cuenta dos veces los resultados '
        'comunes. Hay que restar P(A∩B).',
    symptom: 'Obtiene un valor inflado, a veces mayor que 1.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l3',
    remedyExperimentId: 'x8_union_interseccion',
  ),
  Misconception(
    id: 'producto_sin_independencia',
    name: 'Producto sin independencia',
    belief: '«P(A y B) = P(A)·P(B), siempre».',
    correction:
        'Solo si son independientes. Sin reposición, la segunda extracción '
        'depende de la primera: hay que usar P(B|A).',
    symptom: 'Usa (k/n)² en extracciones sin reposición.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l6',
    remedyExperimentId: 'x11_urna',
  ),
  Misconception(
    id: 'al_menos_uno_suma',
    name: '«Al menos uno» sumando',
    belief: '«Si cada intento tiene p, en n intentos la probabilidad es n·p».',
    correction:
        'Eso puede pasar de 1. La forma correcta es 1 − (1−p)ⁿ.',
    symptom: 'Multiplica p por n y obtiene valores absurdos con n grande.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l4',
  ),
  Misconception(
    id: 'ninguno_es_uno_menos_p',
    name: '«Ninguno» mal calculado',
    belief: '«P(ninguno en n intentos) = 1 − p».',
    correction: 'Es (1−p)ⁿ: el complemento se aplica a cada ensayo y luego se '
        'multiplica.',
    symptom: 'Ignora el exponente n al calcular «ninguno».',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l4',
  ),
  Misconception(
    id: 'o_inclusivo_exclusivo',
    name: '«O» leído como excluyente',
    belief: '«“A o B” significa uno de los dos, pero no ambos».',
    correction:
        'En probabilidad «o» es inclusivo por defecto: A∪B incluye los casos '
        'donde ocurren los dos, salvo que el enunciado diga lo contrario.',
    symptom: 'Excluye la intersección sin que el problema lo pida.',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l2',
  ),
  Misconception(
    id: 'complemento_de_interseccion',
    name: 'Complemento de una intersección',
    belief: '«(A∩B)\' = A\'∩B\'».',
    correction:
        'Leyes de De Morgan: (A∩B)\' = A\'∪B\'. Que no ocurran los dos no '
        'significa que no ocurra ninguno.',
    symptom: 'Confunde «no ambos» con «ninguno».',
    family: MisconceptionFamily.reglasYEventos,
    remedyLessonId: 'm2_l2',
  ),

  // ---------------- F4 · Condicional y Bayes --------------------------
  Misconception(
    id: 'condicional_invertida',
    name: 'Condicional invertida',
    belief: '«P(A|B) es lo mismo que P(B|A)».',
    correction:
        'Cambian el espacio al que se condiciona y, por tanto, el '
        'denominador. P(fiebre|gripe) es alta; P(gripe|fiebre), no.',
    symptom: 'Divide entre el total equivocado de la tabla.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l7',
    remedyExperimentId: 'x10_condicional_tabla',
  ),
  Misconception(
    id: 'tasa_base_ignorada',
    name: 'Tasa base ignorada',
    belief: '«La prueba acierta el 99 %, así que un positivo es 99 % seguro».',
    correction:
        'Con una enfermedad rara, la mayoría de los positivos vienen de la '
        'enorme población sana. La tasa base manda.',
    symptom: 'Responde con la sensibilidad cuando le piden el valor '
        'predictivo positivo.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l8',
    remedyExperimentId: 'x12_tamizaje',
  ),
  Misconception(
    id: 'condicional_es_conjunta',
    name: 'Condicional confundida con conjunta',
    belief: '«P(A|B) es la probabilidad de que ocurran A y B».',
    correction:
        'P(A∩B) se mide sobre todo Ω; P(A|B) se mide solo dentro de B, y por '
        'eso es mayor o igual.',
    symptom: 'No reduce el denominador al condicionar.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l7',
    remedyExperimentId: 'x10_condicional_tabla',
  ),
  Misconception(
    id: 'denominador_no_reducido',
    name: 'Denominador sin reducir',
    belief: 'Al condicionar sigue dividiendo entre el total general.',
    correction:
        'Condicionar es cambiar de espacio muestral: el nuevo total es el '
        'tamaño del evento que condiciona.',
    symptom: 'En una tabla de contingencia divide entre el gran total.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l7',
    remedyExperimentId: 'x10_condicional_tabla',
  ),
  Misconception(
    id: 'falacia_conjuncion',
    name: 'Falacia de la conjunción',
    belief: '«Es más probable que sea ingeniera Y deportista que solo '
        'ingeniera, porque encaja mejor con la descripción».',
    correction:
        'Añadir una condición nunca puede aumentar la probabilidad: '
        'P(A∩B) ≤ P(A) siempre.',
    symptom: 'Ordena una conjunción por encima de uno de sus componentes.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l2',
  ),
  Misconception(
    id: 'evidencia_confirma_causa',
    name: 'La evidencia confirma la causa',
    belief: '«Si el resultado es compatible con la hipótesis, la hipótesis es '
        'cierta».',
    correction:
        'Una evidencia compatible también puede venir de otras causas mucho '
        'más frecuentes. Hay que comparar P(E|H) con P(E) completa.',
    symptom: 'Ignora las causas alternativas al interpretar un resultado.',
    family: MisconceptionFamily.condicionalYBayes,
    remedyLessonId: 'm2_l8',
    remedyExperimentId: 'x13_prevalencia',
  ),

  // ---------------- F5 · Conteo ---------------------------------------
  Misconception(
    id: 'orden_importa_confundido',
    name: 'Orden: combinación por variación',
    belief: 'Usa C(n,k) donde el orden importa, o P(n,k) donde no importa.',
    correction:
        'Prueba concreta: intercambia dos elementos elegidos. Si el resultado '
        'es OTRO caso, el orden importa.',
    symptom: 'Sus resultados difieren del correcto en un factor k!.',
    family: MisconceptionFamily.conteo,
    remedyLessonId: 'm3_l3',
    remedyExperimentId: 'x16_orden',
  ),
  Misconception(
    id: 'reposicion_ignorada',
    name: 'Reposición ignorada',
    belief: 'Usa nᵏ cuando los elementos no pueden repetirse (o al revés).',
    correction:
        'Con reposición cada etapa vuelve a tener n opciones; sin reposición '
        'tiene una menos cada vez.',
    symptom: 'Cuenta 10⁴ contraseñas de dígitos distintos.',
    family: MisconceptionFamily.conteo,
    remedyLessonId: 'm3_l2',
    remedyExperimentId: 'x11_urna',
  ),
  Misconception(
    id: 'criterio_mixto',
    name: 'Numerador y denominador con criterios distintos',
    belief: 'Cuenta los favorables con orden y los posibles sin orden (o al '
        'revés).',
    correction:
        'La regla de Laplace exige el MISMO criterio arriba y abajo. '
        'Cualquiera de los dos sirve, mientras sea el mismo.',
    symptom: 'Resultados que difieren en k! del correcto, sin patrón claro.',
    family: MisconceptionFamily.conteo,
    remedyLessonId: 'm3_l5',
  ),
  Misconception(
    id: 'sobreconteo_repetidos',
    name: 'Sobreconteo con elementos repetidos',
    belief: 'Cuenta n! ordenaciones de una palabra con letras repetidas.',
    correction:
        'Hay que dividir entre el factorial de cada grupo idéntico: las '
        'permutaciones que solo intercambian letras iguales son la misma.',
    symptom: 'Da 6! para las ordenaciones de «CASAS».',
    family: MisconceptionFamily.conteo,
    remedyLessonId: 'm3_l4',
  ),

  // ---------------- F6 · Modelado -------------------------------------
  Misconception(
    id: 'formula_por_parecido',
    name: 'Fórmula elegida por parecido',
    belief: 'Busca en el enunciado palabras que se parezcan a un ejemplo ya '
        'resuelto y copia su fórmula.',
    correction:
        'El método se decide respondiendo cuatro preguntas: qué se pide, si '
        'importa el orden, si hay reposición y si los eventos se solapan.',
    symptom: 'Acierta en los ejercicios del tema y falla en los mezclados.',
    family: MisconceptionFamily.modelado,
    remedyLessonId: 'm4_l1',
  ),
  Misconception(
    id: 'inferir_sin_experimento',
    name: 'Probabilidad sin experimento aleatorio',
    belief: 'Calcula una probabilidad sobre datos que no provienen de un '
        'mecanismo aleatorio.',
    correction:
        'Sin experimento aleatorio no hay espacio muestral, y sin espacio '
        'muestral el número que salga no significa nada.',
    symptom: 'Aplica Laplace a una encuesta de voluntarios o a una opinión.',
    family: MisconceptionFamily.modelado,
    remedyLessonId: 'm4_l4',
  ),
];

/// Índice por id, para resolver remedios y retroalimentaciones.
final Map<String, Misconception> kMisconceptionsById = {
  for (final m in kMisconceptions) m.id: m,
};
