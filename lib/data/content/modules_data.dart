/// Los cuatro módulos.
library;

import '../../domain/models/module.dart';

const List<AppModule> kModules = [
  AppModule(
    id: 'm1',
    order: 1,
    name: 'Fundamentos',
    question: '¿De qué estamos hablando cuando decimos «probable»?',
    description:
        'Experimento aleatorio, espacio muestral, eventos y las tres formas '
        'de asignar probabilidad. Aquí el espacio muestral se construye a '
        'mano antes de que aparezca cualquier fórmula: es lo que sostiene '
        'todo lo demás.',
    iconKey: 'dice',
    colorIndex: 0,
  ),
  AppModule(
    id: 'm2',
    order: 2,
    name: 'Eventos',
    question: '¿Cómo se combinan dos sucesos sin equivocarse?',
    description:
        'Operaciones con eventos, regla de la suma, complemento, '
        'independencia, probabilidad condicional y Bayes. Es el módulo donde '
        'se pierde más gente del curso, y donde esta app pone más '
        'experimentos.',
    iconKey: 'venn',
    colorIndex: 1,
  ),
  AppModule(
    id: 'm3',
    order: 3,
    name: 'Conteo',
    question: '¿Cuántos casos hay, y los estoy contando dos veces?',
    description:
        'Principio multiplicativo, variaciones, combinaciones y '
        'permutaciones con repetición. No como catálogo de fórmulas, sino '
        'como respuesta a dos preguntas: ¿importa el orden? ¿hay reposición?',
    iconKey: 'grid',
    colorIndex: 2,
  ),
  AppModule(
    id: 'm4',
    order: 4,
    name: 'Problemas',
    question: '¿Qué clase de problema tengo delante?',
    description:
        'Doce casos profesionales y el método de las cuatro preguntas. Los '
        'enunciados no vienen etiquetados con el tema: clasificarlos es la '
        'competencia que se evalúa aquí.',
    iconKey: 'briefcase',
    colorIndex: 3,
  ),
];

final Map<String, AppModule> kModulesById = {
  for (final m in kModules) m.id: m,
};

const List<String> kModuleOrder = ['m1', 'm2', 'm3', 'm4'];
