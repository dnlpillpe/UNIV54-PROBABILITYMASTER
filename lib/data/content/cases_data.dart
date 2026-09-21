/// Los doce casos profesionales del módulo 4.
///
/// Once carreras más un caso transversal. Dos terminan en «con estos datos no
/// corresponde calcular»: saber cuándo parar es parte de la competencia.
library;

import '../../domain/math/figure_registry.dart';
import '../../domain/models/case_study.dart';
import '../../domain/models/exercise.dart';

const List<CaseStudy> kCases = [
  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c01_minas',
    career: 'Ingeniería de Minas',
    title: 'Detección de gas en labor subterránea',
    scenario:
        'En una labor subterránea se instalan 3 detectores de metano '
        'independientes. Cada uno detecta una acumulación peligrosa con '
        'probabilidad 0,92. El protocolo exige evacuar si al menos uno se '
        'activa. El supervisor propone retirar uno de los tres para reducir '
        'costos de mantenimiento, argumentando que «con dos ya se cubre '
        'prácticamente lo mismo».',
    data: [
      'Detectores instalados: 3, independientes',
      'Probabilidad de detección de cada uno: 0,92',
      'Criterio de evacuación: al menos un detector activado',
    ],
    question: '¿Qué le respondes al supervisor?',
    detects: ['al_menos_uno_suma', 'producto_sin_independencia'],
    figures: [
      ContentFigure(
        id: 'det3',
        fn: 'parallelEqual',
        args: [92, 100, 3],
        label: 'Detección con 3 sensores',
        format: FigureFormat.percent,
      ),
      ContentFigure(
        id: 'det2',
        fn: 'parallelEqual',
        args: [92, 100, 2],
        label: 'Detección con 2 sensores',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('Con 3 la detección es 99,95 % y con 2 baja a 99,36 %: el fallo '
          'no detectado se multiplica por 12,5',
          correct: true,
          feedback: 'Correcto. En términos de porcentaje la caída parece '
              'mínima; en términos de fallos no detectados, pasa de 1 de cada '
              '1 953 a 1 de cada 156.'),
      Choice('Tiene razón: 99,4 % y 99,9 % son prácticamente lo mismo',
          misconceptionId: 'formula_por_parecido',
          feedback: 'En seguridad, lo que importa es la probabilidad de '
              'FALLO, no la de acierto. 0,64 % frente a 0,05 % es una '
              'diferencia de más de un orden de magnitud.'),
      Choice('Con 2 detectores la probabilidad es 0,92 × 0,92 = 84,6 %',
          misconceptionId: 'complemento_de_interseccion',
          feedback: 'Eso es la probabilidad de que AMBOS detecten, que no es '
              'lo que pide el protocolo. Basta con uno: hay que calcular '
              '1 − P(ninguno detecta).'),
      Choice('Con 3 detectores la probabilidad es 3 × 0,92 = 276 %',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'Un valor mayor que 1 es imposible: es la alarma de que '
              '«al menos uno» no se calcula sumando.'),
    ],
    justifications: [
      Choice('Porque «al menos uno» se calcula por complemento: '
          '1 − 0,08ⁿ, y en seguridad se compara la tasa de fallo, no la de '
          'acierto',
          correct: true,
          feedback: 'Exacto: ese es el par de ideas que decide el caso.'),
      Choice('Porque los detectores en paralelo suman sus probabilidades',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'No suman: eso daría valores imposibles. Se combina por '
              'complemento.'),
      Choice('Porque tres detectores siempre son mejores que dos, sin '
          'necesidad de calcular',
          misconceptionId: 'formula_por_parecido',
          feedback: 'La conclusión coincide, pero sin la cifra no puedes '
              'defenderla frente a un argumento de costos.'),
    ],
    resolution:
        'Cada detector falla con probabilidad 0,08. Con 3 independientes, '
        'P(ninguno detecta) = 0,08³ = 0,000512, así que la detección es '
        '{{det3}}. Con 2, P(ninguno) = 0,08² = 0,0064 y la detección baja a '
        '{{det2}}.\n\n'
        'Traducido a lo que importa: con 3 detectores se escapa 1 '
        'acumulación de cada 1 953; con 2, 1 de cada 156. El riesgo de fallo '
        'no detectado se multiplica por 12,5.',
    assumptions:
        'Se asume que los tres detectores fallan de forma INDEPENDIENTE. Es '
        'un supuesto fuerte y a menudo falso: si comparten alimentación '
        'eléctrica, calibración, lote de fabricación o el mismo punto de '
        'instalación mal ventilado, los fallos están correlacionados y el '
        'cálculo sobreestima la seguridad real. En un informe serio esto se '
        'declara, y se diversifica la fuente de alimentación y el lote.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c02_sistemas',
    career: 'Ingeniería de Sistemas',
    title: 'Alertas del sistema de detección de intrusos',
    scenario:
        'El IDS de la empresa genera alertas de intrusión. En pruebas '
        'controladas detecta el 98 % de los ataques reales y genera una '
        'alerta falsa en el 1 % de las sesiones legítimas. En un día normal '
        'hay 20 000 sesiones legítimas y, en promedio, 4 intentos reales de '
        'intrusión. El equipo de seguridad pide automatizar el bloqueo de '
        'toda cuenta que genere una alerta.',
    data: [
      'Sensibilidad del IDS: 98 %',
      'Tasa de falsas alertas: 1 % de las sesiones legítimas',
      'Sesiones legítimas por día: 20 000',
      'Intentos reales de intrusión por día: 4',
    ],
    question: '¿Debe automatizarse el bloqueo ante cualquier alerta?',
    detects: ['tasa_base_ignorada', 'condicional_invertida'],
    options: [
      Choice('No: solo unas 2 de cada 100 alertas corresponden a un ataque '
          'real',
          correct: true,
          feedback: 'Correcto. 3,92 alertas verdaderas frente a 200 falsas al '
              'día: el bloqueo automático dejaría fuera a 200 usuarios '
              'legítimos cada día.'),
      Choice('Sí: el IDS acierta el 98 %',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El 98 % es P(alerta | ataque). Lo que decide el bloqueo '
              'es P(ataque | alerta), que con 4 ataques entre 20 000 sesiones '
              'es de apenas 1,9 %.'),
      Choice('Sí, porque el 1 % de falsas alertas es un valor bajo',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'El 1 % es bajo como tasa, pero se aplica a 20 000 '
              'sesiones: son 200 alertas falsas diarias, cincuenta veces más '
              'que las verdaderas.'),
      Choice('No, porque el IDS no es suficientemente sensible',
          feedback: 'La sensibilidad es excelente. El problema es la '
              'proporción de ataques en el tráfico total, no la calidad del '
              'detector.'),
    ],
    justifications: [
      Choice('Porque con una tasa base de 4 entre 20 004, las falsas alertas '
          'superan ampliamente a las verdaderas: P(ataque | alerta) ≈ 1,9 %',
          correct: true,
          feedback: 'Exacto. Y la consecuencia de diseño es escalonar: '
              'alerta automática, bloqueo con verificación.'),
      Choice('Porque ninguna decisión de seguridad debe automatizarse',
          feedback: 'Demasiado general: con una tasa base alta, automatizar '
              'sería razonable. Lo que decide es el número, no el principio.'),
      Choice('Porque el 98 % debería ser 99,9 % para poder automatizar',
          misconceptionId: 'condicional_invertida',
          feedback: 'Subir la sensibilidad no arregla el problema: lo que '
              'domina es la tasa de falsos positivos aplicada a un tráfico '
              'enorme.'),
    ],
    resolution:
        'Alertas verdaderas al día: 4 × 0,98 = 3,92.\n'
        'Alertas falsas al día: 20 000 × 0,01 = 200.\n'
        'Total de alertas: 203,92.\n\n'
        'P(ataque real | alerta) = 3,92 / 203,92 ≈ 1,92 %.\n\n'
        'El diseño correcto es escalonado: la alerta dispara verificación '
        '(factor adicional, revisión de comportamiento), no bloqueo. Para '
        'que el bloqueo automático fuera defendible habría que bajar la tasa '
        'de falsas alertas a un orden de 0,01 %, o aplicarlo solo a '
        'subconjuntos de tráfico con tasa base mucho más alta.',
    assumptions:
        'Se asume que la sensibilidad medida en pruebas controladas se '
        'mantiene con ataques reales (optimista: los atacantes se adaptan) y '
        'que las sesiones son independientes entre sí. También que 4 '
        'intentos diarios es una estimación válida; si la cifra real fuera '
        '400, la conclusión cambiaría por completo.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c03_electronica',
    career: 'Ingeniería Electrónica',
    title: 'Redundancia en la fuente de alimentación',
    scenario:
        'Diseñas la alimentación de un equipo médico que debe operar sin '
        'interrupción. Cada módulo de fuente tiene una fiabilidad de 0,97 '
        'en 1 000 horas. Puedes montar 1, 2 o 3 módulos en paralelo (basta '
        'con uno para alimentar el equipo). Cada módulo adicional cuesta '
        'espacio, peso y dinero.',
    data: [
      'Fiabilidad de un módulo (1 000 h): 0,97',
      'Configuración: paralelo, basta con uno activo',
      'Requisito del cliente: fiabilidad ≥ 0,9999',
    ],
    question: '¿Cuántos módulos hacen falta para cumplir el requisito?',
    detects: ['producto_sin_independencia'],
    figures: [
      ContentFigure(
        id: 'r2',
        fn: 'parallelEqual',
        args: [97, 100, 2],
        label: 'Fiabilidad con 2 módulos',
        format: FigureFormat.percent,
      ),
      ContentFigure(
        id: 'r3',
        fn: 'parallelEqual',
        args: [97, 100, 3],
        label: 'Fiabilidad con 3 módulos',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('Tres módulos: con dos se llega a 99,91 %, que no alcanza el '
          'requisito',
          correct: true,
          feedback: 'Correcto: 1 − 0,03² = 0,9991 queda por debajo de 0,9999; '
              '1 − 0,03³ = 0,999973 lo supera.'),
      Choice('Dos módulos bastan: 99,91 % redondea a 99,99 %',
          feedback: 'No redondea: 0,9991 y 0,9999 difieren en un factor 9 en '
              'la tasa de fallo (9 × 10⁻⁴ frente a 1 × 10⁻⁴).'),
      Choice('Un módulo basta si se le hace mantenimiento preventivo',
          feedback: 'El mantenimiento cambia la fiabilidad del módulo, pero '
              'el enunciado la fija en 0,97. Con ese dato, un solo módulo '
              'queda tres órdenes de magnitud por debajo.'),
      Choice('Tres módulos, porque la fiabilidad se suma: 3 × 0,97',
          misconceptionId: 'al_menos_uno_suma',
          feedback: 'La conclusión coincide por casualidad, pero 2,91 es '
              'imposible como probabilidad. El paralelo se calcula por '
              'complemento.'),
    ],
    justifications: [
      Choice('Porque en paralelo el sistema falla solo si fallan todos: '
          'R = 1 − (1 − 0,97)ⁿ, y hace falta n = 3',
          correct: true,
          feedback: 'Exacto, y conviene expresarlo en tasa de fallo: '
              '3 × 10⁻² → 9 × 10⁻⁴ → 2,7 × 10⁻⁵.'),
      Choice('Porque cada módulo extra multiplica la fiabilidad por 0,97',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'Eso describe el montaje en SERIE, donde añadir '
              'componentes empeora. En paralelo ocurre lo contrario.'),
      Choice('Porque tres es el estándar de la industria médica',
          feedback: 'Puede ser cierto, pero no es un argumento: el requisito '
              'está dado y se verifica con el cálculo.'),
    ],
    resolution:
        '1 módulo: 97 %.\n'
        '2 módulos: 1 − 0,03² = {{r2}}.\n'
        '3 módulos: 1 − 0,03³ = {{r3}}.\n\n'
        'Solo la configuración de tres módulos supera el 99,99 % exigido. '
        'Expresado como tasa de fallo, que es como se especifica en '
        'confiabilidad: 3 × 10⁻², 9 × 10⁻⁴ y 2,7 × 10⁻⁵ respectivamente.',
    assumptions:
        'Independencia entre módulos: se rompe si comparten la misma línea de '
        'entrada, el mismo lote de condensadores o la misma refrigeración. '
        'Además se asume que el conmutador que reparte la carga no falla; en '
        'la práctica ese conmutador suele ser el punto único de falla que '
        'domina todo el cálculo, y hay que incluirlo en SERIE con el '
        'conjunto.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c04_ambiental',
    career: 'Ingeniería Ambiental',
    title: 'Muestreo de un lote de suelo contaminado',
    scenario:
        'Un terreno se divide en 40 parcelas. Por el historial del sitio se '
        'estima que 6 de ellas superan el límite de plomo. El presupuesto '
        'alcanza para analizar 8 parcelas elegidas al azar. El cliente '
        'pregunta qué probabilidad hay de no encontrar ninguna parcela '
        'contaminada, es decir, de dar el terreno por limpio siendo falso.',
    data: [
      'Parcelas totales: 40',
      'Parcelas contaminadas (estimadas): 6',
      'Parcelas analizadas: 8, al azar y sin reposición',
    ],
    question: '¿Cuál es la probabilidad de no detectar ninguna contaminada?',
    detects: ['reposicion_ignorada', 'producto_sin_independencia'],
    figures: [
      ContentFigure(
        id: 'p_nada',
        fn: 'hypergeometric',
        args: [40, 6, 8, 0],
        label: 'P(0 contaminadas en 8 de 40 con 6 contaminadas)',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('Alrededor del 24 %: hay un riesgo alto de falso «limpio»',
          correct: true,
          feedback: 'Correcto: C(34,8)/C(40,8) ≈ 0,236. Casi uno de cada '
              'cuatro muestreos daría el terreno por limpio.'),
      Choice('Alrededor del 27 %, usando (34/40)⁸',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'Eso asume reposición: como si una parcela pudiera '
              'analizarse dos veces. Con 40 parcelas y 8 análisis, el '
              'agotamiento importa: la respuesta correcta es menor.'),
      Choice('Prácticamente cero: 8 de 40 es una muestra grande',
          feedback: 'El 20 % de la superficie parece mucho, pero con solo 6 '
              'parcelas contaminadas la probabilidad de esquivarlas todas es '
              'considerable.'),
      Choice('15 %, que es 6/40',
          misconceptionId: 'formula_por_parecido',
          feedback: '6/40 es la proporción contaminada del terreno, no la '
              'probabilidad de que el muestreo falle.'),
    ],
    justifications: [
      Choice('Porque es muestreo sin reposición de una población pequeña: '
          'C(34,8)/C(40,8), modelo hipergeométrico',
          correct: true,
          feedback: 'Exacto, y la conclusión práctica es que 8 parcelas no '
              'bastan para certificar.'),
      Choice('Porque cada parcela es independiente con p = 34/40',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'No son independientes: cada parcela analizada sale del '
              'conjunto y cambia las proporciones.'),
      Choice('Porque el muestreo aleatorio siempre detecta la contaminación '
          'si existe',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'El muestreo aleatorio evita el sesgo, no garantiza la '
              'detección. Con n pequeño, no detectar es perfectamente '
              'posible.'),
    ],
    resolution:
        'P(ninguna contaminada) = C(34,8)/C(40,8) = {{p_nada}}.\n\n'
        'Es decir, casi uno de cada cuatro muestreos de este tamaño '
        'certificaría '
        'como limpio un terreno que no lo está. La recomendación profesional '
        'no es entregar el número y ya: es decir cuántas parcelas harían '
        'falta para bajar ese riesgo a un nivel aceptable, o proponer '
        'muestreo dirigido por el historial del sitio en lugar de aleatorio '
        'simple.',
    assumptions:
        'Se asume que la estimación de 6 parcelas contaminadas es correcta; '
        'si fueran menos, el riesgo de falso «limpio» sería aún mayor. '
        'También que la contaminación está confinada a parcelas completas y '
        'que el análisis de laboratorio no produce falsos negativos, lo que '
        'en la práctica habría que sumar al cálculo.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c05_administracion',
    career: 'Administración',
    title: 'Dos canales de venta y una promoción',
    scenario:
        'Una cadena analiza 1 000 clientes del último trimestre. 620 '
        'compraron en tienda física, 480 compraron en línea y 100 no '
        'compraron por ninguno de los dos canales (solo devoluciones o '
        'consultas). El área de marketing quiere saber cuántos clientes son '
        '«omnicanal» (compraron por los dos canales) para dimensionar una '
        'promoción cruzada.',
    data: [
      'Clientes analizados: 1 000',
      'Compraron en tienda física: 620',
      'Compraron en línea: 480',
      'No compraron por ningún canal: 100',
    ],
    question: '¿Cuántos clientes son omnicanal?',
    detects: ['suma_sin_restar_interseccion'],
    options: [
      Choice('200',
          correct: true,
          feedback: 'Correcto: si 900 compraron por al menos un canal, '
              '620 + 480 − 900 = 200 usaron los dos.'),
      Choice('1 100, sumando ambos canales',
          misconceptionId: 'probabilidad_mayor_que_uno',
          feedback: 'Más clientes que la base analizada: alarma inmediata. '
              'Ese exceso de 100 sobre 1 000 es justamente la señal de que '
              'hay solapamiento.'),
      Choice('140, restando 620 + 480 − 1 000',
          misconceptionId: 'suma_sin_restar_interseccion',
          feedback: 'Casi: usaste 1 000 como total de compradores, pero 100 '
              'clientes no compraron por ningún canal. La unión es 900, no '
              '1 000.'),
      Choice('No se puede saber sin más datos',
          feedback: 'Sí se puede: la regla de la suma permite despejar la '
              'intersección cuando se conocen la unión y las dos partes.'),
    ],
    justifications: [
      Choice('Porque P(A∪B) = P(A) + P(B) − P(A∩B), y la unión son los 900 '
          'que compraron por algún canal',
          correct: true,
          feedback: 'Exacto: el dato de los 100 que no compraron es el que '
              'fija la unión.'),
      Choice('Porque el total analizado es 1 000 y esa es la unión',
          misconceptionId: 'suma_sin_restar_interseccion',
          feedback: 'La unión es «al menos un canal» = 900. Los 100 restantes '
              'están fuera de los dos conjuntos.'),
      Choice('Porque los canales son independientes y se multiplica: '
          '0,62 × 0,48 × 1 000 ≈ 298',
          misconceptionId: 'producto_sin_independencia',
          feedback: 'La independencia no está dada, y los datos muestran que '
              'no se cumple: el valor real (200) es bastante menor que 298, '
              'lo que indica que los canales se sustituyen entre sí.'),
    ],
    resolution:
        'Compradores por al menos un canal: 1 000 − 100 = 900.\n'
        '|Tienda ∪ Línea| = |Tienda| + |Línea| − |ambos|\n'
        '900 = 620 + 480 − |ambos| → |ambos| = 200.\n\n'
        'Dato adicional que vale más que la respuesta: si los canales fueran '
        'independientes se esperarían ~298 omnicanal. Los 200 observados '
        'indican que los clientes tienden a usar un canal **en lugar** del '
        'otro. Una promoción cruzada tiene sentido precisamente por eso, '
        'pero su público objetivo son los 700 monocanal, no los 200 que ya '
        'son omnicanal.',
    assumptions:
        'Se asume que los 1 000 clientes analizados son representativos del '
        'trimestre y que el registro identifica correctamente al mismo '
        'cliente en los dos canales. Si la identificación falla (compras sin '
        'cuenta en tienda física), los 200 omnicanal están subestimados y '
        'toda la conclusión se debilita.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c06_economia',
    career: 'Economía',
    title: 'Señal de recesión y tasa base',
    scenario:
        'Un indicador adelantado ha anticipado correctamente 8 de las '
        'últimas 10 recesiones. También se ha activado en 12 de los 90 '
        'periodos sin recesión posterior. En el periodo estudiado, las '
        'recesiones ocurrieron en 10 de cada 100 trimestres. Hoy el '
        'indicador se activó y un directivo pide recortar la inversión de '
        'inmediato.',
    data: [
      'Trimestres con recesión posterior: 10 de 100',
      'El indicador se activó en 8 de esos 10',
      'El indicador se activó en 12 de los 90 restantes',
    ],
    question: '¿Qué probabilidad de recesión indica realmente la señal?',
    detects: ['tasa_base_ignorada', 'condicional_invertida'],
    options: [
      Choice('40 %: la señal sube el riesgo del 10 % al 40 %, pero no lo hace '
          'probable',
          correct: true,
          feedback: 'Correcto: 8 / (8 + 12) = 0,40. Es información valiosa —'
              'cuadruplica el riesgo— pero la mayoría de las señales no '
              'termina en recesión.'),
      Choice('80 %, porque acierta 8 de cada 10 recesiones',
          misconceptionId: 'condicional_invertida',
          feedback: 'El 80 % es P(señal | recesión). Lo que necesitas para '
              'decidir es P(recesión | señal), que es la inversa.'),
      Choice('10 %, la tasa base: la señal no aporta nada',
          misconceptionId: 'evidencia_confirma_causa',
          feedback: 'Sí aporta: cuadruplica la probabilidad. Ignorar la señal '
              'es el error contrario al de creerla al pie de la letra.'),
      Choice('67 %, porque 8 de 12 falsos positivos es mayoría',
          feedback: 'La cuenta correcta compara los 8 verdaderos con el total '
              'de activaciones (8 + 12 = 20), no con los falsos.'),
    ],
    justifications: [
      Choice('Porque hay que comparar las señales verdaderas con TODAS las '
          'señales: 8 de 20',
          correct: true,
          feedback: 'Exacto, y así es como se comunica a un directivo: '
              '«de cada 20 veces que esto se enciende, 8 terminan en '
              'recesión».'),
      Choice('Porque el indicador tiene 80 % de precisión histórica',
          misconceptionId: 'condicional_invertida',
          feedback: '«Precisión» es una palabra ambigua que aquí encubre una '
              'condicional invertida. Hay que decir cuál de las dos es.'),
      Choice('Porque los indicadores adelantados nunca son fiables',
          misconceptionId: 'evidencia_confirma_causa',
          feedback: 'Este lo es bastante: multiplica el riesgo por cuatro. El '
              'problema es la tasa base, no el indicador.'),
    ],
    resolution:
        'De 100 trimestres: 10 con recesión (8 con señal) y 90 sin recesión '
        '(12 con señal). Total de señales: 20.\n\n'
        'P(recesión | señal) = 8/20 = 40 %.\n\n'
        'La recomendación profesional no es «recortar» ni «ignorar»: es '
        'declarar que el riesgo pasó del 10 % al 40 % y dimensionar la '
        'respuesta a esa magnitud — por ejemplo, medidas reversibles y de '
        'bajo costo, no un recorte estructural que costaría caro en el 60 % '
        'de los casos en que no hay recesión.',
    assumptions:
        'La muestra es de 10 recesiones: poquísimo. Con esos datos, la '
        'incertidumbre sobre el 40 % es enorme y debería declararse. Además '
        'se asume que la tasa base histórica del 10 % sigue vigente y que la '
        'relación entre indicador y economía no ha cambiado estructuralmente, '
        'algo que en economía rara vez se sostiene por décadas.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c07_contabilidad',
    career: 'Contabilidad',
    title: 'Muestreo de auditoría sobre facturas',
    scenario:
        'Auditas una cartera de 500 facturas. La dirección afirma que el '
        'nivel de error es a lo sumo del 2 % (10 facturas con error). Tu '
        'plan de muestreo prevé revisar 25 facturas al azar. Si no aparece '
        'ninguna con error, se emitiría una opinión sin salvedades.',
    data: [
      'Facturas en la cartera: 500',
      'Facturas con error según la dirección: 10 (2 %)',
      'Tamaño de la muestra: 25, sin reposición',
    ],
    question: '¿Qué riesgo asumes al concluir «sin errores» tras revisar 25 '
        'facturas?',
    detects: ['reposicion_ignorada', 'muestra_pequena_representa'],
    figures: [
      ContentFigure(
        id: 'p_cero',
        fn: 'hypergeometric',
        args: [500, 10, 25, 0],
        label: 'P(0 errores en muestra de 25 con 10 de 500 erróneas)',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('Alto: incluso siendo cierto el 2 %, hay ~60 % de probabilidad '
          'de no ver ningún error',
          correct: true,
          feedback: 'Correcto. La muestra de 25 es demasiado pequeña para '
              'detectar una tasa del 2 %: no ver errores no es evidencia de '
              'que no los haya.'),
      Choice('Bajo: 25 de 500 es el 5 % de la cartera, suficiente',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'El porcentaje de la población no es lo que importa. Lo '
              'que importa es cuántos errores se esperan en la muestra: '
              '25 × 0,02 = 0,5, es decir, medio error.'),
      Choice('Nulo: si no hay errores en la muestra, no hay errores',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'Ausencia de evidencia no es evidencia de ausencia, y '
              'aquí se puede cuantificar exactamente cuánta información '
              'aporta la muestra.'),
      Choice('2 %, el nivel de error declarado',
          misconceptionId: 'condicional_invertida',
          feedback: 'El 2 % es la tasa de error supuesta, no el riesgo de '
              'que tu muestreo la pase por alto.'),
    ],
    justifications: [
      Choice('Porque P(0 errores en 25 | tasa real 2 %) ≈ 60 %: el '
          'procedimiento tiene poca potencia para detectar esa tasa',
          correct: true,
          feedback: 'Exacto, y de ahí sale la recomendación: ampliar la '
              'muestra o usar muestreo estratificado por monto.'),
      Choice('Porque las 25 facturas se eligieron sin reposición y eso '
          'invalida el muestreo',
          misconceptionId: 'reposicion_ignorada',
          feedback: 'El muestreo sin reposición es lo correcto en auditoría; '
              'solo cambia la fórmula (hipergeométrica), no la validez.'),
      Choice('Porque siempre hay errores en cualquier cartera',
          feedback: 'Puede ser cierto, pero no es un argumento cuantitativo '
              'ni defendible en un papel de trabajo.'),
    ],
    resolution:
        'P(0 errores en la muestra | 10 erróneas de 500) = '
        'C(490,25)/C(500,25) = {{p_cero}}.\n\n'
        'Es decir, aun siendo cierta la tasa del 2 %, tu procedimiento no '
        'detectaría ningún error el 60 % de las veces. La conclusión «sin '
        'errores» sería falsa en la mayoría de los escenarios donde la tasa '
        'es la declarada.\n\n'
        'Acción profesional: calcular el tamaño de muestra que da una '
        'potencia aceptable (para detectar una tasa del 2 % con 95 % de '
        'confianza harían falta unas 140 facturas), o aplicar muestreo por '
        'unidades monetarias, que concentra la revisión donde está el riesgo.',
    assumptions:
        'Se asume que la muestra es genuinamente aleatoria y que el auditor '
        'detecta el error cuando lo revisa. Si la selección la propone el '
        'auditado, el muestreo aleatorio deja de existir y ninguna fórmula '
        'aplica.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c08_psicologia',
    career: 'Psicología',
    title: 'Tamizaje de riesgo en una población escolar',
    scenario:
        'Un colegio de 2 000 estudiantes aplica un cuestionario breve de '
        'tamizaje para detectar estudiantes en riesgo de bajo rendimiento '
        'severo. El instrumento tiene 85 % de sensibilidad y 80 % de '
        'especificidad. La prevalencia estimada del riesgo en esta población '
        'es del 5 %. La dirección propone citar a los padres de todos los '
        'estudiantes que den positivo.',
    data: [
      'Estudiantes: 2 000',
      'Prevalencia estimada: 5 %',
      'Sensibilidad: 85 %',
      'Especificidad: 80 %',
    ],
    question: '¿Qué proporción de los citados estaría realmente en riesgo?',
    detects: ['tasa_base_ignorada'],
    figures: [
      ContentFigure(
        id: 'vpp',
        fn: 'ppv',
        args: [5, 100, 85, 100, 80, 100],
        label: 'VPP del tamizaje escolar',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('Alrededor del 18 %: la mayoría de los citados serían falsos '
          'positivos',
          correct: true,
          feedback: 'Correcto: 85 verdaderos positivos frente a 380 falsos. '
              'Citar a todos genera 380 alarmas familiares innecesarias.'),
      Choice('85 %, la sensibilidad del instrumento',
          misconceptionId: 'tasa_base_ignorada',
          feedback: 'La sensibilidad es P(positivo | en riesgo). La pregunta '
              'es la inversa, y con una prevalencia del 5 % la respuesta es '
              'muy distinta.'),
      Choice('80 %, la especificidad',
          misconceptionId: 'condicional_invertida',
          feedback: 'La especificidad es P(negativo | sin riesgo): otra '
              'condicional, tampoco la pedida.'),
      Choice('5 %, la prevalencia',
          feedback: 'Esa es la probabilidad antes del cuestionario. El '
              'resultado positivo la sube de 5 % a ~18 %: aporta '
              'información, aunque no sea concluyente.'),
    ],
    justifications: [
      Choice('Porque con prevalencia baja los falsos positivos, aunque sean '
          'solo el 20 % de los sanos, superan ampliamente a los verdaderos',
          correct: true,
          feedback: 'Exacto: 20 % de 1 900 es mucho más que 85 % de 100.'),
      Choice('Porque el instrumento tiene poca sensibilidad',
          misconceptionId: 'condicional_invertida',
          feedback: 'El 85 % de sensibilidad es razonable. El problema es la '
              'especificidad combinada con la baja prevalencia.'),
      Choice('Porque los cuestionarios breves no sirven para nada',
          misconceptionId: 'evidencia_confirma_causa',
          feedback: 'Sirven como primer filtro: multiplican por 3,6 la '
              'probabilidad. Lo que no deben hacer es sustituir a la '
              'evaluación.'),
    ],
    resolution:
        'De 2 000 estudiantes: 100 en riesgo (85 positivos) y 1 900 sin '
        'riesgo (380 positivos por error). Total de positivos: 465.\n\n'
        'VPP = 85/465 = {{vpp}}.\n\n'
        'El uso correcto de un tamizaje con estas cifras es como PRIMER '
        'filtro: reduce 2 000 estudiantes a 465 que merecen una evaluación '
        'individual más profunda. Lo que no puede hacerse es tratar el '
        'positivo como un diagnóstico ni comunicarlo a las familias como '
        'tal. Además hay 15 estudiantes en riesgo que dieron negativo, y el '
        'protocolo debe contemplarlos.',
    assumptions:
        'La prevalencia del 5 % es una estimación; si la población escolar '
        'tuviera mayor riesgo, el VPP subiría. Se asume también que '
        'sensibilidad y especificidad medidas en la validación del '
        'instrumento se mantienen en esta población, lo que no siempre '
        'ocurre al cambiar de contexto cultural o de edad.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c09_biologia',
    career: 'Biología',
    title: 'Cruce de plantas y proporción mendeliana',
    scenario:
        'Cruzas dos plantas heterocigotas (Aa × Aa) para un rasgo con '
        'herencia mendeliana simple, donde A es dominante. La teoría predice '
        '25 % de descendencia con fenotipo recesivo. En tu invernadero '
        'obtienes 80 plantas y solo 14 muestran el fenotipo recesivo '
        '(17,5 %). Un compañero sugiere que el modelo mendeliano no aplica a '
        'esta especie.',
    data: [
      'Cruce: Aa × Aa',
      'Proporción teórica del fenotipo recesivo: 1/4',
      'Descendencia observada: 80 plantas, 14 recesivas (17,5 %)',
    ],
    question: '¿Los datos contradicen el modelo mendeliano?',
    detects: ['muestra_pequena_representa', 'espacio_incompleto'],
    options: [
      Choice('No: con n = 80 y p = 0,25 el error estándar es ~4,8 puntos, y '
          '17,5 % está a poco más de 1,5 de ellos',
          correct: true,
          feedback: 'Correcto. Es una desviación normal, no evidencia contra '
              'el modelo.'),
      Choice('Sí: 17,5 % está claramente por debajo del 25 %',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Con 80 plantas, el número esperado de recesivas es 20 y '
              'observar 14 es perfectamente compatible con el azar del '
              'muestreo. Habría que repetir con muchas más plantas.'),
      Choice('No, porque el cruce Aa × Aa da 1/3 de recesivos',
          misconceptionId: 'espacio_incompleto',
          feedback: 'El espacio muestral del cruce es {AA, Aa, aA, aa}: '
              'cuatro casos, no tres. El fenotipo recesivo es 1 de 4, no 1 '
              'de 3. Es el mismo error de las dos monedas.'),
      Choice('Sí, y en la próxima siembra habrá más recesivas para compensar',
          misconceptionId: 'ley_de_promedios',
          feedback: 'No hay compensación: la próxima siembra rondará el 25 % '
              'por su cuenta.'),
    ],
    justifications: [
      Choice('Porque la variación de muestreo con n = 80 permite fácilmente '
          'una desviación de 6 plantas respecto de las 20 esperadas',
          correct: true,
          feedback: 'Exacto, y así se reporta: con la incertidumbre '
              'declarada.'),
      Choice('Porque el modelo mendeliano es una ley y no admite excepción',
          misconceptionId: 'formula_por_parecido',
          feedback: 'Los modelos sí se pueden refutar con datos. Lo que pasa '
              'aquí es que estos datos no alcanzan para refutarlo.'),
      Choice('Porque 14 y 20 son números parecidos',
          feedback: 'La intuición apunta bien, pero «parecidos» no es un '
              'argumento: hay que comparar la diferencia con el error '
              'estándar.'),
    ],
    resolution:
        'El espacio muestral del cruce Aa × Aa es {AA, Aa, aA, aa}: el '
        'fenotipo recesivo requiere aa, es decir 1/4.\n\n'
        'Con n = 80 y p = 0,25, se esperan 20 recesivas, con error estándar '
        '√(80 × 0,25 × 0,75) ≈ 3,87 plantas. Observar 14 está a 1,55 errores '
        'estándar: dentro de lo normal.\n\n'
        'Para distinguir un 17,5 % real de un 25 % real harían falta '
        'centenares de plantas. La conclusión correcta es «los datos son '
        'compatibles con el modelo», no «el modelo es correcto» ni «el '
        'modelo falló».',
    assumptions:
        'Se asume que las 80 plantas son toda la descendencia obtenida y no '
        'una selección (si se descartaron plántulas débiles, y el genotipo '
        'recesivo afecta al vigor, hay sesgo de supervivencia). También que '
        'el rasgo tiene herencia mendeliana simple sin penetrancia '
        'incompleta.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c10_humanidades',
    career: 'Humanidades',
    title: 'La encuesta que no se puede proyectar',
    scenario:
        'Para un trabajo sobre hábitos de lectura, publicas un formulario en '
        'tus redes y en los grupos de tu facultad. Responden 640 personas: '
        'el 71 % declara leer al menos un libro al mes. Quieres escribir: '
        '«el 71 % de los jóvenes universitarios lee al menos un libro al mes '
        '(margen de error ±3,5 %)».',
    data: [
      'Respuestas obtenidas: 640',
      'Declaran leer ≥ 1 libro/mes: 71 %',
      'Difusión: redes propias y grupos de la facultad',
      'Tasa de respuesta: desconocida',
    ],
    question: '¿Qué puedes afirmar con estos datos?',
    detects: ['inferir_sin_experimento', 'muestra_pequena_representa'],
    options: [
      Choice('Solo que el 71 % de QUIENES RESPONDIERON lo declara: no hay '
          'muestreo aleatorio y el margen de error no aplica',
          correct: true,
          feedback: 'Correcto. El dato es real y describible; lo que no se '
              'puede es proyectarlo a una población.'),
      Choice('Que el 71 % de los universitarios lee, con ±3,5 %',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'El margen de error cuantifica el ruido de un muestreo '
              'aleatorio. Aquí no hubo muestreo: los que respondieron se '
              'eligieron a sí mismos, y quien lee suele estar más dispuesto a '
              'responder una encuesta sobre lectura.'),
      Choice('Que el 71 % de los universitarios lee, pero con un margen '
          'mayor por ser una sola facultad',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Ampliar el margen no corrige un sesgo de selección: lo '
              'disfraza. El problema no es la precisión, es la dirección del '
              'error, que es desconocida.'),
      Choice('Nada en absoluto: los datos no sirven',
          feedback: 'Sí sirven como descripción de quienes respondieron, y '
              'como estudio exploratorio para diseñar después un muestreo '
              'real. Lo que no permiten es la proyección.'),
    ],
    justifications: [
      Choice('Porque sin mecanismo aleatorio de selección no hay espacio '
          'muestral y ningún margen de error corrige el sesgo',
          correct: true,
          feedback: 'Exacto: esta es la frase que debería ir en la sección de '
              'limitaciones del trabajo.'),
      Choice('Porque 640 respuestas son pocas para una población grande',
          misconceptionId: 'muestra_pequena_representa',
          feedback: '640 respuestas ALEATORIAS serían muchísimas. El número '
              'no es el problema.'),
      Choice('Porque las encuestas en línea siempre exageran los resultados',
          feedback: 'No siempre, y no sabemos en qué dirección sesga esta. La '
              'ignorancia sobre la dirección del sesgo es precisamente el '
              'problema.'),
    ],
    resolution:
        'Con 640 respuestas autoseleccionadas, el ±3,5 % es aritméticamente '
        'calculable y conceptualmente vacío: mide el ruido de un muestreo '
        'aleatorio que aquí no existe.\n\n'
        'Lo que se puede escribir con rigor: «entre las 640 personas que '
        'respondieron el formulario, el 71 % declara leer al menos un libro '
        'al mes. La muestra es autoseleccionada y no permite estimar la '
        'proporción en la población universitaria».\n\n'
        'Hay además un segundo problema, independiente del muestreo: es una '
        'conducta **declarada**, y la lectura es un hábito socialmente '
        'valorado. La deseabilidad social empuja el número hacia arriba '
        'aunque el muestreo fuera perfecto.',
    assumptions:
        'Ninguna asumible permite la proyección. Para poder hacerla harían '
        'falta un marco muestral de la población universitaria y una '
        'selección aleatoria dentro de él, además de registrar la tasa de '
        'respuesta y analizar quién no respondió.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c11_desarrollo',
    career: 'Desarrollo personal',
    title: 'La racha del método de estudio',
    scenario:
        'Adoptaste un método de estudio nuevo hace tres semanas. En ese '
        'tiempo sacaste 17, 18 y 16 en tres evaluaciones, cuando tu promedio '
        'histórico era 14. Concluyes que el método funciona y decides '
        'recomendarlo a tus compañeros como algo probado.',
    data: [
      'Notas previas: promedio 14, con notas entre 10 y 18',
      'Notas con el método nuevo: 17, 18, 16',
      'Evaluaciones desde el cambio: 3',
      'Otros cambios en el periodo: no registrados',
    ],
    question: '¿Qué puedes concluir?',
    detects: ['muestra_pequena_representa', 'inferir_sin_experimento'],
    options: [
      Choice('Que es un indicio alentador, pero con 3 evaluaciones y sin '
          'control no se puede atribuir la mejora al método',
          correct: true,
          feedback: 'Correcto. Tres datos, sin grupo de comparación y con '
              'otros cambios posibles: es una hipótesis, no una conclusión.'),
      Choice('Que el método funciona: tres subidas seguidas no son '
          'casualidad',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'Con notas que históricamente oscilan entre 10 y 18, tres '
              'valores altos seguidos son perfectamente posibles por azar. Y '
              'además hay regresión a la media y efecto de novedad en juego.'),
      Choice('Que el método funciona solo para ti, pero no se puede '
          'generalizar',
          feedback: 'Ni siquiera para ti está establecido: falta separar el '
              'efecto del método del de otros cambios simultáneos.'),
      Choice('Que no sirve de nada: tres datos no son datos',
          feedback: 'Tres datos son poca evidencia, no evidencia nula. '
              'Sirven para justificar seguir probando y para diseñar un '
              'registro mejor.'),
    ],
    justifications: [
      Choice('Porque no hay experimento controlado: sin comparación y con '
          'n = 3, la variación normal y otros factores explican igual de '
          'bien el resultado',
          correct: true,
          feedback: 'Exacto. Lo útil ahora es registrar sistemáticamente y '
              'seguir midiendo.'),
      Choice('Porque tres es siempre un número insuficiente de datos',
          misconceptionId: 'muestra_pequena_representa',
          feedback: 'No hay un número mágico: depende de la variabilidad. '
              'Con notas muy estables, tres podrían decir bastante.'),
      Choice('Porque las notas no son un experimento aleatorio y nunca se '
          'pueden analizar',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'Sí se pueden analizar; lo que no se puede es atribuir '
              'causalidad sin diseño. Un registro largo y sistemático daría '
              'información real.'),
    ],
    resolution:
        'Hay al menos cuatro explicaciones alternativas, todas compatibles '
        'con los datos:\n\n'
        '1. **Variación normal**: si tus notas oscilan entre 10 y 18, tres '
        'altas seguidas ocurren con cierta frecuencia por azar.\n'
        '2. **Regresión a la media**: si cambiaste de método justo después de '
        'un mal periodo, la subida ocurriría igual sin cambiar nada.\n'
        '3. **Efecto de novedad y atención**: estudiar de forma nueva casi '
        'siempre implica estudiar más, al menos al principio.\n'
        '4. **Otros cambios simultáneos**: cursos más fáciles, mejor sueño, '
        'menos carga laboral.\n\n'
        'Conclusión honesta: «tres resultados por encima de mi promedio '
        'después del cambio». Para saber más: seguir registrando muchas '
        'evaluaciones, anotar las horas dedicadas y la dificultad percibida, '
        'y no recomendar como probado lo que todavía es una corazonada '
        'razonable.',
    assumptions:
        'Para atribuir causalidad haría falta un diseño que este caso no '
        'tiene: comparación con un periodo equivalente, control de las horas '
        'de estudio y de la dificultad de las evaluaciones. Nada de eso '
        'impide seguir usando el método —cuesta poco y puede ayudar— pero sí '
        'impide presentarlo como demostrado.',
  ),

  // ------------------------------------------------------------------
  CaseStudy(
    id: 'c12_transversal',
    career: 'Transversal',
    title: 'Un premio en la promoción del supermercado',
    scenario:
        'Una cadena lanza una promoción: cada compra superior a cierto monto '
        'entrega un cupón con probabilidad 1/50 de ser premiado. Un cliente '
        'compra 30 veces durante la campaña y no gana nada. Escribe una queja '
        'diciendo que la promoción es un fraude, porque «con 30 cupones y 1 '
        'de cada 50, debería haber ganado al menos una vez».',
    data: [
      'Probabilidad de premio por cupón: 1/50 = 0,02',
      'Cupones del cliente: 30, independientes',
    ],
    question: '¿Tiene razón el cliente?',
    detects: ['al_menos_uno_suma', 'falacia_jugador'],
    figures: [
      ContentFigure(
        id: 'p_gana',
        fn: 'atLeastOne',
        args: [1, 50, 30],
        label: 'P(al menos un premio en 30 cupones)',
        format: FigureFormat.percent,
      ),
      ContentFigure(
        id: 'p_nada30',
        fn: 'noneIn',
        args: [1, 50, 30],
        label: 'P(ningún premio en 30 cupones)',
        format: FigureFormat.percent,
      ),
    ],
    options: [
      Choice('No: la probabilidad de no ganar nada en 30 cupones es del 55 %, '
          'lo más probable era justamente no ganar',
          correct: true,
          feedback: 'Correcto: 0,98³⁰ ≈ 0,545. No ganar era el resultado más '
              'probable.'),
      Choice('Sí: 30 × (1/50) = 0,6, así que debería haber ganado',
          misconceptionId: 'al_menos_uno_suma',
          feedback: '0,6 sería la probabilidad de ganar al menos una vez si '
              'se pudiera sumar, pero no se puede: con 60 cupones daría 1,2, '
              'que es imposible. El cálculo correcto es 1 − 0,98³⁰ ≈ 45,5 %.'),
      Choice('Sí, porque 1 de cada 50 significa que 1 de cada 50 cupones es '
          'premiado con seguridad',
          misconceptionId: 'falacia_jugador',
          feedback: 'Una probabilidad de 1/50 no garantiza un premio cada 50 '
              'cupones: los cupones no llevan la cuenta.'),
      Choice('No se puede saber sin conocer cuántos cupones emitió la cadena',
          feedback: 'Si cada cupón tiene probabilidad independiente 1/50, el '
              'total emitido no cambia el cálculo para este cliente.'),
    ],
    justifications: [
      Choice('Porque P(al menos uno) = 1 − 0,98³⁰ ≈ 45,5 %, así que no ganar '
          'era más probable que ganar',
          correct: true,
          feedback: 'Exacto, y esa es la forma de responder la queja con un '
              'número verificable.'),
      Choice('Porque las promociones nunca dan premios reales',
          misconceptionId: 'inferir_sin_experimento',
          feedback: 'No hay ninguna evidencia de eso en el caso, y la queja '
              'se responde con el cálculo, no con una sospecha.'),
      Choice('Porque tendría que haber comprado 50 veces para ganar',
          misconceptionId: 'falacia_jugador',
          feedback: 'Con 50 cupones la probabilidad de ganar al menos uno es '
              '~63,6 %, no 100 %.'),
    ],
    resolution:
        'P(ningún premio en 30 cupones) = 0,98³⁰ = {{p_nada30}}.\n'
        'P(al menos un premio) = {{p_gana}}.\n\n'
        'No ganar nada era el resultado más probable. El error del cliente es '
        'el clásico de «al menos uno»: multiplicar 30 × 1/50 en lugar de usar '
        'el complemento.\n\n'
        'Dicho esto, hay una parte legítima en la queja: una promoción que '
        'anuncia «1 de cada 50» y no dice qué significa para un cliente '
        'típico está comunicando mal. La respuesta profesional del área de '
        'marketing sería publicar el dato en la forma que la gente entiende: '
        '«la mayoría de los clientes con 30 cupones no ganará».',
    assumptions:
        'Se asume que cada cupón tiene probabilidad 1/50 de forma '
        'independiente y constante. Si la promoción funcionara con un número '
        'fijo de premios repartidos en un número fijo de cupones (sin '
        'reposición), el modelo correcto sería hipergeométrico, y con premios '
        'ya agotados la probabilidad real para un cliente tardío podría ser '
        'cero. Esa diferencia no es menor: es lo que distingue una promoción '
        'honesta de una engañosa, y debería estar en las bases.',
  ),
];

final Map<String, CaseStudy> kCasesById = {for (final c in kCases) c.id: c};
