/// Módulo 4 — Problemas.
library;

import '../../domain/models/lesson.dart';

const List<Lesson> kLessonsM4 = [
  Lesson(
    id: 'm4_l1',
    moduleId: 'm4',
    title: 'El método de las cuatro preguntas',
    objective:
        'Clasificar un problema antes de buscar una fórmula, y saber por qué '
        'esa es la parte difícil.',
    cards: [
      LessonCard(
        title: 'El problema real no es calcular',
        body: 'En el examen del curso los ejercicios vienen agrupados por '
            'tema, así que el tema ya está resuelto antes de empezar. Fuera '
            'del curso, no.\n\n'
            'Cuando un enunciado llega sin etiqueta, el estudiante entrenado '
            'para calcular busca una fórmula que se «parezca» a algo visto. '
            'Esa estrategia funciona en la práctica del tema y fracasa en '
            'todo lo demás.',
        kind: CardKind.alerta,
        targetsMisconception: 'formula_por_parecido',
      ),
      LessonCard(
        title: 'Las cuatro preguntas',
        body: '**1. ¿Qué me piden exactamente?** Una probabilidad, un conteo, '
            'una condicional o una causa.\n\n'
            '**2. ¿Cuál es el experimento y cuál es Ω?** Si cabe, escríbelo.\n\n'
            '**3. ¿Importa el orden? ¿Hay reposición?** Estas dos deciden '
            'todo el conteo.\n\n'
            '**4. ¿Los eventos se solapan? ¿Se influyen?** Estas dos deciden '
            'si sumas, restas o multiplicas.\n\n'
            'Responder las cuatro lleva menos de un minuto y elimina casi '
            'todos los errores de método.',
        kind: CardKind.formula,
      ),
      LessonCard(
        title: 'Palabras que delatan',
        body: '| En el enunciado | Casi siempre significa |\n'
            '|---|---|\n'
            '| «al menos» | complemento |\n'
            '| «sabiendo que», «dado que», «de los que» | condicional |\n'
            '| «sin reposición», «de los restantes» | dependencia |\n'
            '| «de cuántas maneras» | conteo puro, sin dividir |\n'
            '| «cuál es la probabilidad de que sea… si resultó…» | Bayes |\n'
            '| «y», «ambos», «a la vez» | intersección |\n\n'
            'Ninguna es infalible, pero todas son buenas pistas de primera '
            'lectura.',
        kind: CardKind.conexion,
      ),
      LessonCard(
        title: 'El tutor de la app es este árbol',
        body: 'La pantalla del tutor recorre exactamente estas preguntas y '
            'termina proponiendo un método **con su condición de uso**.\n\n'
            'Úsala al principio para los problemas que no sabes por dónde '
            'coger. La meta es dejar de necesitarla: cuando el árbol lo '
            'recorres de cabeza en diez segundos, el módulo 4 está aprobado.',
        kind: CardKind.conexion,
      ),
    ],
  ),
  Lesson(
    id: 'm4_l2',
    moduleId: 'm4',
    title: 'Traducir el enunciado',
    objective: 'Convertir un texto profesional en eventos y datos.',
    cards: [
      LessonCard(
        title: 'Define los eventos por escrito',
        body: 'Antes de cualquier número: escribe «Sea A = …», «Sea B = …», '
            'con frases completas.\n\n'
            'Parece burocrático y es donde se gana el problema. La mitad de '
            'los errores de condicional se deben a que A y B nunca llegaron a '
            'definirse con precisión, y a mitad de cálculo cambiaron de '
            'significado.',
      ),
      LessonCard(
        title: 'Ordena los datos en una tabla',
        body: 'Casi todos los problemas de dos eventos caben en una tabla de '
            '2×2 o en un árbol de dos niveles. Dibuja uno de los dos **antes** '
            'de decidir la fórmula.\n\n'
            'Con la tabla, muchas condicionales se resuelven dividiendo dos '
            'números, sin usar ninguna fórmula. Con el árbol, la regla del '
            'producto y la probabilidad total se leen recorriendo ramas.',
      ),
      LessonCard(
        title: 'Cuidado con los porcentajes ambiguos',
        body: '«El 30 % de los productos defectuosos vienen de la línea A» no '
            'es lo mismo que «el 30 % de los productos de la línea A son '
            'defectuosos».\n\n'
            'La primera frase es P(A | defectuoso); la segunda, '
            'P(defectuoso | A). Son números distintos y llevan a decisiones '
            'opuestas.\n\n'
            'Cuando un enunciado (o un informe real) no deja claro cuál es, '
            'la respuesta profesional no es adivinar: es preguntar.',
        kind: CardKind.alerta,
        targetsMisconception: 'condicional_invertida',
      ),
    ],
  ),
  Lesson(
    id: 'm4_l3',
    moduleId: 'm4',
    title: 'Verificar el resultado',
    objective:
        'Detectar un resultado imposible o implausible antes de entregarlo.',
    cards: [
      LessonCard(
        title: 'Cuatro controles de 10 segundos',
        body: '**1. ¿Está entre 0 y 1?** Si no, error de método.\n\n'
            '**2. ¿Tiene el tamaño esperado?** Si el evento era raro y salió '
            '0,8, revisa el complemento.\n\n'
            '**3. ¿Suma 1 con su complemento?** Calcula el contrario por otro '
            'camino y comprueba.\n\n'
            '**4. ¿Qué pasa en los casos extremos?** Pon n = 1 o p = 0 en tu '
            'fórmula y mira si da lo obvio.',
        kind: CardKind.formula,
        targetsMisconception: 'probabilidad_mayor_que_uno',
      ),
      LessonCard(
        title: 'La simulación mental',
        body: 'Imagina 1 000 casos y cuenta con números enteros. Si el '
            'resultado que obtuviste implica «0,3 personas», algo no cuadra.\n\n'
            'Este truco —frecuencias naturales en vez de porcentajes— es el '
            'mismo que hace obvio el problema del test médico, y funciona en '
            'casi cualquier problema de Bayes.',
      ),
      LessonCard(
        title: 'Declara tus supuestos',
        body: 'Un resultado sin supuestos declarados no es una respuesta '
            'profesional. Escribe siempre qué asumiste:\n\n'
            '• ¿equiprobabilidad?\n'
            '• ¿independencia?\n'
            '• ¿muestreo con o sin reposición?\n'
            '• ¿la población es estable?\n\n'
            'La app evalúa esto explícitamente: en los casos, la elección '
            'vale 0,6 y la justificación 0,4, precisamente porque acertar el '
            'número por la razón equivocada no sirve para nada en el trabajo.',
        kind: CardKind.alerta,
      ),
    ],
  ),
  Lesson(
    id: 'm4_l4',
    moduleId: 'm4',
    title: 'Cuándo NO calcular',
    objective:
        'Reconocer las situaciones donde una probabilidad calculada es '
        'engañosa.',
    cards: [
      LessonCard(
        title: 'Sin experimento aleatorio no hay probabilidad',
        body: 'Si los datos no vienen de un mecanismo aleatorio conocido, el '
            'número que salga puede ser aritméticamente correcto y '
            'completamente falso como afirmación sobre el mundo.\n\n'
            'Encuestas de voluntarios, datos de quienes respondieron, '
            'registros de los casos que llegaron a la consulta: todos tienen '
            'un filtro de selección que ninguna fórmula corrige.',
        kind: CardKind.alerta,
        targetsMisconception: 'inferir_sin_experimento',
      ),
      LessonCard(
        title: 'Cuatro señales de alarma',
        body: '**1. Sesgo de selección** — la muestra se eligió a sí misma.\n\n'
            '**2. Supervivencia** — solo ves los casos que llegaron hasta el '
            'final (los aviones que volvieron, las empresas que siguen '
            'abiertas).\n\n'
            '**3. Dependencia oculta** — tratas como independientes eventos '
            'con una causa común (dos componentes alimentados por la misma '
            'fuente no fallan de forma independiente).\n\n'
            '**4. Evento único** — «probabilidad de que este proyecto '
            'fracase» no es frecuentista; si la das, dila como lo que es.',
      ),
      LessonCard(
        title: 'La respuesta correcta puede ser «no se puede»',
        body: 'Dos de los doce casos de este módulo terminan en «con estos '
            'datos no corresponde calcular». No son casos defectuosos: son el '
            'punto.\n\n'
            'En el trabajo, entregar un número que parece riguroso sobre '
            'datos que no lo sostienen hace más daño que no entregar nada. '
            'Saber cuándo parar es parte de la competencia, y aquí se evalúa '
            'como tal.',
        kind: CardKind.alerta,
      ),
    ],
  ),
];
