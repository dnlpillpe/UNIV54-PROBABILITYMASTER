/// Glosario: 52 términos, cada uno con su error frecuente cuando lo tiene.
library;

import '../../domain/models/glossary_term.dart';

const List<GlossaryTerm> kGlossary = [
  GlossaryTerm(
      term: 'Experimento aleatorio',
      moduleId: 'm1',
      definition: 'Proceso repetible, con resultados posibles conocidos de '
          'antemano, cuyo resultado concreto no se puede predecir.',
      caution: 'Si falla cualquiera de las tres condiciones, no hay espacio '
          'muestral y no hay probabilidad que calcular.'),
  GlossaryTerm(
      term: 'Espacio muestral',
      moduleId: 'm1',
      notation: 'Ω',
      definition: 'Conjunto de todos los resultados posibles del experimento.',
      caution: 'Un mismo experimento admite varios espacios muestrales '
          'válidos; solo algunos son equiprobables.'),
  GlossaryTerm(
      term: 'Resultado elemental',
      moduleId: 'm1',
      notation: 'ω',
      definition: 'Cada uno de los elementos del espacio muestral.'),
  GlossaryTerm(
      term: 'Evento (suceso)',
      moduleId: 'm1',
      notation: 'A ⊆ Ω',
      definition: 'Subconjunto del espacio muestral; ocurre si el resultado '
          'obtenido pertenece a él.',
      caution: 'El denominador de Laplace cuenta resultados, no eventos.'),
  GlossaryTerm(
      term: 'Evento elemental',
      moduleId: 'm1',
      definition: 'Evento formado por un solo resultado.'),
  GlossaryTerm(
      term: 'Evento seguro',
      moduleId: 'm1',
      notation: 'Ω',
      definition: 'Evento que siempre ocurre. P(Ω) = 1.'),
  GlossaryTerm(
      term: 'Evento imposible',
      moduleId: 'm1',
      notation: '∅',
      definition: 'Evento que nunca ocurre. P(∅) = 0.',
      caution: 'P(A) = 0 no obliga a que A sea imposible en espacios '
          'infinitos, pero en los finitos de este curso sí.'),
  GlossaryTerm(
      term: 'Regla de Laplace',
      moduleId: 'm1',
      notation: 'P(A) = |A|/|Ω|',
      definition: 'Casos favorables entre casos posibles.',
      caution: 'Solo vale si TODOS los resultados son igualmente probables. '
          'Verificarlo es parte del método.'),
  GlossaryTerm(
      term: 'Equiprobabilidad',
      moduleId: 'm1',
      definition: 'Propiedad de un espacio muestral en el que todos los '
          'resultados tienen la misma probabilidad.',
      caution: 'Las sumas de dos dados NO son equiprobables; los 36 pares '
          'ordenados, sí.'),
  GlossaryTerm(
      term: 'Frecuencia relativa',
      moduleId: 'm1',
      notation: 'fᵣ = k/n',
      definition: 'Proporción de veces que ocurrió un evento en n '
          'repeticiones.'),
  GlossaryTerm(
      term: 'Ley de los grandes números',
      moduleId: 'm1',
      definition: 'Al crecer el número de repeticiones, la frecuencia '
          'relativa se acerca a la probabilidad teórica.',
      caution: 'Se estabiliza la proporción, no la diferencia absoluta, que '
          'tiende a crecer con √n.'),
  GlossaryTerm(
      term: 'Falacia del jugador',
      moduleId: 'm1',
      definition: 'Creencia de que una racha modifica la probabilidad del '
          'siguiente ensayo independiente.',
      caution: 'La moneda no tiene memoria: después de cualquier racha, la '
          'probabilidad es la misma.'),
  GlossaryTerm(
      term: 'Probabilidad clásica',
      moduleId: 'm1',
      definition: 'Asignada contando casos igualmente probables.'),
  GlossaryTerm(
      term: 'Probabilidad frecuentista',
      moduleId: 'm1',
      definition: 'Asignada como el límite de la frecuencia relativa al '
          'repetir el experimento muchas veces.'),
  GlossaryTerm(
      term: 'Probabilidad subjetiva',
      moduleId: 'm1',
      definition: 'Grado de creencia, actualizable con evidencia; se usa en '
          'eventos únicos no repetibles.',
      caution: 'Es legítima, pero hay que declararla como tal y no '
          'presentarla con la autoridad de un conteo.'),
  GlossaryTerm(
      term: 'Axiomas de Kolmogórov',
      moduleId: 'm1',
      definition: 'P(A) ≥ 0; P(Ω) = 1; para eventos excluyentes, la '
          'probabilidad de la unión es la suma de las probabilidades.'),
  GlossaryTerm(
      term: 'Momios (odds)',
      moduleId: 'm1',
      notation: 'a : b',
      definition: 'Razón entre casos favorables y desfavorables. '
          'P = a/(a+b).',
      caution: '«3 a 1 en contra» es P = 1/4, no 1/3.'),
  GlossaryTerm(
      term: 'Unión',
      moduleId: 'm2',
      notation: 'A ∪ B',
      definition: 'Evento «ocurre A, ocurre B, o ambos».',
      caution: 'En probabilidad el «o» es inclusivo por defecto.'),
  GlossaryTerm(
      term: 'Intersección',
      moduleId: 'm2',
      notation: 'A ∩ B',
      definition: 'Evento «ocurren A y B a la vez».'),
  GlossaryTerm(
      term: 'Complemento',
      moduleId: 'm2',
      notation: "A'",
      definition: 'Evento «no ocurre A». P(A\') = 1 − P(A).',
      caution: 'Después de calcular por complemento, hay que volver: el error '
          'más común es entregar P(A\') creyendo que es P(A).'),
  GlossaryTerm(
      term: 'Diferencia de eventos',
      moduleId: 'm2',
      notation: 'A − B',
      definition: 'Evento «ocurre A pero no B». P(A−B) = P(A) − P(A∩B).'),
  GlossaryTerm(
      term: 'Eventos mutuamente excluyentes',
      moduleId: 'm2',
      definition: 'No pueden ocurrir a la vez: A ∩ B = ∅.',
      caution: 'Excluyentes NO es lo mismo que independientes; de hecho son '
          'casi opuestos.'),
  GlossaryTerm(
      term: 'Eventos independientes',
      moduleId: 'm2',
      definition: 'Saber que ocurrió uno no cambia la probabilidad del otro: '
          'P(A∩B) = P(A)·P(B).',
      caution: 'Sin reposición NO hay independencia.'),
  GlossaryTerm(
      term: 'Partición',
      moduleId: 'm2',
      definition: 'Conjunto de eventos excluyentes entre sí que juntos cubren '
          'todo el espacio muestral.',
      caution: 'Es el requisito de la probabilidad total y de Bayes.'),
  GlossaryTerm(
      term: 'Regla de la suma',
      moduleId: 'm2',
      notation: 'P(A∪B) = P(A) + P(B) − P(A∩B)',
      definition: 'Probabilidad de que ocurra al menos uno de dos eventos.',
      caution: 'Restar la intersección no es opcional salvo que sea vacía.'),
  GlossaryTerm(
      term: 'Regla del producto',
      moduleId: 'm2',
      notation: 'P(A∩B) = P(A)·P(B|A)',
      definition: 'Probabilidad de que ocurran dos eventos.',
      caution: 'La versión P(A)·P(B) exige independencia demostrada, no '
          'supuesta.'),
  GlossaryTerm(
      term: 'Probabilidad condicional',
      moduleId: 'm2',
      notation: 'P(A|B) = P(A∩B)/P(B)',
      definition: 'Probabilidad de A cuando se sabe que ocurrió B; equivale a '
          'cambiar el espacio muestral a B.',
      caution: 'P(A|B) ≠ P(B|A). Confundirlas es el error más caro del '
          'curso.'),
  GlossaryTerm(
      term: 'Probabilidad conjunta',
      moduleId: 'm2',
      notation: 'P(A∩B)',
      definition: 'Probabilidad de que ocurran los dos, medida sobre todo Ω.',
      caution: 'Siempre es menor o igual que la condicional correspondiente.'),
  GlossaryTerm(
      term: 'Probabilidad marginal',
      moduleId: 'm2',
      definition: 'Probabilidad de un solo evento, obtenida sumando las '
          'conjuntas de una fila o columna de la tabla.'),
  GlossaryTerm(
      term: 'Tabla de contingencia',
      moduleId: 'm2',
      definition: 'Tabla de doble entrada con las frecuencias de las cuatro '
          'combinaciones de dos eventos.',
      caution: 'Al condicionar, el denominador es el total de la fila o '
          'columna, no el gran total.'),
  GlossaryTerm(
      term: 'Leyes de De Morgan',
      moduleId: 'm2',
      notation: "(A∪B)' = A'∩B'  ·  (A∩B)' = A'∪B'",
      definition: 'Reglas para el complemento de uniones e intersecciones.',
      caution: '«No ambos» no es «ninguno».'),
  GlossaryTerm(
      term: 'Probabilidad total',
      moduleId: 'm2',
      notation: 'P(B) = Σ P(Aᵢ)·P(B|Aᵢ)',
      definition: 'Probabilidad de un evento sumada por casos de una '
          'partición.'),
  GlossaryTerm(
      term: 'Teorema de Bayes',
      moduleId: 'm2',
      notation: 'P(A|B) = P(A)·P(B|A)/P(B)',
      definition: 'Permite invertir una condicional: ir del efecto observado '
          'a la causa.',
      caution: 'Sin la tasa base P(A) el resultado no se puede calcular, y es '
          'justo el dato que la intuición ignora.'),
  GlossaryTerm(
      term: 'Tasa base',
      moduleId: 'm2',
      definition: 'Probabilidad a priori de la causa, antes de observar '
          'evidencia.',
      caution: 'Con causas raras, la tasa base domina el resultado por encima '
          'de la calidad de la prueba.'),
  GlossaryTerm(
      term: 'Sensibilidad',
      moduleId: 'm2',
      notation: 'P(+ | enfermo)',
      definition: 'Proporción de casos positivos que la prueba detecta.'),
  GlossaryTerm(
      term: 'Especificidad',
      moduleId: 'm2',
      notation: 'P(− | sano)',
      definition: 'Proporción de casos negativos que la prueba descarta '
          'correctamente.'),
  GlossaryTerm(
      term: 'Valor predictivo positivo',
      moduleId: 'm2',
      notation: 'P(enfermo | +)',
      definition: 'Probabilidad de que un positivo sea real.',
      caution: 'No es una propiedad de la prueba: depende de la prevalencia '
          'de la población donde se aplique.'),
  GlossaryTerm(
      term: 'Falso positivo',
      moduleId: 'm2',
      definition: 'Resultado positivo en un caso que no lo es.'),
  GlossaryTerm(
      term: 'Falacia de la conjunción',
      moduleId: 'm2',
      definition: 'Creer que una descripción más específica es más probable '
          'que una más general.',
      caution: 'P(A∩B) ≤ P(A), siempre.'),
  GlossaryTerm(
      term: 'Fiabilidad en serie',
      moduleId: 'm2',
      notation: 'R = ∏ rᵢ',
      definition: 'Fiabilidad de un sistema que necesita que todos sus '
          'componentes funcionen.'),
  GlossaryTerm(
      term: 'Fiabilidad en paralelo',
      moduleId: 'm2',
      notation: 'R = 1 − ∏(1 − rᵢ)',
      definition: 'Fiabilidad de un sistema al que le basta un componente '
          'activo.'),
  GlossaryTerm(
      term: 'Principio multiplicativo',
      moduleId: 'm3',
      notation: 'n₁·n₂·…·nₖ',
      definition: 'Número de formas de completar una tarea por etapas '
          'sucesivas.',
      caution: 'Exige que el NÚMERO de opciones de cada etapa no dependa de '
          'lo elegido antes.'),
  GlossaryTerm(
      term: 'Permutación',
      moduleId: 'm3',
      notation: 'n!',
      definition: 'Ordenación de todos los elementos de un conjunto.'),
  GlossaryTerm(
      term: 'Permutación circular',
      moduleId: 'm3',
      notation: '(n−1)!',
      definition: 'Ordenación alrededor de una mesa redonda, donde las '
          'rotaciones son la misma disposición.'),
  GlossaryTerm(
      term: 'Variación sin repetición',
      moduleId: 'm3',
      notation: 'P(n,k) = n!/(n−k)!',
      definition: 'Selecciones ordenadas de k elementos entre n, sin '
          'repetir.'),
  GlossaryTerm(
      term: 'Variación con repetición',
      moduleId: 'm3',
      notation: 'nᵏ',
      definition: 'Selecciones ordenadas de k elementos entre n, pudiendo '
          'repetir.'),
  GlossaryTerm(
      term: 'Combinación',
      moduleId: 'm3',
      notation: 'C(n,k) = n!/(k!(n−k)!)',
      definition: 'Selecciones no ordenadas de k elementos entre n, sin '
          'repetir.',
      caution: 'Prueba del intercambio: si cambiar dos elegidos da otro caso, '
          'el orden importa y no son combinaciones.'),
  GlossaryTerm(
      term: 'Combinación con repetición',
      moduleId: 'm3',
      notation: 'C(n+k−1, k)',
      definition: 'Selecciones no ordenadas de k elementos entre n tipos, '
          'pudiendo repetir.'),
  GlossaryTerm(
      term: 'Permutaciones con repetición',
      moduleId: 'm3',
      notation: 'n!/(n₁!·n₂!…)',
      definition: 'Ordenaciones de n objetos con grupos indistinguibles.',
      caution: 'Sin dividir por cada grupo repetido se sobrecuenta.'),
  GlossaryTerm(
      term: 'Problema del cumpleaños',
      moduleId: 'm3',
      definition: 'Con 23 personas la probabilidad de que dos compartan '
          'cumpleaños ya supera el 50 %.',
      caution: 'La intuición falla porque cuenta personas cuando lo que '
          'manda son parejas.'),
  GlossaryTerm(
      term: 'Distribución binomial',
      moduleId: 'm3',
      notation: 'P(X=k) = C(n,k)pᵏ(1−p)ⁿ⁻ᵏ',
      definition: 'Número de éxitos en n ensayos independientes con la misma '
          'probabilidad p.',
      caution: 'Exige p constante: con población pequeña y sin reposición, '
          'no vale.'),
  GlossaryTerm(
      term: 'Distribución hipergeométrica',
      moduleId: 'm3',
      notation: 'C(K,k)·C(N−K,n−k)/C(N,n)',
      definition: 'Número de éxitos al extraer n elementos sin reposición de '
          'una población finita.',
      caution: 'Es el modelo del muestreo de auditoría y de control de '
          'calidad.'),
  GlossaryTerm(
      term: 'Sesgo de selección',
      moduleId: 'm4',
      definition: 'Distorsión producida cuando la muestra no se eligió al '
          'azar, sino por un mecanismo relacionado con lo que se mide.',
      caution: 'Ningún margen de error lo corrige, y más datos sesgados solo '
          'dan más confianza en un número equivocado.'),
  GlossaryTerm(
      term: 'Sesgo de supervivencia',
      moduleId: 'm4',
      definition: 'Analizar solo los casos que llegaron al final, ignorando '
          'los que desaparecieron por el camino.'),
];
